//
//  Extensions.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 14.10.2022.
//

import UIKit
import RxSwift

extension UIImage {
    
    func config(size: CGFloat) -> UIImage {
        return self.withConfiguration(UIImage.SymbolConfiguration.init(pointSize: size))
    }
    
    func aspectFittedToWidth(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
    
        return renderer.image { [weak self] _ in
            self?.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension PublishSubject {
    
    func bind(_ block: @escaping (Element) -> Void) -> Disposable {
        return self.subscribe { el in
            block(el)
        } onError: { error in
            
        } onCompleted: {
            
        } onDisposed: {
            
        }
    }
}
