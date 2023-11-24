//
//  CategoryItemView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 24/11/2023.
//

import SwiftUI

class CategoryItemViewModel: ObservableObject {
    @Published var category: CategoryModel
    
    init(category: CategoryModel) {
        self.category = category
    }
}

struct CategoryItemView: View {
    @StateObject var viewModel: CategoryItemViewModel
    
    var body: some View {
        ZStack {
            
        }
    }
}

