//
//  CategoryDetailView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 02/12/2023.
//

import SwiftUI

struct CategoryDetailView<CategoryType: CategoryRepresentable>: View {
    @State var category: CategoryType
    
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
                Text(category.information ?? "Kunne ikke laste inn informasjon.")
                    .foregroundColor(.myContrastColor)
                    .padding()
            }
        }
        .padding()
    }
}
