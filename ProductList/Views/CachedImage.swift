//
//  CachedImage.swift
//  ProductList
//
//  Created by Anil Oruganti on 16/05/25.
//

import SwiftUI

struct CachedImage: View {
    
    let productInfo: ProductImageDetails
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
            if let thumbnail = try await ImageCacheManager.shared.loadImage(imageInfo: productInfo){
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
    
    let imgInfo = ProductImageDetails(id: 1, thumbImg: "https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp", images: ["https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp"], storage: .diskCache)
    CachedImage(productInfo: imgInfo)    
}
