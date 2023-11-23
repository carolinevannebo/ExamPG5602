//
//  DarkModeViewModifier.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 23/11/2023.
//

import Foundation
import SwiftUI

public struct DarkModeViewModifier: ViewModifier {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true

    public func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
            .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
