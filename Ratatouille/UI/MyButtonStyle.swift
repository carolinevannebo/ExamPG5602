//
//  MyButtonStyle.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 02/12/2023.
//

import Foundation
import SwiftUI

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(Color.myAccentColor)
                .frame(height: 50)
            
            configuration.label
                .foregroundColor(Color.mySubTitleColor)
                .fontWeight(.semibold)
        }
    }
}
