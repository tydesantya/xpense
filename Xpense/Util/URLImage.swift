//
//  URLImage.swift
//  Covid-ID
//
//  Created by Teddy Santya on 4/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    
    @Published var downloadedImage: UIImage?
    let didChange = PassthroughSubject<ImageLoader?, Never>()
    
    func load(url: String) {
        
        guard let imageURL = URL(string: url) else {
            fatalError("ImageURL is not correct!")
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                     self.didChange.send(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.downloadedImage = UIImage(data: data)
                self.didChange.send(self)
            }
            
        }.resume()
        
    }
    
}

struct URLImage: View {
    
    @ObservedObject private var imageLoader = ImageLoader()
    
    var placeholder: Image
    
    init(url: String?, placeholder: Image = Image(systemName: "photo")) {
        self.placeholder = placeholder
        if let url = url {
            self.imageLoader.load(url: url)
        }
    }
    
    var body: some View {
        if let uiImage = self.imageLoader.downloadedImage {
            return Image(uiImage: uiImage)
                .renderingMode(.original)
                .resizable()
        } else {
            return placeholder
                .renderingMode(.original)
                .resizable()
        }
    }
    
}
