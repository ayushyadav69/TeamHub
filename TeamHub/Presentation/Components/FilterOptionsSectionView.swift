//
//  FilterOptionsSectionView.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import SwiftUI

struct FilterOptionsSectionView<Option: Hashable>: View {
    let title: String
    let options: [Option]
    let label: (Option) -> String
    let isSelected: (Option) -> Bool
    let onTap: (Option) -> Void

    var body: some View {
        Section(title) {
            ForEach(options, id: \.self) { option in
                Button {
                    onTap(option)
                } label: {
                    SelectableFilterRow(
                        title: label(option),
                        isSelected: isSelected(option)
                    )
                }
            }
        }
    }
}
