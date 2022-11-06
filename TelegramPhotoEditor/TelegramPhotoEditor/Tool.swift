//
//  Tool.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit
import PencilKit
import RxSwift

enum ToolType: String {
    case brush
//    case neon
    case pen
    case pencil
    case eraser
    case objectEraser
//    case blurEraser
    case lasso
}

struct ToolTipType {
    var name: String
    var image: UIImage?
}

class Tool {
    
    var type: ToolType {
        didSet {
            updates.onNext(self)
        }
    }
    
    var width: CGFloat? {
        didSet {
            updates.onNext(self)
        }
    }
    
    var color: UIColor = .white {
        didSet {
            updates.onNext(self)
        }
    }
    
    var needTip: Bool {
        switch type {
        case .eraser,
//                .blurEraser,
                .objectEraser,
                .lasso:
            return false
        default:
            return true
        }
    }
    
    var tipTypeIndex: Int? = 0 {
        didSet {
            if let tipTypeIndex = tipTypeIndex {
                switch type {
                case .eraser,
//                        .blurEraser,
                        .objectEraser:
                    switch tipTypeIndex {
//                    case 2:
//                        type = .blurEraser
                    case 1:
                        type = .objectEraser
                    case 0:
                        type = .eraser
                    default:
                        break
                    }
                default:
                    updates.onNext(self)
                }
            }
        }
    }
    
    var minWidth: CGFloat? {
        switch type {
        case .pen:
            let inkType = PKInkingTool.InkType.pen
            return inkType.validWidthRange.lowerBound
        case .pencil:
            let inkType = PKInkingTool.InkType.pencil
            return inkType.validWidthRange.lowerBound
        case .brush:
            let inkType = PKInkingTool.InkType.marker
            return inkType.validWidthRange.lowerBound
        default:
            return nil
        }
    }
    
    var maxWidth: CGFloat? {
        switch type {
        case .pen:
            let inkType = PKInkingTool.InkType.pen
            return inkType.validWidthRange.upperBound
        case .pencil:
            let inkType = PKInkingTool.InkType.pencil
            return inkType.validWidthRange.upperBound
        case .brush:
            let inkType = PKInkingTool.InkType.marker
            return inkType.validWidthRange.upperBound
        default:
            return nil
        }
    }
    
    var defaultWidth: CGFloat? {
        switch type {
        case .pen:
            let inkType = PKInkingTool.InkType.pen
            return inkType.defaultWidth
        case .pencil:
            let inkType = PKInkingTool.InkType.pencil
            return inkType.defaultWidth
        case .brush:
            let inkType = PKInkingTool.InkType.marker
            return inkType.defaultWidth
        default:
            return nil
        }
    }
    
    var updates: PublishSubject<Tool> = .init()
    
    var absolutePercentage: CGFloat? {
        get {
            guard let width = width, let maxWidth = maxWidth else { return nil }
            return width / maxWidth
        }
    }
    
    var relativePercentage: CGFloat? {
        get {
            guard let width = width,
                    let maxWidth = maxWidth, let minWidth = minWidth else { return nil }
            return (width - minWidth) / (maxWidth - minWidth)
        }
        set(newValue) {
            guard let newValue else { return }
            guard newValue <= 1.0 && newValue >= 0 else { return }
            guard let maxWidth = maxWidth, let minWidth = minWidth else { return }
            self.width = (maxWidth - minWidth) * newValue + minWidth
        }
    }
    
    func getTipTypes() -> [ToolTipType] {
        switch type {
        case .brush, .pen, .pencil:
            if #available(iOS 14, *) {
                return [
                    ToolTipType(name: "Round", image: UIImage(named: "roundTip")),
                    ToolTipType(name: "Arrow", image: UIImage(named: "arrowTip")),
                ]
            } else {
                return [
                    ToolTipType(name: "Round", image: UIImage(named: "roundTip"))
                ]
            }
        case .eraser, .objectEraser:
            return [
                ToolTipType(name: "Eraser", image: UIImage(named: "roundTip")),
                ToolTipType(name: "Object Eraser", image: UIImage(named: "xmarkTip"))
            ]
        default:
            return []
        }
    }
    
    init(type: ToolType) {
        self.type = type
        switch type {
        case .pen:
            self.relativePercentage = 0.5
            self.color = .white
        case .brush:
            self.relativePercentage = 0.5
            self.color = .yellow
        case .pencil:
            self.relativePercentage = 0.5
            self.color = .systemBlue
        default:
            break
        }
    }
    
    var canModify: Bool {
        return type != .lasso
    }
    
    func baseImage() -> UIImage? {
        return UIImage(named: type.rawValue + "-base")
    }
    
    func tipImage() -> UIImage? {
        return UIImage(named: type.rawValue + "-tip")
    }
}
