//
//  UserListViewModelTests.swift
//  UserListTests
//
//  Created by Elo on 16/09/2024.
//

import XCTest
import SwiftUI
@testable import UserList

struct MockUserListRepository: UserListRepositoryProtocol {
    var result: Result<[User], Error>
    
    func fetchUsers(quantity: Int) async throws -> [User] {
        switch result {
        case .success(let users):
            return users
        case .failure(let error):
            throw error
        }
    }
}

final class UserListViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockRepository: MockUserListRepository!
    
    func createDob(from isoDateString: String, age: Int) -> Dob {
        let dobJSON = """
        {
            "date": "\(isoDateString)",
            "age": \(age)
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Dob.self, from: dobJSON)
        } catch {
            fatalError("Erreur de décodage de Dob : \(error)")
        }
    }
    
    override func setUp() {
        super.setUp()
        
        
        
        
        let userResponse = UserListResponse.User(
            name: Name(title: "Mr", first: "John", last: "Doe"),
            dob: createDob(from: "2023-09-15T12:34:56.789Z", age: 30),
            picture: Picture(large: "https://example.com/large.jpg", medium: "https://example.com/medium.jpg", thumbnail: "https://example.com/thumb.jpg")
        )
        
        let sampleUser = User(from: userResponse)
        
        mockRepository = MockUserListRepository(result: .success([sampleUser]))
        viewModel = UserListViewModel(repository: mockRepository)
    }
    
    func testFetchUsersSuccess() async {
        // Given
        XCTAssertEqual(viewModel.users.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.users.count, 1)
            XCTAssertFalse(self.viewModel.isLoading) 
        }
    }
    
    func testFetchUsersFailure() async {
        // Given
        let error = URLError(.badServerResponse)
        mockRepository = MockUserListRepository(result: .failure(error))
        viewModel = UserListViewModel(repository: mockRepository)
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.viewModel.users.isEmpty) // The user's list remain empty
            XCTAssertFalse(self.viewModel.isLoading) // Loading stop even after fail
            
        }
    }
    
    func testToggleListViewToGridView() {
        // Given
        XCTAssertFalse(viewModel.isGridView)
        
        // When
        viewModel.isGridView.toggle()
        
        // Then
        XCTAssertTrue(viewModel.isGridView)
    }
    
    func testUserDetailViewRendering() {
        let userResponse = UserListResponse.User(
            name: Name(title: "Mr", first: "John", last: "Doe"),
            dob: createDob(from: "2023-09-15T12:34:56.789Z", age: 30),
            picture: Picture(large: "https://example.com/large.jpg", medium: "https://example.com/medium.jpg", thumbnail: "https://example.com/thumb.jpg")
        )
        
        let sampleUser = User(from: userResponse)
        
        let view = UserDetailView(user: sampleUser)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
    }
}
