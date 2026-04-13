//
//  NetworkStatusView.swift
//  TeamHub
//
//  Created by Ayush yadav on 13/04/26.
//

import SwiftUI

struct NetworkStatusView: View {
    
    let text: String
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Circle()
                .fill(text == "Offline" ? .red : .green)
                .frame(width: 8, height: 8)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
//                .lineLimit(1)
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .fixedSize()
    }
}

//#Preview {
//    NetworkStatusView()
//}
