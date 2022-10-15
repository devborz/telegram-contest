//
//  TipTypeButton.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 14.10.2022.
//

import UIKit

class TipTypeButton: UIButton {

    var currentType: Int = 0 {
        didSet {
            setType()
        }
    }
    
    var tips: [ToolTipType] = []
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        semanticContentAttribute = .forceRightToLeft
        setTitleColor(.white, for: .normal)
        setTitleColor(.gray, for: .highlighted)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setType() {
        guard currentType < tips.count else { return }
        setTitle(tips[currentType].name, for: .normal)
        setImage(tips[currentType].image?.aspectFittedToWidth(20),
                 for: .normal)
    }

}
