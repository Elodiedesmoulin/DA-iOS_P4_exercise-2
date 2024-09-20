//
//  UserListViewModel.swift
//  UserList
//
//  Created by Elo on 09/09/2024.
//

import SwiftUI

class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var isGridView = false
    @Published var selectedUser: User?
    
    
    private let repository: UserListRepositoryProtocol
    
    init(repository: UserListRepositoryProtocol = UserListRepository()) {
        self.repository = repository
    }
    
    
    func fetchUsers() {
        isLoading = true
        Task {
            do {
                let users = try await repository.fetchUsers(quantity: 20)
                
                DispatchQueue.main.async {
                    self.users.append(contentsOf: users)
                    self.isLoading = false
                }
            } catch {
                print("Error fetching users: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    
    func reloadUsers() {
        users.removeAll()
        fetchUsers()
    }
    
    func selectUser(_ user: User) {
            self.selectedUser = user
        }
}
