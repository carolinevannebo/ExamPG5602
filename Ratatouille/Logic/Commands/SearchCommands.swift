//
//  SearchCommands.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 25/11/2023.
//

import Foundation

class SearchRandomCommand: ICommand {
    typealias Input = Void
    typealias Output = MealModel?

    func execute(input: Input) async -> Output {
        do {
            let result = await APIClient.getRandomMeal()

            switch result {
                case .success(let meal):
                print("Got meal: \(meal.name )")
                    return meal
                case .failure(let error):
                    throw error
            }
        } catch {
            print("Unexpected error in SearchRandomCommand: \(error)")
            return nil
        }
    }
}

class SearchMealsCommand: ICommand {
    typealias Input = String
    typealias Output = Result<[MealModel], Error>
    
    func execute(input: Input) async -> Output {
        do {
            print("Searching for meals with input: \(input)")
            let result = await APIClient.getMeals(input: input)
            
            switch result {
                
            case .success(var meals):
                print("Got \(meals.count) meals, loading isFavorite attribute...")
                
                meals = await ConnectAttributesCommand().execute(input: meals)
                
                return .success(meals)
                
            case .failure(let error):
                switch error { // TODO: burde fikse error messages som i archivecommands, men prioriter funksjonalitet nå
                    case .badInput:
                        print("No results for the provided input")
                        throw error
                    case .unMatchedId:
                        print("No id matched search")
                        throw error
                    default:
                        print("Unexpected error: \(error)")
                        throw error
                }
            }
        } catch {
            print("Error in SearchMealsCommand: \(error)")
            return .failure(error)
        }
    }
}

//class SearchMealsCommand: ICommand {
//    typealias Input = String
//    typealias Output = [MealModel]?
//    
//    func execute(input: Input) async -> Output {
//        do {
//            print("Searching for meals with input: \(input)")
//            let result = await APIClient.getMeals(input: input)
//            
//            switch result {
//                
//            case .success(var meals):
//                print("Got \(meals.count) meals, loading isFavorite attribute...")
//                
//                meals = await ConnectAttributesCommand().execute(input: meals)
//                
//                return meals
//                
//            case .failure(let error):
//                switch error {
//                    case .badInput:
//                        print("No results for the provided input")
//                        throw error
//                    case .unMatchedId:
//                        print("No id matched search")
//                        throw error
//                    default:
//                        print("Unexpected error: \(error)")
//                        throw error
//                }
//            }
//        } catch {
//            print("Error in SearchMealsCommand: \(error)") // TODO: feilhåndtering med meldinger til UI
//            return nil
//        }
//    }
//}

class FilterByAreaCommand: ICommand {
    typealias Input = String
    typealias Output = Result<[MealModel], Error>
    
    func execute(input: Input) async -> Output {
        do {
            let result = await APIClient.filterMealsByArea(input: input)
            
            switch result {
            case .success(let meals):
                var completeMeals = try await withThrowingTaskGroup(of: MealModel.self) { group in
                    for meal in meals {
                        group.addTask {
                            do {
                                return try await APIClient.fetchAdditionalInformation(for: meal)!
                            } catch {
                                print("Error fetching additional information: \(error)")
                                return meal
                            }
                        }
                    }
                    
                    return try await group.reduce(into: []) { result, element in
                        result.append(element)
                    }
                }
                
                completeMeals = await ConnectAttributesCommand().execute(input: completeMeals)
                return .success(completeMeals)
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error in FilterByAreaCommand: \(error)")
            return .failure(error)
        }
    }
}

//class FilterByAreaCommand: ICommand {
//    typealias Input = String
//    typealias Output = [MealModel]?
//    
//    func execute(input: Input) async -> Output {
//        do {
//            let result = await APIClient.filterMealsByArea(input: input)
//            
//            switch result {
//            case .success(let meals):
//                var completeMeals = try await withThrowingTaskGroup(of: MealModel.self) { group in
//                    for meal in meals {
//                        group.addTask {
//                            do {
//                                return try await APIClient.fetchAdditionalInformation(for: meal)!
//                            } catch {
//                                print("Error fetching additional information: \(error)")
//                                return meal
//                            }
//                        }
//                    }
//                    
//                    return try await group.reduce(into: []) { result, element in
//                        result.append(element)
//                    }
//                }
//                
//                completeMeals = await ConnectAttributesCommand().execute(input: completeMeals)
//                return completeMeals
//            case .failure(let error):
//                throw error
//            }
//        } catch {
//            print("Unexpected error in FilterByAreaCommand: \(error)")
//            return nil
//        }
//    }
//}

class FilterByCategoryCommand: ICommand {
    typealias Input = String
    typealias Output = Result<[MealModel], Error>

    func execute(input: Input) async -> Output {
        do {
            
            let result = await APIClient.filterMealsByCategory(input: input)

            switch result {
                case .success(let meals):
                
                // API responds with incomplete meals, matching information with id to fetch additional attributes
                var completeMeals = try await withThrowingTaskGroup(of: MealModel.self) { group in
                    for meal in meals {
                        group.addTask {
                            do {
                                return try await APIClient.fetchAdditionalInformation(for: meal)!
                            } catch {
                                print("Error fetching additional information: \(error)")
                                return meal
                            }
                        }
                    }
                    
                    return try await group.reduce(into: []) { result, element in
                        result.append(element)
                    }
                }
                
                // Assigning isFavorite attribute based on match/no match in CoreData
                completeMeals = await ConnectAttributesCommand().execute(input: completeMeals)
                
                return .success(completeMeals)
                case .failure(let error):
                    throw error
            }
        } catch {
            print("Unexpected error in FilterByCategoryCommand: \(error)")
            return .failure(error)
        }
    }
}

// TODO: this filter logic is slow, fix it -> a little better, but can still be better
//class FilterByCategoryCommand: ICommand {
//    typealias Input = String
//    typealias Output = [MealModel]?
//
//    func execute(input: Input) async -> Output {
//        do {
//            let result = await APIClient.filterMealsByCategory(input: input)
//
//            switch result {
//                case .success(let meals):
//                
//                // API responds with incomplete meals, matching information with id to fetch additional attributes
//                var completeMeals = try await withThrowingTaskGroup(of: MealModel.self) { group in
//                    for meal in meals {
//                        group.addTask {
//                            do {
//                                return try await APIClient.fetchAdditionalInformation(for: meal)!
//                            } catch {
//                                print("Error fetching additional information: \(error)")
//                                return meal
//                            }
//                        }
//                    }
//                    
//                    return try await group.reduce(into: []) { result, element in
//                        result.append(element)
//                    }
//                }
//                
//                // Assigning isFavorite attribute based on match/no match in CoreData
//                completeMeals = await ConnectAttributesCommand().execute(input: completeMeals)
//                
//                return completeMeals
//                case .failure(let error):
//                    throw error
//            }
//        } catch {
//            print("Unexpected error in FilterByCategoryCommand: \(error)")
//            return nil
//        }
//    }
//}

class FilterByIngredientCommand: ICommand {
    typealias Input = String
    typealias Output = Result<[MealModel], Error>
    
    func execute(input: Input) async -> Output {
        do {
            let result = await APIClient.filterMealsByIngredient(input: input)
            
            switch result {
            case .success(let meals):
                var completeMeals = try await withThrowingTaskGroup(of: MealModel.self) { group in
                    for meal in meals {
                        group.addTask {
                            do {
                                return try await APIClient.fetchAdditionalInformation(for: meal)!
                            } catch {
                                print("Error fetching additional information: \(error)")
                                return meal
                            }
                        }
                    }
                    
                    return try await group.reduce(into: []) { result, element in
                        result.append(element)
                    }
                }
                
                completeMeals = await ConnectAttributesCommand().execute(input: completeMeals)
                return .success(completeMeals)
            case .failure(let error):
                throw error
            }
        } catch {
            print("Unexpected error in FilterByIngredientCommand: \(error)")
            return .failure(error)
        }
    }
}

//class FilterByIngredientCommand: ICommand {
//    typealias Input = String
//    typealias Output = [MealModel]?
//    
//    func execute(input: Input) async -> Output {
//        do {
//            let result = await APIClient.filterMealsByIngredient(input: input)
//            
//            switch result {
//            case .success(let meals):
//                var completeMeals = try await withThrowingTaskGroup(of: MealModel.self) { group in
//                    for meal in meals {
//                        group.addTask {
//                            do {
//                                return try await APIClient.fetchAdditionalInformation(for: meal)!
//                            } catch {
//                                print("Error fetching additional information: \(error)")
//                                return meal
//                            }
//                        }
//                    }
//                    
//                    return try await group.reduce(into: []) { result, element in
//                        result.append(element)
//                    }
//                }
//                
//                completeMeals = await ConnectAttributesCommand().execute(input: completeMeals)
//                return completeMeals
//            case .failure(let error):
//                throw error
//            }
//        } catch {
//            print("Unexpected error in FilterByIngredientCommand: \(error)")
//            return nil
//        }
//    }
//}
