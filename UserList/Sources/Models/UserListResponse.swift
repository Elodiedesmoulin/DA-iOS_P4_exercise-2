import Foundation

struct UserListResponse: Codable {
    let results: [User]
    
    // MARK: - User
    struct User: Codable {
        let name: Name
        let dob: Dob
        let picture: Picture
    }
}

