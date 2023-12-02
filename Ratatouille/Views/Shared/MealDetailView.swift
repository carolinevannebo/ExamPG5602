//
//  MealDetailView.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 26/11/2023.
//

import SwiftUI
import NukeUI

struct MealDetailView<MealType: MealRepresentable>: View {
    @State var meal: MealType
    @State var categoryIsPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Header
                MealHeader(meal: $meal, categoryIsPresented: $categoryIsPresented)
                
                // Ingredients
                IngredientList<MealType>(ingredients: $meal.wrappedValue.ingredients!)
                
                // Instructions
                InstructionsSection(meal: $meal.wrappedValue)
            }
            .navigationTitle(meal.name)
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
            .sheet(isPresented: $categoryIsPresented) {
                // Category information sheet
                CategoryDetailView(category: meal.category!)
                    .modifier(DarkModeViewModifier())
                    .presentationDetents([.medium, .large])
                    .presentationBackground(Color.myBackgroundColor.opacity(0.8))
            }
        }
        .modifier(DarkModeViewModifier())
    }
}

struct MealHeader<MealType: MealRepresentable>: View {
    var meal: Binding<MealType>
    var categoryIsPresented: Binding<Bool>
    
    init(meal: Binding<MealType>, categoryIsPresented: Binding<Bool>) {
        self.meal = meal
        self.categoryIsPresented = categoryIsPresented
    }
    
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.mySecondaryColor)
                    .shadow(radius: 5)
                    .opacity(0.5)
                
                // Text boxes
                HStack {
                    VStack (alignment: .leading) {
                            CategoryButton(category: meal.wrappedValue.category!)
                                .onTapGesture {
                                    categoryIsPresented.wrappedValue = true
                                }
                        AreaTextBox(area: meal.wrappedValue.area!, backgroundColor: .myAccentColor, textColor: .mySubTitleColor)
                        Spacer()
                        
                    }
                    .frame(width: 175, height: 90)
                    .padding()
                    
                    Spacer()
                }
            }
            .frame(height: 110)
            .padding(.vertical)
            
            // Meal image
            HStack {
                Spacer()
                
                if meal.wrappedValue.image != nil {
                    CircleImage(url: meal.wrappedValue.image!, width: 140, height: 140, strokeColor: .clear, lineWidth: 0).padding(.trailing)
                } else {
                    Image(uiImage: UIImage(named: "demoMeal")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.clear, lineWidth: 0))
                        .shadow(radius: 5)
                        .padding(.trailing)
                }
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
    }
}

struct AreaTextBox<AreaType: AreaRepresentable>: View {
    @State var area: AreaType
    @State var flag: UIImage?
    
    @State var backgroundColor: Color
    @State var textColor: Color
    
    let fetchFlagCommand = FetchFlagCommand()
    
    func setFlag() async {
        do {
            if let flag = await fetchFlagCommand.execute(input: area.name) {
                DispatchQueue.main.async {
                    self.flag = flag
                }
            } else {
                throw AreaTextBoxError.noFlag
            }
        } catch {
            print("Unexpected error while setting flag to view: \(error)")
        }
    }
    
    enum AreaTextBoxError: Error {
        case noFlag
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(backgroundColor)
                .opacity(0.9)
                .shadow(radius: 2)
            HStack {
                Text(area.name)
                    .foregroundColor(textColor)
                    .font(.system(size: 14))
                    .padding(.leading)
                
                Spacer()
                
                if flag != nil {
                    Image(uiImage: flag!).padding(.trailing)
                }
            }
        }
        .onAppear {
            Task { await setFlag() }
        }
    }
}

struct CategoryButton<CategoryType: CategoryRepresentable>: View {
    @State var category: CategoryType
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.myAccentColor)
                .opacity(0.9)
                .shadow(radius: 2)
            HStack {
                Text(category.name)
                    .font(.system(size: 14))
                    .padding(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .padding(.trailing)
            }
            .foregroundColor(.mySubTitleColor)
        }
    }
}

struct IngredientList<MealType: MealRepresentable>: View where MealType.IngredientType: IngredientRepresentable {
    @State var isShowingSection = false
    @State var ingredients: MealType.IngredientsCollection
    
    var body: some View {
        NavigationView {
            List {
                Section("Ingredienser") {
                    if let arrayIngredients = ingredients as? [IngredientRepresentable] {
                        IngredientArrayContent(ingredients: arrayIngredients)
                    } else if let nsSetIngredients = ingredients as? NSSet {
                        IngredientNSSetContent(ingredients: nsSetIngredients)
                    }
                }
            }
            .listStyle(.plain)
            .padding(.horizontal)
            .background(Color.myBackgroundColor)
        }
    }
}

struct IngredientArrayContent: View {
    var ingredients: [IngredientRepresentable]
    
    var body: some View {
        ForEach(0..<ingredients.count, id: \.self) { index in
            Text(ingredients[index].name!)
                .foregroundColor(.myContrastColor)
                .listRowSeparatorTint(Color.myAccentColor)
                .listRowBackground(Color.clear.opacity(0))
        }
    }
}

struct IngredientNSSetContent: View {
    var ingredients: NSSet
    
    var body: some View {
        ForEach(Array(ingredients) as! [IngredientRepresentable], id: \.id) { ingredient in
            Text(ingredient.name!)
                .foregroundColor(.myContrastColor)
                .listRowSeparatorTint(Color.myAccentColor)
                .listRowBackground(Color.clear.opacity(0))
        }
    }
}

struct InstructionsSection<MealType: MealRepresentable>: View {
    //var meal: MealModel
    var meal: MealType
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.mySecondaryColor)
                .shadow(radius: 5)
                .opacity(0.5)
                .padding(.top)
            
            LazyVStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .foregroundColor(.myAccentColor)
                        .shadow(radius: 5)
                        .frame(width: 230, height: 40)
                    
                    Text("Instruksjoner")
                        .font(.system(size: 20))
                        .foregroundColor(.mySubTitleColor)
                }
                
                Text(meal.instructions!)
                    .foregroundColor(.myContrastColor)
                    .padding()
                
                // YouTube video?
            }
        }
        .padding(.horizontal)
    }
}

struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MealDetailView(meal: DemoMeal().meal)
    }
}
