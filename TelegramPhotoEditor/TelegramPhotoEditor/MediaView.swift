//
//  MediaView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit
import Photos
import AVKit

class MediaView: UIView {
    
    enum Media {
        case image(UIImage)
        case video(AVAsset)
    }
    
    var media: Media

    var imageView: UIImageView!
    
    var videoView: VideoView!
    
    let canvasView = CanvasView()
    
    init(frame: CGRect, media: Media) {
        self.media = media
        super.init(frame: frame)
        switch media {
        case .image(let image):
            imageView = .init(image: image)
            imageView.frame = .init(origin: .zero,
                                     size: frame.size)
            addSubview(imageView)
        case .video(let asset):
            videoView = .init()
            videoView.frame = .init(origin: .zero,
                                     size: frame.size)
            videoView.asset = asset
            videoView.playerLayer.frame = .init(origin: .zero,
                                                size: frame.size)
            addSubview(videoView)
            videoView.play()
        }
        
        addSubview(canvasView)
        canvasView.frame = .init(origin: .zero,
                                 size: frame.size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        videoView?.play()
    }
    
    func pause() {
        videoView?.pause()
    }
    
}
