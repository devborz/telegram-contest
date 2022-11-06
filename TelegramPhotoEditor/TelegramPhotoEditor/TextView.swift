//
//  TextView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 19.10.2022.
//

import UIKit

class TextView: UITextView {
    
    
    override init(frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
