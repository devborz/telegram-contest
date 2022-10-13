//
//  Tool.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit
import PencilKit

enum ToolType: String {
    case brush
    case neon
    case pen
    case pencil
    case eraser
    case objectEraser
    case blurEraser
    case lasso
}

class Tool {
    
    var type: ToolType
    
    var width: CGFloat
    
    var color: UIColor = .clear
    
    var needTip: Bool {
        switch type {
        case .blurEraser, .eraser, .objectEraser, .lasso:
            return false
        default:
            return true
        }
    }
    
    init(type: ToolType, width: CGFloat) {
        self.type = type
        self.width = width
        switch type {
        case .pen:
            self.color = .white
        case .brush:
            self.color = .yellow
        case .neon:
            self.color = .systemGreen
        case .pencil:
            self.color = .systemBlue
        default:
            break
        }
    }
    
    func baseImage() -> UIImage? {
        return UIImage(named: type.rawValue + "-base")
    }
    
    func tipImage() -> UIImage? {
        return UIImage(named: type.rawValue + "-tip")
    }
}
