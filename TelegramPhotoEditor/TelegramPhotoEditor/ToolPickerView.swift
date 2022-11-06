//
//  ToolPickerView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit
import RxSwift

protocol ToolPickerViewDelegate: AnyObject {
    
    func didChangeTool(_ pickerView: ToolPickerView, tool: Tool)
    
    func didStartModifyingTool(_ pickerView: ToolPickerView, tool: Tool)
    
}

class ToolPickerView: UIView {
    
    weak var delegate: ToolPickerViewDelegate?
    
    enum State {
        case normal
        case modifying
    }
    
    var state: State = .normal {
        didSet {
            if state != oldValue {
                setState()
            }
        }
    }

    let tools: [Tool] = [
        .init(type: .pen),
        .init(type: .brush),
        .init(type: .pencil),
        .init(type: .lasso),
        .init(type: .eraser)
    ]
    
    var toolViews: [ToolView] = []
    
    var selectedToolIndex: Int = 0
    
    var currentTool: Tool {
        return tools[selectedToolIndex]
    }
    
    var toolsTopConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        for i in 0..<tools.count {
            let view = ToolView()
            view.setup(tools[i])
            view.delegate = self
            toolViews.append(view)
        }
        layout()
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layer = CAGradientLayer()
        layer.startPoint = .init(x: 0, y: 0)
        layer.endPoint = .init(x: 0, y: 1)
        layer.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor,
        ]
        layer.locations = [
            .init(floatLiteral: (frame.height - 15) / frame.height),
            .init(floatLiteral: 1)
        ]
        layer.frame = .init(origin: .zero, size: frame.size)
        self.layer.mask = layer
    }
    
    func layout() {
        toolViews.forEach { $0.removeFromSuperview() }
        toolsTopConstraints = []
        var spacerViews: [UIView] = []
        for i in 0..<toolViews.count {
            let toolView = toolViews[i]
            toolView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(toolView)
            if i == 0 {
                let leftConstraint = toolView.leftAnchor.constraint(equalTo: leftAnchor)
                leftConstraint.priority = .defaultLow
                leftConstraint.isActive = true
            } else {
                let lastView = toolViews[i - 1]
                let spacerView = UIView()
                spacerView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(spacerView)
                spacerView.leftAnchor.constraint(equalTo: lastView.rightAnchor).isActive = true
                spacerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
                spacerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                spacerViews.append(spacerView)
                
                toolView.leftAnchor.constraint(equalTo: spacerView.rightAnchor).isActive = true
                
                if i == tools.count - 1 {
                    let rightConstraint = toolView.rightAnchor.constraint(equalTo: rightAnchor)
                    rightConstraint.priority = .defaultLow
                    rightConstraint.isActive = true
                }
            }
            let topConstraint = toolView.topAnchor.constraint(equalTo: topAnchor,
                                                              constant: 20)
            topConstraint.isActive = true
            toolsTopConstraints.append(topConstraint)
            toolView.heightAnchor.constraint(equalToConstant: 90).isActive = true
            toolView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        for i in 1..<spacerViews.count {
            spacerViews[i].widthAnchor
                .constraint(equalTo: spacerViews[i - 1].widthAnchor).isActive = true
        }
        toolsTopConstraints[selectedToolIndex].constant = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentToolCenterConstraint: NSLayoutConstraint?
    
    func setState() {
        switch state {
        case .modifying:
            for i in 0..<self.toolViews.count {
                if i == self.selectedToolIndex {
                    let view = self.toolViews[i]
                    
                    currentToolCenterConstraint = view.centerXAnchor
                        .constraint(equalTo: centerXAnchor)
                    currentToolCenterConstraint?.isActive = true
                    self.toolsTopConstraints[i].constant = 20
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0, options: .curveEaseOut) {
                        let scale: CGFloat = 130 / 90
                        view.transform = .identity.scaledBy(x: scale, y: scale)
                        self.layoutIfNeeded()
                    }
                } else {
                    self.toolsTopConstraints[i].constant = 120
                    UIView.animate(withDuration: 0.5, delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0, options: .curveEaseOut) {
                        self.toolViews[i].alpha = 0
                        self.layoutIfNeeded()
                    }
                }
            }
        case .normal:
            for i in 0..<self.toolViews.count {
                if i == self.selectedToolIndex {
                    let view = self.toolViews[i]
                    
                    currentToolCenterConstraint?.isActive = false
                    self.toolsTopConstraints[i].constant = 0
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0, options: .curveEaseOut) {
                        view.transform = .identity
                        self.layoutIfNeeded()
                    }
                } else {
                    self.toolsTopConstraints[i].constant = 20
                    UIView.animate(withDuration: 0.5, delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0, options: .curveEaseOut) {
                        self.toolViews[i].alpha = 1
                        self.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
}

extension ToolPickerView: ToolViewDelegate {
    
    func toolSelected(_ toolView: ToolView, tool: Tool) {
        guard state == .normal else { return }
        guard let index = tools.firstIndex(where: { element in
            return element.type == tool.type
        }) else { return }
        if selectedToolIndex == index {
            guard tool.canModify else { return }
            let oldState = state
            state = .modifying
            if state != oldState {
                delegate?.didStartModifyingTool(self, tool: tool)
            }
        } else {
            let oldValue = selectedToolIndex
            selectedToolIndex = index
            if oldValue != index {
                delegate?.didChangeTool(self, tool: tool)
                self.toolsTopConstraints[oldValue].constant = 20
                self.toolsTopConstraints[index].constant = 0
                UIView.animate(withDuration: 0.2) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
}

protocol ToolViewDelegate: AnyObject {
    
    func toolSelected(_ toolView: ToolView, tool: Tool)
    
}

class ToolView: UIView {
    
    weak var delegate: ToolViewDelegate?
    
    weak var tool: Tool?
    
    let baseImageView = UIImageView()
    
    let tipImageView = UIImageView()
    
    let widthView = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        baseImageView.contentMode = .scaleAspectFit
        tipImageView.contentMode = .scaleAspectFit
        
        addSubview(baseImageView)
        baseImageView.frame = .init(origin: .zero, size: frame.size)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        baseImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(baseImageView)
        baseImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        baseImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        baseImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        baseImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    let disposeBag = DisposeBag()
    
    func setup(_ tool: Tool) {
        self.tool = tool
        baseImageView.image = tool.baseImage()
        
        if tool.needTip {
            addSubview(tipImageView)
            tipImageView.image = tool.tipImage()?.withRenderingMode(.alwaysTemplate)
            tipImageView.tintColor = tool.color
            tipImageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tipImageView)
            tipImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            tipImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            tipImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            tipImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            if let widthPercentage = tool.absolutePercentage {
                addSubview(widthView)
                widthView.frame = .init(x: 11.5, y: 40,
                                        width: 17,
                                        height: widthPercentage * 17)
                widthView.backgroundColor = tool.color
                widthView.layer.cornerRadius = 1
                widthView.clipsToBounds = true
            }
        }
        
        tool.updates.bind { [weak self] tool in
            DispatchQueue.main.async {
                self?.updateTool(tool)
            }
        }.disposed(by: disposeBag)
    }
    
    func updateTool(_ tool: Tool) {
        baseImageView.image = tool.baseImage()
        tipImageView.tintColor = tool.color
        widthView.backgroundColor = tool.color
        widthView.frame.size.height = (tool.absolutePercentage ?? 0) * 17
    }
    
    @objc
    func handleTap() {
        guard let tool = tool else { return }
        delegate?.toolSelected(self, tool: tool)
    }
}
