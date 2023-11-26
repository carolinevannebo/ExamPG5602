//
//  MealDetailView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 26/11/2023.
//

import SwiftUI

struct MealDetailView: View {
    @State var meal: MealModel = DemoMeal().meal
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .foregroundColor(.mySecondaryColor)
                        .shadow(radius: 5)
                        .opacity(0.5)
                    HStack {
                        VStack (alignment: .leading) {
                            VStack {
                                CustomSubTitle(text: meal.category!.name)
                                CustomSubTitle(text: meal.area!.name)
                            }
                            .frame(height: 90)
                            // some ingredients
                            Spacer()
                            
                        }
                        .padding()
                        Image(uiImage: UIImage(named: "demo")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 0))
                            .shadow(radius: 5)
                            .padding()
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
                
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
        }
        .environment(\.colorScheme, .dark) // TODO: midlertidig, du må endre fargene dine
    }
}

struct CustomSubTitle: View {
    @State var text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.myAccentColor)
                .opacity(0.9)
                .shadow(radius: 2)
            HStack {
                Text(text)
                    .font(.system(size: 14))
                    .padding(.leading)
                Spacer()
                Image(systemName: "arrow.right")
                    .padding(.trailing)
            }
            .foregroundColor(.white)
            .opacity(0.7)
        }
    }
}

struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MealDetailView()
    }
}
