//
//  MockUserListRepository.swift
//  UserListTests
//
//  Created by Elo on 17/09/2024.
//

import XCTest
@testable import UserList

class MockUserListRepository: UserListRepositoryProtocol {
    var fetchUsersResult: Result<[User], Error> = .success([])
    
    func fetchUsers(quantity: Int) async throws -> [User] {
        switch fetchUsersResult {
        case .success(let users):
            return users
        case .failure(let error):
            throw error
        }
    }
}



