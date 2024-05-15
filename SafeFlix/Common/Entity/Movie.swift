//
//  Movie.swift
//  SafeFlix
//
//  Created by Irham Naufal on 14/05/24.
//

import SwiftUI

struct Movie: Identifiable {
    var id = UUID()
    var title: String
    var synopsis: String
    var rating: Rating
    var videoURL: URL
    var poster: Image
    var year: Int
}

enum Rating: Int, CaseIterable {
    case all = 0
    case _13 = 13
    case _17 = 17
    case _21 = 21
}

extension Movie {
    static let sample: [Movie] = [
        .init(title: "Sri Asih", synopsis: "Alana discover the truth about her origin: she’s not an ordinary human being. She may be the gift for humanity and become its protector as Sri Asih. Or a destruction, if she can’t control her anger.", rating: ._13, videoURL: URL(string: "https://youtu.be/QeT6Ke2kQYo?si=emA6qFGDwRwjo2az").orEmpty(), poster: .Default.sriAsih, year: 2022),
        .init(title: "Sri Asih", synopsis: "Alana discover the truth about her origin: she’s not an ordinary human being. She may be the gift for humanity and become its protector as Sri Asih. Or a destruction, if she can’t control her anger.", rating: ._13, videoURL: URL(string: "https://youtu.be/QeT6Ke2kQYo?si=emA6qFGDwRwjo2az").orEmpty(), poster: .Default.sriAsih, year: 2022),
        .init(title: "Sri Asih", synopsis: "Alana discover the truth about her origin: she’s not an ordinary human being. She may be the gift for humanity and become its protector as Sri Asih. Or a destruction, if she can’t control her anger.", rating: ._13, videoURL: URL(string: "https://youtu.be/QeT6Ke2kQYo?si=emA6qFGDwRwjo2az").orEmpty(), poster: .Default.sriAsih, year: 2022),
        .init(title: "Sri Asih", synopsis: "Alana discover the truth about her origin: she’s not an ordinary human being. She may be the gift for humanity and become its protector as Sri Asih. Or a destruction, if she can’t control her anger.", rating: ._13, videoURL: URL(string: "https://youtu.be/QeT6Ke2kQYo?si=emA6qFGDwRwjo2az").orEmpty(), poster: .Default.sriAsih, year: 2022),
    ]
}
