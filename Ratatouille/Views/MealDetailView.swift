//
//  MealDetailView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 26/11/2023.
//

import SwiftUI
import NukeUI

struct MealDetailView: View {
    @State var meal: MealModel
    @State var categoryIsPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Header
                MealHeader(meal: $meal, categoryIsPresented: $categoryIsPresented)
                
                // Ingredients
                IngredientList(ingredients: $meal.wrappedValue.ingredients!)
                
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

struct MealHeader: View {
    var meal: Binding<MealModel>
    var categoryIsPresented: Binding<Bool>
    
    init(meal: Binding<MealModel>, categoryIsPresented: Binding<Bool>) {
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
                            AreaTextBox(area: meal.wrappedValue.area!)
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

// Sheet
struct CategoryDetailView: View {
    @State var category: CategoryModel
    
    var body: some View {
        VStack {
            ZStack {
                // Header
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .foregroundColor(.myPrimaryColor)
                    HStack {
                        Text(category.name)
                            .foregroundColor(.myContrastColor)
                            .font(.system(size: 25))
                            .padding(.leading)
                        Spacer()
                    }
                }
                .frame(height: 50)
                
                HStack {
                    Spacer()
                    
                    if category.image != nil {
                        CircleImage(url: category.image!, width: 100, height: 100, strokeColor: .clear, lineWidth: 0).padding(.trailing, 40)
                    } else {
                        Image(uiImage: UIImage(named: "demoCategory")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.clear, lineWidth: 0))
                            .shadow(radius: 5)
                            .padding(.trailing, 40)
                    }
                }
                .padding()
            }
            
            // Content
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundColor(.myPrimaryColor)
                Text(category.information!)
                    .foregroundColor(.myContrastColor)
                    .padding()
            }
        }
        .padding()
    }
}

struct AreaTextBox: View {
    @State var area: AreaModel
    @State var flag: UIImage?
    
    let fetchFlagCommand = FetchFlagCommand()
    
    func setFlag() async {
        do {
            if let flag = await fetchFlagCommand.execute(input: area) {
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
                .foregroundColor(.myAccentColor)
                .opacity(0.9)
                .shadow(radius: 2)
            HStack {
                Text(area.name)
                    .foregroundColor(.mySubTitleColor)
                    .font(.system(size: 14))
                    .padding(.leading)
                
                Spacer()
                
                if flag != nil {
                    Image(uiImage: flag!).padding(.trailing)// TODO: set default image if nil
                }
            }
        }
        .onAppear {
            Task {
                await setFlag()
            }
        }
    }
}

struct CategoryButton: View {
    @State var category: CategoryModel
    
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

struct SectionHeader: View {
    // source: https://github.com/ondrej-kvasnovsky/collapsable-expandable-list
    @Binding var isOn: Bool
    @State var title: String
    @State var onLabel: String
    @State var offLabel: String
    
    var body: some View {
        Button(action: {
            withAnimation {
                isOn.toggle()
            }
        }, label: {
            if isOn {
                Text(offLabel)
            } else {
                Text(onLabel)
            }
        })
        .font(.caption)
        .foregroundColor(.myAccentColor)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .overlay(
            Text(title),
            alignment: .leading
        )
    }
}


// TODO: FÅR IKKE LISTA TIL Å COMPRIMERES, DEN TAR OPP ALL WHITESPACE NÅR DEN SKAL VÆRE LUKKET
struct IngredientList: View {
    @State var ingredients: [IngredientModel]
    @State var isShowingSection = false
    
    var body: some View {
        NavigationView {
                List {
                    Section(
                        "Ingredienser"
//                        header: SectionHeader(isOn: $isShowingSection, title: "Ingredienser", onLabel: "Vis", offLabel: "Skjul")
                    ) {
                        
//                        if isShowingSection {
                            IngredientListContent(ingredients: ingredients)
//                        }
                    }
                }
                .padding(.horizontal)
                .listStyle(.plain)
                .background(Color.myBackgroundColor)
        }
        .padding(.bottom)
//        .frame(minHeight: 70, maxHeight: 300)
    }
}

struct IngredientListContent: View {
    var ingredients: [IngredientModel]
    
    var body: some View {
        ForEach(0..<ingredients.count, id: \.self) { index in
            Text(ingredients[index].name!)
                .foregroundColor(.myContrastColor)
                .listRowSeparatorTint(Color.myAccentColor)
                .listRowBackground(Color.clear.opacity(0))
        }
    }
}

struct InstructionsSection: View {
    var meal: MealModel
    
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
                
                Spacer()
           
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
