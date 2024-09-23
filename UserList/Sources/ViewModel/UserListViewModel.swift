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
    @Published var error: UserListError?  // Pour gérer les messages d'erreur
    
    private let repository: UserListRepositoryProtocol
    
    init(repository: UserListRepositoryProtocol = UserListRepository()) {
        self.repository = repository
    }
    
    func fetchUsers() {
        isLoading = true
        error = nil
        Task {
            do {
                let users = try await repository.fetchUsers(quantity: 20)
                
                DispatchQueue.main.async {
                    self.users.append(contentsOf: users)
                    self.isLoading = false
                }
            } catch let urlError as URLError {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = .networkError(urlError)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = .unexpectedError(error.localizedDescription)
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

