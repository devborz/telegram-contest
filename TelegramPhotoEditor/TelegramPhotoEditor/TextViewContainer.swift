//
//  TextViewContainer.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 17.10.2022.
//

import UIKit

protocol TextViewContainerDelegate: AnyObject {
    
    func textViewDeleteTapped(_ view: TextViewContainer)
    
    func textViewDublicateTapped(_ view: TextViewContainer)
    
    func textViewSelected(_ view: TextViewContainer)
    
    func currentView() -> UIView?
    
}

class TextViewContainer: UIView, Sticker {
    
    weak var delegate: TextViewContainerDelegate?
    
    enum State: Int {
        case normal = 0
        case selected = 1
        case editing = 2
    }
    
    var state: State = .editing {
        didSet {
            setState()
        }
    }

    var alignment: NSTextAlignment = .center {
        didSet {
            setAlignment()
        }
    }
    
    var filling: TextFilling = .normal {
        didSet {
            setFilling()
        }
    }
    
    var font: Font {
        return _font
    }
    
    private var _font: Font = .init(font: .init(name: "SFProDisplay-Bold", size: 35),
                                    name: "San Francisco")
    
    var text: String {
        return textView.text ?? ""
    }
    
    let textView = TextView()
    
    var contentSize: CGSize {
        return textView.contentSize
    }
    
    var centerYConstraint: NSLayoutConstraint?
    
    var centerXConstraint: NSLayoutConstraint?
    
    var leftConstraint: NSLayoutConstraint?
    
    var rightConstraint: NSLayoutConstraint?
    
    var transformForEditing: CGAffineTransform = .identity
    
    var transformForDisplaying: CGAffineTransform = .identity
    
    let dashedFrameLayer = CAShapeLayer()
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var fontSize: CGFloat {
        return _fontSize
    }
    
    private var _fontSize: CGFloat = 35
    
    var menuItems: [UIMenuItem] {
        return [
            .init(title: "Delete", action: #selector(handleDeleteTapped)),
            .init(title: "Edit", action: #selector(handleEditTapped)),
            .init(title: "Dublicate", action: #selector(handleDublicateTapped)),
        ]
    }
    
    enum MenuEvent {
        case show, hide
    }
    
    var isMenuShown = false {
        didSet {
            if isMenuShown {
                showDashLayer()
            } else {
                if !transforming {
                    hideDashLayer()
                }
            }
        }
    }
    
    var transforming: Bool = false {
        didSet {
            if transforming {
                showDashLayer()
            } else {
                hideDashLayer()
            }
        }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        textView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        textView.isScrollEnabled = false
        textView.font = font.font
        textView.backgroundColor = .clear
        setAlignment()
        
        textView.isUserInteractionEnabled = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(gesture)
        addMenuObserver(.show)
        addMenuObserver(.hide)
        
        layer.insertSublayer(dashedFrameLayer, at: 0)
        dashedFrameLayer.opacity = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showDashLayer() {
//        self.dashedFrameLayer.opacity = 1
    }
    
    func hideDashLayer() {
//        self.dashedFrameLayer.opacity = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = CGSize(width: textView.frame.width + 20,
                          height: textView.frame.height + 20)
        dashedFrameLayer.frame = .init(origin: .zero, size: size)
        let bezierPath = UIBezierPath(roundedRect: .init(origin: .zero, size: size),
                                      cornerRadius: 20)
        dashedFrameLayer.path = bezierPath.cgPath
        dashedFrameLayer.lineDashPattern = [10, 6]
        dashedFrameLayer.lineJoin = .round
        dashedFrameLayer.lineWidth = 2
        dashedFrameLayer.strokeColor = UIColor.lightGray.cgColor
        dashedFrameLayer.fillColor = UIColor.clear.cgColor
    }
    
    func updateHeight() {
        let height = textView.sizeThatFits(.init(width: textView.bounds.width,
                                                 height: .greatestFiniteMagnitude)).height
        textView.contentSize.height = height
    }
    
    func setAlignment() {
        textView.textAlignment = alignment
        guard let _ = superview else { return }
        centerXConstraint?.isActive = alignment == .center
        leftConstraint?.isActive = alignment == .left
        rightConstraint?.isActive = alignment == .right
    }
    
    func setFilling() {
        var attributes: [NSAttributedString.Key : Any] = [:]
        switch filling {
        case .normal:
            attributes = [
                .strokeWidth : 0,
                .font : font.font?.withSize(self.fontSize) ?? .systemFont(ofSize: 35,
                                                                          weight: .bold),
                .strokeColor : UIColor.black,
                .foregroundColor : UIColor.white
            ]
        case .stroke:
            attributes = [
                .strokeWidth : -4,
                .font : font.font?.withSize(self.fontSize) ?? .systemFont(ofSize: 35,
                                                                          weight: .bold),
                .strokeColor : UIColor.black,
                .foregroundColor : UIColor.white
            ]
        case .filled:
            attributes = [
                .strokeWidth : 0,
                .font : font.font?.withSize(self.fontSize) ?? .systemFont(ofSize: 35,
                                                                          weight: .bold),
                .strokeColor : UIColor.black,
                .foregroundColor : UIColor.white
            ]
        case .semi:
            attributes = [
                .strokeWidth : 0,
                .font : font.font?.withSize(self.fontSize) ?? .systemFont(ofSize: 35,
                                                                          weight: .bold),
                .strokeColor : UIColor.black,
                .foregroundColor : UIColor.white
            ]
        }
        textView.typingAttributes = attributes
        textView.attributedText = NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    func setFont(_ font: Font) {
        _font = font
        textView.font = font.font?.withSize(_fontSize)
    }
    
    func setFontSize(_ size: CGFloat) {
        _fontSize = size
        _font.font = _font.font?.withSize(size)
        textView.font = font.font?.withSize(size)
        setFilling()
    }
    
    @objc
    func handleDeleteTapped() {
        delegate?.textViewDeleteTapped(self)
    }
    
    @objc
    func handleEditTapped() {
        textView.becomeFirstResponder()
    }
    
    @objc
    func handleDublicateTapped() {
        delegate?.textViewDublicateTapped(self)
    }
    
    func setState() {
        switch state {
        case .normal:
            textView.isUserInteractionEnabled = false
        case .selected:
            textView.isUserInteractionEnabled = false
            delegate?.textViewSelected(self)
        case .editing:
            textView.isUserInteractionEnabled = true
        }
    }
    
    @objc
    func handleTap() {
        if isMenuShown {
            textView.becomeFirstResponder()
            UIMenuController.shared.hideMenu()
        } else {
            state = .selected
            delegate?.textViewSelected(self)
            UIMenuController.shared.menuItems = menuItems
            UIMenuController.shared.arrowDirection = .down
            UIMenuController.shared.showMenu(from: self, rect: .zero)
            becomeFirstResponder()
        }
    }
    
    func addMenuObserver(_ event: MenuEvent) {
        switch event {
        case .show:
            let showNotificationName = UIMenuController.didShowMenuNotification
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(menuDidShow(_:)),
                                                   name: showNotificationName,
                                                   object: nil)
        case .hide:
            let hideNotificationName = UIMenuController.didHideMenuNotification
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(menuDidHide(_:)),
                                                   name: hideNotificationName,
                                                   object: nil)
        }
    }
    
    func removeMenuObserver(_ event: MenuEvent) {
        switch event {
        case .show:
            let showNotificationName = UIMenuController.didShowMenuNotification
            NotificationCenter.default.removeObserver(self,
                                                      name: showNotificationName,
                                                      object: nil)
        case .hide:
            let hideNotificationName = UIMenuController.didHideMenuNotification
            NotificationCenter.default.removeObserver(self,
                                                      name: hideNotificationName,
                                                      object: nil)
        }
    }
    
    private var notificationObject: NSObject?
    
    func hideMenu() {
        guard isMenuShown else { return }
        UIMenuController.shared.hideMenu()
    }
    
    @objc
    func menuDidShow(_ notification: NSNotification) {
        guard let notificationObject = notification.object as? NSObject,
              let targetView = notificationObject.value(forKeyPath: "_targetView") as? UIView else {
            return
        }
        guard targetView == self else { return }
        isMenuShown = true
    }
    
    @objc
    func menuDidHide(_ notification: NSNotification) {
        guard let notificationObject = notification.object as? NSObject,
              let targetView = notificationObject.value(forKeyPath: "_targetView") as? UIView else {
            return
        }
        guard targetView == self else { return }
        handleMenuHidden()
    }
    
    func handleMenuHidden() {
        isMenuShown = false
    }
    
    func didBecomeNotActive() {
        handleMenuHidden()
        state = .normal
    }
    
}
