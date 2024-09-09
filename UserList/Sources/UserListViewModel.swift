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

    private let repository = UserListRepository()
    
    func fetchUsers() {
        isLoading = true
        Task {
            do {
                let users = try await repository.fetchUsers(quantity: 20)
                self.users.append(contentsOf: users)
                isLoading = false
            } catch {
                print("Error fetching users: \(error.localizedDescription)")
            }
            
            /*
             ????
             DispatchQueue.main.async {
             self.users.append(contentsOf: users)
             self.isLoading = false
         }
     } catch {
         print("Error fetching users: \(error.localizedDescription)")
     }
             */
            
        }
    }
    
    
    func reloadUsers() {
        users.removeAll()
        fetchUsers()
    }
}
