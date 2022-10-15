//
//  CanvasView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit
import PencilKit
import RxSwift

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
            canvasView.allowsFingerDrawing = true
        }
        
        canvasView.delegate = self
        canvasView.backgroundColor = .clear
        
        canvasView.drawing = PKDrawing()
        canvasView.overrideUserInterfaceStyle = .light
    }
    
    private func updateBrush() {
        guard let currentTool = currentTool else { return }
        var pkTool: PKTool?
        switch currentTool.type {
        case .pen:
            if let width = currentTool.width {
                let tool = PKInkingTool.init(.pen,
                                             color: currentTool.color,
                                             width: width)
                
                pkTool = tool
            }
        case .eraser:
            let tool = PKEraserTool.init(.bitmap)
            pkTool = tool
        case .brush:
            if let width = currentTool.width {
                let tool = PKInkingTool.init(.marker,
                                             color: currentTool.color,
                                             width: width)
                
                pkTool = tool
            }
        case .neon:
            break
        case .pencil:
            if let width = currentTool.width {
                let tool = PKInkingTool.init(.pencil,
                                             color: currentTool.color,
                                             width: width)
                
                pkTool = tool
            }
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
    
    var disposeBag = DisposeBag()
    
    func setBrush() {
        guard let currentTool = currentTool else { return }
        disposeBag = DisposeBag()
        updateBrush()
        currentTool.updates.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateBrush()
            }
        }.disposed(by: disposeBag)
    }
}

extension CanvasView: PKCanvasViewDelegate {
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {

    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
    }
    
}
