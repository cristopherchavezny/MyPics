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

enum PhotoType: Int {
    case Album, Photos
}

class PHAssetManager: NSObject {
    fileprivate final weak var photoLibraryChangeDelegate: PhotoLibraryChangeDelegate?

    final var phAssets: [PHAsset] = []
    fileprivate final var assetFetchResult: PHFetchResult<PHAsset>
    fileprivate final let fetchOptions: PHFetchOptions
    
    fileprivate final var cachingImageManager: PHCachingImageManager
    fileprivate final var requestOptions: PHImageRequestOptions
    fileprivate final var imageManager: PHImageManager
    
    fileprivate final var photoType: PhotoType
    fileprivate final let assetSortDescriptor = "creationDate"
    
    init(photoLibraryChangeDelegate: PhotoLibraryChangeDelegate?,
         assetFetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>(),
         fetchOptions: PHFetchOptions = PHFetchOptions(),
         cachingImageManager: PHCachingImageManager = PHCachingImageManager(),
         requestOptions: PHImageRequestOptions = PHImageRequestOptions(),
         imageManager: PHImageManager = PHImageManager(),
         photoType: PhotoType) {
        self.photoLibraryChangeDelegate = photoLibraryChangeDelegate
        self.assetFetchResult = assetFetchResult
        self.fetchOptions = fetchOptions
        self.cachingImageManager = cachingImageManager
        self.requestOptions = requestOptions
        self.imageManager = imageManager
        self.photoType = photoType
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: assetSortDescriptor, ascending: false)]

        cachingImageManager.allowsCachingHighQualityImages = true
        
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat
        
        super.init()
        
        PHPhotoLibrary.shared().register(self)
        getPhotosFrom(photoType: self.photoType)
    }
    
    deinit {
        stopCachingImagesForAllAssets()
    }
    
    fileprivate final func getPhotosFrom(photoType: PhotoType) {
        switch photoType {
        case .Album:
            getAlbums()
        default:
            getPhotos()
        }
    }
    
    fileprivate final func getAlbums() {
        let albumsFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        let smartAlbumsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        let allAlbums = [albumsFetchResult, smartAlbumsFetchResult]
        
        for album in allAlbums {
            album.enumerateObjects { [weak self] (phAssetCollection, index, stop) in
                self?.fetchOptions.fetchLimit = 1

                let albumFetchResult = PHAsset.fetchAssets(in: phAssetCollection, options: self?.fetchOptions)
                albumFetchResult.enumerateObjects({ [weak self] (phAsset, index, stop) in
                    self?.phAssets.append(phAsset)
                })
            }
        }
    }
    
    fileprivate final func getPhotos() {
        assetFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        enumerateFetchResults()
    }
    
    fileprivate final func enumerateFetchResults() {
        phAssets.removeAll()
        assetFetchResult.enumerateObjects { [weak self] (phAsset, _, _) in
            self?.phAssets.append(phAsset)
        }
    }
    
    final func startCaching(prefetchedAssets: [PHAsset], targetSize: CGSize) {
        cachingImageManager.startCachingImages(for: prefetchedAssets,
                                               targetSize: targetSize,
                                               contentMode: .default,
                                               options: nil
        )
    }
    
    final func stopCaching(prefetchedAssets: [PHAsset], targetSize: CGSize) {
        cachingImageManager.stopCachingImages(for: prefetchedAssets,
                                              targetSize: targetSize,
                                              contentMode: .default,
                                              options: nil
        )
    }
    
    final func requestImageFromCach(forAsset: PHAsset, targetSize: CGSize, completionHandler: @escaping (UIImage?) -> Void) {
        cachingImageManager.requestImage(for: forAsset,
                                         targetSize: targetSize,
                                         contentMode: .default,
                                         options: requestOptions) { (image, _) in
                                            completionHandler(image)
        }
    }
    
    final func requestFullSizeImageFromCach(forAsset: PHAsset, completionHandler: @escaping (UIImage?) -> Void) {
        let newRequestOptions = requestOptions
        newRequestOptions.isSynchronous = true
        
        imageManager.requestImage(for: forAsset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .default,
                                  options: newRequestOptions) { (image, dict) in
                                    completionHandler(image)
        }
        
    }
    
    fileprivate final func stopCachingImagesForAllAssets() {
        cachingImageManager.stopCachingImagesForAllAssets()
    }
}

// PHPhotoLibraryChangeObserver gets called when a new image has been added to Phopto Library
extension PHAssetManager: PHPhotoLibraryChangeObserver {
    internal final func photoLibraryDidChange(_ changeInstance: PHChange) {
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

