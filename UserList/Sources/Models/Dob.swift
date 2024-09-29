//
//  Dob.swift
//  UserList
//
//  Created by Elo on 16/09/2024.
//

import Foundation

struct Dob: Codable, Equatable {
    let date: Date
    let age: Int
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isoDate = try container.decode(String.self, forKey: .date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let parsedDate = dateFormatter.date(from: isoDate) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Le format de la date est invalide.")
        }
        self.date = parsedDate
        
        self.age = try container.decode(Int.self, forKey: .age)
    }
    
    //For tests
    init(date: Date, age: Int) {
        self.date = date
        self.age = age
    }
    
    func formattedDate() -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        return displayFormatter.string(from: date)
    }
}
