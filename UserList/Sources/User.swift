import Foundation

struct User: Identifiable {
    var id = UUID()
    let name: Name
    let dob: Dob
    let picture: Picture
    
    init(from userResponse: UserListResponse.User) {
            self.name = userResponse.name
            self.dob = userResponse.dob
            self.picture = userResponse.picture
        }
}
