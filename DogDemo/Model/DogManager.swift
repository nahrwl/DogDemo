//
//  DogManager.swift
//  DogDemo
//
//  Created by Nathan Wallace on 3/24/18.
//  Copyright © 2018 Nathan Wallace. All rights reserved.
//

import SwiftyJSON
import CoreData


/* Delegate for DogManager so the current view controller can subscribe to updates */
protocol DogManagerDelegate {
    func didEndRefreshing()
}


class DogManager {
    var delegate: DogManagerDelegate?
    
    static let shared = DogManager()
    private init() {}
    
    // This property tracks the number of outstanding API requests
    // regarding fetching the URL of a random dog image.
    // When the counter reaches 0, it will end refreshing.
    private var imageURLFetchTracker: UInt = 0 {
        didSet {
            if imageURLFetchTracker == 0 {
                // End refreshing
                refreshing = false
            }
        }
    }
    
    private(set) var refreshing = false {
        didSet {
            // If refreshing changes from true to false
            if !refreshing && oldValue {
                // Notify the delegate
                delegate?.didEndRefreshing()
            }
        }
    }
    
    func refreshDogBreeds() {
        refreshing = true
        DogService.fetchDogBreeds(success: { (data) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let moc = appDelegate.persistentContainer.viewContext
            
            for (breed, _):(String, JSON) in data["message"] {
                let req: NSFetchRequest<DogMO> = DogMO.fetchRequest()
                req.predicate = NSPredicate(format: "breed == %@", breed)
                
                do {
                    let fetchedDogs = try moc.fetch(req)
                    
                    // If the dog breed isn't already stored, store it
                    if fetchedDogs.count == 0 {
                        let dog = DogMO(context: moc)
                        dog.breed = breed
                    }
                } catch {
                    fatalError("Failed to refresh dogs: \(error)")
                }
                
                self.refreshImageForBreed(breed)
                
            }
            
            appDelegate.saveContext()
        }, failure: { (error) in
            self.refreshing = false
        })
    }
    
    
    func refreshImageForBreed(_ breed: String) {
        imageURLFetchTracker += 1
        DogService.fetchRandomImageForBreed(breed, success: { (data) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let moc = appDelegate.persistentContainer.viewContext
            
            let req: NSFetchRequest<DogMO> = DogMO.fetchRequest()
            req.predicate = NSPredicate(format: "breed == %@", breed)
            
            let fetchedDogs: [DogMO]?
            do {
                fetchedDogs = try moc.fetch(req)
            } catch {
                fatalError("Failed to refresh dogs: \(error)")
            }
            
            guard let dogs = fetchedDogs else { return }
            guard dogs.count > 0 else { return }
            
            let imageURLString = data["message"].stringValue
            for dogMO in dogs {
                dogMO.imageURL = URL(string: imageURLString)
            }
            
            self.imageURLFetchTracker -= 1
            
            appDelegate.saveContext()
        }, failure: { (error) in
            self.imageURLFetchTracker -= 1
        })
    }
}
