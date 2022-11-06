//
//  CanvasView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit
import PencilKit
import RxSwift

protocol CanvasViewDelegate: AnyObject {
    
    func canvasViewDrawingDidChange(_ canvasView: CanvasView, drawing: PKDrawing)
    
}

class CanvasView: UIView {
    
    weak var delegate: CanvasViewDelegate?
    
    var canvasView: PKCanvasView = .init()
    
    var lastChangeDoneProgrammaticaly: Bool = false
    
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
    
    func undo(_ drawing: PKDrawing) {
        canvasView.drawing = drawing
    }
    
    func clearAll() {
        canvasView.drawing = PKDrawing()
    }
    
    private func config() {
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
        canvasView.overrideUserInterfaceStyle = .light
        
        canvasView.drawing = PKDrawing()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                    action: #selector(handleLongPress(_:)))
        addGestureRecognizer(gestureRecognizer)
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
    
    @objc
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let currentTool = currentTool else { return }
        switch currentTool.type {
        case .pen, .pencil, .brush:
            break
        default:
            return
        }
        if #available(iOS 14.0, *) {
            var points: [PKStrokePoint] = []
            let strokePoint = PKStrokePoint(location: .zero,
                                            timeOffset: 0,
                                            size: .init(width: 500,
                                                        height: 500),
                                            opacity: 1,
                                            force: 0,
                                            azimuth: 0,
                                            altitude: 0)
            points.append(strokePoint)
            let stroke = PKStroke(ink: .init(.pen, color: currentTool.color),
                                  path: .init(controlPoints: points,
                                              creationDate: Date()),
                                  transform: .identity.scaledBy(x: 4, y: 4))
            canvasView.drawing.strokes.append(stroke)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 14.0, *)
    func addArrowToLastStroke(_ stroke: PKStroke) {
        guard let currentCanvasTool = canvasView.tool as? PKInkingTool,
              let tool = currentTool else {
            let drawing = currentDrawingCopy()
            delegate?.canvasViewDrawingDidChange(self, drawing: drawing)
            return
        }

        let tipTypes = tool.getTipTypes()
        switch tool.type {
        case .pen, .pencil, .brush:
            break
        default:
            let drawing = currentDrawingCopy()
            delegate?.canvasViewDrawingDidChange(self, drawing: drawing)
            return
        }
        let strokePoints = stroke.path.map { $0 }
        guard let index = tool.tipTypeIndex,
              tipTypes[index].name == "Arrow",
              strokePoints.count >= 5 else {
            let drawing = currentDrawingCopy()
            delegate?.canvasViewDrawingDidChange(self, drawing: drawing)
            return
        }
        let strokePoint_A = strokePoints[strokePoints.count - 5]
        let strokePoint_B = strokePoints[strokePoints.count - 1]
        let point_A = strokePoint_A.location
        let point_B = strokePoint_B.location
        
        let xDiff = point_B.x - point_A.x
        let yDiff = -point_B.y + point_A.y
        let hypotenuse = sqrt(xDiff * xDiff + yDiff * yDiff)
        let alpha_cos = xDiff / hypotenuse
        let alpha_sin = yDiff / hypotenuse
        
        let alpha = atan2(alpha_sin, alpha_cos)
        
        let point_C = CGPoint(x: point_B.x + 60 * cos(alpha - 3 * .pi / 4),
                              y: point_B.y - 60 * sin(alpha - 3 * .pi / 4))
        let point_D = CGPoint(x: point_B.x + 60 * cos(alpha + 3 * .pi / 4),
                              y: point_B.y - 60 * sin(alpha + 3 * .pi / 4))
        
        
        let points = [point_C, point_C, point_B, point_B, point_D]
        
        
        var stroke_points: [PKStrokePoint] = []
        for i in 0..<points.count {
            stroke_points.append(PKStrokePoint(location: points[i],
                                               timeOffset: CGFloat(i) * 0.1,
                                               size: strokePoint_B.size,
                                               opacity: strokePoint_B.opacity,
                                               force: 0,
                                               azimuth: 0,
                                               altitude: 0))
        }
        var arrowStrokePoints: [PKStrokePoint] = strokePoints
        arrowStrokePoints.append(contentsOf: stroke_points)
        let arrowStroke = PKStroke(ink: currentCanvasTool.ink,
                                   path: .init(controlPoints: arrowStrokePoints,
                                               creationDate: Date()))
        
        let count = canvasView.drawing.strokes.count
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.lastChangeDoneProgrammaticaly = true
            self.canvasView.drawing.strokes[count - 1] = arrowStroke
        }
    }
    
    func currentDrawingCopy() -> PKDrawing {
//        if #available(iOS 14, *) {
//            return PKDrawing(strokes: canvasView.drawing.strokes)
//        }
        let drawing = PKDrawing().appending(canvasView.drawing)
        return drawing
    }
}

extension CanvasView: PKCanvasViewDelegate {
    

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let drawing = currentDrawingCopy()
        if #available(iOS 14.0, *) {
            if !lastChangeDoneProgrammaticaly {
                if let lastStroke = canvasView.drawing.strokes.last {
                    addArrowToLastStroke(lastStroke)
                } else {
                    delegate?.canvasViewDrawingDidChange(self, drawing: drawing)
                }
            } else {
                delegate?.canvasViewDrawingDidChange(self, drawing: drawing)
                lastChangeDoneProgrammaticaly = false
            }
        } else {
            delegate?.canvasViewDrawingDidChange(self, drawing: drawing)
        }
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
    }
    
    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
    }
    
}
