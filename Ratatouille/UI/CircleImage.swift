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
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(Circle())
                .overlay(Circle().stroke(strokeColor, lineWidth: lineWidth))
                .shadow(radius: 5)
                //.padding()
        } else {
            // You might want to replace this with a placeholder or loading spinner
            ImageLoadingAnimation(width: width, height: height)
                .onAppear { loadImage() }
        }
    }

    func loadImage() {
        guard let url = URL(string: url) else {
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }

            guard let data = data, error == nil else {
                return
            }

            if let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }.resume()
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        let url: String = "https://www.themealdb.com/images/media/meals/qqwypw1504642429.jpg"
        CircleImage(url: url, width: 50, height: 50, strokeColor: Color.white, lineWidth: 0)
    }
}
