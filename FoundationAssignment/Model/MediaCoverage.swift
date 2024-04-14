//
//  MediaCoverage.swift
//  FoundationAssignment
//
//  Created by Gaurang Patel on 14/04/24.
//

import Foundation

struct MediaCoverage: Decodable {
    let id: String
    let title: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageUrl = "cover_image_url"
    }
}
