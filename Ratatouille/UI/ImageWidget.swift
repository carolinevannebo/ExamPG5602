//
//  MealImageWidget.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 24/11/2023.
//

import Foundation
import SwiftUI

struct ImageWidget: View {
    let url: String
    
    init(url: String) {
        self.url = url
    }
    
    var body: some View {
        ZStack (alignment: .leading) {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .foregroundColor(.mySecondaryColor)
                
            CircleImage(url: url, width: 65, height: 65, strokeColor: Color.white, lineWidth: 0).padding()
        }.frame(width: 90)
    }
}
