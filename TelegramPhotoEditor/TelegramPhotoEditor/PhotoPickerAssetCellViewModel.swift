//
//  PhotoPickerAssetCellViewModel.swift
//  PhotoPicker
//
//  Created by Усман Туркаев on 01.09.2022.
//

import Foundation
import Photos

class PhotoPickerAssetCellViewModel: Hashable, Equatable {
    
    static func == (lhs: PhotoPickerAssetCellViewModel, rhs: PhotoPickerAssetCellViewModel) -> Bool {
        return lhs.asset.localIdentifier == rhs.asset.localIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.localIdentifier)
    }
    
    var asset: PHAsset
    
    init(asset: PHAsset) {
        self.asset = asset
    }
}
