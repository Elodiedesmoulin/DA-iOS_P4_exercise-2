//
//  UserListError.swift
//  UserList
//
//  Created by Elo on 23/09/2024.
//

import SwiftUI

enum UserListError: Error, LocalizedError, Equatable{
    case networkError(URLError)
    case unexpectedError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let urlError):
            return mapURLError(urlError)

        case .unexpectedError(let message):
            return message
        }
    }
    
    private func mapURLError(_ error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet:
            return "You appear to be offline. Please check your internet connection."
        case .timedOut:
            return "The request timed out. Please try again."
        case .cannotFindHost, .cannotConnectToHost:
            return "Unable to connect to the server. Please try again later."
        case .networkConnectionLost:
            return "The network connection was lost. Please try again."
        default:
            return "A network error occurred: \(error.localizedDescription)"
        }
    }
}
