//
//  ImageUploader.swift
//  TeamHub
//
//  Created by Ayush yadav on 27/03/26.
//

import Foundation

protocol ImageUploader {
    func upload(_ data: Data) async throws -> String
}

final class CloudinaryImageUploader: ImageUploader {
    
    private let cloudName: String
    private let uploadPreset: String
    
    init(cloudName: String, uploadPreset: String) {
        self.cloudName = cloudName
        self.uploadPreset = uploadPreset
    }
    
    func upload(_ data: Data) async throws -> String {
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // upload_preset
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        body.append("\(uploadPreset)\r\n")
        
        // file
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        let (responseData, response) = try await URLSession.shared.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIError.custom("Image upload failed")
        }
        
        let result = try JSONDecoder().decode(CloudinaryUploadResponse.self, from: responseData)
        
        return result.secureUrl
    }
}

