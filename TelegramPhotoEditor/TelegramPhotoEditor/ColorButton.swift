//
//  ColorButton.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 15.10.2022.
//

import UIKit

class ColorButton: UIButton {

    private let gradientView = UIImageView(image: UIImage(named: "gradient")?.aspectFittedToWidth(32))
    
    private let colorBackgroundView = UIView()
    
    private let colorView = UIView()
    
    private let highlightView = UIView()
    
    var color: UIColor = .white {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            highlightView.alpha = isHighlighted ? 0.5 : 0.0
        }
    }
    
    var tapHandler: (() -> ())?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)
        gradientView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        gradientView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        gradientView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        gradientView.contentMode = .center
        gradientView.isUserInteractionEnabled = false

        colorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorView)
        colorView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        colorView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        colorView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        colorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        colorView.backgroundColor = .white
        colorView.isUserInteractionEnabled = false

        colorView.layer.cornerRadius = 10
        colorView.clipsToBounds = true

        highlightView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlightView)
        highlightView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        highlightView.leftAnchor.constraint(equalTo: leftAnchor, constant: 4).isActive = true
        highlightView.rightAnchor.constraint(equalTo: rightAnchor, constant: -4).isActive = true
        highlightView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        highlightView.backgroundColor = .white
        highlightView.layer.cornerRadius = 16
        highlightView.alpha = 0
        highlightView.isUserInteractionEnabled = false
        
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func handleTap() {
        tapHandler?()
    }
    
    
}
