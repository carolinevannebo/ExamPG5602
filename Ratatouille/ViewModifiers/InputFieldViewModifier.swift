//
//  InputFieldViewModifier.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 30/11/2023.
//

import Foundation
import SwiftUI

enum InputType {
    case inputMeal
    case inputArea
}

struct InputFieldViewModifier: ViewModifier {
    @StateObject var viewModel: RecipeBrowserViewModel
    
    var areaInput: Binding<String>?
    let inputType: InputType
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                switch inputType {
                case .inputMeal: mealInputView
                case .inputArea: areaInputView
                }
            }
        )
    }
    
    var mealInputView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .shadow(radius: 1)
                .foregroundColor(Color.myInputBgColor)
                
            HStack {
                TextField("", text: $viewModel.input).placeholder(when: $viewModel.input.wrappedValue.isEmpty) {
                    Text("Søk etter navn, bokstav, id...").foregroundColor(Color.myPlaceholderColor)
                }
                .onSubmit {
                    Task {
                        await viewModel.searchMeals(isDemo: false)
                    }
                }
                        
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .frame(width: 17, height: 17)
            }
            .padding(20)
            .frame(minWidth: 100, minHeight: 40)
            .foregroundColor(Color.myInputTextColor)
        }
    }
    
    var areaInputView: some View { // TODO: #1 kom tilbake hit etter refaktorering
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .shadow(radius: 1)
                .foregroundColor(Color.myInputBgColor)
            HStack {
                TextField("", text: areaInput!).placeholder(when: ((areaInput?.wrappedValue.isEmpty) != nil)) {
                    Text("Søk etter landområde...").foregroundColor(Color.myPlaceholderColor)
                }
                .onSubmit {
                    Task {
//                        await viewModel.searchMeals(isDemo: false)
                    }
                }
                        
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .frame(width: 10, height: 10)
            }
            .padding(20)
            .frame(minWidth: 80, minHeight: 20)
            .foregroundColor(Color.myInputTextColor)
        }
    }
}
