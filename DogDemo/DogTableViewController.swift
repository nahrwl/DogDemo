//
//  DogTableViewController.swift
//  DogDemo
//
//  Created by Nathan Wallace on 3/23/18.
//  Copyright © 2018 Nathan Wallace. All rights reserved.
//

import UIKit
import CoreData

class DogTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, DogManagerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<DogMO>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DogManager.shared.delegate = self

        title = "Dog Breeds"
        
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        initializeFetchedResultsController()
        refreshData()
    }
    
    
    func initializeFetchedResultsController() {
        let request:NSFetchRequest<DogMO> = DogMO.fetchRequest()
        let breedSort = NSSortDescriptor(key: "breed", ascending: true)
        request.sortDescriptors = [breedSort]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let moc = appDelegate.persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to create fetchedResultsController: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogCell", for: indexPath) as! DogTableViewCell
        
        guard let dog = fetchedResultsController?.object(at: indexPath) else {
            fatalError("Cell configuration failed because there is no fetchedResultsController.")
        }
        
        cell.dogTitle.text = dog.breed
        cell.imageURL = dog.imageURL
        
        return cell
    }
    
    // MARK: - Refreshing
    
    @objc func refreshData() {
        DogManager.shared.refreshDogBreeds()
    }
    
    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Dog Manager Delegate
    
    func didEndRefreshing() {
        endRefreshing()
    }
    

    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
