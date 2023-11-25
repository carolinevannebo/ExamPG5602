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
            if (viewModel.meal.isFavorite) {
                Image(systemName: "heart.fill")
                    .onTapGesture {
                        Task {
                            viewModel.hasTappedHeart = false
                            await viewModel.handleTappedHeart()
                        }
                    }
            } else {
                Image(systemName: "heart")
                    .onTapGesture {
                        Task {
                            viewModel.hasTappedHeart = true
                            await viewModel.handleTappedHeart()
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
    @StateObject var viewModel: FavoriteItemViewModel
    
    var body: some View {
        HStack {
            if (viewModel.hasTappedArchive) {
                Image(systemName: "archivebox.fill")
                    .onTapGesture {
                        Task {
                            viewModel.hasTappedArchive = false
                            await viewModel.handleTappedArchive()
                        }
                    }
            } else {
                Image(systemName: "archivebox")
                    .onTapGesture {
                        Task {
                            viewModel.hasTappedArchive = true
                            await viewModel.handleTappedArchive()
                        }
                    }
            }
            Spacer()
        }
        .foregroundColor(.mySwipeIconColor)
        .font(.system(size: 35))
        .padding(.leading, 30)
    }
}
