//
//  Slider.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit

protocol SliderDelegate: AnyObject {
    
    func sliderDidChange(_ slider: Slider, value: CGFloat)
    
    func sliderBeginEditing(_ slider: Slider)
    
    func sliderEndEditing(_ slider: Slider)
}

class Slider: UIView {

    weak var delegate: SliderDelegate?
    
    lazy var thumbView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    lazy var thumbViewContainer: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 10
        return view
    }()
    
    var minValue: CGFloat = 5
    
    var maxValue: CGFloat = 100
    
    var thumbBottomConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        thumbViewContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumbViewContainer)
        thumbViewContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        thumbViewContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        thumbBottomConstraint = thumbViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        thumbBottomConstraint.isActive = true
        thumbViewContainer.heightAnchor.constraint(equalTo:
                                                thumbViewContainer.widthAnchor, constant: -10).isActive = true
        
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        thumbViewContainer.addSubview(thumbView)
        thumbView.topAnchor.constraint(equalTo: thumbViewContainer.topAnchor).isActive = true
        thumbView.leftAnchor.constraint(equalTo: thumbViewContainer.leftAnchor,
                                        constant: 5).isActive = true
        thumbView.rightAnchor.constraint(equalTo: thumbViewContainer.rightAnchor,
                                         constant: -5).isActive = true
        thumbView.bottomAnchor.constraint(equalTo: thumbViewContainer.bottomAnchor).isActive = true
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePanGesture(_:)))
        thumbViewContainer.addGestureRecognizer(panGesture)
        setNeedsDisplay()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.init(white: 1, alpha: 0.5).cgColor)
        context.move(to: .init(x: 5, y: 15))
        context.addLine(to: .init(x: rect.width - 5, y: 15))
        context.addLine(to: .init(x: rect.width / 2, y: rect.height))
        context.addLine(to: .init(x: 5, y: 15))
        context.setFillColor(UIColor.init(white: 1, alpha: 0.5).cgColor)
        context.fillPath()
    }
    
    @objc
    func handleLongpress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            delegate?.sliderBeginEditing(self)
        case .changed:
            break
        case .ended:
            delegate?.sliderEndEditing(self)
        default:
            break
        }
    }
    
    @objc
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let yLocation = gesture.location(in: self).y
        let height = bounds.height
        let constant: CGFloat = max(min(-height + yLocation, 0), -height + 30)
        switch gesture.state {
        case .began:
            delegate?.sliderBeginEditing(self)
        case .changed:
            thumbBottomConstraint.constant = constant
            let percentage = constant / (-height + 30)
            let currentWidth = percentage * (maxValue - minValue) + minValue
            delegate?.sliderDidChange(self, value: currentWidth)
        case .ended:
            delegate?.sliderEndEditing(self)
        default:
            break
        }
    }
    
    func setValue(_ value: CGFloat) {
        let percentage = (value - minValue) / (maxValue - minValue)
        let constant = -(bounds.height - 30) * percentage
        thumbBottomConstraint.constant = constant
    }
}
