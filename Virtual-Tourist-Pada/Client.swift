//
//  Client.swift
//  Virtual-Tourist-Pada
//
//  Created by Brenna Pada on 9/21/22.
//

import Foundation

class PhotoSearch {
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest"
        static let photoSearch = "?method=flickr.photos.search"
        static let apiKey = "5d2fa7c557092af5a187b3600ba71fe7"
        static let secret = "7b69f42ee21797fb"
        
        case grabPhotos(Double, Double, Int)
        
        var stringValue: String {
            switch self {
            case .grabPhotos(let lat, let lon, let page):
                return Endpoints.base + Endpoints.photoSearch + "&extras=url_sq" + "&api_key=\(Endpoints.apiKey)" + "&lat=\(lat)" + "&lon=\(lon)" + "&per_page=30" + "&page=\(page)" + "&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: Search for photos and parse results
    
    class func grabPhotos(lat: Double, lon: Double, page: Int, completion: @escaping (Photos?, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.grabPhotos(lat, lon, page).url)
        print(request)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                    print("Error with GET request")
                }
                return
            }
            //https://knowledge.udacity.com/questions/899643
            let range = 5..<data.count
            let newData = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(PhotoSearchResponse.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject.photos, nil)
                    print("Success")
                }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                        print("Error, could not read data")
                    }
                }
            }
        task.resume()
        return
     }
    
}
