//
//  GalleryViewController.swift
//  TelegramPhotoEditor
//
//  Created by Усман Туркаев on 12.10.2022.
//

import UIKit
import Photos
import PhotosUI

class GalleryViewController: UIViewController {
    
    struct LayoutConfig {
        
        let numberOfCellsInARow: Int
        
        let spacing: CGFloat
        
        func layout() -> UICollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()
            let side = (UIScreen.main.bounds.width - spacing * CGFloat(numberOfCellsInARow)) / CGFloat(numberOfCellsInARow)
            layout.itemSize = .init(width: side, height: side)
            layout.minimumLineSpacing = spacing
            layout.minimumInteritemSpacing = spacing
            return layout
        }
    }
    
    enum Section {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, PhotoPickerAssetCellViewModel>!
    
    var allLayoutConfigs: [LayoutConfig] = [
        .init(numberOfCellsInARow: 12, spacing: 0),
        .init(numberOfCellsInARow: 5, spacing: 0),
        .init(numberOfCellsInARow: 3, spacing: 1),
        .init(numberOfCellsInARow: 1, spacing: 1)
    ]
    
    var layoutConfigIndex: Int = 2
    
    var layoutConfig: LayoutConfig {
        return allLayoutConfigs[layoutConfigIndex]
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "PhotoPickerAssetCell",
                                      bundle: nil), forCellWithReuseIdentifier: "asset")
        collectionView.collectionViewLayout = layoutConfig.layout()
        
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "asset", for: indexPath) as! PhotoPickerAssetCell
            cell.setup(viewModel: itemIdentifier)
            return cell
        })
  
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    var checkedPersmissions = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !checkedPersmissions {
            checkedPersmissions = true
            checkPermissions()
        }
    }
    
    @objc
    func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        
    }
    
    var content: [PhotoPickerAssetCellViewModel] = []
    
    var assets: PHFetchResult<PHAsset>?
    
    func checkPermissions() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined, .denied:
            self.presentAllowAccessController(status)
        case .restricted:
            break
        case .authorized, .limited:
            PHPhotoLibrary.shared().register(self)
            self.load()
        @unknown default:
            break
        }
    }
    
    func presentAllowAccessController(_ status: PHAuthorizationStatus) {
        let vc = AllowAccessViewController()
        vc.delegate = self
        vc.authorzationStatus = status
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func load() {
        assets = loadAssets()
        
        reload()
    }
    
    func reload() {
        var items: [PhotoPickerAssetCellViewModel] = []
        for i in 0..<(assets?.count ?? 0) {
            if let asset = assets?.object(at: i) {
                items.append(.init(asset: asset))
            }
        }
        content = items
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoPickerAssetCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(content, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func editAsset(_ asset: PHAsset) {
        let vc = PhotoEditorViewController()
        vc.asset = asset
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let viewModel = content[indexPath.item]
        editAsset(viewModel.asset)
    }
}

extension GalleryViewController: AllowAccessViewControllerDelegate {
    
    func didChangeAuthorizationStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized, .limited:
            PHPhotoLibrary.shared().register(self)
            self.load()
        default:
            break
        }
    }
    
}


// MARK: - Library listener
extension GalleryViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        load()
    }
}

