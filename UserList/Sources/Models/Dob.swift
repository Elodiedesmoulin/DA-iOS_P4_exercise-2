//
//  Dob.swift
//  UserList
//
//  Created by Elo on 16/09/2024.
//

import Foundation

struct Dob: Codable {
    let date: Date
    let age: Int
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isoDate = try container.decode(String.self, forKey: .date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let parsedDate = dateFormatter.date(from: isoDate) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Le format de la date est invalide.")
        }
        self.date = parsedDate
        
        self.age = try container.decode(Int.self, forKey: .age)
    }
    
    func formattedDate() -> String {
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter2.string(from: date)
        return dateString
    }
    
}
