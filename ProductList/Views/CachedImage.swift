//
//  CachedImage.swift
//  ProductList
//
//  Created by Anil Oruganti on 16/05/25.
//

import SwiftUI

struct CachedImage: View {
    
    let thumbnailString: String
    let cacheType: CacheStorage
    @State private var image: UIImage?
    
    var body: some View {
        if let anImage = image{
            Image(uiImage: anImage)
                .resizable()
        }else{
            
            ProgressView()
                .onAppear {
                    Task{
                        await loadThumbnail()
                    }
                }
        }
    }
    
    private func loadThumbnail() async{
        do{
            if let thumbnail = await try ImageCacheManager.shared.loadImage(storageType: cacheType,
                                                                            urlString: thumbnailString){
                await MainActor.run {
                    self.image = thumbnail
                }
            }
            
        }catch{
            print("Image loading failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CachedImage(thumbnailString: "https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp", cacheType: .diskCache)
}
