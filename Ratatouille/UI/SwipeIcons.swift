//
//  SwipeIcons.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 24/11/2023.
//

import Foundation
import SwiftUI

struct HeartIcon: View {
    @StateObject var viewModel: MealItemViewModel
    
    var body: some View {
        HStack {
            Spacer()
            if (viewModel.hasTappedHeart) {
                Image(systemName: "heart.fill")
                    .onTapGesture {
                        viewModel.hasTappedHeart = false
                    }
            } else {
                Image(systemName: "heart")
                    .onTapGesture {
                        Task {
                            viewModel.hasTappedHeart = true
                            let result = await viewModel.saveFavorite.execute(input: viewModel.meal)
                            print(result)
                        }
                    }
            }
        }
        .foregroundColor(.mySwipeIconColor)
        .font(.system(size: 35))
        .padding(.trailing, 30)
    }
}

struct ArchiveIcon: View {
    @StateObject var viewModel: FavoritesViewModel
    
    var body: some View {
        HStack {
            Spacer()
            if (viewModel.hasTappedArchive) {
                Image(systemName: "archive.fill")
                    .onTapGesture {
                        viewModel.hasTappedArchive = false
                    }
            } else {
                Image(systemName: "archive")
                    .onTapGesture {
                        Task {
                            viewModel.hasTappedArchive = true
                            // TODO: call on function to archive favorite
                        }
                    }
            }
        }
        .foregroundColor(.mySwipeIconColor)
        .font(.system(size: 35))
        .padding(.trailing, 30)
    }
}
