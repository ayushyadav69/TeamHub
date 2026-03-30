//
//  PhoneRowView.swift
//  TeamHub
//
//  Created by Ayush yadav on 27/03/26.
//

import SwiftUI

struct PhoneRowView: View {
    
    @Binding var mobile: Mobile
    let mobileTypes: [MobileType]
    let isTypeUsed: (MobileType, String) -> Bool
    let onDelete: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                TextField("Number", text: $mobile.number)
                    .keyboardType(.numberPad)
                
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
            }
            
            Picker("Type", selection: $mobile.type) {
                
                ForEach(filteredTypes, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private var filteredTypes: [MobileType] {
        mobileTypes.filter {
            $0 == mobile.type || !isTypeUsed($0, mobile.id!)
        }
    }
}
