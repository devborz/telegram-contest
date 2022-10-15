//
//  SegmentSliderView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 12.10.2022.
//

import UIKit

protocol SegmentControlDelegate: AnyObject {
    
    func didSelectSegment(_ control: SegmentSliderView, segmentIndex: Int)
    
    func didChangeToolWidth(_ control: SegmentSliderView, percentage: CGFloat)
    
}

class SegmentSliderView: UIView {
    
    enum State {
        case segment, slider
    }
    
    var state: State {
        return _state
    }
    
    private var _state: State = .segment
    
    var stateChangeAnimationDuration: CGFloat {
        return 0.2
    }
    
    weak var delegate: SegmentControlDelegate?
    
    var segments: [String] = [] {
        didSet {
            config()
        }
    }
    
    var currentIndex: Int = 0 {
        didSet {
            if oldValue != currentIndex {
                delegate?.didSelectSegment(self, segmentIndex: currentIndex)
            }
        }
    }
    
    private let stackView = UIStackView()
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style:
            .systemUltraThinMaterialDark))
    
    private var items: [Button] = []
    
    private var sliderView = UIView()
    
    private var sliderLeftConstraint: NSLayoutConstraint!
    
    private var sliderWidthConstraint: NSLayoutConstraint!
    
    private var sliderHeightConstraint: NSLayoutConstraint!
    
    private var backgroundMaskLayer: CAShapeLayer = CAShapeLayer()
    
    init(_ segments: [String]) {
        super.init(frame: .zero)
        self.segments = segments
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        sliderView.backgroundColor = UIColor(named: "SegmentGray")
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sliderView)
        sliderView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sliderHeightConstraint = sliderView.heightAnchor
            .constraint(equalToConstant: 34)
        sliderHeightConstraint.isActive = true
        sliderLeftConstraint = sliderView.leftAnchor.constraint(equalTo: leftAnchor, constant: 1)
        sliderLeftConstraint.isActive = true
        sliderWidthConstraint = sliderView.widthAnchor.constraint(equalToConstant: 0)
        sliderWidthConstraint.isActive = true
        sliderView.layer.cornerRadius = 17
        sliderView.clipsToBounds = true
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.distribution = .fillEqually
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action:
                                                    #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if state == .segment {
            sliderWidthConstraint.constant = (frame.width - 2) / CGFloat(segments.count)
        }
    }
    
    func config() {
        sliderWidthConstraint.constant = (frame.width - 2) / CGFloat(segments.count)
        items.forEach { stackView.removeArrangedSubview($0) }
        items.forEach { $0.removeFromSuperview() }
        items = []
        for i in 0..<segments.count {
            let button = Button()
            button.setTitle(segments[i], for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.addTarget(self, action: #selector(handleButtonTap(_:)),
                             for: .touchUpInside)
            stackView.insertArrangedSubview(button, at: i)
            self.items.append(button)
        }
        items[0].isSelected = true
    }
    
    @objc
    func handleButtonTap(_ button: Button) {
        guard let index = items.firstIndex(of: button) else { return }
        
    
        let width = sliderWidthConstraint.constant
        sliderLeftConstraint.constant = 1 + width * CGFloat(index)
        currentIndex = index
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
    
    class Button: UIButton {
        
        
    }
    
    func makeSegment() {
        guard state == .slider else { return }
        _state = .segment
        setupBackground(animated: true)
        sliderHeightConstraint.constant = 34
        let width = sliderWidthConstraint.constant
        sliderLeftConstraint.constant = 1 + width * CGFloat(currentIndex)
        sliderWidthConstraint.constant = width
        sliderView.layer.cornerRadius = 17
        UIView.animate(withDuration: stateChangeAnimationDuration,
                       delay: 0.0, options: .curveEaseOut) {
            self.items.forEach { $0.alpha = 1 }
            self.sliderView.backgroundColor = UIColor(named: "SegmentGray")
            self.layoutIfNeeded()
        }
    }
    
    let sliderRadius: CGFloat = 14
    
    var percentage: CGFloat = 0
    
    func makeSlider(percentage: CGFloat) {
        guard state == .segment && currentIndex == 0 else { return }
        _state = .slider
        self.percentage = percentage
        setupBackground(animated: true)
        sliderHeightConstraint.constant = 2 * sliderRadius
        sliderWidthConstraint.constant = 2 * sliderRadius
        sliderLeftConstraint.constant = (frame.width - 40 - 2 * sliderRadius) * percentage
        sliderView.layer.cornerRadius = sliderRadius
        UIView.animate(withDuration: stateChangeAnimationDuration,
                       delay: 0.0, options: .curveEaseOut) {
            self.items.forEach { $0.alpha = 0 }
            self.sliderView.backgroundColor = .white
            self.layoutIfNeeded()
        }
    }
    
    var sliderLeftConstraintConstant: CGFloat = 0.0
    
    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard state == .slider else { return }
        switch gesture.state {
        case .began:
            sliderLeftConstraintConstant = sliderLeftConstraint.constant
        case .changed:
            let translation = gesture.translation(in: self)
            sliderLeftConstraint.constant = min(max((translation.x + sliderLeftConstraintConstant),
                                                    0), frame.width - 40 - 2 * sliderRadius)
            percentage = sliderLeftConstraint.constant / (frame.width - 40 - 2 * sliderRadius)
            delegate?.didChangeToolWidth(self, percentage: percentage)
        default:
            break
        }
    }
    
    func setupBackground(animated: Bool = false) {
        let path = getMaskLayerPath()
        if animated {
            let anim = CABasicAnimation(keyPath: "path")

            anim.fromValue = backgroundMaskLayer.path

            anim.toValue = path

            anim.duration = stateChangeAnimationDuration

            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)

            backgroundMaskLayer.add(anim, forKey: nil)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            backgroundMaskLayer.path = path
            CATransaction.commit()
        } else {
            backgroundMaskLayer.frame = .init(origin: .zero, size: frame.size)
            backgroundMaskLayer.path = path
            blurView.layer.mask = backgroundMaskLayer
        }
    }
    
    func getMaskLayerPath() -> CGPath {
        var width = bounds.width
        let height = bounds.height
        let path = UIBezierPath()
        switch state {
        case .segment:
            let radius = height / 2
            let yCenter = height / 2
            path.move(to: .init(x: radius, y: yCenter - radius))
            path.addArc(withCenter: .init(x: radius, y: yCenter),
                        radius: radius,
                        startAngle: -.pi / 2,
                        endAngle: .pi / 2, clockwise: false)
            path.addLine(to: .init(x: width - radius, y: yCenter + radius))
            path.addArc(withCenter: .init(x: width - radius, y: yCenter),
                        radius: radius,
                        startAngle: .pi / 2,
                        endAngle: -.pi / 2, clockwise: false)
            path.addLine(to: .init(x: radius, y: yCenter - radius))
        case .slider:
            width -= 40
            let leftRadius: CGFloat = 3
            let rightRadius: CGFloat = 13
            let yCenter = height / 2
            path.move(to: .init(x: leftRadius, y: yCenter - leftRadius))
            path.addArc(withCenter: .init(x: leftRadius, y: yCenter),
                        radius: leftRadius,
                        startAngle: -.pi / 2,
                        endAngle: .pi / 2, clockwise: false)
            path.addLine(to: .init(x: width - rightRadius, y: yCenter + rightRadius))
            path.addArc(withCenter: .init(x: width - rightRadius, y: yCenter),
                        radius: rightRadius,
                        startAngle: .pi / 2,
                        endAngle: -.pi / 2, clockwise: false)
            path.addLine(to: .init(x: leftRadius, y: yCenter - leftRadius))
        }
        return path.cgPath
    }

}
