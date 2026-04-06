//
//  EmployeeRowView.swift
//  TeamHub
//
//  Created by Ayush yadav on 25/03/26.
//

import SwiftUI

struct EmployeeRowView: View {
    
    let employee: Employee
    
    var body: some View {
        content
    }
}

private extension EmployeeRowView {
    
    var content: some View {
        
        HStack(spacing: 12) {
            
            profileImage
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(employee.name)
                    .font(.headline)
                
                Text(employee.designation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(employee.department)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            statusView
        }
        .padding(.vertical, 6)
    }
}

private extension EmployeeRowView {
    
    var statusView: some View {
        
        Text(employee.isActive ? "Active" : "Inactive")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusBackground)
            .clipShape(Capsule())
    }
    
    var statusBackground: some ShapeStyle {
        employee.isActive
        ? Color.green.opacity(0.15)
        : Color.secondary.opacity(0.15)
    }
}

private extension EmployeeRowView {
    
    var profileImage: some View {
        
        Group {
            if let path = employee.imageLocalPath,
               let data = ImageStorage.load(path: path),
               let uiImage = UIImage(data: data) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                
            } else {
                
                CachedAsyncImage(url: URL(string: employee.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                }
                .id(employee.imageURL)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            }
        }
    }
}
