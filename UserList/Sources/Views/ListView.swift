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
        List(users) { user in
            NavigationLink(destination: UserDetailView(user: user)) {
                UserRowView(user: user)
            }
            .onAppear {
                if loadMore(user) {
                    fetchUsers()
                }
            }
        }
    }
}
