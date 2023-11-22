//
//  APIClient.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 13/11/2023.
//

import Foundation
import CoreData
import SwiftUI

class APIClient: ObservableObject {
    //public var managedObjectContext = PersistenceController.shared.container.viewContext
    
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
    
    static func saveAreas(managedObjectContext: NSManagedObjectContext) async -> Void {
        do {
            let json = try await getJson(endpoint: listAreasEndpoint)
            let areas = parseJsonToAreas(json)
            
            //let managedObjectContext = PersistenceController.shared.container.viewContext // må refaktoreres til å brukes flere steder
            
            for areaData in areas {
                guard let name = areaData.name else {
                    print("Skipping area due to missing data")
                    continue
                }
                
                // Fetch or create Area
                let areaFetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
                areaFetchRequest.predicate = NSPredicate(format: "name == %@", name)
                
                if let fetchedArea = try managedObjectContext.fetch(areaFetchRequest).first {
                    // Area already exists, update it if needed
                    fetchedArea.name = name
                    print("Area already exists: \(fetchedArea.name ?? "")")
                } else {
                    // Create a new Area
                    let newArea = Area(context: managedObjectContext)
                    newArea.name = name
                    print("New area created: \(newArea.name ?? "")")
                }
            }
            
            // Save changes to Core Data
            DataController.shared.saveContext()

        } catch let error {
            print(error)
        }
    }
    
    static func saveIngredients(managedObjectContext: NSManagedObjectContext) async -> Void {
        do {
            let json = try await getJson(endpoint: listIngredientsEndpoint)
            let ingredients = parseJsonToIngredients(json)
            
            for ingredientData in ingredients {
                guard let id = ingredientData.id, let name = ingredientData.name else {
                    print("Skipping ingredient due to missing data")
                    continue
                }
                
                let ingredientFetchRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
                ingredientFetchRequest.predicate = NSPredicate(format: "id == %@", id)
                
                try await managedObjectContext.perform {
                    if let fetchedIngredient = try managedObjectContext.fetch(ingredientFetchRequest).first {
                        // Category already exists, update it if needed
                        fetchedIngredient.name = name
                        fetchedIngredient.information = ingredientData.information
                        print("Ingredient already exists: \(fetchedIngredient.name ?? "")")
                    } else {
                        // Create new ingredient
                        let newIngredient = Ingredient(context: managedObjectContext)
                        newIngredient.id = id
                        newIngredient.name = name
                        newIngredient.information = newIngredient.information
                        
                        print("New ingredient created: \(newIngredient.name ?? "")")
                    }
                }
            }
            
            // Save changes to Core Data
            DataController.shared.saveContext()
//            try await managedObjectContext.perform {
//                try managedObjectContext.save()
//            }
            
        } catch let error {
            print(error)
        }
    }
    
    static func saveCategories(managedObjectContext: NSManagedObjectContext) async -> Void {
        do {
            let json = try await getJson(endpoint: listCategoriesEndpoint)
            let categories = parseJsonToCategories(json)
            
            //let managedObjectContext = PersistenceController.shared.container.viewContext // må refaktoreres til å brukes flere steder
            
            for categoryData in categories {
                guard let id = categoryData.id, let name = categoryData.name else {
                    print("Skipping category due to missing data")
                    continue
                }
                        
                // Fetch or create Category
                let categoryFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "id == %@", id)
                
                try await managedObjectContext.perform {
                    if let fetchedCategory = try managedObjectContext.fetch(categoryFetchRequest).first {
                        // Category already exists, update it if needed
                        fetchedCategory.name = name
                        fetchedCategory.image = categoryData.image
                        fetchedCategory.information = categoryData.information
                        
                        print("Category already exists: \(fetchedCategory.name ?? "")")
                    } else {
                        // Create a new Category
                        let newCategory = Category(context: managedObjectContext)
                        newCategory.id = id
                        newCategory.name = name
                        newCategory.image = categoryData.image
                        newCategory.information = categoryData.information
                        
                        print("New category created: \(newCategory.name ?? "")")
                    }
                }
            }
                    
            DataController.shared.saveContext()
            
        } catch let error {
            print(error)
        }
    }
    
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
    
    private static func parseJsonToMeals(_ json: Data) -> [Meal] {
        do {
            let mealWrapper = try JSONDecoder().decode(MealsWrapper.self, from: json)
            
            if !mealWrapper.meals.isEmpty {
                return mealWrapper.meals
            } else {
                throw APIClientError.parseError
            }
        } catch let error {
            print(error)
        }
        return []
    }
    
    static func testIngredients() async {
        do {
            let json = try await getJson(endpoint: listIngredientsEndpoint)
            let ingredients = parseJsonToIngredients(json)
            
            ingredients.forEach { ingredient in
                print("ID: \(ingredient.id ?? "N/A")")
                print("Name: \(ingredient.name ?? "N/A")")
                print("Description: \(ingredient.information ?? "N/A")")
                print("-------------------")
            }
        } catch let error {
            print(error)
        }
    }
    
    static func testAreas() async {
        do {
            let json = try await getJson(endpoint: listAreasEndpoint)
            let areas = parseJsonToAreas(json)
            
            areas.forEach { area in
                print(area.name ?? "N/A")
                print("-------------------")
            }
        } catch let error {
            print(error)
        }
    }
    
    static func testCategories() async {
        do {
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
    
    static func testMeals() async { // TODO: write actual tests for this
        do {
            let json = try await getJson(endpoint: searchRandomEndpoint)
            
            let meals = parseJsonToMeals(json)
            meals.forEach { meal in
                print("id: \(meal.id ?? "N/A")")
                print("name: \(meal.name ?? "N/A")")
                print("instructions: \(meal.instructions ?? "N/A")")
                print("image link: \(meal.image ?? "N/A")")
                print("area: \(meal.area?.name ?? "N/A")")
                print("category: \(meal.category?.name ?? "N/A")")
                print("ingredients: ")
                
                meal.ingredients?.forEach { ingredient in
                    print("\((ingredient as! Ingredient).name ?? "N/A")")
                }
                
                print("-------------------")
            }
            
        } catch let error {
            print(error)
        }
    }
    
    static func getRandomMeal() async -> Result<Meal, APIClientError> {
        do {
            let json = try await getJson(endpoint: searchRandomEndpoint)
            let meals = parseJsonToMeals(json)

            if let meal = meals.first {
                return .success(meal)
            } else {
                return .failure(APIClientError.parseError)
            }
        } catch let error as APIClientError {
            return .failure(error)
        } catch {
            return .failure(APIClientError.failed(underlying: error))
        }
    }
    
    static func isNumeric(_ input: String) -> Bool {
        let numericRegex = "^[0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", numericRegex)
        return predicate.evaluate(with: input)
    }
    
    static func getMeals(input: String) async -> Result<[Meal], APIClientError> {
        do {
            var searchString = ""
            
            if isNumeric(input) { // searching by id
                searchString = "\(searchByIdEndpoint)\(input)"
            } else {
                if input.count == 1 {
                    searchString = "\(searchByLetterEndpoint)\(input)" // 1 or more results
                } else {
                    searchString = "\(searchByNameEndpoint)\(input)" // 1 result
                }
            }
            
            let json = try await getJson(endpoint: searchString)
            let meals = parseJsonToMeals(json)
            
            if isNumeric(input) && meals.isEmpty {
                return .failure(APIClientError.unMatchedId)
            }
            
            if input.count >= 1 && meals.isEmpty {
                return .failure(APIClientError.badInput)
            }
            
            if meals.isEmpty {
                return .failure(APIClientError.parseError)
            }
            
            return .success(meals)
            
        } catch let error as APIClientError {
            return .failure(error)
        } catch {
            return .failure(APIClientError.failed(underlying: error))
        }
    }
    
    static func getIngredients(input: String) async -> Result<[Ingredient], APIClientError> {
        do {
            let searchString = "\(searchByIngredientEndpoint)\(input)"
            let json = try await getJson(endpoint: searchString)
            let ingredients = parseJsonToIngredients(json)
            
            if !ingredients.isEmpty {
                return .success(ingredients)
            } else {
                return .failure(APIClientError.parseError)
            }
        } catch let error as APIClientError {
            return .failure(error)
        } catch {
            return .failure(APIClientError.failed(underlying: error))
        }
    }
    
    static func getAreas(input: String) async -> Result<[Area], APIClientError> {
        do {
            let searchString = "\(searchByAreaEndpoint)\(input)"
            let json = try await getJson(endpoint: searchString)
            let areas = parseJsonToAreas(json)
            
            if !areas.isEmpty {
                return .success(areas)
            } else {
                return .failure(APIClientError.parseError)
            }
        } catch let error as APIClientError {
            return .failure(error)
        } catch {
            return .failure(APIClientError.failed(underlying: error))
        }
    }
    
    static func getCategories(input: String) async -> Result<[Category], APIClientError> {
        do {
            let searchString = "\(searchByCategoryEndpoint)\(input)"
            let json = try await getJson(endpoint: searchString)
            let categories = parseJsonToCategories(json)
            
            if !categories.isEmpty {
                return .success(categories)
            } else {
                return .failure(APIClientError.parseError)
            }
        } catch let error as APIClientError {
            return .failure(error)
        } catch {
            return .failure(APIClientError.failed(underlying: error))
        }
    }
    
    static func deleteAllRecords(managedObjectContext: NSManagedObjectContext) async {
        //let managedObjectContext = PersistenceController.shared.container.viewContext
        
        let categoriesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let areasFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Area")
        let ingredientsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        let mealsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Meal")
        
        let categoriesDeleteRequest = NSBatchDeleteRequest(fetchRequest: categoriesFetchRequest)
        let areasDeleteRequest = NSBatchDeleteRequest(fetchRequest: areasFetchRequest)
        let ingredientsDeleteRequest = NSBatchDeleteRequest(fetchRequest: ingredientsFetchRequest)
        let mealsDeleteRequest = NSBatchDeleteRequest(fetchRequest: mealsFetchRequest)
            
        do {
            try await managedObjectContext.perform {
                
                try managedObjectContext.execute(categoriesDeleteRequest)
                try managedObjectContext.execute(areasDeleteRequest)
                try managedObjectContext.execute(ingredientsDeleteRequest)
                try managedObjectContext.execute(mealsDeleteRequest)
                
                DataController.shared.saveContext()
                print("All records deleted")
            }
            
        } catch {
            print("Error deleting records: \(error.localizedDescription)")
        }
    }
    
    enum APIClientError: Error {
        case statusCode(Int)
        case clientError
        case serverError
        case parseError
        case failed(underlying: Error)
        case badInput
        case unMatchedId
        case unknown
    }
}
