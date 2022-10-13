//
//  AllowAccessViewController.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 12.10.2022.
//

import UIKit
import Lottie
import Photos

protocol AllowAccessViewControllerDelegate: AnyObject {
    
    func didChangeAuthorizationStatus(_ status: PHAuthorizationStatus)
    
}

class AllowAccessViewController: UIViewController {
    
    weak var delegate:AllowAccessViewControllerDelegate?
    
    var animationView: LottieAnimationView!
    
    var allowAccessButton: UIButton!
    
    var allowAccessLabel: UILabel!
    
    var containerView: UIView!
    
    var authorzationStatus: PHAuthorizationStatus = .notDetermined

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        containerView = .init()
        containerView.backgroundColor = .systemBackground
        
        animationView = LottieAnimationView(name: "duck")
        animationView.loopMode = .loop
        
        allowAccessButton = .init()
        allowAccessButton.setTitle("Allow Access", for: .normal)
        allowAccessButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        allowAccessButton.backgroundColor = .systemBlue
        allowAccessButton.layer.cornerRadius = 10
        allowAccessButton.layer.cornerCurve = .continuous
        allowAccessButton.clipsToBounds = true
        allowAccessButton.addTarget(self, action: #selector(allowAccessButtonTapped),
                                    for: .touchUpInside)
        
        allowAccessLabel = .init()
        allowAccessLabel.text = "Access Your Photos and Videos"
        allowAccessLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        allowAccessLabel.textAlignment = .center
        allowAccessLabel.adjustsFontSizeToFitWidth = true
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        allowAccessButton.translatesAutoresizingMaskIntoConstraints = false
        allowAccessLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(animationView)
        containerView.addSubview(allowAccessButton)
        containerView.addSubview(allowAccessLabel)
        
        animationView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor,
                                             multiplier: 0.33).isActive = true
        animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        allowAccessLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor,
                                              constant: 20).isActive = true
        allowAccessLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor,
                                               constant: 10).isActive = true
        allowAccessLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor,
                                                 constant: -10).isActive = true
        allowAccessLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        allowAccessButton.topAnchor.constraint(equalTo: allowAccessLabel.bottomAnchor,
                                               constant: 20).isActive = true
        allowAccessButton.leftAnchor.constraint(equalTo: containerView.leftAnchor,
                                                constant: 10).isActive = true
        allowAccessButton.rightAnchor.constraint(equalTo: containerView.rightAnchor,
                                                 constant: -10).isActive = true
        allowAccessButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        allowAccessButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        view.addSubview(containerView)
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
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
        animationView.play()
    }
    
    @objc
    func openAndCloseActivity(_ notification: Notification)  {
        if notification.name == UIApplication.didBecomeActiveNotification {
            animationView.play()
        } else {
            animationView.stop()
        }
    }
    
    @objc
    func allowAccessButtonTapped() {
        switch authorzationStatus {
        case .notDetermined:
            requestAuthorization()
        case .denied:
            showAllowAccess()
        default:
            break
        }
    }
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch status {
                case .denied:
                    strongSelf.showAllowAccess()
                case .authorized, .limited:
                    self?.delegate?.didChangeAuthorizationStatus(status)
                    self?.dismiss(animated: true)
                default:
                    break
                }
            }
        }
    }
    
    func showAllowAccess() {
        let alertController = UIAlertController(title: "Allow access to all photos", message: "You can change access in settings", preferredStyle: .alert)
        let notNowAction = UIAlertAction(title: "Not now", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        let openSettingsAction = UIAlertAction(title: "Open settings",
                                               style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) else {
                    return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        alertController.addAction(openSettingsAction)
        alertController.addAction(notNowAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
