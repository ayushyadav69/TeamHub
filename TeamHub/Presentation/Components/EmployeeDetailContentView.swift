//
//  EmployeeDetailContentView.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import SwiftUI

struct EmployeeDetailContentView: View {
    let employee: EmployeeDetail

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                EmployeeDetailHeaderView(employee: employee)
                EmployeeDetailInfoSectionView(employee: employee)
                EmployeeDetailPhoneSectionView(mobiles: employee.mobiles)
            }
            .padding()
        }
    }
}

private struct EmployeeDetailHeaderView: View {
    let employee: EmployeeDetail

    var body: some View {
        VStack(spacing: 12) {
            EmployeeDetailProfileImageView(employee: employee)

            Text(employee.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text(employee.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct EmployeeDetailProfileImageView: View {
    let employee: EmployeeDetail

    var body: some View {
        Group {
            if let path = employee.imageLocalPath,
               let data = ImageStorage.load(path: path),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())

            } else {
                CachedAsyncImage(url: URL(string: employee.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                            Circle()
                                .fill(Color(.secondarySystemBackground))

                        Text(employee.name.initials)
                            .font(.system(size: 60, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                }
                .id(employee.imageURL)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            }
        }
    }
}

private struct EmployeeDetailInfoSectionView: View {
    let employee: EmployeeDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            EmployeeDetailInfoRow(title: "Designation", value: employee.designation)
            EmployeeDetailInfoRow(title: "Department", value: employee.department)
            EmployeeDetailInfoRow(
                title: "Location",
                value: "\(employee.city), \(employee.country)"
            )

            if let date = employee.joiningDate {
                EmployeeDetailInfoRow(
                    title: "Joining Date",
                    value: date.formatted(date: .numeric, time: .omitted)
                )
            }

            HStack {
                Text("Status")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(employee.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        employee.isActive
                        ? Color.green.opacity(0.15)
                        : Color.secondary.opacity(0.15)
                    )
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EmployeeDetailInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.body)
        }
    }
}

private struct EmployeeDetailPhoneSectionView: View {
    let mobiles: [Mobile]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Phone Numbers")
                .font(.headline)

            if mobiles.isEmpty {
                Text("No phone numbers available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

            } else {
                ForEach(mobiles, id: \.id) { mobile in
                    EmployeeDetailPhoneRow(mobile: mobile)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EmployeeDetailPhoneRow: View {
    let mobile: Mobile

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(mobile.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(mobile.number)
                    .font(.body)
            }

            Spacer()
        }
    }
}
