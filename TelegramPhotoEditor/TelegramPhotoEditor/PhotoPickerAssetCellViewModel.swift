//
//  PhotoPickerAssetCellViewModel.swift
//  PhotoPicker
//
//  Created by Усман Туркаев on 01.09.2022.
//

import Foundation
import Photos
import UIKit

enum Media {
    case image(UIImage), video(URL)
}

protocol PhotoPickerAssetCellViewModelDelegate: AnyObject {
    
    func update()
    
}

class PhotoPickerAssetCellViewModel: Hashable, Equatable {
    
    weak var delegate: PhotoPickerAssetCellViewModelDelegate?
    
    static func == (lhs: PhotoPickerAssetCellViewModel, rhs: PhotoPickerAssetCellViewModel) -> Bool {
        return lhs.asset.localIdentifier == rhs.asset.localIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.localIdentifier)
    }
    
    var asset: PHAsset
    
    var modifiedMedia: Media? {
        didSet {
            delegate?.update()
        }
    }
    
    init(asset: PHAsset) {
        self.asset = asset
    }
}
