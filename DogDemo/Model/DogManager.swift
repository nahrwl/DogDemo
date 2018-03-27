//
//  DogManager.swift
//  DogDemo
//
//  Created by Nathan Wallace on 3/24/18.
//  Copyright © 2018 Nathan Wallace. All rights reserved.
//

import SwiftyJSON
import CoreData


protocol DogManagerDelegate {
    func didEndRefreshing()
}


class DogManager {
    var delegate: DogManagerDelegate?
    
    static let shared = DogManager()
    private init() {}
    
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
            
            self.refreshing = false
            appDelegate.saveContext()
        }, failure: { (error) in
            self.refreshing = false
        })
    }
    
    
    func refreshImageForBreed(_ breed: String) {
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
            
            appDelegate.saveContext()
        }, failure: nil)
    }
}
