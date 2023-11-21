//
//  CircleImage.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 21/11/2023.
//

import SwiftUI

struct CircleImage: View {
    let url: String
    let width: CGFloat
    let height: CGFloat
    let strokeColor: Color
    let lineWidth: CGFloat
    
    @State private var image: Image = Image(systemName: "photo")
    
    var body: some View {
        Group {
            if let uiImage = loadImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(strokeColor, lineWidth: lineWidth))
                    .shadow(radius: 5)
                    .padding()
            } else {
                // Placeholder or error handling if image loading fails
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(strokeColor, lineWidth: lineWidth))
                    .shadow(radius: 5)
                    .padding()
            }
        }
    }

    func loadImage() -> UIImage? {
        guard let url = URL(string: url),
                let data = try? Data(contentsOf: url),
                let uiImage = UIImage(data: data) else {
            return nil
        }
        return uiImage
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        let url: String = "https://www.themealdb.com/images/media/meals/qqwypw1504642429.jpg"
        CircleImage(url: url, width: 50, height: 50, strokeColor: Color.white, lineWidth: 0)
    }
}
