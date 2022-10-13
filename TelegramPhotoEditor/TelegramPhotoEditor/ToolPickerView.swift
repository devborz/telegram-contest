//
//  ToolPickerView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit

protocol ToolPickerViewDelegate: AnyObject {
    
    func didChangeTool(_ pickerView: ToolPickerView, tool: Tool)
    
}

class ToolPickerView: UIView {
    
    weak var delegate: ToolPickerViewDelegate?

    let tools: [Tool] = [
        .init(type: .pen, width: 10),
        .init(type: .brush, width: 10),
        .init(type: .neon, width: 10),
        .init(type: .pencil, width: 10),
        .init(type: .lasso, width: 0),
        .init(type: .eraser, width: 10)
    ]
    
    var toolViews: [ToolView] = []
    
    var selectedToolIndex: Int = 0
    
    var currentTool: Tool {
        return tools[selectedToolIndex]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tools.forEach { tool in
            let view = ToolView()
            view.setup(tool)
            view.delegate = self
            toolViews.append(view)
        }
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func layout() {
        toolViews.forEach { $0.removeFromSuperview() }
        let space: CGFloat = (frame.width - CGFloat(tools.count) * 40) / CGFloat(tools.count - 1)
        for i in 0..<toolViews.count {
            let toolView = toolViews[i]
            addSubview(toolView)
            toolView.frame = .init(x: (40 + space) * CGFloat(i) ,
                                   y: selectedToolIndex == i ? 0 : 20,
                                   width: 40,
                                   height: frame.height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ToolPickerView: ToolViewDelegate {
    
    func toolSelected(_ toolView: ToolView, tool: Tool) {
        guard let index = tools.firstIndex(where: { element in
            return element.type == tool.type
        }) else { return }
        if selectedToolIndex == index { } else {
            let oldValue = selectedToolIndex
            selectedToolIndex = index
            delegate?.didChangeTool(self, tool: tool)
            UIView.animate(withDuration: 0.2) {
                self.toolViews[oldValue].frame.origin.y = 20
                self.toolViews[index].frame.origin.y = 0
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseImageView.contentMode = .scaleAspectFit
        tipImageView.contentMode = .scaleAspectFit
        
        addSubview(baseImageView)
        baseImageView.frame = .init(origin: .zero, size: frame.size)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        baseImageView.frame = .init(origin: .zero, size: frame.size)
        tipImageView.frame = .init(origin: .zero, size: frame.size)
    }
    
    func setup(_ tool: Tool) {
        self.tool = tool
        baseImageView.image = tool.baseImage()
        
        if tool.needTip {
            addSubview(tipImageView)
            tipImageView.image = tool.tipImage()?.withRenderingMode(.alwaysTemplate)
            tipImageView.tintColor = tool.color
            
            addSubview(widthView)
            widthView.frame = .init(x: 11.5, y: 40, width: 17, height: tool.width)
            widthView.backgroundColor = tool.color
            widthView.layer.cornerRadius = 1
            widthView.clipsToBounds = true
        }
    }
    
    func updateWidth() {
        
    }
    
    @objc
    func handleTap() {
        guard let tool = tool else { return }
        delegate?.toolSelected(self, tool: tool)
    }
}
