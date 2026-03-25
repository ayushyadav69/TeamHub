//
//  CachedAsyncImage.swift
//  TeamHub
//
//  Created by Ayush yadav on 25/03/26.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: Image?
    
    var body: some View {
        Group {
            if let image {
                content(image)
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        guard let url else { return }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                image = Image(uiImage: uiImage)
            }
        } catch {
            // Offline and no cache → image stays nil
        }
    }
}
