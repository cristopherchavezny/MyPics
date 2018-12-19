//
//  PHAssetManager.swift
//  MyPics
//
//  Created by Cris C on 12/14/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import Photos
import Foundation

protocol PhotoLibraryChangeDelegate: class {
    func photoLibraryChanged(changeDetails: PHFetchResultChangeDetails<PHAsset>)
}

class PHAssetManager: NSObject {
    var phAssets: [PHAsset] = []
    var assetFetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    let options = PHFetchOptions()
    
    weak var photoLibraryChangeDelegate: PhotoLibraryChangeDelegate? = nil
    
    fileprivate final var cachingImageManager: PHCachingImageManager
    fileprivate final var requestOptions: PHImageRequestOptions
    fileprivate final var imageManager: PHImageManager
    
    fileprivate final let assetSortDescriptor = "creationDate"
    
    init(cachingImageManager: PHCachingImageManager = PHCachingImageManager(),
         requestOptions: PHImageRequestOptions = PHImageRequestOptions(),
         imageManager: PHImageManager = PHImageManager()) {
        self.cachingImageManager = cachingImageManager
        self.requestOptions = requestOptions
        self.imageManager = imageManager
        
        cachingImageManager.allowsCachingHighQualityImages = true
        
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat
        
        super.init()
        
        PHPhotoLibrary.shared().register(self)
        getPhotos()
    }
    
    deinit {
        stopCachingImagesForAllAssets()
    }
    
    func getPhotos() {
        options.sortDescriptors = [NSSortDescriptor(key: assetSortDescriptor, ascending: false)]
        
        assetFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        enumerateFetchResults()
    }
    
    func enumerateFetchResults() {
        phAssets.removeAll()
        assetFetchResult.enumerateObjects { [weak self] (phAsset, _, _) in
            self?.phAssets.append(phAsset)
        }
    }
    
    func startCaching(prefetchedAssets: [PHAsset], targetSize: CGSize) {
        cachingImageManager.startCachingImages(for: prefetchedAssets,
                                               targetSize: targetSize,
                                               contentMode: .default,
                                               options: nil
        )
    }
    
    func stopCaching(prefetchedAssets: [PHAsset], targetSize: CGSize) {
        cachingImageManager.stopCachingImages(for: prefetchedAssets,
                                              targetSize: targetSize,
                                              contentMode: .default,
                                              options: nil
        )
    }
    
    func requestImageFromCach(forAsset: PHAsset, targetSize: CGSize, completionHandler: @escaping (UIImage?) -> Void) {
        cachingImageManager.requestImage(for: forAsset,
                                         targetSize: targetSize,
                                         contentMode: .default,
                                         options: requestOptions) { (image, _) in
                                            completionHandler(image)
        }
    }
    
    func requestFullSizeImageFromCach(forAsset: PHAsset, completionHandler: @escaping (UIImage?) -> Void) {
        let newRequestOptions = requestOptions
        newRequestOptions.isSynchronous = true
        
        imageManager.requestImage(for: forAsset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .default,
                                  options: newRequestOptions) { (image, dict) in
                                    completionHandler(image)
        }
        
    }
    
    func stopCachingImagesForAllAssets() {
        cachingImageManager.stopCachingImagesForAllAssets()
    }
    
}

extension PHAssetManager: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let changeDetailsToFetchResults = changeInstance.changeDetails(for: assetFetchResult) {
            assetFetchResult = changeDetailsToFetchResults.fetchResultAfterChanges
            enumerateFetchResults()
            
            if changeDetailsToFetchResults.hasIncrementalChanges {
                DispatchQueue.main.sync {
                    photoLibraryChangeDelegate?.photoLibraryChanged(changeDetails: changeDetailsToFetchResults)
                }
            }
        }
    }
    
}

