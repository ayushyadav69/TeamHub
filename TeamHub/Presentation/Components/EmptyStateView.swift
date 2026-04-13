//
//  EmptyStateView.swift
//  TeamHub
//
//  Created by Ayush yadav on 13/04/26.
//

import SwiftUI

struct EmptyStateView: View {

    let message: String

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {

                Image(systemName: "person.3")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
