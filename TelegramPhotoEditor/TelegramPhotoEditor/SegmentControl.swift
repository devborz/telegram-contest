//
//  SegmentControl.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 12.10.2022.
//

import UIKit

protocol SegmentControlDelegate: AnyObject {
    
    func didSelectSegment(_ control: SegmentControl, segmentIndex: Int)
    
}

class SegmentControl: UIView {
    
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
    
    init(_ segments: [String]) {
        super.init(frame: .zero)
        self.segments = segments
//        backgroundColor = UIColor(named: "DarkGray")
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        sliderView.backgroundColor = UIColor(named: "SegmentGray")
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sliderView)
        sliderView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        sliderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        sliderLeftConstraint = sliderView.leftAnchor.constraint(equalTo: leftAnchor, constant: 1)
        sliderLeftConstraint.isActive = true
        
        sliderWidthConstraint = sliderView.widthAnchor.constraint(equalToConstant: 0)
        sliderWidthConstraint.isActive = true
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.distribution = .fillEqually
        
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        sliderView.layer.cornerRadius = sliderView.frame.height / 2
        sliderView.clipsToBounds = true
        sliderWidthConstraint.constant = (frame.width - 2) / CGFloat(segments.count)
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

}
