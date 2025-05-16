//
//  ProductListService.swift
//  ProductList
//
//  Created by Anil Oruganti on 11/05/25.
//

import Foundation
import UIKit

enum ApiServiceError: Error {
    case invalidURL
    case invalidURLResponse
    case statusCodeError(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self{
        case .invalidURL:
            return "Invalid URL"
        case .invalidURLResponse :
            return "Invalid URL Response"
        case .statusCodeError(let statusCode ):
            return "Status code Error \(statusCode)"
        case .decodingError((let error)):
            return "Falied due to decode service response & error is - \(error.localizedDescription)"
        case .networkError(let error):
            return "Falied due to network error & error is - \(error.localizedDescription))"
        }
    }
}

class ProductListService {
    
    func getProductLists() async throws -> [Product] {
        guard let url = URL(string: "https://dummyjson.com/products") else {
            throw ApiServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            throw ApiServiceError.invalidURLResponse
        }
        guard (200...299).contains(response.statusCode) else {
            throw ApiServiceError.statusCodeError(response.statusCode)
        }
        
        let decoder = JSONDecoder()
        do {
            let productListData = try decoder.decode(ProductListData.self, from: data)
            return productListData.products
        } catch let error as DecodingError{
            throw ApiServiceError.decodingError(error)
        }catch {
            throw ApiServiceError.networkError(error)
        }
    }
}


