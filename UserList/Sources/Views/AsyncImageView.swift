//
//  AsyncImageView.swift
//  UserList
//
//  Created by Elo on 09/09/2024.
//

import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } placeholder: {
            ProgressView()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }
}
