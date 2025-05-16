//
//  ProductListView.swift
//  ProductList
//
//  Created by Anil Oruganti on 11/05/25.
//

import SwiftUI

struct ProductListView: View {
    
    @StateObject private var viewModel = ProductListViewModel()
    
    var body: some View {
        ZStack {
            
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
            } else {
                VStack {
                    
                    List(viewModel.productsList) { product in
                        HStack {
                            CachedImage(thumbnailString: product.thumbnail,
                                        cacheType: .urlCache)
                            .frame(width: 80, height: 80)
                            
                            VStack(alignment: .leading) {
                                Text(product.title)
                                Text(product.category)
                                Text("$\(product.price)")
                                Text(product.description)
                                    .font(.footnote)
                                    .lineLimit(3)
                            }
                        }
                    }
                    
                    Button("Retry") {
                        Task {
                            await viewModel.getProducts()
                        }
                    }
                }
                .alert("Alert!",
                       isPresented: $viewModel.showErrorAlert,
                       actions: { EmptyView() },
                       message: { Text(viewModel.errorMessage) })
            }
        }
        .task {
            await viewModel.getProducts()
        }
    }
}


//struct ThumbnailImage: View {
//    
//    @State var thumbImgUrl: String = ""
//    
//    var body: some View {
//
//        AsyncImage(url: URL(string: thumbImgUrl)) { image in
//            image.resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 80, height: 80)
//        } placeholder: {
//            ProgressView()
//                .controlSize(.large)
//        }
//    }
//}

#Preview {
    ProductListView()
}
