//
//  Functions.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 12.10.2022.
//

import Photos
import UIKit

func loadAssets() -> PHFetchResult<PHAsset> {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
    return PHAsset.fetchAssets(with: fetchOptions)
}

func getAssetImage(asset: PHAsset, size: CGSize,
                   completion: @escaping (PHAsset, UIImage?) -> Void) {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.deliveryMode = .opportunistic
    options.isSynchronous = false
    options.isNetworkAccessAllowed = true
    manager.requestImage(for: asset, targetSize: size,
                         contentMode: .aspectFill, options: options,
                         resultHandler: { result, info in
        completion(asset, result)
    })
}

func getAVAssetSync(asset: PHAsset) -> AVAsset? {
    let manager = PHImageManager.default()
    let options = PHVideoRequestOptions()
    options.isNetworkAccessAllowed = true
    var avasset: AVAsset?
    manager.requestAVAsset(forVideo: asset, options: options) { result, _, _ in
        avasset = result
    }
    return avasset
}

func getAssetImageSync(asset: PHAsset, size: CGSize? = nil) -> UIImage? {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.deliveryMode = .highQualityFormat
    options.isSynchronous = true
    options.isNetworkAccessAllowed = true
    var image: UIImage?
    manager.requestImage(for: asset, targetSize: size ?? PHImageManagerMaximumSize,
                         contentMode: .aspectFill, options: options,
                         resultHandler: { result, info in
        image = result
    })
    return image
}

func getAVAsset(asset: PHAsset, handler: @escaping (AVAsset?) -> Void) {
    let manager = PHImageManager.default()
    let options = PHVideoRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .mediumQualityFormat
    manager.requestAVAsset(forVideo: asset, options: options) { result, _, _ in
        handler(result)
    }
}

func getVideoSize(asset: AVAsset) -> CGSize? {
    guard let track = asset.tracks(withMediaType: AVMediaType.video).first else { return nil }
    let size = track.naturalSize.applying(track.preferredTransform)
    return CGSize(width: abs(size.width), height: abs(size.height))
}

func screenWidth() -> CGFloat {
    return UIScreen.main.bounds.width
}

func topHeight() -> CGFloat {
    guard let window = UIApplication.shared.windows.first else { return 0 }
    return window.safeAreaInsets.top
}

func bottomHeight() -> CGFloat {
    guard let window = UIApplication.shared.windows.first else { return 0 }
    return window.safeAreaInsets.bottom
}
