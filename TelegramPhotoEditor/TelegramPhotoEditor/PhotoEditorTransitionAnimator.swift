//
//  PhotoEditorTransitionAnimator.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 16.10.2022.
//

import UIKit

protocol PhotoEditorTransitionDelegate: AnyObject {
    
    func frameForSelectedImageView() -> CGRect
    
    func selectedImageView() -> UIImageView
}

class PhotoEditorTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.3
    
    var presenting = true
    
    weak var delegate: PhotoEditorTransitionDelegate?
    
    let transitionImageView = UIImageView()
    
    let dimView = UIView()
    
    override init() {
        transitionImageView.backgroundColor = .systemBackground
        transitionImageView.contentMode = .scaleAspectFill
        transitionImageView.clipsToBounds = true
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        dimView.backgroundColor = .black
        let containerView = transitionContext.containerView
        
        let vc = transitionContext.viewController(forKey: presenting ? .to : .from)!
        
        guard let vc = vc as? PhotoEditorViewController else {
            return
        }

        let cellFrame = delegate?.frameForSelectedImageView() ?? .zero
        let cellImageView = delegate?.selectedImageView() ?? UIImageView()
        
        dimView.frame = vc.view.bounds
        if presenting {
            dimView.alpha = 0
            containerView.addSubview(dimView)
            containerView.addSubview(transitionImageView)
            containerView.addSubview(vc.view)
            
            vc.view.alpha = 0
            vc.scrollView.alpha = 0
            transitionImageView.frame = cellFrame

            var endFrame = cellFrame
            if let image = cellImageView.image {
                transitionImageView.image = image
                endFrame = calculateZoomInImageFrame(image: image, forView: vc.view)
            }
            transitionImageView.isHidden = cellImageView.image == nil
            
            UIView.animate(withDuration: duration, delay: 0.0,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 0) {
                self.transitionImageView.frame = endFrame
                self.dimView.alpha = 1
                vc.view.alpha = 1
            } completion: { [weak self] _ in
                self?.transitionImageView.isHidden = true
                vc.scrollView.alpha = 1
                transitionContext.completeTransition(true)
            }
        } else {
            dimView.alpha = 1
            vc.scrollView.alpha = 0
            transitionImageView.alpha = 1
            if let mediaViewFrame = vc.mediaView?.frame {
                transitionImageView.frame = vc.scrollView.convert(mediaViewFrame,
                                                                  to: vc.view)
                transitionImageView.isHidden = cellImageView.image == nil
            } else {
                transitionImageView.isHidden = true
            }
            
            UIView.animate(withDuration: duration, delay: 0.0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0) {
                self.transitionImageView.frame = cellFrame
                self.dimView.alpha = 0
                vc.view.alpha = 0
            } completion: { [weak self] _ in
                self?.transitionImageView.isHidden = true
                cellImageView.isHidden = false
                transitionContext.completeTransition(true)
            }
        }

    }
    
    func animationEnded(_ transitionCompleted: Bool) {
    }
}

func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
    let viewRatio = view.frame.size.width / view.frame.size.height
    let imageRatio = image.size.width / image.size.height
    let touchesSides = (imageRatio > viewRatio)

    if touchesSides {
        let height = view.frame.width / imageRatio
        let yPoint = view.frame.minY + (view.frame.height - height) / 2
        return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
    } else {
        let width = view.frame.height * imageRatio
        let xPoint = view.frame.minX + (view.frame.width - width) / 2
        return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
    }
}
