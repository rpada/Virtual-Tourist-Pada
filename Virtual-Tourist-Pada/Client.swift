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
            case .grabPhotos(let latitude, let longitude, let page):
                return Endpoints.base + Endpoints.photoSearch + "&extras=url_m" + "&api_key=\(Endpoints.apiKey)" + "&accuracy=16" + "&lat=\(latitude)" +
                "&lon=\(longitude)" + "&per_page=20" + "&page=\(Int.random(in: 1...10))" + "&format=json&nojsoncallback=1"
                // https://knowledge.udacity.com/questions/672188
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    // adapted from udacity movie project: https://classroom.udacity.com/nanodegrees/nd003/parts/2b0b0f37-f10b-41dc-abb4-a346f293027a/modules/4b26ca51-f2e8-45a3-92df-a1797f597a19/lessons/cd890113-636f-474a-8558-8b1a5e633c77/concepts/b6181fb1-c0aa-4a35-9078-3f2e177075ac#
    // https://classroom.udacity.com/nanodegrees/nd003/parts/2b0b0f37-f10b-41dc-abb4-a346f293027a/modules/4b26ca51-f2e8-45a3-92df-a1797f597a19/lessons/7f5f110b-8f78-413d-af65-db7dca09e338/concepts/4dceaf4e-8fa6-43a5-af5a-9ca7fdfd7c25
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            //https://knowledge.udacity.com/questions/899643
            // let range = 5..<data.count
            // let newData = data.subdata(in: range)
            // doesn't work when I do this. I'm guessing for this API this step is not neccessary
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }

    // https://classroom.udacity.com/nanodegrees/nd003/parts/2b0b0f37-f10b-41dc-abb4-a346f293027a/modules/4b26ca51-f2e8-45a3-92df-a1797f597a19/lessons/cd890113-636f-474a-8558-8b1a5e633c77/concepts/13238b1f-33b9-42a0-9597-6618a9168a33
    
    // https://classroom.udacity.com/nanodegrees/nd003/parts/2b0b0f37-f10b-41dc-abb4-a346f293027a/modules/4b26ca51-f2e8-45a3-92df-a1797f597a19/lessons/3283ae8e-5dd5-483b-9c49-2faac7c53276/concepts/6acdc289-de30-4f0e-b408-626668c70629
    class func searchPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping (ResponsefromFlickr?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.grabPhotos(latitude, longitude, page).url, responseType: ResponsefromFlickr.self) { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    completion(response, nil)
                    }
            } else {
                completion(nil, error)
                print("Error!")
            }
        }
    }
}
