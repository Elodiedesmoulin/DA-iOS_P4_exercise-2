import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: UUID { UUID() }
    let name: Name
    let dob: Dob
    let picture: Picture
}
