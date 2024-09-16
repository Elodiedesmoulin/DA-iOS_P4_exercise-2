import SwiftUI

struct UserDetailView: View {
    let user: User
    
    var body: some View {
        VStack {
            AsyncImageView(url: URL(string: user.picture.large), size: 200)
            
            VStack(alignment: .leading) {
                Text("\(user.name.first) \(user.name.last)")
                    .font(.headline)
                Text("Date of Birth: \(user.dob.formattedDate())")
                    .font(.subheadline)
                Text("Age: \(user.dob.age)")
                    .font(.subheadline)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("\(user.name.first) \(user.name.last)")
    }
}
