//
//  SelectableFilterRow.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import SwiftUI

struct SelectableFilterRow: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
            }
        }
    }
}
