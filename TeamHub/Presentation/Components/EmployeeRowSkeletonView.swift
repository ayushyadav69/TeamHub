//
//  EmployeeRowSkeletonView.swift
//  TeamHub
//
//  Created by Ayush yadav on 13/04/26.
//

import SwiftUI

struct EmployeeRowSkeletonView: View {
    
    var body: some View {
        HStack(spacing: 12) {
            
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 10)
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 20)
        }
        .padding(.vertical, 6)
        .shimmer() //  APPLY HERE
    }
}
