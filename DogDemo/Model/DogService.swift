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
    private init() {} // This class cannot be initialized.
    
    /* Generic function for fetching from the dog.ceo API */
    static func fetch(_ endpoint: String, success: ((JSON) -> Void)?, failure: ((Error) -> Void)?) {
        Alamofire.request("https://dog.ceo" + endpoint)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let json):
                    let data = JSON(json)
                    print("Response JSON: \(json)")
                    
                    success?(data)
                case .failure(let error):
                    print("Error retrieving dog API info: \(error)")
                    failure?(error)
                }
        }
    }
    
    
    /* Dog breed list endpoint */
    static func fetchDogBreeds(success: ((JSON) -> Void)?, failure: ((Error) -> Void)?) {
        fetch("/api/breeds/list/all", success: success, failure: failure)
    }
    
    
    /* Dog breed image endpoint */
    static func fetchRandomImageForBreed(_ breed: String, success: ((JSON) -> Void)?, failure: ((Error) -> Void)?) {
        fetch("/api/breed/\(breed)/images/random", success: success, failure: failure)
    }
    
}
