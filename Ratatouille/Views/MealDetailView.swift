//
//  MealDetailView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 26/11/2023.
//

import SwiftUI

struct MealDetailView: View {
    @State var meal: MealModel
    @State var categoryIsPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                MealHeader(meal: $meal, categoryIsPresented: $categoryIsPresented)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .foregroundColor(.myDiffusedColor)
                        .shadow(radius: 5)
                        .opacity(0.5)
                    Text(meal.instructions!).padding()
                }
                .padding(.horizontal)
            }
            .navigationTitle(meal.name)
            .background(Color.myBackgroundColor)
            .toolbarBackground(.visible, for: .tabBar)
            .sheet(isPresented: $categoryIsPresented) {
                CategoryDetailView(category: meal.category!)
                    .modifier(DarkModeViewModifier()) // TODO: check darkmode
                    //.preferredColorScheme(.dark) // TODO: midlertidig
                    .presentationBackground(Color.myBackgroundColor.opacity(0.8))
            }
        }
        .modifier(DarkModeViewModifier()) // TODO: check darkmode
        //.environment(\.colorScheme, .dark) // TODO: midlertidig, du må endre fargene dine
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
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.mySecondaryColor)
                .shadow(radius: 5)
                .opacity(0.5)
            HStack {
                VStack (alignment: .leading) {
                    VStack {
                        CategoryButton(category: meal.wrappedValue.category!)
                            .onTapGesture {
                                categoryIsPresented.wrappedValue = true
                            }
                        AreaTextBox(area: meal.wrappedValue.area!)
                    }
                    .frame(height: 90)
                    // some ingredients
                    Spacer()
                    
                }
                .padding()
                
                if meal.wrappedValue.image != nil {
                    CircleImage(url: meal.wrappedValue.image!, width: 140, height: 140, strokeColor: .clear, lineWidth: 0)
                } else {
                    Image(uiImage: UIImage(named: "demoMeal")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.clear, lineWidth: 0))
                        .shadow(radius: 5)
                        .padding()
                }
            }
        }
        .frame(height: 200)
        .padding(.horizontal)
    }
}

struct CategoryDetailView: View {
    @State var category: CategoryModel
    
    var body: some View {
        ScrollView {
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
                        Image(uiImage: UIImage(named: "demoCategory")!) // TODO: meal.category.image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.clear, lineWidth: 0))
                            .shadow(radius: 5)
                            .padding(.trailing, 40)
                    }
                }
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
                Image(uiImage: flag!) // TODO: set default image if nil
                    .padding(.leading)
                
                Spacer()
                
                Text(area.name)
                    .foregroundColor(.mySubTitleColor)
                    .font(.system(size: 14))
                    .padding(.trailing)
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

//struct MealDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealDetailView(meal: DemoMeal().meal)
//    }
//}
