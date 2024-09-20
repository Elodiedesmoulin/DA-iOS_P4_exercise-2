//
//  UserListViewModelTests.swift
//  UserListTests
//
//  Created by Elo on 16/09/2024.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import UserList


final class UserListViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockRepository: MockUserListRepository!
    let expectation = XCTestExpectation(description: #function)
    
    
    override func setUp() {
        super.setUp()
        
        mockRepository = MockUserListRepository()
        viewModel = UserListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
            viewModel = nil
            mockRepository = nil
            super.tearDown()
        }
    
    func createMockUser(firstName: String = "John", lastName: String = "Doe", age: Int = 30) -> User {
            let name = Name(title: "Mr", first: firstName, last: lastName)
            let dob = Dob(date: Date(), age: age)
            let picture = Picture(large: "https://example.com/large.jpg", medium: "https://example.com/medium.jpg", thumbnail: "https://example.com/thumb.jpg")
            return User(from: UserListResponse.User(name: name, dob: dob, picture: picture))
        }
    
    
    // Test initialisation
        func testInitialState() {
            XCTAssertTrue(viewModel.users.isEmpty)
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertFalse(viewModel.isGridView)
        }

    func testFetchUsersSuccess() {
        
        // Given
        let mockUsers = [
            createMockUser(firstName: "John", lastName: "Doe", age: 30),
            createMockUser(firstName: "Jane", lastName: "Doe", age: 28)
        ]
        mockRepository.fetchUsersResult = .success(mockUsers)
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        
        XCTAssertEqual(viewModel.users.count, mockUsers.count)
        XCTAssertEqual(viewModel.users[0].name.first, "John")
        XCTAssertFalse(viewModel.isLoading)
    }
    

    
    func testFetchUsersFailure() {
        
        // Given
       
        mockRepository.fetchUsersResult = .failure(NSError(domain: "TestError", code: 1, userInfo: nil))
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(self.viewModel.users.isEmpty) // The user's list remain empty
        XCTAssertFalse(self.viewModel.isLoading) // Loading stop even after fail
    }
    
    func testIsLoadingStateDuringFetch() {
        mockRepository.fetchUsersResult = .success([createMockUser()])
        
        XCTAssertFalse(viewModel.isLoading)
        
        viewModel.fetchUsers()
        
        XCTAssertTrue(viewModel.isLoading)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(viewModel.isLoading)
    }
    
    
    func testSwitchingViewModes() {
        // Given
        XCTAssertFalse(viewModel.isGridView)
        
        // When switching to grid view
        viewModel.isGridView.toggle()
        
        // Then
        XCTAssertTrue(viewModel.isGridView)
        
        // When switching back to list view
        viewModel.isGridView.toggle()
        
        // Then
        XCTAssertFalse(viewModel.isGridView)
    }
    
    
    func testReloadUsers() {
        let mockUser = createMockUser(firstName: "John", lastName: "Doe", age: 30)
        mockRepository.fetchUsersResult = .success([mockUser])
        
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(viewModel.users.count, 1)
        
        viewModel.reloadUsers()
        
        XCTAssertTrue(viewModel.users.isEmpty) // Ajout
        
        let reloadExpectation = XCTestExpectation(description: "Reload users")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                reloadExpectation.fulfill()
            }
            wait(for: [reloadExpectation], timeout: 2)
            
        XCTAssertEqual(viewModel.users.count, 1)
        
    }
    
    func testReloadUsersFailure() {
        //Given
        mockRepository.fetchUsersResult = .failure(NSError(domain: "TestError", code: 1, userInfo: nil))

        //When
        viewModel.reloadUsers()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        //Then
        XCTAssertTrue(viewModel.users.isEmpty, "La liste doit être vide après un reload échoué.")
        XCTAssertFalse(viewModel.isLoading, "L'état de chargement doit être faux après un reload échoué.")
    }
    
    
    func testUserDetailViewRendering() {
        
        let mockUser = createMockUser(firstName: "John", lastName: "Doe", age: 30)
        
        // When : Créer la vue UserDetailView avec l'utilisateur mock
        
        let view = UserDetailView(user: mockUser)
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)
    }
    
    func testFetchManyUsersPerformance() {
        // Générer une grande quantité d'utilisateurs mock
        let mockUsers = (0..<1000).map { _ in
            createMockUser(firstName: "John", lastName: "Doe", age: 30)
        }
        mockRepository.fetchUsersResult = .success(mockUsers)
        
       
            viewModel.fetchUsers()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.expectation.fulfill()
            }
            wait(for: [expectation], timeout: 2)
            
            // Vérification du nombre d'utilisateurs récupérés
        XCTAssertEqual(viewModel.users.count, mockUsers.count)
    }
    
    func testReloadUsersResetsUserList() {
        // Given
        let mockUsers = [createMockUser(), createMockUser(firstName: "Jane")]
        mockRepository.fetchUsersResult = .success(mockUsers)
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(viewModel.users.count, 2)
        
        // When reloading users
        let newMockUser = createMockUser(firstName: "Alice")
        mockRepository.fetchUsersResult = .success([newMockUser])
        viewModel.reloadUsers()
        
        let reloadExpectation = XCTestExpectation(description: "Reload users")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                reloadExpectation.fulfill()
            }
            wait(for: [reloadExpectation], timeout: 2)
        
        // Then
        XCTAssertEqual(viewModel.users.count, 1)
        XCTAssertEqual(viewModel.users.first?.name.first, "Alice")
    }
    
    func testFetchUsersRetryAfterNetworkError() {
        // Given
        mockRepository.fetchUsersResult = .failure(URLError(.notConnectedToInternet))
        viewModel.fetchUsers()
        
        // Attendre le premier échec
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        
        // Then
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        
        // When retry après échec
        let mockUser = createMockUser()
        mockRepository.fetchUsersResult = .success([mockUser])
        viewModel.fetchUsers()
        
        // Then
        let reloadExpectation = XCTestExpectation(description: "Reload users")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                reloadExpectation.fulfill()
            }
            wait(for: [reloadExpectation], timeout: 3)
        
        XCTAssertEqual(viewModel.users.count, 1)
    }
    
    func testListViewPagination() {
        // Given
        let initialUsers = (0..<10).map { _ in createMockUser() }
        let additionalUsers = (0..<5).map { _ in createMockUser() }
        mockRepository.fetchUsersResult = .success(initialUsers)
        
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        // When
        let fetchMoreExpectation = XCTestExpectation(description: "Fetch more users")
        mockRepository.fetchUsersResult = .success(additionalUsers)
        
        // Simuler que le dernier utilisateur est affiché
        if let lastUser = viewModel.users.last {
            viewModel.fetchUsers() // Devrait déclencher le chargement des utilisateurs supplémentaires
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            fetchMoreExpectation.fulfill()
        }
        
        wait(for: [fetchMoreExpectation], timeout: 2)
        
        // Then
        XCTAssertEqual(viewModel.users.count, initialUsers.count + additionalUsers.count)
    }
    
    
    func testGridViewPagination() {
        // Given
        let initialUsers = (0..<10).map { _ in createMockUser() }
        let additionalUsers = (0..<5).map { _ in createMockUser() }
        mockRepository.fetchUsersResult = .success(initialUsers)
        
        viewModel.isGridView = true
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        // When
        let fetchMoreExpectation = XCTestExpectation(description: "Fetch more users")
        mockRepository.fetchUsersResult = .success(additionalUsers)
        
        // Simuler que le dernier utilisateur est affiché
            viewModel.fetchUsers() // Devrait déclencher le chargement des utilisateurs supplémentaires

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            fetchMoreExpectation.fulfill()
        }
        
        wait(for: [fetchMoreExpectation], timeout: 2)
        
        // Then
        XCTAssertEqual(viewModel.users.count, initialUsers.count + additionalUsers.count)
    }
    
    func testSwitchViewAndFetchUsers() {
        // Given
        let mockUsers = [createMockUser()]
        mockRepository.fetchUsersResult = .success(mockUsers)
        
        // When
        viewModel.isGridView = true
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        // Verify GridView
        XCTAssertTrue(viewModel.isGridView)
        XCTAssertEqual(viewModel.users.count, mockUsers.count)
        
        // Toggle to ListView
        viewModel.isGridView.toggle()
        
        XCTAssertFalse(viewModel.isGridView)
        XCTAssertEqual(viewModel.users.count, mockUsers.count)
    }
    
    
    func testUserSelection() {
            // Given
            let mockUser = createMockUser(firstName: "John", lastName: "Doe", age: 30)
            viewModel.users = [mockUser]
            
            // When
            viewModel.selectUser(mockUser)
            
            // Then
            XCTAssertNotNil(viewModel.selectedUser)
            XCTAssertEqual(viewModel.selectedUser?.name.first, "John")
            XCTAssertEqual(viewModel.selectedUser?.name.last, "Doe")
            XCTAssertEqual(viewModel.selectedUser?.dob.age, 30)
        }
        
    
    
}


