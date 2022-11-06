//
//  PhotoEditorViewController.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 12.10.2022.
//

import UIKit
import Photos
import Lottie
import PencilKit

enum Mode {
    case draw, text
}

class PhotoEditorViewController: UIViewController {
    
    enum Change {
        case drawing(PKDrawing)
        case text(TextViewContainer)
    }
    
    var bottomSegment: SegmentSliderView!
    
    var asset: PHAsset!
    
    let cancelButton = UIButton()
    
    let backButton = UIButton()
    
    let downloadButton = UIButton()
    
    let addButton = UIButton()
    
    let undoButton = UIButton()
    
    let clearAllButton = UIButton()
    
    let zoomOutButton = UIButton()
    
    let topView = UIView()
    
    let scrollView = UIScrollView()
    
    let topBlurView = BlurGradientView(position: .bottom)
    
    let bottomBlurView = BlurGradientView(position: .top)
    
    var toolPicker = ToolPickerView()
    
    let tipTypeButton = TipTypeButton()
    
    var mediaView: MediaView! {
        didSet {
            guard let mediaView else { return }
            mediaView.mode = self.currentMode
            mediaView.canvasView.delegate = self
            mediaView.textEditingView.textEditBar.delegate = self
            mediaView.textEditingView.delegate = self
            changes.append(.drawing(mediaView.canvasView.currentDrawingCopy()))
        }
    }
    
    let backToCancelAnimation = LottieAnimationView(name: "backToCancel")
     
    let addButtonBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    
    var fontSlider = Slider(frame: .zero)
    
    let colorButton = ColorButton()
    
    let textEditBar = TextEditBarView()
    
    let textDoneButton = UIButton()
    
    let textCancelButton = UIButton()
    
    var fontSliderLeftConstraint: NSLayoutConstraint!
    
    var fontSliderCenterConstraint: NSLayoutConstraint!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var hasChanges: Bool {
        if changes.count == 1,
           case .drawing(_) = changes.first {
            return false
        } else if changes.count == 0 {
            return false
        }
        return true
    }
    
    var currentMode: Mode = .draw {
        didSet {
            if currentMode != oldValue {
                setMode()
            }
        }
    }
    
    var changes: [Change] = [] {
        didSet {
            clearAllButton.isEnabled = hasChanges
            undoButton.isEnabled = hasChanges
            downloadButton.isEnabled = hasChanges
        }
    }
    
    private var didFirstLayout = false

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        configViews()
        layout()
        setupMediaViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didFirstLayout {
            didFirstLayout = true
            bottomSegment.setupBackground()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:  UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openAndCloseActivity), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openAndCloseActivity), name: UIApplication.didBecomeActiveNotification, object: nil)
        mediaView?.play()
    }
    
    @objc
    func openAndCloseActivity(_ notification: Notification)  {
        if notification.name == UIApplication.didBecomeActiveNotification {
            mediaView?.play()
        } else {
            mediaView?.pause()
        }
    }
    
    func configViews() {
    
        topBlurView.blurRadius = 5
        topBlurView.colorTint = .clear

        bottomBlurView.blurRadius = 5
        bottomBlurView.colorTint = .clear
        
        bottomSegment = .init(["Draw", "Text"])
        bottomSegment.delegate = self
        
        cancelButton.setImage(UIImage(named: "cancel")?.aspectFittedToWidth(33), for: .normal)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped),
                               for: .touchUpInside)
        
        backButton.setImage(UIImage(named: "back")?.aspectFittedToWidth(33), for: .normal)
        
        backButton.addTarget(self, action: #selector(backButtonTapped),
                               for: .touchUpInside)
        
        downloadButton.setImage(UIImage(named: "download"), for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped),
                               for: .touchUpInside)
        downloadButton.isEnabled = false
        
        undoButton.setImage(UIImage(named: "undo"), for: .normal)
        undoButton.addTarget(self, action: #selector(undoButtonTapped),
                             for: .touchUpInside)
        undoButton.isEnabled = false
   
        clearAllButton.setTitle("Clear All", for: .normal)
        clearAllButton.setTitleColor(.white, for: .normal)
        clearAllButton.setTitleColor(.lightText, for: .disabled)
        clearAllButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        clearAllButton.addTarget(self, action: #selector(clearAllButtonTapped),
                                 for: .touchUpInside)
        clearAllButton.isEnabled = false
        
        addButton.setImage(UIImage(named: "add")?.aspectFittedToWidth(32), for: .normal)
        addButtonBlurView.layer.cornerRadius = 16
        addButtonBlurView.clipsToBounds = true
        
        if #available(iOS 14, *) {
            let shapeRectangleAction = UIAction(title: "Rectangle",
                                                image: UIImage(named: "shapeRectangle")) { [weak self] _ in
                self?.handleAddShape("Rectangle")
            }
            let shapeEllipseAction = UIAction(title: "Ellipse",
                                              image: UIImage(named: "shapeEllipse")) { [weak self] _ in
                self?.handleAddShape("Ellipse")
            }
            let shapeBubbleAction = UIAction(title: "Bubble",
                                             image: UIImage(named: "shapeBubble")) { [weak self] _ in
                self?.handleAddShape("Bubble")
            }
            let shapeStarAction = UIAction(title: "Star",
                                           image: UIImage(named: "shapeStar")) { [weak self] _ in
                self?.handleAddShape("Star")
            }
            let shapeArrowAction = UIAction(title: "Arrow",
                                            image: UIImage(named: "shapeArrow")) { [weak self] _ in
                self?.handleAddShape("Arrow")
            }
           let menu = UIMenu(children: [
                shapeArrowAction,
                shapeStarAction,
                shapeBubbleAction,
                shapeEllipseAction,
                shapeRectangleAction,
            ])
            addButton.menu = menu
            addButton.showsMenuAsPrimaryAction = true

        } else {
            addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        }
        
        zoomOutButton.setTitle("Zoom Out", for: .normal)
        zoomOutButton.setImage(UIImage(named: "zoomOut"), for: .normal)
        zoomOutButton.setTitleColor(.white, for: .normal)
        zoomOutButton.addTarget(self, action: #selector(zoomOutButtonTapped),
                                for: .touchUpInside)
        zoomOutButton.setTitleColor(.gray, for: .highlighted)
        zoomOutButton.isHidden = true
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = .black
        scrollView.keyboardDismissMode = .interactive
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
    
        toolPicker.delegate = self
        
        tipTypeButton.alpha = 0
        if #available(iOS 14, *) {

        } else {
            tipTypeButton.addTarget(self, action: #selector(tipTypeButtonTapped),
                                    for: .touchUpInside)
        }
        
        textEditBar.delegate = self
        textEditBar.isHidden = true
        
        colorButton.tapHandler = colorButtonTapped
        
        textDoneButton.setTitle("Done", for: .normal)
        textDoneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        textCancelButton.setTitle("Cancel", for: .normal)
        textDoneButton.addTarget(self, action: #selector(textDoneButtonTapped),
                                 for: .touchUpInside)
        
        
        fontSlider.alpha = 0
        fontSlider.delegate = self
    }
    
    func layout() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        bottomBlurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBlurView)
        bottomBlurView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomBlurView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        backToCancelAnimation.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backToCancelAnimation)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                            constant: -10).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor,
                                           constant: 10).isActive = true
        
        backToCancelAnimation.heightAnchor.constraint(equalToConstant: 33).isActive = true
        backToCancelAnimation.widthAnchor.constraint(equalToConstant: 33).isActive = true
        backToCancelAnimation.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor).isActive = true
        backToCancelAnimation.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
        backToCancelAnimation.isHidden = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        backButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                            constant: -10).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor,
                                           constant: 10).isActive = true
        backButton.isHidden = true
        
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(downloadButton)
        downloadButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        downloadButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,                                 constant: -10).isActive = true
        downloadButton.rightAnchor.constraint(equalTo: view.rightAnchor,
                                          constant: -10).isActive = true
        
        bottomSegment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomSegment)
        bottomSegment.heightAnchor.constraint(equalToConstant: 36).isActive = true
        bottomSegment.leftAnchor.constraint(equalTo: view.leftAnchor,
                                            constant: 60).isActive = true
        bottomSegment.rightAnchor.constraint(equalTo: view.rightAnchor,
                                             constant: -60).isActive = true
        bottomSegment.topAnchor.constraint(equalTo: bottomBlurView.topAnchor,
                                           constant: 1).isActive = true
        bottomSegment.centerYAnchor
            .constraint(equalTo: downloadButton.centerYAnchor).isActive = true
        
        toolPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolPicker)
        toolPicker.heightAnchor.constraint(equalToConstant: 90).isActive = true
        toolPicker.leftAnchor.constraint(equalTo: view.leftAnchor,
                                         constant: 70).isActive = true
        toolPicker.rightAnchor.constraint(equalTo: view.rightAnchor,
                                          constant: -70).isActive = true
        toolPicker.bottomAnchor.constraint(equalTo: bottomSegment.topAnchor,
                                           constant: -5).isActive = true
        
        topBlurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBlurView)
        topBlurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topBlurView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topBlurView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        topView.bottomAnchor.constraint(equalTo: topBlurView.bottomAnchor).isActive = true
        
        textDoneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textDoneButton)
        textDoneButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textDoneButton.rightAnchor.constraint(equalTo: view.rightAnchor,
                                              constant: -10).isActive = true
        textDoneButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textDoneButton.alpha = 0
        
        textCancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textCancelButton)
        textCancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textCancelButton.leftAnchor.constraint(equalTo: view.leftAnchor,
                                               constant: 10).isActive = true
        textCancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textCancelButton.alpha = 0
        
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(undoButton)
        undoButton.topAnchor.constraint(equalTo: topView.topAnchor,
                                        constant: 10).isActive = true
        undoButton.leftAnchor.constraint(equalTo: topView.leftAnchor,
                                         constant: 10).isActive = true
        undoButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor,
                                           constant: -10).isActive = true
        
        clearAllButton.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(clearAllButton)
        clearAllButton.topAnchor.constraint(equalTo: topView.topAnchor,
                                            constant: 10).isActive = true
        clearAllButton.rightAnchor.constraint(equalTo: topView.rightAnchor,
                                              constant: -10).isActive = true
        clearAllButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor,
                                               constant: -10).isActive = true
        
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(zoomOutButton)
        zoomOutButton.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        zoomOutButton.topAnchor.constraint(equalTo: topView.topAnchor,
                                           constant: 10).isActive = true
        zoomOutButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor,
                                              constant: -10).isActive = true
        
        addButtonBlurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButtonBlurView)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.centerXAnchor.constraint(equalTo: downloadButton.centerXAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: downloadButton.topAnchor,
                                          constant: -10).isActive = true
        addButtonBlurView.topAnchor.constraint(equalTo: addButton.topAnchor,
                                               constant: 4).isActive = true
        addButtonBlurView.leftAnchor.constraint(equalTo: addButton.leftAnchor,
                                                constant: 4).isActive = true
        addButtonBlurView.rightAnchor.constraint(equalTo: addButton.rightAnchor,
                                                 constant: -4).isActive = true
        addButtonBlurView.bottomAnchor.constraint(equalTo: addButton.bottomAnchor,
                                                  constant: -4).isActive = true
        
        tipTypeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tipTypeButton)
        tipTypeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tipTypeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        tipTypeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,                                 constant: -10).isActive = true
        tipTypeButton.rightAnchor.constraint(equalTo: view.rightAnchor,
                                          constant: -10).isActive = true
        
        
        colorButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorButton)
        colorButton.leftAnchor.constraint(equalTo: view.leftAnchor,
                                             constant: 10).isActive = true
        colorButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                            constant: -60).isActive = true
        
        textEditBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textEditBar)
        textEditBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        textEditBar.leftAnchor.constraint(equalTo: colorButton.rightAnchor,
                                          constant: 10).isActive = true
        textEditBar.rightAnchor.constraint(equalTo: addButton.leftAnchor,
                                          constant: -10).isActive = true
        textEditBar.centerYAnchor.constraint(equalTo: colorButton.centerYAnchor).isActive = true
        
        fontSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fontSlider)
        fontSliderCenterConstraint = fontSlider.centerYAnchor.constraint(equalTo: view.topAnchor)
        fontSliderCenterConstraint.constant = view.bounds.height / 2
        fontSliderCenterConstraint.isActive = true
        fontSliderLeftConstraint = fontSlider.leftAnchor.constraint(equalTo: view.leftAnchor,
                                                                      constant: -20)
        fontSliderLeftConstraint.isActive = true
        fontSlider.widthAnchor.constraint(equalToConstant: 40).isActive = true
        fontSlider.heightAnchor.constraint(equalTo: view.heightAnchor,
                                            multiplier: 0.35).isActive = true
    }
    
    @objc
    func textDoneButtonTapped() {
        mediaView?.textEditingView.handleTap()
    }
    
    @objc
    func textCancelButtoNTapped() {
        switch asset.mediaType {
        case .video:
            break
        case .image:
            break
        default:
            break
        }
    }
    
    func setupMediaViews() {
        guard let asset = asset else { return }
        switch asset.mediaType {
        case .image:
            setupImageView()
        case .video:
            setupVideo()
        default:
            break
        }
    }
    
    func setupImageView() {
        guard let image = getAssetImageSync(asset: asset) else { return }
        let size = image.size
        let scale = getScale(size)
        let scaledSize = CGSize(width: size.width * scale,
                                height: size.height * scale)
        mediaView = .init(frame: .init(origin: .zero, size: view.frame.size),
                          media: .image(image), contentSize: scaledSize)
        scrollView.addSubview(mediaView)
        scrollView.contentSize = view.frame.size
        
        centerMediaView()
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        scrollView.maximumZoomScale = 5
        mediaView.setDrawingTool(toolPicker.currentTool)
    }
    
    var videoSize: CGSize?
    
    var videoAsset: AVAsset?
    
    func setupVideo() {
        getAVAsset(asset: asset) { [weak self] avasset in
            DispatchQueue.main.async {
                guard let strongSelf = self,
                      let avasset = avasset,
                      let size = getVideoSize(asset: avasset) else { return }
                strongSelf.videoSize = size
                strongSelf.videoAsset = avasset
                let scale = strongSelf.getScale(size)
                let scaledSize = CGSize(width: size.width * scale,
                                        height: size.height * scale)
                strongSelf.mediaView = .init(frame: .init(origin: .zero,
                                                          size: strongSelf.view.frame.size),
                                             media: .video(avasset),
                                             contentSize: scaledSize)
                
                strongSelf.scrollView.addSubview(strongSelf.mediaView)
                strongSelf.scrollView.contentSize = strongSelf.view.frame.size
                
                strongSelf.centerMediaView()
                strongSelf.scrollView.minimumZoomScale = 1
                strongSelf.scrollView.zoomScale = 1
                strongSelf.scrollView.maximumZoomScale = 5
                strongSelf.mediaView.setDrawingTool(strongSelf.toolPicker.currentTool)
                strongSelf.mediaView.play()
            }
        }
    }
    
    func getScale(_ size: CGSize) -> CGFloat {
        let heightScale = scrollView.bounds.size.height / size.height
        let widthScale = scrollView.bounds.size.width / size.width
        let minScale = min(heightScale, widthScale)
        return minScale
    }
    
    func setZoomScale(_ size: CGSize) {
        let heightScale = scrollView.bounds.size.height / size.height
        let widthScale = scrollView.bounds.size.width / size.width
        let minScale = min(heightScale, widthScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4
    }
    
    func centerMediaView() {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * CGFloat(0.5), CGFloat(0.0))
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
    
    @objc
    func downloadButtonTapped() {
        guard let mediaView = mediaView else { return }
        let rect = CGRect(origin: .zero, size: mediaView.canvasView.canvasView.frame.size)
        let picture = mediaView.canvasView.takeScreenshot()
        let text = mediaView.textEditingView.takeScreenshot()
        switch asset.mediaType {
        case .image:
            guard let image = mediaView.imageView.image else { return }
            let imageSize = image.size
            let contentLayer = CALayer()
            contentLayer.frame = .init(origin: .zero, size: imageSize)
            contentLayer.contents = image.cgImage
            contentLayer.contentsGravity = .resizeAspectFill
            let paintLayer: CALayer = CALayer()
            paintLayer.frame = .init(origin: .zero, size: imageSize)
            paintLayer.contentsGravity = .resizeAspectFill
            let paintImage = picture
            paintLayer.contents = paintImage.cgImage
            let textLayer = CALayer()
            textLayer.frame = .init(origin: .zero, size: imageSize)
            let textImage = text
            textLayer.contents = textImage.cgImage
            textLayer.contentsGravity = .resizeAspectFill
            
            let outputLayer = CALayer()
            outputLayer.frame = CGRect(origin: .zero, size: imageSize)
            outputLayer.addSublayer(contentLayer)
            outputLayer.addSublayer(paintLayer)
            outputLayer.addSublayer(textLayer)
            
            let result = outputLayer.renderImage()
//            return result
            print()
        default:
            guard let asset = videoAsset as? AVURLAsset, let videoSize else { return }
            let composition = AVMutableComposition()
            guard
              let compositionTrack = composition.addMutableTrack(
                withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let assetTrack = asset.tracks(withMediaType: .video).first
              else {
                print("Something is wrong with the asset.")
                return
            }

            do {
              let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
              try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
              
              if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
                let compositionAudioTrack = composition.addMutableTrack(
                  withMediaType: .audio,
                  preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                  timeRange,
                  of: audioAssetTrack,
                  at: .zero)
              }
            } catch {
              print(error)
              return
            }
            
            compositionTrack.preferredTransform = assetTrack.preferredTransform
            
            let videoFrame = CGRect(origin: .zero, size: videoSize)
            let videoLayer = CALayer()
            var videoLayerFrame = videoFrame
            videoLayerFrame.origin.y = videoSize.height - videoLayerFrame.origin.y - videoLayerFrame.height
            
            videoLayer.frame = videoLayerFrame
            videoLayer.masksToBounds = true
            
            let paintLayer: CALayer = CALayer()
            paintLayer.frame = .init(origin: .zero, size: videoSize)
            paintLayer.contentsGravity = .resizeAspectFill
            let paintImage = picture
            paintLayer.contents = paintImage.cgImage
            
            let textLayer = CALayer()
            textLayer.frame = .init(origin: .zero, size: videoSize)
            let textImage = text
            textLayer.contents = textImage.cgImage
            textLayer.contentsGravity = .resizeAspectFill
            
            let outputLayer = CALayer()
            outputLayer.frame = CGRect(origin: .zero, size: videoSize)
            outputLayer.addSublayer(videoLayer)
            outputLayer.addSublayer(paintLayer)
            outputLayer.addSublayer(textLayer)
            
            let videoComposition = AVMutableVideoComposition()
            let isPortrait = isPortrait(from: assetTrack.preferredTransform)
            let renderSize: CGSize
            
            if isPortrait {
              renderSize = CGSize(
                width: assetTrack.naturalSize.height,
                height: assetTrack.naturalSize.width)
            } else {
              renderSize = assetTrack.naturalSize
            }
            
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
              postProcessingAsVideoLayer: videoLayer,
              in: outputLayer)

            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(
              start: .zero,
              duration: composition.duration)
            videoComposition.instructions = [instruction]
            let layerInstruction = compositionLayerInstruction(
                for: compositionTrack,
                assetTrack: assetTrack)
            
            var ptr = assetTrack.preferredTransform
            
            let yScale = videoSize.height / renderSize.height
            let xScale = videoSize.width / renderSize.width
            
            ptr.tx = ptr.tx == 0 ? 0 : renderSize.width
            ptr.ty = ptr.ty == 0 ? 0 : renderSize.height
            
            let bugFixTransform = ptr.concatenating(.init(scaleX: xScale,
                                                          y: yScale))
            
            layerInstruction.setTransform(bugFixTransform, at: .zero)
            
            instruction.layerInstructions = [layerInstruction]

            guard let export = AVAssetExportSession(
              asset: composition,
              presetName: AVAssetExportPreset1280x720)
              else {
                print("Cannot create export session.")
                return
            }
            
            let videoName = UUID().uuidString
            var exportURL: URL = URL(fileURLWithPath: NSTemporaryDirectory())
              .appendingPathComponent(videoName)
              .appendingPathExtension("mov")
            export.videoComposition = videoComposition
            export.outputFileType = .mov
            export.outputURL = exportURL


            export.exportAsynchronously { [weak self] in
              DispatchQueue.main.async {
                switch export.status {
                case .completed:
                    break
                default:
                  print("Something went wrong during export.")
                  print(export.error ?? "unknown error")
                  break
                }
              }
            }
        }
    }
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
//        let transform = assetTrack.preferredTransform
//        instruction.setTransform(transform, at: .zero)

        return instruction
    }
    
    private func isPortrait(from transform: CGAffineTransform) -> Bool {
        if transform.a == 0 && abs(transform.b) == 1.0 && abs(transform.c) == 1.0 && transform.d == 0 {
            return true
        }
        return false
    }
    
    @objc
    func cancelButtonTapped() {
        if hasChanges {
            let message = "If you go back now, you will lose any changes that you've made."
            let alertController = UIAlertController(title: "Discard media?",
                                                    message: message, preferredStyle: .alert)
            let discardAction = UIAlertAction(title: "Discard",
                                              style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(discardAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    var shouldSaveNextCanvasChange = true
    
    @objc
    func undoButtonTapped() {
        guard hasChanges, let mediaView,
              let lastChange = changes.popLast() else { return }
        switch lastChange {
        case .text(let textView):
            mediaView.textEditingView.removeTextView(textView)
        case .drawing:
            if let drawingBeforeIndex = changes.lastIndex(where: { value in
                if case .drawing = value {
                    return true
                }
                return false
            }), case let .drawing(drawingBefore) = changes[drawingBeforeIndex] {
                removedChangeIndex = drawingBeforeIndex
                changes.remove(at: drawingBeforeIndex)
                mediaView.canvasView.lastChangeDoneProgrammaticaly = true
                mediaView.canvasView.undo(drawingBefore)
            }
        }
    }
    
    var removedChangeIndex: Int?
    
    @objc
    func clearAllButtonTapped() {
        guard hasChanges, let mediaView else { return }
        changes = []
        mediaView.canvasView.clearAll()
        mediaView.textEditingView.clearAll()
    }
    
    @objc
    func addButtonTapped() {
        let menu = Menu([
            .init(title: "Rectangle", image: UIImage(named: "shapeRectangle")) { [weak self] _ in
                self?.handleAddShape("Rectangle")
            },
            .init(title: "Ellipse", image: UIImage(named: "shapeEllipse")) { [weak self] _ in
                self?.handleAddShape("Ellipse")
            },
            .init(title: "Bubble", image: UIImage(named: "shapeBubble")) { [weak self] _ in
                self?.handleAddShape("Bubble")
            },
            .init(title: "Star", image: UIImage(named: "shapeStar")) { [weak self] _ in
                self?.handleAddShape("Star")
            },
            .init(title: "Arrow", image: UIImage(named: "shapeArrow")) { [weak self] _ in
                self?.handleAddShape("Arrow")
            }
        ])
        menu.frame.origin.x = addButton.frame.maxX - 150
        menu.frame.origin.y = addButton.frame.origin.y - 10 - menu.frame.height
        let vc = MenuViewController(menu: menu)
        present(vc, animated: false)
    }
    
    @objc
    func tipTypeButtonTapped() {
        let tool = toolPicker.currentTool
        let tips: [ToolTipType] = tool.getTipTypes()
        var actions: [Menu.Action] = []
        for i in 0..<tips.count {
            actions.append(Menu.Action(title: tips[i].name,
                                  image: tips[i].image) { [weak self] _ in
                tool.tipTypeIndex = i
                self?.tipTypeButton.setTitle(tips[i].name, for: .normal)
                self?.tipTypeButton.setImage(tips[i].image, for: .normal)
            })
        }
        let menu = Menu(actions)
        let vc = MenuViewController(menu: menu)
        menu.frame.origin.x = tipTypeButton.frame.maxX - 150
        menu.frame.origin.y = tipTypeButton.frame.origin.y - 10 - menu.frame.height
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: false)
    }
    
    @objc
    func zoomOutButtonTapped() {
        scrollView.setZoomScale(scrollView.minimumZoomScale,
                                animated: true)
    }
    
    @objc
    func colorButtonTapped() {
        let currentTool = toolPicker.currentTool
        switch currentTool.type {
        case .brush, .pencil, .pen:
            break
        default:
            return
        }
        if #available(iOS 14, *) {
            let vc = UIColorPickerViewController()
            vc.selectedColor = currentTool.color
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    func setMode() {
        switch currentMode {
        case .draw:
            scrollView.pinchGestureRecognizer?.isEnabled = true
            textEditBar.isHidden = true
            toolPicker.isHidden = false
            scrollView.isScrollEnabled = true
        case .text:
            textEditBar.isHidden = false
            toolPicker.isHidden = true
            scrollView.zoomScale = 1
            scrollView.pinchGestureRecognizer?.isEnabled = false
            mediaView?.textEditingView.createNewTextView()
        }
        mediaView?.mode = currentMode
    }
    
    func handleAddShape(_ shapeName: String) {
        
    }
    
    func setButtonsState() {
        undoButton.isEnabled = hasChanges
        clearAllButton.isEnabled = hasChanges
        downloadButton.isEnabled = hasChanges
    }
    
}

extension PhotoEditorViewController: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard mediaView?.mode == .draw else { return }
        centerMediaView()
        zoomOutButton.isHidden = scrollView.zoomScale <= scrollView.minimumZoomScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentMode == .draw ? mediaView : nil
    }

}

extension PhotoEditorViewController: SegmentControlDelegate {
    
    func didChangeToolWidth(_ control: SegmentSliderView, percentage: CGFloat) {
        mediaView?.canvasView.currentTool?.relativePercentage = percentage
        mediaView?.canvasView.setBrush()
    }

    func didSelectSegment(_ control: SegmentSliderView, segmentIndex: Int) {
        currentMode = segmentIndex == 0 ? .draw : .text
    }
    
}

extension PhotoEditorViewController: ToolPickerViewDelegate {
    func didStartModifyingTool(_ pickerView: ToolPickerView, tool: Tool) {
        cancelButton.isHidden = true
        backToCancelAnimation.currentFrame = 30
        prepareTipTypeButton(tool)
        DispatchQueue.main.async {
            self.backToCancelAnimation.isHidden = false
            self.backToCancelAnimation.play(fromFrame: 30, toFrame: 59,
                                            loopMode: .none) { [weak self] completed in
                guard let strongSelf = self else { return }
                strongSelf.backButton.isHidden = false
                strongSelf.backToCancelAnimation.isHidden = true
                strongSelf.backToCancelAnimation.currentFrame = 0
            }
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
                self.addButtonBlurView.transform = .identity.scaledBy(x: 0.01, y: 0.01)
                self.addButton.transform = .identity.scaledBy(x: 0.01, y: 0.01)
                self.colorButton.transform = .identity.scaledBy(x: 0.01, y: 0.01)
                self.downloadButton.transform = .identity
                    .translatedBy(x: 10, y: 0)
                    .scaledBy(x: 0.01, y: 0.01)
                let tips = tool.getTipTypes()
                if tips.count <= 1 {
                    self.tipTypeButton.alpha = 0
                } else {
                    self.tipTypeButton.alpha = 1
                }
            }
            if let percentage = tool.relativePercentage {
                self.bottomSegment.makeSlider(percentage: percentage)
            } else {
                UIView.animate(withDuration: 0.2, delay: 0.0) {
                    self.bottomSegment.alpha = 0
                }
            }
        }
    }
    
    @objc
    func backButtonTapped() {
        backButton.isHidden = true
        DispatchQueue.main.async {
            self.bottomSegment.makeSegment()
            self.backToCancelAnimation.isHidden = false
            self.backToCancelAnimation.play(fromFrame: 0, toFrame: 30,
                                            loopMode: .none) { [weak self] completed in
                guard let strongSelf = self else { return }
                strongSelf.cancelButton.isHidden = false
                strongSelf.backToCancelAnimation.isHidden = true
                strongSelf.backToCancelAnimation.currentFrame = 30
            }
            self.toolPicker.state = .normal
            if let _ = self.toolPicker.currentTool.relativePercentage {
            } else {
                UIView.animate(withDuration: 0.2, delay: 0.0) {
                    self.bottomSegment.alpha = 1
                }
            }
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
                self.addButtonBlurView.transform = .identity
                self.addButton.transform = .identity
                self.colorButton.transform = .identity
                self.downloadButton.transform = .identity
                self.tipTypeButton.alpha = 0
            }
        }
    }
    
    func prepareTipTypeButton(_ tool: Tool) {
        let tips: [ToolTipType] = tool.getTipTypes()
        guard let currentTipIndex = tool.tipTypeIndex else {
            return 
        }
        if #available(iOS 14, *) {
            var actions: [UIAction] = []
            for i in 0..<tips.count {
                actions.append(UIAction(title: tips[i].name,
                                        image: tips[i].image) { [weak self] _ in
                    tool.tipTypeIndex = i
                    self?.tipTypeButton.setTitle(tips[i].name, for: .normal)
                    self?.tipTypeButton.setImage(tips[i].image, for: .normal)
                })
            }
            self.tipTypeButton.menu = UIMenu(children: actions.reversed())
            self.tipTypeButton.showsMenuAsPrimaryAction = true
        }
        tipTypeButton.setTitle(tips[currentTipIndex].name, for: .normal)
        tipTypeButton.setImage(tips[currentTipIndex].image, for: .normal)
    }
    
    func didChangeTool(_ pickerView: ToolPickerView, tool: Tool) {
        colorButton.color = tool.color
        mediaView?.setDrawingTool(tool)
    }
    
}

extension PhotoEditorViewController: UIColorPickerViewControllerDelegate {
    
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController,
                                   didSelect color: UIColor, continuously: Bool) {
        toolPicker.currentTool.color = color
        colorButton.color = color
        mediaView?.canvasView.setBrush()
    }

}

extension PhotoEditorViewController: TextEditBarViewDelegate {
    func didSelectAlignment(_ view: TextEditBarView, alignment: NSTextAlignment) {
        if view == self.textEditBar {
            mediaView?.textEditingView.textEditBar.alignment = alignment
        } else {
            textEditBar.alignment = alignment
        }
        mediaView?.textEditingView.currentTextViewContainer?.alignment = alignment
    }
    
    func didSelectFilling(_ view: TextEditBarView, filling: TextFilling) {
        if view == self.textEditBar {
            mediaView?.textEditingView.textEditBar.filling = filling
        } else {
            textEditBar.filling = filling
        }
        mediaView?.textEditingView.currentTextViewContainer?.filling = filling
    }
    
    func didSelectFont(_ view: TextEditBarView, font: Font, index: Int) {
        if view == self.textEditBar {
            mediaView?.textEditingView.textEditBar.setCurrentFont(index, scrolls: true)
        } else {
            textEditBar.setCurrentFont(index, scrolls: true)
        }
        mediaView?.textEditingView.currentTextViewContainer?.setFont(font)
    }
    
}

extension PhotoEditorViewController: CanvasViewDelegate {
    
    func canvasViewDrawingDidChange(_ canvasView: CanvasView, drawing: PKDrawing) {
        if let removedChangeIndex {
            changes.insert(.drawing(drawing), at: removedChangeIndex)
            self.removedChangeIndex = nil
        } else {
            changes.append(.drawing(drawing))
        }
    }
    
}

extension PhotoEditorViewController: TextEditingViewDelegate {
    
    func textViewAdded(_ editView: TextEditingView, textView: TextViewContainer) {
        changes.append(.text(textView))
    }
    
    func textViewRemoved(_ editView: TextEditingView, textView: TextViewContainer) {
        for i in 0..<changes.count {
            if case let .text(_textView) = changes[i],
                _textView == textView {
                changes.remove(at: i)
                return
            }
        }
    }
    
    func textViewSelected(_ editView: TextEditingView, textView: TextViewContainer?) {
        if let textView {
            textEditBar.isHidden = false
            textEditBar.filling = textView.filling
            textEditBar.alignment = textView.alignment
            editView.textEditBar.filling = textView.filling
            editView.textEditBar.alignment = textView.alignment
            guard let index = textEditBar.fonts.firstIndex(where: { value in
                return value.name == textView.font.name
            }) else { return }
            textEditBar.setCurrentFont(index, scrolls: true)
            editView.textEditBar.setCurrentFont(index, scrolls: true)
        } else {
            textEditBar.isHidden = true
        }
    }
    
    func didShowKeyboard(_ editView: TextEditingView, keyboardHeight: CGFloat) {
        guard let statusBarHeight = view
            .window?
            .windowScene?
            .statusBarManager?.statusBarFrame.height else { return }
        scrollView.contentOffset.y = -statusBarHeight + keyboardHeight / 2
        topView.alpha = 0
        topBlurView.alpha = 0
        textDoneButton.alpha = 1
        textCancelButton.alpha = 1
        fontSlider.alpha = 1
        let centerConstraintValue = (view.frame.height - statusBarHeight - keyboardHeight - 50) / 2 + statusBarHeight + 50
        fontSliderCenterConstraint.constant = centerConstraintValue
        view.layoutIfNeeded()
    }
    
    func didHideKeyboard(_ editView: TextEditingView) {
        scrollView.contentOffset = .zero
        topView.alpha = 1
        topBlurView.alpha = 1
        textDoneButton.alpha = 0
        textCancelButton.alpha = 0
        fontSlider.alpha = 0
        let centerConstraintValue = view.frame.height / 2
        fontSliderCenterConstraint.constant = centerConstraintValue
        view.layoutIfNeeded()
    }
    
    func textViewDidStartEditing(_ editView: TextEditingView, textView: TextViewContainer) {
        textEditBar.isHidden = true
        fontSlider.setValue(textView.fontSize)
    }
    
    func textViewDidEndEditing(_ editView: TextEditingView, textView: TextViewContainer) {
        self.textEditBar.isHidden = editView.currentTextViewContainer == nil
    }
    
}

extension PhotoEditorViewController: SliderDelegate {
    
    func sliderBeginEditing(_ slider: Slider) {
        fontSliderLeftConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func sliderEndEditing(_ slider: Slider) {
        fontSliderLeftConstraint.constant = -20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func sliderDidChange(_ slider: Slider, value: CGFloat) {
        mediaView?.textEditingView.currentTextViewContainer?.setFontSize(value)
    }
}
