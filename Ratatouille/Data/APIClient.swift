//
//  APIClient.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//

import Foundation

class APIClient: ObservableObject {
    private static var searchByNameEndpoint = "https://www.themealdb.com/api/json/v1/1/search.php?s=" // Search meal by name
    private static var searchByLetterEndpoint = "https://www.themealdb.com/api/json/v1/1/search.php?f=" // List all meals by first letter
    private static var searchByIdEndpoint = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=" // Lookup full meal details by id
    
    private static var searchRandomEndpoint = "https://www.themealdb.com/api/json/v1/1/random.php" // Lookup single random meal
    private static var listCategoriesEndpoint = "https://www.themealdb.com/api/json/v1/1/categories.php" // List all meal categories
    
    //private static var listCategoriesEndpoint = "https://www.themealdb.com/api/json/v1/1/list.php?c=list" // List all categories - should not use this one
    private static var listAreasEndpoint = "https://www.themealdb.com/api/json/v1/1/list.php?a=list" // List all areas
    private static var listIngredientsEndpoint = "https://www.themealdb.com/api/json/v1/1/list.php?i=list" // List all ingredients
    
    private static var searchByIngredientEndpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?i=" // Filter by main ingredient
    private static var searchByCategoryEndpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?c=" // Filter by category
    private static var searchByAreaEndpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?a=" // Filter by area
    
    private static func getJson(endpoint: String) async throws -> Data {
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = ["Accept": "application/json", "Content-Type": "application/json"]
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                    case 200...299:
                        return data
                    case 400...499:
                        throw APIClientError.clientError
                    case 500...599:
                        throw APIClientError.serverError
                    default:
                        throw APIClientError.statusCode(statusCode)
                }
            }
            
            throw APIClientError.unknown
            
        } catch {
            throw APIClientError.failed(underlying: error)
        }
    }
    
    private static func parseJsonToIngredients(_ json: Data) -> [Ingredient] {
        do {
            let ingredientsWrapper = try JSONDecoder().decode(IngredientsWrapper.self, from: json)
            if !ingredientsWrapper.meals.isEmpty {
                return ingredientsWrapper.meals
            } else {
                throw APIClientError.parseError
            }
            
        } catch let error {
            print(error)
        }
        
        return []
    }
    
    private static func parseJsonToAreas(_ json: Data) -> [Area] {
        do {
            let areasWrapper = try JSONDecoder().decode(AreasWrapper.self, from: json)
            if !areasWrapper.meals.isEmpty {
                return areasWrapper.meals
            } else {
                throw APIClientError.parseError
            }
            
        } catch let error {
            print(error)
        }
        
        return []
    }
    
    private static func parseJsonToCategories(_ json: Data) -> [Category] {
        do {
            let categoriesWrapper = try JSONDecoder().decode(CategoriesWrapper.self, from: json)
            if !categoriesWrapper.categories.isEmpty {
                return categoriesWrapper.categories
            } else {
                throw APIClientError.parseError
            }
        } catch let error {
            print(error)
        }
        
        return []
    }
    
    static func test() async {
        do {
//            let json = try await getJson(endpoint: listIngredientsEndpoint)
//            let ingredients = parseJsonToIngredients(json)
//            ingredients.forEach { ingredient in
//                print("ID: \(ingredient.id ?? "N/A")")
//                print("Name: \(ingredient.name ?? "N/A")")
//                print("Description: \(ingredient.information ?? "N/A")")
//                print("-------------------")
//            }
            
//            let json = try await getJson(endpoint: listAreasEndpoint)
//            let areas = parseJsonToAreas(json)
//            areas.forEach { area in
//                print(area.name ?? "N/A")
//                print("-------------------")
//            }
            
            let json = try await getJson(endpoint: listCategoriesEndpoint)
            let categories = parseJsonToCategories(json)
            categories.forEach { category in
                print("ID: \(category.id ?? "N/A")")
                print("Name: \(category.name ?? "N/A")")
                print("Description: \(category.information ?? "N/A")")
                print("Image link: \(category.image ?? "N/A")")
                print("-------------------")
            }
            
        } catch let error {
            print(error)
        }
    }
    
    enum APIClientError: Error {
        case statusCode(Int)
        case clientError
        case serverError
        case parseError
        case failed(underlying: Error)
        case unknown
    }
    
}
