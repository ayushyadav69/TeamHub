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

            Text(employee.name.capitalized)
                .font(.title2)
                .fontWeight(.semibold)

            HStack {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary.opacity(0.8))
                    .frame(width: 20)
                
                Text(employee.email.lowercased())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
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
        VStack(alignment: .leading, spacing: 20) {
            EmployeeDetailInfoRow(title: "Designation", value: employee.designation, systemImage: "briefcase")
            EmployeeDetailInfoRow(title: "Department", value: employee.department, systemImage: "building.2")
            EmployeeDetailInfoRow(
                title: "Location",
                value: "\(employee.city), \(employee.country)",
                systemImage: "location"
            )

            if let date = employee.joiningDate {
                EmployeeDetailInfoRow(
                    title: "Joining Date",
                    value: date.formatted(date: .numeric, time: .omitted),
                    systemImage: "calendar"
                )
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Image(systemName: employee.isActive ? "person.fill.checkmark" : "person.fill.xmark")
                    .foregroundStyle(.secondary.opacity(0.8))
                    .frame(width: 20)
                
                Text("Status")
                    .foregroundStyle(.secondary)

                Spacer()

                Text(employee.isActive ? "Active" : "Inactive")
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EmployeeDetailInfoRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary.opacity(0.8))
                .frame(width: 20)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
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
