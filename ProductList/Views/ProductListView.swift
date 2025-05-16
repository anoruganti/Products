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
        NavigationStack{
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.large)
                } else {
                    VStack {
                        
                        List(viewModel.productsList) { product in
                            HStack {
                                let imgInfo = getProductImageDetails(productInfo: product)
                                CachedImage(productInfo: imgInfo)
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
            .navigationTitle("Products")
        }
        .task {
            await viewModel.getProducts()
        }
    }
    
    func getProductImageDetails(productInfo: Product) -> ProductImageDetails{
        return ProductImageDetails(id: productInfo.id,
                                   thumbImg: productInfo.thumbnail,
                                   images: productInfo.images,
                                   storage: .diskCache)
    }
}

#Preview {
    ProductListView()
}
