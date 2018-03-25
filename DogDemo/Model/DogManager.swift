//
//  DogManager.swift
//  DogDemo
//
//  Created by Nathan Wallace on 3/24/18.
//  Copyright © 2018 Nathan Wallace. All rights reserved.
//

import Alamofire
import SwiftyJSON
import CoreData


class DogManager {
    static let shared = DogManager()
    private init() {}
    
    func fetchDogBreeds() {
        Alamofire.request("https://dog.ceo/api/breeds/list/all")
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let json):
                    let data = JSON(json)
                    print("Response JSON: \(json)")
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    let moc = appDelegate.persistentContainer.viewContext
                    
                    // Remove all the dogs so they can be replaced with new data
                    let fetch: NSFetchRequest<NSFetchRequestResult> = DogMO.fetchRequest()
                    let req = NSBatchDeleteRequest(fetchRequest: fetch)
                    do {
                        try moc.execute(req)
                    } catch {
                        fatalError("Failed to delete objects: \(error)")
                    }
                    
                    for (breed, _):(String, JSON) in data["message"] {
                        let dog = DogMO(context: moc)
                        dog.breed = breed
                    }
                    
                    appDelegate.saveContext()
                case .failure(let error):
                    print("Error retrieving dog breeds: \(error)")
                }
        }
    }
}
