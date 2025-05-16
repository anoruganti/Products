//
//  ProductListData.swift
//  ProductList
//
//  Created by Anil Oruganti on 11/05/25.
//

import Foundation

struct ProductListData: Codable {
    let products: [Product]
}

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let tags: [String]
    let brand: String?
    let sku: String
    let weight: Int
    let dimensions: ProductDimentions
    let warrantyInformation: String
    let shippingInformation: String
    let availabilityStatus: String
    let reviews: [ProductReview]
    let returnPolicy: String
    let minimumOrderQuantity: Int
    let meta: Meta
    let images: [String]
    let thumbnail: String
}

struct ProductDimentions: Codable {
    let width: Double
    let height: Double
    let depth: Double
}

struct ProductReview: Codable {
    let rating: Int
    let comment: String
    let date: String
    let reviewerName: String
    let reviewerEmail: String
}

struct Meta: Codable {
    let createdAt: String
    let updatedAt: String
    let barcode: String
    let qrCode: String
}
