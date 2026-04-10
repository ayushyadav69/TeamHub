//
//  EmployeeFormPhoneSectionView.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import SwiftUI

struct EmployeeFormPhoneSectionView: View {
    @Binding var mobiles: [Mobile]

    let mobileTypes: [MobileType]
    let canAddPhone: Bool
    let isTypeUsed: (MobileType, String) -> Bool
    let numberError: (String) -> String?
    let onDelete: (String) -> Void
    let onAddPhone: () -> Void

    var body: some View {
        Section("Phone Numbers") {
            ForEach($mobiles) { $mobile in
                PhoneRowView(
                    mobile: $mobile,
                    mobileTypes: mobileTypes,
                    isTypeUsed: isTypeUsed,
                    numberError: numberError(mobile.number),
                    onDelete: {
                        onDelete(mobile.id ?? "")
                    }
                )
            }

            if canAddPhone {
                Button("Add Phone", action: onAddPhone)
            }
        }
    }
}
