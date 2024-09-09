//
//  RowView.swift
//  UserList
//
//  Created by Elo on 09/09/2024.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImageView(url: URL(string: user.picture.thumbnail), size: 50)
            
            VStack(alignment: .leading) {
                Text("\(user.name.first) \(user.name.last)")
                    .font(.headline)
                Text("\(user.dob.date)")
                    .font(.subheadline)
            }
        }
    }
}
