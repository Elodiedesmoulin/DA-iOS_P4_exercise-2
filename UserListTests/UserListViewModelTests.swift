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
    let reloadExpectation = XCTestExpectation(description: #function)
    
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
        return User(name: name, dob: dob, picture: picture)
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isGridView)
    }
    
    // MARK: - Fetch Users Tests
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, mockUsers.count)
        XCTAssertEqual(self.viewModel.users[0].name.first, "John")
        XCTAssertFalse(self.viewModel.isLoading)
    }
    
    func testFetchUsersFailure() {
        // Given
        mockRepository.fetchUsersResult = .failure(NSError(domain: "TestError", code: 1, userInfo: nil))
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertTrue(self.viewModel.users.isEmpty)
        XCTAssertFalse(self.viewModel.isLoading)
    }
    
    func testFetchUsersRetryAfterNetworkError() {
        // Given
        mockRepository.fetchUsersResult = .failure(URLError(.notConnectedToInternet))
        
        //When
        viewModel.fetchUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertTrue(self.viewModel.users.isEmpty)
        XCTAssertFalse(self.viewModel.isLoading)
        
        //When
        let mockUser = createMockUser()
        mockRepository.fetchUsersResult = .success([mockUser])
        viewModel.fetchUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadExpectation.fulfill()
        }
        wait(for: [reloadExpectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 1)
    }
    
    func testFetchUsersMultipleTimes() {
        // Given
        let firstMockUsers = [createMockUser(firstName: "John")]
        mockRepository.fetchUsersResult = .success(firstMockUsers)
        
        //When
        viewModel.fetchUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 1)
        XCTAssertEqual(self.viewModel.users.first?.name.first, "John")
        
        // When
        let secondMockUser = createMockUser(firstName: "Jane")
        mockRepository.fetchUsersResult = .success([secondMockUser])
        viewModel.fetchUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadExpectation.fulfill()
        }
        wait(for: [reloadExpectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 2)
        XCTAssertEqual(self.viewModel.users.last, secondMockUser)
        XCTAssertFalse(self.viewModel.isLoading)
    }
    
    
    //MARK: - Select Users Tests
    
    func testSelectUser() {
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
    
    
    // MARK: - Reload Users Tests
    
    func testReloadUsers() {
        //Given
        let mockUser = createMockUser(firstName: "John", lastName: "Doe", age: 30)
        mockRepository.fetchUsersResult = .success([mockUser])
        
        //When
        viewModel.fetchUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 1)
        
        //When
        viewModel.reloadUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadExpectation.fulfill()
        }
        wait(for: [reloadExpectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 1)
    }
    
    
    func testReloadUsersFailure() {
        // Given
        mockRepository.fetchUsersResult = .failure(NSError(domain: "TestError", code: 1, userInfo: nil))
        
        // When
        viewModel.reloadUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertTrue(self.viewModel.users.isEmpty)
        XCTAssertFalse(self.viewModel.isLoading)
    }
    
    func testReloadUsersResetsUserList() {
        // Given
        let mockUsers = [createMockUser(), createMockUser(firstName: "Jane")]
        mockRepository.fetchUsersResult = .success(mockUsers)
        
        //When
        viewModel.fetchUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 2)
        
        // When
        let newMockUser = createMockUser(firstName: "Alice")
        mockRepository.fetchUsersResult = .success([newMockUser])
        viewModel.reloadUsers()
        
        //Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadExpectation.fulfill()
        }
        wait(for: [reloadExpectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 1)
        XCTAssertEqual(self.viewModel.users.first?.name.first, "Alice")
    }
    
    func testReloadUsersSuccess() {
        // Given
        let mockUser = createMockUser(firstName: "John", lastName: "Doe", age: 30)
        mockRepository.fetchUsersResult = .success([mockUser])
        
        // When
        viewModel.reloadUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 1)
        XCTAssertEqual(self.viewModel.users.first?.name.first, "John")
        XCTAssertFalse(self.viewModel.isLoading)
    }
    
    
    func testReloadUsersUpdatesState() {
        // Given
        let initialUser = createMockUser(firstName: "John", lastName: "Doe")
        mockRepository.fetchUsersResult = .success([initialUser])
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 1)
        
        // When
        let newUser = self.createMockUser(firstName: "Alice")
        self.mockRepository.fetchUsersResult = .success([newUser])
        self.viewModel.reloadUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reloadExpectation.fulfill()
        }
        wait(for: [reloadExpectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.users.count, 1)
        XCTAssertEqual(self.viewModel.users.first?.name.first, "Alice")
    }
    
    // MARK: - Loading State Tests
    
    func testIsLoadingStateDuringFetch() {
        // Given
        mockRepository.fetchUsersResult = .success([createMockUser()])
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        
        // When
        viewModel.fetchUsers()
        
        //Then
        XCTAssertTrue(viewModel.isLoading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertFalse(self.viewModel.isLoading)
    }
    
    func testIsLoadingIsResetAfterError() {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch users."])
        mockRepository.fetchUsersResult = .failure(expectedError)
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertFalse(self.viewModel.isLoading)
    }
    
    // MARK: - Pagination Tests
    
    func testListViewPagination() {
        // Given
        let initialUsers = (0..<10).map { _ in createMockUser() }
        let additionalUsers = (0..<5).map { _ in createMockUser() }
        mockRepository.fetchUsersResult = .success(initialUsers)
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
        
        self.mockRepository.fetchUsersResult = .success(additionalUsers)
        
        // When
        viewModel.fetchUsers()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.reloadExpectation.fulfill()
        }
        wait(for: [reloadExpectation], timeout: 2)
        
        XCTAssertEqual(self.viewModel.users.count, initialUsers.count + additionalUsers.count)
    }
    
    
    // MARK: - Error Tests
    
    func testNetworkErrorNotConnectedToInternet() {
        let error = URLError(.notConnectedToInternet)
        mockRepository.fetchUsersResult = .failure(error)
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.error, UserListError.networkError(error))
    }
    
    func testNetworkErrorTimedOut() {
        let error = URLError(.timedOut)
        mockRepository.fetchUsersResult = .failure(error)
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.error, UserListError.networkError(error))
    }
    
    func testNetworkErrorCannotConnectToHost() {
        let error = URLError(.cannotConnectToHost)
        mockRepository.fetchUsersResult = .failure(error)
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.error, UserListError.networkError(error))
    }
    
    func testNetworkErrorConnectionLost() {
        let error = URLError(.networkConnectionLost)
        mockRepository.fetchUsersResult = .failure(error)
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.error, UserListError.networkError(error))
    }
    
    func testUnexpectedError() {
        let error = NSError(domain: "Test Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "An error occured" ])
        mockRepository.fetchUsersResult = .failure(error)
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.error, UserListError.unexpectedError("An error occured"))
    }
    
    func testNetworkErrorUnknown() {
        let error = URLError(.unknown)
        mockRepository.fetchUsersResult = .failure(error)
        viewModel.fetchUsers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(self.viewModel.error, UserListError.networkError(error))
    }
}

