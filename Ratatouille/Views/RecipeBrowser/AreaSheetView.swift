//
//  AreaSheetView.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 01/12/2023.
//

import SwiftUI

struct AreaSheetView: View {
    @StateObject var viewModel: RecipeBrowserViewModel
    @State private var searchArea: String = ""
    
    @State var filteredAreas: [Area] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<filteredAreas.count, id: \.self) { index in
                    Group {
                        if let mappedArea = mapArea(filteredAreas[index]) {
                            AreaTextBox(area: mappedArea, backgroundColor: .myAccentColor, textColor: .mySubTitleColor)
                        } else {
                            AreaTextBox(area: filteredAreas[index], backgroundColor: .myAccentColor, textColor: .mySubTitleColor)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        searchArea = ""
                        viewModel.chosenArea = filteredAreas[index].name
                        viewModel.searchAreaSheetPresented = false
                        Task { await viewModel.filterByArea() }
                    }
                } // Bug: background is not transparent when search input has no results
            }
            .listStyle(.plain)
            .navigationBarTitle("Landområder", displayMode: .inline)
            .searchable(text: $searchArea, prompt: "Søk etter landområder...")
            .onChange(of: searchArea) { newSearchArea in
                performSearch()
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadAreas()
                performSearch()
            }
        }
    }
    
    func performSearch() {
        Task {
            if searchArea.isEmpty {
                filteredAreas = viewModel.areas
            } else {
                filteredAreas = viewModel.areas.compactMap { mapArea($0)}
            }
        }
    }
    
    func mapArea(_ area: Area) -> Area? {
        guard area.name.localizedCaseInsensitiveContains(searchArea) else {
            return nil
        }
        return area
    }
}
