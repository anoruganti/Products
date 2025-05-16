//
//  ProductListApp.swift
//  ProductList
//
//  Created by Anil Oruganti on 11/05/25.
//

import SwiftUI

@main
struct ProductListApp: App {
    var body: some Scene {
        WindowGroup {
            ProductListView()
                .navigationTitle("Product List")
        }
    }
}
