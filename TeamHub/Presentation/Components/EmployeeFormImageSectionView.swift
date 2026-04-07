//
//  EmployeeFormImageSectionView.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import SwiftUI

struct EmployeeFormImageSectionView: View {
    let selectedImageData: Data?
    let selectedImageURL: String?
    let onChangePhoto: () -> Void

    var body: some View {
        VStack {
            if let data = selectedImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())

            } else if let urlString = selectedImageURL,
                      let url = URL(string: urlString) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            } else {
                Circle()
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "camera")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    )
            }

            Button("Change Photo", action: onChangePhoto)
        }
        .frame(maxWidth: .infinity)
    }
}
