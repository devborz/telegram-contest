//
//  CanvasView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit
import PencilKit

protocol CanvasDelegate: AnyObject {
    
    func canvasDidEndDrawing(_ canvas: CanvasView)
}

class CanvasView: UIView {
    
    weak var delegate: CanvasDelegate?
    
    var canvasView: PKCanvasView = .init()
    
    var drawings: [PKDrawing] = []
    
    // MARK: Brush state
    
    var currentTool: Tool? {
        didSet {
            setBrush()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        config()
    }
    
    func config() {
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(canvasView)
        canvasView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvasView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        canvasView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if #available(iOS 14.0, *) {
            canvasView.drawingPolicy = .anyInput
        } else {
            // Fallback on earlier versions
        }
        canvasView.delegate = self
        canvasView.backgroundColor = .clear
        
        canvasView.drawing = PKDrawing()
    }
    
    func setBrush() {
        guard let currentTool = currentTool else { return }
        var pkTool: PKTool?
        switch currentTool.type {
        case .pen:
            let tool = PKInkingTool.init(.pen,
                                         color: currentTool.color,
                                         width: currentTool.width)
            pkTool = tool
        case .eraser:
            let tool = PKEraserTool.init(.bitmap)
            pkTool = tool
        case .brush:
            let tool = PKInkingTool.init(.marker,
                                         color: currentTool.color,
                                         width: currentTool.width)
            pkTool = tool
        case .neon:
            break
        case .pencil:
            let tool = PKInkingTool.init(.pencil,
                                         color: currentTool.color,
                                         width: currentTool.width)
            pkTool = tool
        case .objectEraser:
            let tool = PKEraserTool.init(.vector)
            pkTool = tool
        case .blurEraser:
            break
        case .lasso:
            let tool = PKLassoTool()
            pkTool = tool
        }
        if let pkTool = pkTool {
            canvasView.tool = pkTool
        }
    }
    
    var didBrushInit = false
}

extension CanvasView: PKCanvasViewDelegate {
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let drawing = self.canvasView.drawing
//        drawings.append(.init(strokes: drawing.strokes))
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
    }
    
}
