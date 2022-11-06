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
    
    let textEditingView: TextEditingView
    
    let textsView = UIView()
    
    let contentSize: CGSize
    
    var mode: Mode = .draw {
        didSet {
            switch mode {
            case .draw:
                textEditingView.isUserInteractionEnabled = false
                textEditingView.currentTextViewContainer?.resignFirstResponder()
                textEditingView.currentTextViewContainer = nil
            case .text:
                textEditingView.isUserInteractionEnabled = true
            }
            blackFrameViews.forEach { view in
                view.isUserInteractionEnabled = mode == .text
            }
        }
    }
    
    init(frame: CGRect, media: Media, contentSize: CGSize) {
        self.media = media
        self.textEditingView = .init(frame: frame)
        self.contentSize = contentSize
        super.init(frame: frame)
        let origin = CGPoint(x: (frame.width - contentSize.width) / 2,
                             y: (frame.height - contentSize.height) / 2)
        switch media {
        case .image(let image):
            imageView = .init(image: image)
            imageView.frame = .init(origin: origin,
                                     size: contentSize)
            
            addSubview(imageView)
        case .video(let asset):
            videoView = .init()
            videoView.frame = .init(origin: origin,
                                     size: contentSize)
            videoView.asset = asset
            videoView.playerLayer.frame = .init(origin: .zero,
                                                size: contentSize)
            addSubview(videoView)
            videoView.play()
        }
        addSubview(canvasView)
        canvasView.frame = .init(origin: .zero,
                                 size: frame.size)
        addSubview(textEditingView)
        textEditingView.frame = .init(origin: .zero,
                                       size: frame.size)
        drawMask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var blackFrameViews: [UIView] = []
    
    func setDrawingTool(_ tool: Tool) {
        canvasView.currentTool = tool
    }
    
    func drawMask() {
        if contentSize.width / contentSize.height >= frame.width / frame.height {
            let topRect: CGRect = .init(x: 0,
                                        y: 0,
                                        width: frame.width,
                                        height: (frame.height - contentSize.height) / 2)
            let bottomRect: CGRect = .init(x: 0,
                                           y: frame.height - (frame.height - contentSize.height) / 2,
                                           width: frame.width,
                                           height: (frame.height - contentSize.height) / 2)
            let topView = UIView()
            topView.frame = topRect
            topView.backgroundColor = .black
            let bottomView = UIView()
            bottomView.frame = bottomRect
            bottomView.backgroundColor = .black
            blackFrameViews = [topView, bottomView]
        } else {
            let leftRect: CGRect = .init(x: 0,
                                        y: 0,
                                        width: (frame.width - contentSize.width) / 2,
                                        height: frame.height)
            let rightRect: CGRect = .init(x: frame.width - (frame.width - contentSize.width) / 2,                              y: 0,
                                           width: (frame.width - contentSize.width) / 2,
                                           height: frame.height)
            let leftView = UIView()
            leftView.frame = leftRect
            leftView.backgroundColor = .black
            let rightView = UIView()
            rightView.frame = rightRect
            rightView.backgroundColor = .black
            blackFrameViews = [leftView, rightView]
        }
        for view in blackFrameViews {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            view.addGestureRecognizer(gesture)
            view.isUserInteractionEnabled = mode == .text
            addSubview(view)
        }
    }
    
    @objc
    private func handleTap() {
        textEditingView.handleTap()
    }
    
    func play() {
        videoView?.play()
    }
    
    func pause() {
        videoView?.pause()
    }
    
}
