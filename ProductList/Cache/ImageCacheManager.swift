//
//  File.swift
//  ProductList
//
//  Created by Anil Oruganti on 12/05/25.
//

import Foundation
import SwiftUI

enum CacheStorage{
    case memoryCache
    case diskCache
    case urlCache
}

struct ProductImageDetails{
    let id: Int
    let thumbImg: String
    let images: [String]
    let storage: CacheStorage
}

protocol ImageCaching{
    func getImageForURL(url: URL) async -> UIImage?
    func setImageForURL(image: UIImage, url: URL)
}

class ImageCacheManager{
    
    static let shared = ImageCacheManager()
    
    // Memory cache using NSCache
    private let memoryCache = NSCache<NSString, NSData>()
    
    // Disk cache directory
    private let fileManager = FileManager.default
    private var diskCacheDirectory: URL
    
    private init() {
        let diskCachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.diskCacheDirectory = diskCachePath.appending(component: "ImageCache")
        
        /// Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: diskCacheDirectory.path){
            try? fileManager.createDirectory(atPath: diskCacheDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Configure memory cache
        memoryCache.countLimit = 500 // Limit to 500 images
        memoryCache.totalCostLimit = 1024 * 1024 * 500 // 500 MB
    }
    
    // Generate a unique file name for the image URL
    private func cacheFileURL(for urlString: String) -> URL {
        let imgURL = URL(string: urlString)!
        let fileName = imgURL.absoluteString
        return diskCacheDirectory.appendingPathComponent(fileName)
    }
    
    private func updateImgDataInMemory(imgData: Data, urlString: String){
        memoryCache.setObject(imgData as NSData, forKey: urlString as NSString)
    }
    
    private func prepareURL(urlString: String) -> URL?{
        return URL(string: urlString)
    }
    
    private func getImageFromData(imgData: Data) -> UIImage?{
        return UIImage(data: imgData)
    }
    
    private func downloadImage(productImgInfo: ProductImageDetails) async throws -> Data?{
        
        let produtId = String(productImgInfo.id)
        guard let imgURL = prepareURL(urlString: productImgInfo.thumbImg) else {
            throw ApiServiceError.invalidURL
        }
        let imgURLRequest = URLRequest(url: imgURL)
        
        let (data, response) = try await URLSession.shared.data(for: imgURLRequest)
        guard let response = response as? HTTPURLResponse else {
            throw ApiServiceError.invalidURLResponse
        }
        guard (200...299).contains(response.statusCode) else {
            throw ApiServiceError.statusCodeError(response.statusCode)
        }
        
        let cacheResponse = CachedURLResponse(response: response, data: data)
        
        // Store in data in cache for faster subsequent access
        switch productImgInfo.storage{
        case .memoryCache:
            updateImgDataInMemory(imgData: data, urlString: productImgInfo.thumbImg)
            
        case .diskCache:
            // Store in disk cache
            do{
                // Write to disk
                let fileURL = diskCacheDirectory.appendingPathComponent(produtId)
                try data.write(to: fileURL)
            }catch{
                print("Error storing image to disk: \(error)")
            }
            
        case .urlCache:
            URLCache.shared.storeCachedResponse(cacheResponse, for: imgURLRequest)
        }
        
        return data
    }
    
    func loadImage(imageInfo: ProductImageDetails) async throws -> UIImage? {
        
        var cachedImgData: Data?
        let produtId = String(imageInfo.id)
        guard let imgURL = prepareURL(urlString: imageInfo.thumbImg) else {
            throw ApiServiceError.invalidURL
        }
        let imgURLRequest = URLRequest(url: imgURL)

        switch imageInfo.storage {
            
        case .memoryCache:
            // Check memory cache first
            if let imageData = memoryCache.object(forKey: imageInfo.thumbImg as NSString){
                cachedImgData = imageData as Data
            }
        case .diskCache:
            // Check disk cache
            let fileURL = diskCacheDirectory.appendingPathComponent(produtId)
            do{
                cachedImgData = try Data(contentsOf: fileURL)
            }catch{
                print("Fetching from disks memory error - \(error.localizedDescription)")
            }
            
        case .urlCache:
            // Check if image is already in URL cache
            if let cacheResponse = URLCache.shared.cachedResponse(for: imgURLRequest){
                cachedImgData = cacheResponse.data
            }
        }

        if let imageData = cachedImgData{
            return getImageFromData(imgData: imageData)
        }else {
            do{
                let imgData = try await downloadImage(productImgInfo: imageInfo)
                if let urlImgData = imgData{
                    return getImageFromData(imgData: urlImgData)
                }
            }catch{
                print("error")
            }
        }
        
        return nil
    }

}
