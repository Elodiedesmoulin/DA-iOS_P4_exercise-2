//
//  ListView.swift
//  UserList
//
//  Created by Elo on 09/09/2024.
//

import SwiftUI

struct ListView: View {
    let users: [User]
    let loadMore: (User) -> Bool
    let fetchUsers: () -> Void
    
    var body: some View {
        List(users.indices, id: \.self) { index in
            NavigationLink(destination: UserDetailView(user: users[index])) {
                UserRowView(user: users[index])
            }
            .onAppear {
                if index == users.count - 1 {
                    fetchUsers()
                }
            }
        }
    }
}
