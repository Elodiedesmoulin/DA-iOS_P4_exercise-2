//
//  UserListViewModel.swift
//  UserList
//
//  Created by Elo on 09/09/2024.
//

import SwiftUI

struct UserListViewModel: View {
    // TODO: - Those properties should be viewModel's OutPuts
    @State private var users: [User] = []
    @State private var isLoading = false
    @State private var isGridView = false

    // TODO: - The property should be declared in the viewModel
    private let repository = UserListRepository()
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    private func fetchUsers() {
        isLoading = true
        Task {
            do {
                let users = try await repository.fetchUsers(quantity: 20)
                self.users.append(contentsOf: users)
                isLoading = false
            } catch {
                print("Error fetching users: \(error.localizedDescription)")
            }
        }
    }
    
    private func reloadUsers() {
        users.removeAll()
        fetchUsers()
    }
}

#Preview {
    UserListViewModel()
}
