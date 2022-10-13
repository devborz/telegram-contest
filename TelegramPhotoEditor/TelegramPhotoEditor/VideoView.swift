//
//  VideoView.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 13.10.2022.
//

import UIKit
import AVKit
import Photos

class VideoView: UIView {
    
    var asset: AVAsset? {
        didSet {
            if let asset = asset {
                let item = AVPlayerItem(asset: asset)
                player = .init(playerItem: item)
                playerLooper = .init(player: player, templateItem: item)
                playerLayer.player = player
            } else {
                player = nil
                playerLooper = nil
                playerLayer.player = nil
            }
        }
    }
    
    private var playerLooper: AVPlayerLooper!
    
    private var player: AVQueuePlayer!
    
    let playerLayer: AVPlayerLayer
    
    override init(frame: CGRect = .zero) {
        playerLayer = .init()
        super.init(frame: frame)
        playerLayer.frame = .init(origin: .zero, size: frame.size)
        playerLayer.videoGravity = .resizeAspectFill
        layer.insertSublayer(playerLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
}
