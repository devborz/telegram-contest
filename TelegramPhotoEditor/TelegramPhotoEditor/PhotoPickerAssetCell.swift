//
//  PhotoPickerAssetCell.swift
//  PhotoPicker
//
//  Created by Усман Туркаев on 31.08.2022.
//

import UIKit
import Photos

class PhotoPickerAssetCell: UICollectionViewCell {
    
    @IBOutlet weak var assetImageView: UIImageView!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    var viewModel: PhotoPickerAssetCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        assetImageView.contentMode = .scaleAspectFill
        durationLabel.layer.shadowColor = UIColor.black.cgColor
        durationLabel.layer.shadowOpacity = 0.3
        durationLabel.layer.shadowRadius = 5
        durationLabel.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
        self.assetImageView.image = nil
    }
    
    func setup(viewModel: PhotoPickerAssetCellViewModel) {
        self.viewModel = viewModel
        let scale = UIScreen.main.scale
        let size = CGSize(width: bounds.size.width * scale,
                          height: bounds.size.height * scale)
        getAssetImage(asset: viewModel.asset,
                      size: size) { [weak self] requestAsset, image in
            DispatchQueue.main.async {
                if self?.viewModel.asset == requestAsset, let image = image {
                    self?.assetImageView.image = image
                }
            }
        }
        
        if viewModel.asset.mediaType == .video {
            durationLabel.text = viewModel.asset.duration.format()
        } else {
            durationLabel.text = ""
        }
    }
}

extension TimeInterval {
    func format() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        if self >= 3600 {
            formatter.allowedUnits = [.second, .minute, .hour]
        } else {
            formatter.allowedUnits = [.second, .minute]
        }
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self)
    }
}

