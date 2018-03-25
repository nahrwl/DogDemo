//
//  DogService.swift
//  DogDemo
//
//  Created by Nathan Wallace on 3/24/18.
//  Copyright © 2018 Nathan Wallace. All rights reserved.
//

import Alamofire
import SwiftyJSON


class DogService {
    
    static func fetch(_ endpoint: String, success: @escaping (JSON) -> Void) {
        Alamofire.request("https://dog.ceo" + endpoint)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let json):
                    let data = JSON(json)
                    print("Response JSON: \(json)")
                    
                    success(data)
                case .failure(let error):
                    print("Error retrieving dog API info: \(error)")
                }
        }
    }
    
    static func fetchDogBreeds(success: @escaping (JSON) -> Void) {
        fetch("/api/breeds/list/all", success: success)
    }
    
    
    static func fetchRandomImageForBreed(_ breed: String, success: @escaping (JSON) -> Void) {
        fetch("/api/breed/\(breed)/images/random", success: success)
    }
    
}
