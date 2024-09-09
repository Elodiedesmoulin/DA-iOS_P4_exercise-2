//
//  GridView.swift
//  UserList
//
//  Created by Elo on 09/09/2024.
//

import SwiftUI

struct GridView: View {
    let users: [User]
    let loadMore: (User) -> Bool
    let fetchUsers: () -> Void
    
    let columns = [GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(users) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        VStack {
                            AsyncImageView(url: URL(string: user.picture.medium), size: 150)
                            
                            Text("\(user.name.first) \(user.name.last)")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .onAppear {
                        if loadMore(user) {
                            fetchUsers()
                        }
                    }
                }
            }
        }
    }
}
