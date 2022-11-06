//
//  BlurGradientView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 20.10.2022.
//

import UIKit

class BlurGradientView: BlurView {
    
    enum GradientPosition {
        case top, bottom
    }
    
    var position: GradientPosition
    
    var clearPartWidth: CGFloat = 5

    init(position: GradientPosition) {
        self.position = position
        super.init(effect: nil)
        
        createMask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createMask()
    }
    
    func createMask() {
        let gradient = CAGradientLayer()
        var locations: [NSNumber] = []
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        switch position {
        case .top:
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 0, y: 0)
        case .bottom:
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
        }
        locations = [
            .init(floatLiteral: 0),
            .init(floatLiteral: (frame.height - clearPartWidth) / frame.height),
            .init(floatLiteral: 1)
        ]
        gradient.locations = locations
        gradient.frame = .init(origin: .zero, size: frame.size)
        layer.mask = gradient
    }
}
