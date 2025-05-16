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
        let fileName = imgURL.lastPathComponent
        return diskCacheDirectory.appendingPathComponent(fileName)
    }
    
    private func updateImgDataInMemory(imgData: Data, urlString: String){
        memoryCache.setObject(imgData as NSData, forKey: urlString as NSString)
    }
    
    private func getImageFromData(imgData: Data) -> UIImage?{
        return UIImage(data: imgData)
    }
    
    private func downloadImage(_ imgURLRequest: URLRequest, cache: CacheStorage) async throws -> Data?{
        
        guard let imgUrlString = imgURLRequest.url?.absoluteString else {
            throw ApiServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: imgURLRequest)
        guard let response = response as? HTTPURLResponse else {
            throw ApiServiceError.invalidURLResponse
        }
        guard (200...299).contains(response.statusCode) else {
            throw ApiServiceError.statusCodeError(response.statusCode)
        }
        
        let cacheResponse = CachedURLResponse(response: response, data: data)
        
        // Store in data in cache for faster subsequent access
        switch cache{
        case .memoryCache:
            updateImgDataInMemory(imgData: data, urlString: imgUrlString)
            
        case .diskCache:
            // Store in disk cache
            do{
                // Write to disk
                let fileURL = self.cacheFileURL(for: imgUrlString)
                try data.write(to: fileURL)
            }catch{
                print("Error storing image to disk: \(error)")
            }
            
        case .urlCache:
            URLCache.shared.storeCachedResponse(cacheResponse, for: imgURLRequest)
        }
        
        return data
    }
    
    func loadImage(storageType: CacheStorage, urlString: String) async throws -> UIImage? {
        
        var cachedImgData: Data?
        let imgURL = URL(string: urlString)!
        let imgURLRequest = URLRequest(url: imgURL)

        switch storageType{
            
        case .memoryCache:
            // Check memory cache first
            if let imageData = memoryCache.object(forKey: urlString as NSString){
                cachedImgData = imageData as Data
            }
        case .diskCache:
            // Check disk cache
            let fileURL = self.cacheFileURL(for: urlString)
            cachedImgData = try Data(contentsOf: fileURL)
            
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
                let imgData = try await downloadImage(imgURLRequest, cache: storageType)
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
