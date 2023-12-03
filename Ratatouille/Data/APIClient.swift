//
//  APIClient.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 22/11/2023.
//

import Foundation
import CoreData

struct APIClient {
    static func getJson(endpoint: String) async throws -> Data {
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
    
    enum APIClientError: Error, LocalizedError {
        case statusCode(Int?)
        case clientError
        case serverError
        case parseError
        case failed(underlying: Error?)
        case badInput
        case unMatchedId
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .clientError:
                return NSLocalizedString("Noe gikk galt hos klienten.", comment: "")
            case .serverError:
                return NSLocalizedString("Noe gikk galt hos serveren.", comment: "")
            case .parseError:
                return NSLocalizedString("Klarte ikke omgjøre data til et leselig format.", comment: "")
            case .badInput:
                return NSLocalizedString("Vennligst oppi gyldig input.", comment: "")
            case .unMatchedId:
                return NSLocalizedString("Ugyldig id.", comment: "")
            default:
                return NSLocalizedString("Noe gikk galt, prøv igjen.", comment: "")
            }
        }
    }
}

extension APIClient {
    private static var searchByNameEndpoint = "https://www.themealdb.com/api/json/v1/1/search.php?s=" // Search meal by name
    private static var searchByLetterEndpoint = "https://www.themealdb.com/api/json/v1/1/search.php?f=" // List all meals by first letter
    private static var searchByIdEndpoint = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=" // Lookup full meal details by id
    private static var searchRandomEndpoint = "https://www.themealdb.com/api/json/v1/1/random.php" // Lookup single random meal
    
    private static func parseJsonToMeals(_ json: Data) -> [MealModel] {
        do {
            let mealWrapper = try JSONDecoder().decode(MealWrapper.self, from: json)
            print("parsing \(mealWrapper.meals.count) meals")
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
    
    static func getRandomMeal() async -> Result<MealModel, APIClientError> {
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
    
    static func filterMealsByArea(input: String) async -> Result<[MealModel], APIClientError> {
        do {
            let searchString = "\(searchByAreaEndpoint)\(input)"
            
            let json = try await getJson(endpoint: searchString)
            let meals = parseJsonToMeals(json)
            
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
    
    static func filterMealsByCategory(input: String) async -> Result<[MealModel], APIClientError> {
        do {
            let searchString = "\(searchByCategoryEndpoint)\(input)"
            
            let json = try await getJson(endpoint: searchString)
            let meals = parseJsonToMeals(json)
            
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
    
    static func replaceSpaces(withUnderscores input: String) -> String {
        return input.replacingOccurrences(of: " ", with: "_")
    }
    
    static func filterMealsByIngredient(input: String) async -> Result<[MealModel], APIClientError> {
        do {
            let safeInput = replaceSpaces(withUnderscores: input)
            
            let searchString = "\(searchByIngredientEndpoint)\(safeInput)"
            
            let json = try await getJson(endpoint: searchString)
            let meals = parseJsonToMeals(json)
            
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
    
    static func getMeals(input: String) async -> Result<[MealModel], APIClientError> {
        do {
            var searchString = ""
            
            if input == " " {
                return .failure(APIClientError.badInput)
            }
            
            if isNumeric(input) { // searching by id
                searchString = "\(searchByIdEndpoint)\(input)"
            } else {
                if input.count == 1 {
                    searchString = "\(searchByLetterEndpoint)\(input)" // 1 or more results
                } else {
                    let safeInput = replaceSpaces(withUnderscores: input)
                    searchString = "\(searchByNameEndpoint)\(safeInput)" // 1 result
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
    
    static func fetchAdditionalInformation(for meal: MealModel) async throws -> MealModel? {
        do {
            let result = await APIClient.getMeals(input: meal.id)
            
            switch result {
            case .success(let idMeals):
                return idMeals.first
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error in fetchAdditionalInformation: \(error)")
            return nil
        }
    }
    
    static func testMeals() async { // TODO: write actual tests for this
        do {
            let json = try await getJson(endpoint: searchRandomEndpoint)
            let meals = parseJsonToMeals(json)
                
            meals.forEach { meal in
                print("id: \(meal.id )")
                print("name: \(meal.name )")
                print("instructions: \(meal.instructions ?? "N/A" )")
                print("image link: \(meal.image ?? "N/A")")
                print("area: \(meal.area?.name ?? "N/A")")
                print("category: \(meal.category?.name ?? "N/A")")
                print("ingredients: ")
    
//                meal.ingredients.forEach { ingredient in
//                    print("\((ingredient).name ?? "N/A")")
//                }
    
                print("-------------------")
            }
    
        } catch let error {
            print(error)
        }
    }
}

extension APIClient {
    private static var listAreasEndpoint = "https://www.themealdb.com/api/json/v1/1/list.php?a=list" // List all areas
    private static var searchByAreaEndpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?a=" // Filter by area
    
    private static func parseJsonToAreas(_ json: Data) -> [AreaModel] {
        do {
            var areasWrapper = try JSONDecoder().decode(AreaWrapper.self, from: json)
            if !areasWrapper.meals.isEmpty {
                
                // need to give areas an id (1-28)
                for i in 0..<areasWrapper.meals.count {
                    areasWrapper.meals[i].id = String(i+1)
                }
                
                return areasWrapper.meals
            } else {
                throw APIClientError.parseError
            }
            
        } catch let error {
            print(error)
        }
        
        return []
    }
    
    static func getAreas() async -> Result<[AreaModel], APIClientError> {
        do {
            let json = try await getJson(endpoint: listAreasEndpoint)
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
    
    static func saveAreas(managedObjectContext: NSManagedObjectContext) async -> Void {
        do {
            let json = try await getJson(endpoint: listAreasEndpoint)
            let areas = parseJsonToAreas(json)
            
            for areaData in areas {
                // Fetch or create Area
                let areaFetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
                areaFetchRequest.predicate = NSPredicate(format: "name == %@", areaData.name.capitalized) // nå som du har ordna id burde predicate endres
                
                if let fetchedArea = try managedObjectContext.fetch(areaFetchRequest).first {
                    // Area already exists
                    if fetchedArea.id == nil {
                        fetchedArea.id = areaData.id
                    }
                    print("Area already exists: \(fetchedArea.name) with id: \(fetchedArea.id ?? "no id")")
                } else {
                    // Create a new Area
                    let newArea = Area(context: managedObjectContext)
                    newArea.name = areaData.name
                    newArea.id = areaData.id //String(areas.count + 1) <-- denne skal til add new area
                    
                    print("New area created: \(newArea.name)")
                }
            }
            
            DataController.shared.saveContext()
            
            // check how many areas are saved in coredata
            let countFetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
            do {
                let count = try managedObjectContext.count(for: countFetchRequest)
                print("Number of areas saved: \(count)")
            } catch {
                print("Error counting areas: \(error)")
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
                print(area.name )
                print("-------------------")
            }
        } catch let error {
            print(error)
        }
    }
}

extension APIClient {
    private static var listCategoriesEndpoint = "https://www.themealdb.com/api/json/v1/1/categories.php" // List all meal categories
    private static var searchByCategoryEndpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?c=" // Filter by category
    
    private static func parseJsonToCategories(_ json: Data) -> [CategoryModel] {
        do {
            let categoriesWrapper = try JSONDecoder().decode(CategoryWrapper.self, from: json)
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
    
    static func getCategories() async -> Result<[CategoryModel], APIClientError> {
        do {
            let json = try await getJson(endpoint: listCategoriesEndpoint)
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
    
    static func saveCategories(managedObjectContext: NSManagedObjectContext) async -> Void {
        do {
            let json = try await getJson(endpoint: listCategoriesEndpoint)
            let categories = parseJsonToCategories(json)
            
            for categoryData in categories {
                guard let id = categoryData.id else {
                    print("Skipping category due to missing data")
                    continue
                }
                        
                // Fetch or create Category
                let categoryFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "id == %@", id)
                
                try await managedObjectContext.perform {
                    if let fetchedCategory = try managedObjectContext.fetch(categoryFetchRequest).first {
                        
                        print("Category already exists: \(fetchedCategory.name )")
                    } else {
                        // Create a new Category
                        let newCategory = Category(context: managedObjectContext)
                        newCategory.id = id
                        newCategory.name = categoryData.name
                        newCategory.image = categoryData.image
                        newCategory.information = categoryData.information
                        
                        print("New category created: \(newCategory.name )")
                        DataController.shared.saveContext()
                    }
                }
            }
            
            // check how many categories are saved in coredata
            let countFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            do {
                let count = try managedObjectContext.count(for: countFetchRequest)
                print("Number of categories saved: \(count)")
                let categoriesInCD = try managedObjectContext.fetch(countFetchRequest)
                for categoryInCD in categoriesInCD {
                    print("This CoreData category has id \(categoryInCD.id ?? "unknown")") // they all have an id
                }
            } catch {
                print("Error counting categories: \(error)")
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
                print("Name: \(category.name )")
                print("Description: \(category.information ?? "N/A")")
                print("Image link: \(category.image ?? "N/A")")
                print("-------------------")
            }
        } catch let error {
            print(error)
        }
    }
}

extension APIClient {
    private static var listIngredientsEndpoint = "https://www.themealdb.com/api/json/v1/1/list.php?i=list" // List all ingredients
    private static var searchByIngredientEndpoint = "https://www.themealdb.com/api/json/v1/1/filter.php?i=" // Filter by main ingredient
    
    private static func parseJsonToIngredients(_ json: Data) -> [IngredientModel] {
        do {
            let ingredientsWrapper = try JSONDecoder().decode(IngredientWrapper.self, from: json)
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
    
    static func getIngredients() async -> Result<[IngredientModel], APIClientError> {
        do {
            let json = try await getJson(endpoint: listIngredientsEndpoint)
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
    
    static func saveIngredients(managedObjectContext: NSManagedObjectContext) async -> Void {
        do {
            let json = try await getJson(endpoint: listIngredientsEndpoint)
            let ingredients = parseJsonToIngredients(json)
            
            for ingredientData in ingredients {
                guard let id = ingredientData.id else {
                    print("Skipping ingredient due to missing data")
                    continue
                }
                
                let ingredientFetchRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
                ingredientFetchRequest.predicate = NSPredicate(format: "id == %@", id)
                
                try await managedObjectContext.perform {
                    if let fetchedIngredient = try managedObjectContext.fetch(ingredientFetchRequest).first {
                        print("Ingredient already exists: \(fetchedIngredient.name ?? "unknown" ) with ID: \(fetchedIngredient.id ?? "unknown")")
                    } else {
                        // Create new ingredient
                        let newIngredient = Ingredient(context: managedObjectContext)
                        newIngredient.id = id
                        newIngredient.name = ingredientData.name?.capitalized
                        newIngredient.information = newIngredient.information
                        
                        print("New ingredient created: \(newIngredient.name ?? "unknown") with id: \(newIngredient.id ?? "unknown")")
                        DataController.shared.saveContext()
                    }
                }
            }
            
        } catch let error {
            print("Could not save ingredients: \(error)")
        }
    }
    
    static func testIngredients() async {
        do {
            let json = try await getJson(endpoint: listIngredientsEndpoint)
            let ingredients = parseJsonToIngredients(json)
            
            ingredients.forEach { ingredient in
                print("ID: \(ingredient.id ?? "N/A")")
                print("Name: \(ingredient.name ?? "N/A" )")
                print("Description: \(ingredient.information ?? "N/A")")
                print("-------------------")
            }
        } catch let error {
            print(error)
        }
    }
}
