//
//  PhotoEditorViewController.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 12.10.2022.
//

import UIKit
import Photos

class PhotoEditorViewController: UIViewController {
    
    var bottomSegment: SegmentControl!
    
    var asset: PHAsset!
    
    let cancelButton = UIButton()
    
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
    
    var mediaView: MediaView!
     
    let addButtonBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        layout()
        setupMediaViews()
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
        view.backgroundColor = .black
    
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
        
        cancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped),
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
        
        addButton.setImage(UIImage(named: "add"), for: .normal)
        
        addButtonBlurView.layer.cornerRadius = 18
        addButtonBlurView.clipsToBounds = true
        
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
    
        toolPicker.delegate = self
    }
    
    func layout() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        bottomBlurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBlurView)
        bottomBlurView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomBlurView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                            constant: -10).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor,
                                           constant: 10).isActive = true
        
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
        addButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        addButton.centerXAnchor.constraint(equalTo: downloadButton.centerXAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: downloadButton.topAnchor,
                                          constant: -10).isActive = true
        addButtonBlurView.topAnchor.constraint(equalTo: addButton.topAnchor).isActive = true
        addButtonBlurView.leftAnchor.constraint(equalTo: addButton.leftAnchor).isActive = true
        addButtonBlurView.rightAnchor.constraint(equalTo: addButton.rightAnchor).isActive = true
        addButtonBlurView.bottomAnchor.constraint(equalTo: addButton.bottomAnchor).isActive = true
        
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
        mediaView = .init(frame: .init(origin: .zero, size: size),
                          media: .image(image))
        mediaView.canvasView.currentTool = toolPicker.currentTool
        scrollView.addSubview(mediaView)
        scrollView.contentSize = size
        
        setZoomScale(image.size)
        centerMediaView()
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    func setupVideo() {
        getAVAsset(asset: asset) { [weak self] avasset in
            DispatchQueue.main.async {
                guard let strongSelf = self,
                      let avasset = avasset,
                      let size = getVideoSize(asset: avasset) else { return }
                strongSelf.mediaView = .init(frame: .init(origin: .zero, size: size),
                                             media: .video(avasset))
                strongSelf.mediaView.canvasView.currentTool = strongSelf.toolPicker.currentTool
                
                strongSelf.scrollView.addSubview(strongSelf.mediaView)
                strongSelf.scrollView.contentSize = size
                
                strongSelf.setZoomScale(size)
                strongSelf.centerMediaView()
                strongSelf.scrollView.zoomScale = strongSelf.scrollView.minimumZoomScale
                strongSelf.mediaView.play()
            }
        }
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
        
    }
    
    @objc
    func zoomOutButtonTapped() {
        scrollView.setZoomScale(scrollView.minimumZoomScale,
                                animated: true)
    }
    
    func setMode() {
        
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
        zoomOutButton.isHidden = scrollView.zoomScale <= scrollView.minimumZoomScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mediaView
    }
    

}

extension PhotoEditorViewController: SegmentControlDelegate {
    
    func didSelectSegment(_ control: SegmentControl, segmentIndex: Int) {
        currentMode = segmentIndex == 0 ? .draw : .text
    }
    
}

extension PhotoEditorViewController: ToolPickerViewDelegate {
    
    func didChangeTool(_ pickerView: ToolPickerView, tool: Tool) {
        mediaView?.canvasView.currentTool = tool
    }
    
}
