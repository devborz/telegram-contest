//
//  Extensions.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 14.10.2022.
//

import UIKit
import RxSwift

extension CALayer {
    
    func renderImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, 0)
        render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
}

extension CGRect {
    
    func mult(_ value: CGFloat) -> CGRect {
        return .init(x: origin.x * value, y: origin.y * value,
                     width: width * value, height: height * value)
    }
}

extension UIView {

    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

extension UIImage {
    
    func config(size: CGFloat) -> UIImage {
        return self.withConfiguration(UIImage.SymbolConfiguration.init(pointSize: size))
    }
    
    func aspectFittedToWidth(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
    
        return renderer.image { [weak self] _ in
            self?.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension PublishSubject {
    
    func bind(_ block: @escaping (Element) -> Void) -> Disposable {
        return self.subscribe { el in
            block(el)
        } onError: { error in
            
        } onCompleted: {
            
        } onDisposed: {
            
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        return boundingBox.height
    }
    
    func size(font: UIFont, width: CGFloat) -> CGSize {
        let attrString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: self.count), nil, CGSize(width: width, height: .greatestFiniteMagnitude), nil)
        return size
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.width
    }
}
