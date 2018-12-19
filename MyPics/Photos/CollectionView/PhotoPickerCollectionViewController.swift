//
//  PhotoPickerCollectionViewController.swift
//  MyPics
//
//  Created by Cris C on 12/14/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "PhotoCell"
private let collectionViewCellNibName = "PhotoCollectionViewCell"

class PhotoPickerCollectionViewController: UICollectionViewController, PhotoLibraryChangeDelegate {
    fileprivate lazy var assetManager: PHAssetManager = {
        [weak self] in
        let assetManager = PHAssetManager()
        assetManager.photoLibraryChangeDelegate = self
        
        return assetManager
    }()

    fileprivate let numberOfItemsPerRow = 2
    fileprivate var contentSize: Int = 0 /// temporary value, set in collectionView: sizeForItemAt
    fileprivate var collectionViewContentSize: CGSize {
        return CGSize(width: contentSize, height: contentSize)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: collectionViewCellNibName, bundle: nil),
                                     forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.prefetchDataSource = self
        self.collectionView.backgroundColor = .white
    }

    func photoLibraryChanged(changeDetails: PHFetchResultChangeDetails<PHAsset>) {
        if changeDetails.hasIncrementalChanges {
            collectionView.performBatchUpdates({
                if let removed = changeDetails.removedIndexes, removed.count > 0 {
                    collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })
                }
                if let inserted = changeDetails.insertedIndexes, inserted.count > 0 {
                    collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                }
                if let changed = changeDetails.changedIndexes, changed.count > 0 {
                    collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                }
                changeDetails.enumerateMoves { fromIndex, toIndex in
                    self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                 to: IndexPath(item: toIndex, section: 0))
                }
            })
        } else {
            collectionView.reloadData()
        }
    }
}

// MARK: UICollectionViewDataSource
extension PhotoPickerCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetManager.phAssets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        let phAsset = assetManager.phAssets[indexPath.item]
        
        assetManager.requestImageFromCach(forAsset: phAsset, targetSize: collectionViewContentSize) {
            (image) in
            if let image = image {
                cell.photoImageView.image = image
            }
        }
        
        return cell
    }
    
}

// MARK: UICollectionViewDataSourcePrefetching
extension PhotoPickerCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var assetsToPrefetch: [PHAsset] = []
        for indexPath in indexPaths {
            let phAsset = assetManager.phAssets[indexPath.item]
            assetsToPrefetch.append(phAsset)
        }

        assetManager.startCaching(prefetchedAssets: assetsToPrefetch, targetSize: collectionViewContentSize)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        var assetsToStopPrefetch: [PHAsset] = []

        for indexPath in indexPaths {
            let phAsset = assetManager.phAssets[indexPath.item]
            assetsToStopPrefetch.append(phAsset)
        }

        assetManager.stopCaching(prefetchedAssets: assetsToStopPrefetch, targetSize: collectionViewContentSize)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PhotoPickerCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if contentSize == 0 {
            let layoutMargins = collectionView.layoutMargins
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = layoutMargins.left
                + layoutMargins.right
                + (flowLayout.minimumInteritemSpacing
                    * CGFloat(numberOfItemsPerRow - 1))
            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
            contentSize = size
        }
        
        return collectionViewContentSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        /// Padding should be the same around all the edges of the collectionView
        let cellPadding = CGFloat(8)
        
        return UIEdgeInsets(top: cellPadding, left: cellPadding, bottom: cellPadding, right: cellPadding)
    }
}
