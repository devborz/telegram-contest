//
//  StickerView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 22.10.2022.
//

import UIKit

protocol Sticker: AnyObject {
    
    func hideMenu()
    
    var transforming: Bool { get set }

}
