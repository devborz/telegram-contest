//
//  Text.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 17.10.2022.
//

import UIKit

enum TextFilling {
    
    case normal
    case stroke
    case filled
    case semi
    
    var buttonImage: UIImage? {
        switch self {
        case .normal:
            return UIImage(named: "default")
        case .stroke:
            return UIImage(named: "stroke")
        case .filled:
            return UIImage(named: "filled")
        case .semi:
            return UIImage(named: "semi")
        }
    }
}

struct Font {
    
    var font: UIFont?
    
    var name: String
    
}
