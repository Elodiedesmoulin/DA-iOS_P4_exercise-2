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
    @State private var isFetching = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(users.indices, id: \.self) { index in
                    NavigationLink(destination: UserDetailView(user: users[index])) {
                        VStack {
                            AsyncImageView(url: URL(string: users[index].picture.medium), size: 150)
                            Text("\(users[index].name.first) \(users[index].name.last)")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .onAppear {
                        if index == users.count - 1 {
                            fetchUsers()
                        }
                    }
                }
            }
        }
        
    }
}

