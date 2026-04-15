//
//  DTOtoDomain.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

extension MobileDTO {
    
    func toDomain() -> Mobile {
        Mobile(
            id: id,
            type: MobileType(rawValue: type.lowercased()) ?? .other,
            number: number
        )
    }
}

extension EmployeeDTO {
    
    func toEmployee() -> Employee {
        Employee(
            id: id,
            name: name,
            designation: designation,
            department: department,
            isActive: isActive,
            imageURL: imgURL,
            syncStatus: nil
        )
    }
}

extension EmployeeDTO {
    
    func toEmployeeDetail(dateParser: DateParsing, dateParserISO: DateParsing) -> EmployeeDetail {
        
        EmployeeDetail(
            id: id,
            name: name,
            email: email,
            designation: designation,
            department: department,
            city: city,
            country: country,
            isActive: isActive,
            imageURL: imgURL,
            joiningDate: dateParser.parse(joiningDate) ,
            createdAt: dateParserISO.parse(createdAt ?? ""),
            updatedAt: dateParserISO.parse(updatedAt ?? ""),
            deletedAt: dateParserISO.parse(deletedAt ?? ""),
            mobiles: mobiles?.map { $0.toDomain() } ?? [],
            syncStatus: nil
        )
    }
}

extension EmployeeDetail {
    
    func toRequestDTO(dateFormatter: DateFormatting, dateFormatterISO: DateFormatting) -> EmployeeRequestDTO {
        
        EmployeeRequestDTO(
            id: id,
            name: name,
            email: email,
            designation: designation,
            department: department,
            city: city,
            country: country,
            is_active: isActive,
            img_url: imageURL,
            joining_date: dateFormatter.string(from: joiningDate),
            created_at: createdAt != nil ? dateFormatterISO.string(from: createdAt!) : "",
            updated_at: updatedAt != nil ? dateFormatterISO.string(from: updatedAt!) : "",
            deleted_at: deletedAt != nil ? dateFormatterISO.string(from: deletedAt!) : "",
            mobiles: mobiles.map {
                MobileRequestDTO(
                    number: $0.number,
                    type: $0.type.rawValue
                )
            }
        )
    }
}

extension FiltersDTO {
    
    func toDomain() -> Filters {
        
        Filters(
            designations: designations,
            departments: departments,
            statuses: statuses.map {
                StatusFilter(
                    label: $0.label,
                    value: $0.value == "active"
                )
            },
            mobileTypes: mobileTypes.map {
                MobileType(rawValue: $0.value) ?? .other
            }
        )
    }
}
