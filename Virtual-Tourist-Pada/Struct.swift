//
//  Struct.swift
//  Virtual-Tourist-Pada
//
//  Created by Brenna Pada on 9/21/22.
//
import Foundation

struct ResponsefromFlickr: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photo: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page,
             pages,
             total,
             photo
        case perPage = "perpage"
    }
}

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    let urlSq: String
    
    enum CodingKeys: String, CodingKey {
        case id,
             owner,
             secret,
             server,
             farm,
             title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case urlSq = "url_sq"
    }
}


