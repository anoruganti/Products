//
//  ProductListViewModel.swift
//  ProductList
//
//  Created by Anil Oruganti on 11/05/25.
//

import Foundation
import SwiftUI

class ProductListViewModel: ObservableObject {
    @Published var productsList: [Product] = []
    @Published var showErrorAlert: Bool = false
    @Published var isLoading: Bool = false
    
    var errorMessage: String = ""
    
    @MainActor
    func getProducts() async {
        isLoading = true
        do {
            productsList = try await ProductListService().getProductLists()
            isLoading = false
        } catch {
            isLoading = false
            showErrorAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
}


