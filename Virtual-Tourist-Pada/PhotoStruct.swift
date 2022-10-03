//
//  PhotoStruct.swift
//  Virtual-Tourist-Pada
//
//  Created by Brenna Pada on 10/2/22.
//

import Foundation

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
    let urlm: String
    
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
        case urlm = "url_m"
    }
}
