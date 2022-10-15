//
//  PhotoEditorViewController.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 12.10.2022.
//

import UIKit
import Photos
import Lottie

class PhotoEditorViewController: UIViewController {
    
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
    
    let topBlurView = BlurView()
    
    let topMiddleBlurView = BlurView()
    
    let bottomBlurView = BlurView()
    
    let bottomMiddleBlurView = BlurView()
    
    var toolPicker = ToolPickerView()
    
    let tipTypeButton = TipTypeButton()
    
    var mediaView: MediaView!
    
    let backToCancelAnimation = LottieAnimationView(name: "backToCancel")
     
    let addButtonBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    
    let colorButton = ColorButton()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    enum Mode {
        case draw, text
    }
    
    var hasChanges: Bool {
        return false
    }
    
    var currentMode: Mode = .draw {
        didSet {
            if currentMode != oldValue {
                setMode()
            }
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
        
        topMiddleBlurView.blurRadius = 10
        topMiddleBlurView.colorTint = .clear
        topMiddleBlurView.alpha = 0.3

        bottomBlurView.blurRadius = 5
        bottomBlurView.colorTint = .clear
        
        bottomMiddleBlurView.blurRadius = 10
        bottomMiddleBlurView.colorTint = .clear
        bottomMiddleBlurView.alpha = 0.3
        
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
    
        toolPicker.delegate = self
        
        tipTypeButton.alpha = 0
        if #available(iOS 14, *) {
            
        } else {
            tipTypeButton.addTarget(self, action: #selector(tipTypeButtonTapped),
                                    for: .touchUpInside)
        }
        
        colorButton.tapHandler = colorButtonTapped
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
//        cancelButton.isHidden = true
        
        backToCancelAnimation.heightAnchor.constraint(equalToConstant: 33).isActive = true
        backToCancelAnimation.widthAnchor.constraint(equalToConstant: 33).isActive = true
        backToCancelAnimation.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor).isActive = true
        backToCancelAnimation.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
        backToCancelAnimation.isHidden = true
//        backToCancelAnimation.backgroundColor = .red
        
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
        bottomSegment.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -10).isActive = true
        bottomSegment.leftAnchor.constraint(equalTo: view.leftAnchor,
                                            constant: 60).isActive = true
        bottomSegment.rightAnchor.constraint(equalTo: view.rightAnchor,
                                             constant: -60).isActive = true
        bottomSegment.topAnchor.constraint(equalTo: bottomBlurView.topAnchor,
                                           constant: 1).isActive = true
        
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
        mediaView = .init(frame: .init(origin: .zero, size: scaledSize),
                          media: .image(image))
        scrollView.addSubview(mediaView)
        scrollView.contentSize = scaledSize
        
        centerMediaView()
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        scrollView.maximumZoomScale = 5
        mediaView.canvasView.currentTool = toolPicker.currentTool
    }
    
    func setupVideo() {
        getAVAsset(asset: asset) { [weak self] avasset in
            DispatchQueue.main.async {
                guard let strongSelf = self,
                      let avasset = avasset,
                      let size = getVideoSize(asset: avasset) else { return }
                let scale = strongSelf.getScale(size)
                let scaledSize = CGSize(width: size.width * scale,
                                        height: size.height * scale)
                strongSelf.mediaView = .init(frame: .init(origin: .zero, size: scaledSize),
                                             media: .video(avasset))
                
                strongSelf.scrollView.addSubview(strongSelf.mediaView)
                strongSelf.scrollView.contentSize = scaledSize
                
                strongSelf.centerMediaView()
                strongSelf.scrollView.minimumZoomScale = 1
                strongSelf.scrollView.zoomScale = 1
                strongSelf.scrollView.maximumZoomScale = 5
                strongSelf.mediaView.canvasView.currentTool = strongSelf.toolPicker.currentTool
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
        dismiss(animated: true)
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
    
    @objc
    func undoButtonTapped() {
        
    }
    
    @objc
    func clearAllButtonTapped() {
        
    }
    
    @objc
    func addButtonTapped() {
        let menu = Menu([
            .init(name: "Rectangle", image: UIImage(named: "shapeRectangle")) { [weak self] _ in
                self?.handleAddShape("Rectangle")
            },
            .init(name: "Ellipse", image: UIImage(named: "shapeEllipse")) { [weak self] _ in
                self?.handleAddShape("Ellipse")
            },
            .init(name: "Bubble", image: UIImage(named: "shapeBubble")) { [weak self] _ in
                self?.handleAddShape("Bubble")
            },
            .init(name: "Star", image: UIImage(named: "shapeStar")) { [weak self] _ in
                self?.handleAddShape("Star")
            },
            .init(name: "Arrow", image: UIImage(named: "shapeArrow")) { [weak self] _ in
                self?.handleAddShape("Arrow")
            }
        ])
        menu.frame.origin.x = addButton.frame.maxX - 150
        menu.frame.origin.y = addButton.frame.origin.y - 10 - menu.frame.height
        let vc = MenuController(menu: menu)
        present(vc, animated: false)
    }
    
    @objc
    func tipTypeButtonTapped() {
        let tool = toolPicker.currentTool
        let tips: [ToolTipType] = tool.getTipTypes()
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
            self.tipTypeButton.menu = UIMenu(children: actions)
            self.tipTypeButton.showsMenuAsPrimaryAction = true
        }
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
        case .brush, .neon, .pencil, .pen:
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
        centerMediaView()
        mediaView?.canvasView.setBrush()
        zoomOutButton.isHidden = scrollView.zoomScale <= scrollView.minimumZoomScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mediaView
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
                self.tipTypeButton.alpha = 1
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
            self.tipTypeButton.menu = UIMenu(children: actions)
            self.tipTypeButton.showsMenuAsPrimaryAction = true
            self.tipTypeButton.setTitle(tips[currentTipIndex].name, for: .normal)
            self.tipTypeButton.setImage(tips[currentTipIndex].image, for: .normal)
        }
    }
    
    func didChangeTool(_ pickerView: ToolPickerView, tool: Tool) {
        colorButton.color = tool.color
        mediaView?.canvasView.currentTool = tool
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
