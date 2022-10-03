//
//  PhotosStruct.swift
//  Virtual-Tourist-Pada
//
//  Created by Brenna Pada on 10/2/22.
//

import Foundation

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
