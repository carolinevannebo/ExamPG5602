//
//  Animation.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 23/11/2023.
//

import Foundation
import SwiftyGif
import SwiftUI

struct AnimatedGif: UIViewRepresentable {
    @Binding var url: URL

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(gifURL: self.url)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.setGifFromURL(self.url)
    }
}
//AnimatedGifView(url: Binding(get: { myModel.gif.url }, set: { _ in }))
