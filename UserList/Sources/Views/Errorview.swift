//
//  Errorview.swift
//  UserList
//
//  Created by Elo on 23/09/2024.
//

import SwiftUI

struct ErrorView: View {
    let error: UserListError
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .font(.headline)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Text("Retry")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}



