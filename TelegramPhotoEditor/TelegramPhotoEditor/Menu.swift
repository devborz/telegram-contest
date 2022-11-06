//
//  Menu.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 15.10.2022.
//

import UIKit


protocol ItemViewDelegate: AnyObject {
    
    func didSelectItem(_ itemView: Menu.ActionView)
    
}

class Menu: UIView {
    
    weak var menuController: MenuViewController?
    
    struct Action {
        var title: String
        var image: UIImage?
        var handler: ((Action) -> ())?
    }
    
    var actions: [Action]
    
    var didSelect: Bool = false
    
    class ActionView: UIView {
        
        weak var delegate: ItemViewDelegate?
        
        let action: Action
        
        let imageView = UIImageView()
        
        let label = UILabel()
        
        let dimView = UIView()
        
        init(_ action: Action) {
            self.action = action
            super.init(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            label.topAnchor.constraint(equalTo: topAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            label.textColor = .white
            label.text = action.title
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            imageView.leftAnchor.constraint(equalTo: label.rightAnchor).isActive = true
            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            imageView.image = action.image?.aspectFittedToWidth(24)
            imageView.contentMode = .center
            
            dimView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(dimView)
            dimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            dimView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            dimView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            dimView.backgroundColor = .label
            dimView.alpha = 0
            
            heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tapGesture)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc
        func handleTap() {
            action.handler?(action)
            delegate?.didSelectItem(self)
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            UIView.animate(withDuration: 0.3) {
                self.dimView.alpha = 0.3
            }
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesCancelled(touches, with: event)
            UIView.animate(withDuration: 0.3) {
                self.dimView.alpha = 0
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            UIView.animate(withDuration: 0.3) {
                self.dimView.alpha = 0
            }
        }
    }
    
    let stackView = UIStackView()
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    
    init(_ actions: [Action]) {
        self.actions = actions
        super.init(frame: .zero)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        
        for i in 0..<actions.count {
            if i != 0 {
                let view = UIView()
                view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                view.backgroundColor = .separator
                
                stackView.addArrangedSubview(view)
            }
            let view = ActionView(actions[i])
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
        
        frame = .init(x: 0, y: 0, width: 150,
                      height: CGFloat(actions.count) * 40.5 - 0.5)
        
        layer.cornerRadius = 14
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Menu: ItemViewDelegate {
    
    func didSelectItem(_ itemView: ActionView) {
        guard !didSelect else { return }
        didSelect = true
        menuController?.dismiss(animated: true)
    }
    
}
