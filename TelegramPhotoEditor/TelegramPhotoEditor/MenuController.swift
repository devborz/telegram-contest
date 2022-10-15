//
//  MenuController.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 15.10.2022.
//

import UIKit

class MenuController: UIViewController {
    
    let menu: Menu
    
    private let backgroundView = BackgroundView()
    
    init(menu: Menu) {
        self.menu = menu
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menu.alpha = 0
        menu.menuController = self
        view.addSubview(backgroundView)
        view.addSubview(menu)
        backgroundView.frame = view.bounds
        backgroundView.touchesBeganHandler = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        view.backgroundColor = .clear
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2) {
            self.menu.alpha = 1
        }
    }
    
    class BackgroundView: UIView {
        
        var touchesBeganHandler: (() -> ())?
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            touchesBeganHandler?()
        }
    }
    
}
