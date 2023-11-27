////
////  SearchFieldModifier.swift
////  Ratatouille
////
////  Created by Caroline Vannebo on 27/11/2023.
////
//
//import Foundation
//import SwiftUI
//
//struct SearchFieldModifier: ViewModifier {
//    var input: Binding<String>
//
//    func body(content: Content) -> some View {
//        content.overlay(
//            searchFieldView
//        )
//    }
//
//    var searchFieldView: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 25, style: .continuous)
//                .shadow(radius: 5)
//                .foregroundColor(Color.myAccentColor)
//
//            HStack {
//                TextField("",
//                          text: input,
//                          prompt: Text("Søk etter navn, bokstav, id...").foregroundColor(Color.myContrastColor)
//                ).onSubmit {
//                    Task {
//                        await MealListViewModel().searchMeals(isDemo: false)
//                    }
//                }
//
//                Image(systemName: "magnifyingglass")
//                    .resizable()
//                    .fontWeight(.semibold)
//                    .frame(width: 17, height: 17)
//                    .foregroundColor(Color.mySecondaryColor)
//            }
//            .padding(20)
//            .frame(minWidth: 100, minHeight: 40)
//            .foregroundColor(Color.mySecondaryColor)
//        }
//    }
//}
//
