//
//  ViewCoordinator.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 23/11/2023.
//

import SwiftUI
import SwiftyGif

struct ViewCoordinator: View {
    @State private var isActive: Bool = false
    @State private var opacity: Double = 0
    
    var body: some View {
        if isActive {
            MainView()
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.7)) {
                        self.opacity = 1
                    }
                }
        } else {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        isActive = true
                    }
                }
        }
    }
}

struct MainView: View {
    @State private var selection = 2
    
    var body: some View {
        TabView(selection: $selection) {
            
            Group {
                FavoritesView().tabItem {
                    Label("Favoritter", systemImage: "heart.circle.fill").padding()
                }.tag(1)
                
                RecipeBrowserView().tabItem {
                    Label("Oppskrifter", systemImage: "magnifyingglass.circle.fill").padding()
                }.tag(2)
                
                SettingsView().tabItem {
                    Label("Innstillinger", systemImage: "gear.circle.fill").padding()
                }.tag(3)
                
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(Color.myBackgroundColor, for: .tabBar)
        }
        .modifier(DarkModeViewModifier())
    }
}


struct SplashView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer().frame(height: 300)
                AnimatedGif(url: Binding.constant(Bundle.main.url(forResource: "remy-eating", withExtension: "gif")!))
            }
        }
        .ignoresSafeArea()
    }
}
