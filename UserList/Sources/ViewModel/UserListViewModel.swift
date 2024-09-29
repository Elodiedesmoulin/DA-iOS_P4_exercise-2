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
    @Published var error: UserListError?
    
    private let repository: UserListRepositoryProtocol
    
    init(repository: UserListRepositoryProtocol = UserListRepository()) {
        self.repository = repository
    }
    
    func fetchUsers() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let newUsers = try await repository.fetchUsers(quantity: 20)
                
                DispatchQueue.main.async {
                    // Éviter les doublons avant d'ajouter les nouveaux utilisateurs
                    let uniqueUsers = newUsers.filter { !self.users.contains($0) }
                    self.users.append(contentsOf: uniqueUsers)
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

