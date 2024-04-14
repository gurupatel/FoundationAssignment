//
//  MediaCoverage.swift
//  FoundationAssignment
//
//  Created by Gaurang Patel on 14/04/24.
//

import Foundation

struct MediaCoverage: Codable {
    var id: String? = nil
    var title: String? = nil
    var language: String? = nil
    var mediaType: Int? = nil
    var coverageURL: String? = nil
    var publishedAt: String? = nil
    var publishedBy: String? = nil
    var thumbnail: Thumbnail? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case language
        case mediaType
        case publishedAt
        case publishedBy
        case coverageURL
        case thumbnail
    }
}

struct Thumbnail : Codable {
    var id : String? = nil
    var version : Int? = nil
    var domain : String? = nil
    var basePath : String? = nil
    var key : String? = nil
}
