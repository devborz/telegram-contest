//
//  TextEditingView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 17.10.2022.
//

import UIKit

protocol TextEditingViewDelegate: AnyObject {
    
    func textViewAdded(_ editView: TextEditingView, textView: TextViewContainer)
    
    func textViewRemoved(_ editView: TextEditingView, textView: TextViewContainer)
    
    func textViewDidStartEditing(_ editView: TextEditingView, textView: TextViewContainer)
    
    func textViewDidEndEditing(_ editView: TextEditingView, textView: TextViewContainer)
    
    func textViewSelected(_ editView: TextEditingView, textView: TextViewContainer?)
    
    func didShowKeyboard(_ editView: TextEditingView, keyboardHeight: CGFloat)
    
    func didHideKeyboard(_ editView: TextEditingView)
    
}

class TextEditingView: UIView {
    
    enum State {
        case normal
        case transforming
        case editing
    }
    
    private var _state: State = .normal
    
    var state: State {
        return _state
    }
    
    weak var delegate: TextEditingViewDelegate?
    
    var currentTextViewContainer: TextViewContainer? {
        didSet {
            if currentTextViewContainer != oldValue {
                oldValue?.didBecomeNotActive()
                delegate?.textViewSelected(self, textView: currentTextViewContainer)
            }
        }
    }
    
    var keyboardMinY: CGFloat? = nil
    
    var textEditBar = TextEditBarView()
    
    let dimView: UIView
    
    var textViews: Set<TextViewContainer> = []
    
    var gestures: Set<UIGestureRecognizer> = []
    
    var transformingView: UIView?
    
    var currentTransform: CGAffineTransform = .identity

    override init(frame: CGRect) {
        dimView = .init(frame: frame)
        super.init(frame: frame)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
       
        setupKeyboardObservers()
        
        textEditBar.frame = .init(x: 0, y: 0, width: frame.width, height: 46)
        textEditBar.addBlurBackground()
        
        clipsToBounds = true
        
        dimView.backgroundColor = .init(white: 0, alpha: 0.5)
        dimView.alpha = 0
        
    }
    
    var textEditBarTopConstraint: NSLayoutConstraint!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createNewTextView() {
        let textViewContainer = TextViewContainer(frame: .zero)
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textViewContainer)
        textViewContainer.textView.delegate = self
        textViewContainer.textView.inputAccessoryView = textEditBar
        textViewContainer.leftConstraint = textViewContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        textViewContainer.leftConstraint?.isActive = false
        textViewContainer.rightConstraint = textViewContainer.rightAnchor.constraint(equalTo: rightAnchor,
                                                                   constant: -20)
        textViewContainer.rightConstraint?.isActive = false
        textViewContainer.centerYConstraint = textViewContainer.centerYAnchor
            .constraint(equalTo: topAnchor,
            constant: 0)
        textViewContainer.centerYConstraint?.isActive = true
        textViewContainer.centerXConstraint = textViewContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
        textViewContainer.centerXConstraint?.isActive = true
        textViewContainer.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor,
                                       constant: 20).isActive = true
        textViewContainer.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor,
                                        constant: -20).isActive = true
        textViewContainer.textView.becomeFirstResponder()
        textViewContainer.alpha = 0
        textViewContainer.delegate = self
        currentTextViewContainer = textViewContainer
        addGesturesToView(textViewContainer)
        textViews.insert(textViewContainer)
        delegate?.textViewAdded(self, textView: textViewContainer)
    }
    
    @objc
    func handleGesture(_ gestureRecognizer: UIGestureRecognizer) {
        guard _state != .editing else { return }
        switch gestureRecognizer.state {
        case .began:
            if gestures.isEmpty {
                guard let currentView = gestureRecognizer.view,
                      let sticker = currentView as? Sticker else {
                    return
                }
                sticker.transforming = true
                sticker.hideMenu()
                transformingView = currentView
                bringSubviewToFront(currentView)
                _state = .transforming
                currentTransform = currentView.transform
            }
            gestures.insert(gestureRecognizer)
        case .changed:
            var transform = currentTransform
            guard let currentView = transformingView else {
                return
            }
            for gesture in gestures {
                transform = createViewTransform(gesture, transform: transform, view: currentView)
            }
            currentView.transform = transform
        case .ended:
            gestures.remove(gestureRecognizer)
            if gestures.isEmpty {
                guard let currentView = gestureRecognizer.view,
                      let sticker = currentView as? Sticker else {
                    return
                }
                sticker.transforming = false
                _state = .normal
                transformingView = nil
            }
        default:
            break
        }
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        let endFrame: CGRect =
            notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]  as! CGRect
        DispatchQueue.main.async {
            self.currentTextViewContainer?.centerYConstraint?.constant = (self.frame.height - 20) / 2
            self.currentTextViewContainer?.alpha = 1
        }
        self.delegate?.didShowKeyboard(self, keyboardHeight: endFrame.height)
        self.textEditBar.alpha = 1
    }
    
    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        keyboardMinY = nil
        self.textEditBar.alpha = 0
        self.delegate?.didHideKeyboard(self)
    }
    
    @objc
    func keyboardWillChangeFrame(_ notification: NSNotification) {
        let endFrame: CGRect =
            notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]  as! CGRect
        guard let editorFrame = self.superview?.frame else { return }
        keyboardMinY = endFrame.origin.y - editorFrame.origin.y
        
//        fontSliderCenterConstraint.constant = keyboardMinY! / 2
//        textEditBarTopConstraint.constant = keyboardMinY! - 40

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    @objc
    func handleTap() {
        if currentTextViewContainer?.textView.isFirstResponder ?? false {
            currentTextViewContainer?.textView.resignFirstResponder()
        } else {
            createNewTextView()
        }
    }
    
    func createViewTransform(_ gestureRecognizer: UIGestureRecognizer,
                             transform: CGAffineTransform, view: UIView) -> CGAffineTransform {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let tr = transform
            let t = panGesture.translation(in: self)
            let scale: Double = sqrt(tr.a * tr.a + tr.c * tr.c)
            let angle: Double = atan2(tr.b, tr.a)
            var rt = CGPoint(x: t.y * CGFloat(sin(angle)) + t.x * CGFloat(cos(angle)),
                             y: -t.x * CGFloat(sin(angle)) + t.y * CGFloat(cos(angle)))
            rt.x /= scale
            rt.y /= scale
            return transform.translatedBy(x: rt.x, y: rt.y)
        } else if let pinchGesture = gestureRecognizer as? UIPinchGestureRecognizer {
            return transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
        } else if let rotationGesture = gestureRecognizer as? UIRotationGestureRecognizer {
            return transform.rotated(by: rotationGesture.rotation)
        }
        return transform
    }
    
}

extension TextEditingView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let textView = textView.superview as? TextViewContainer else { return }
        textView.state = .editing
        _state = .editing
        delegate?.textViewDidStartEditing(self, textView: textView)
        currentTextViewContainer = textView
        textView.transformForDisplaying = textView.transform
        bringSubviewToFront(textView)
        UIView.animate(withDuration: 0.3) {
            textView.transform = textView.transformForEditing
        }
        
        insertSubview(dimView, belowSubview: textView)
        
        delegate?.textViewDidStartEditing(self, textView: textView)
        UIView.animate(withDuration: 0.3) {
            self.dimView.alpha = 1
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let currentTextView = currentTextViewContainer else { return }
        currentTextView.state = .selected
        if currentTextView.textView == textView {
            _state = .normal
            guard let textView = textView.superview as? TextViewContainer else { return }
            textView.transformForEditing = textView.transform
            
            UIView.animate(withDuration: 0.3) {
                textView.transform = textView.transformForDisplaying
            }
            let text = textView.text.trimmingCharacters(in: [" ", "\n"])
            if text.isEmpty {
                delegate?.textViewRemoved(self, textView: textView)
                textView.removeFromSuperview()
                currentTextViewContainer = nil
            }
            delegate?.textViewDidEndEditing(self, textView: currentTextView)
            UIView.animate(withDuration: 0.3) {
                self.dimView.alpha = 0
            } completion: { _ in
                self.dimView.removeFromSuperview()
            }
        }
    }
}

extension TextEditingView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.view == otherGestureRecognizer.view
    }
}

extension TextEditingView: TextViewContainerDelegate {
    func currentView() -> UIView? {
        return currentTextViewContainer
    }
    
    func textViewDeleteTapped(_ view: TextViewContainer) {
        delegate?.textViewRemoved(self, textView: view)
        view.removeFromSuperview()
        textViews.remove(view)
        if currentTextViewContainer == view {
            currentTextViewContainer = nil
        }
    }
    
    func textViewSelected(_ view: TextViewContainer) {
        currentTextViewContainer = view
    }
    
    func textViewDublicateTapped(_ view: TextViewContainer) {
        let textViewContainer = TextViewContainer(frame: .zero)
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textViewContainer)
        textViewContainer.textView.delegate = self
        textViewContainer.textView.inputAccessoryView = textEditBar
        textViewContainer.leftConstraint = textViewContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        textViewContainer.leftConstraint?.isActive = false
        textViewContainer.rightConstraint = textViewContainer.rightAnchor.constraint(equalTo: rightAnchor,
                                                                   constant: -20)
        textViewContainer.rightConstraint?.isActive = false
        textViewContainer.centerYConstraint = textViewContainer.centerYAnchor
                    .constraint(equalTo: topAnchor,
                                constant: self.frame.height / 2)
        textViewContainer.centerYConstraint?.isActive = true
        textViewContainer.centerXConstraint = textViewContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
        textViewContainer.centerXConstraint?.isActive = true
        textViewContainer.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor,
                                       constant: 20).isActive = true
        textViewContainer.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor,
                                        constant: -20).isActive = true
        textViewContainer.delegate = self
        
        textViewContainer.textView.text = view.text
        textViewContainer.filling = view.filling
        textViewContainer.alignment = view.alignment
        
        textViewContainer.setFont(view.font)
        textViewContainer.setFontSize(view.fontSize)
        
        textViewContainer.transform = view.transform
        addGesturesToView(textViewContainer)
        textViews.insert(textViewContainer)
        delegate?.textViewAdded(self, textView: textViewContainer)
    }
    
    
    func addGesturesToView(_ view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(handleGesture(_:)))
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action: #selector(handleGesture(_:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self,
                                                              action: #selector(handleGesture(_:)))
        panGestureRecognizer.delegate = self
        pinchGestureRecognizer.delegate = self
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        view.addGestureRecognizer(rotationGestureRecognizer)
        view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    func removeTextView(_ textView: TextViewContainer) {
        textViews.remove(textView)
        textView.removeFromSuperview()
    }
    
    func clearAll() {
        textViews.forEach { textView in
            textView.removeFromSuperview()
        }
        textViews = []
    }
    
}
