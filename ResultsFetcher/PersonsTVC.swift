//
//  PersonsTVC.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit
import CoreData

class PersonCell: UITableViewCell {
    var person: Person? {
        didSet {
            self.textLabel?.text = self.person!.firstName! + " " + self.person!.secondName!
        }
    }
    var job: Job? {
        didSet {
            let outText: String
            if let text = self.textLabel?.text {
                outText = text + " " + self.job!.name!
            } else {
                outText = "from " + self.job!.name!
            }
            self.textLabel?.text = outText
        }
    }
    var city: City? {
        didSet {
            let outText: String
            if let text = self.textLabel?.text {
                outText = text + " " + self.city!.name!
            } else {
                outText = "from " + self.city!.name!
            }
            self.textLabel?.text = outText
        }
    }
}

class PersonVC: UIViewController {
    var person: Person?
    var job: Job?
    var city: City?
    
    @IBOutlet var firstNameTF: UITextField!
    @IBOutlet var secondNameTF: UITextField!
    @IBOutlet weak var jobTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.firstNameTF.text = self.person?.firstName
        self.secondNameTF.text = self.person?.secondName
        self.jobTF.text = self.job?.name
        self.cityTF.text = self.city?.name
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        print("saveButtonPressed")
        let moc = CoreDataManager.sharedManager.managedObjectContext
        if self.person == nil {
            self.person = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: moc) as? Person
        }
        self.person?.firstName = self.firstNameTF.text
        self.person?.secondName = self.secondNameTF.text
        
        if self.job == nil {
            // TODO: search for Job with this name
            self.job = NSEntityDescription.insertNewObjectForEntityForName("Job", inManagedObjectContext: moc) as? Job
        }
        self.job?.name = self.jobTF.text
        
        if self.city == nil {
            // TODO: search for City with this name
            self.city = NSEntityDescription.insertNewObjectForEntityForName("City", inManagedObjectContext: moc) as? City
        }
        self.city?.name = self.cityTF.text
        
        // Relationships:
        self.person?.job = self.job
        self.person?.city = self.city
        self.job?.persons?.addObject(self.person!)
        self.city?.persons?.addObject(self.person!)
        
        CoreDataManager.sharedManager.saveContext()
    }
}

extension CoreDataManager {
    func fetchedResultsController(entityName: String, cacheName: String, sortDescriptors: [NSSortDescriptor]) -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: cacheName)
    }
}

class PersonsTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    var fetchresultsController: NSFetchedResultsController?

    override func viewDidLoad() {
        super.viewDidLoad()
        let moc = CoreDataManager.sharedManager.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "secondName", ascending: true)]
        self.fetchresultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "Root")
        
        self.fetchresultsController?.delegate = self
        do {
            try self.fetchresultsController?.performFetch()
        } catch _ { print("something went wrong") }
    }

//  MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let tableView = self.tableView
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.updateCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchresultsController?.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let varValue: Int
        let numberOfObjects = (self.fetchresultsController!.sections![section]).numberOfObjects
        varValue = numberOfObjects
        return varValue
    }
    
    func updateCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        if let personCell = cell as? PersonCell, person = self.fetchresultsController?.objectAtIndexPath(indexPath) as? Person {
            personCell.person = person
            //personCell.job = person.job
            //personCell.city = person.city
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCellID", forIndexPath: indexPath)
        self.updateCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            if let person = (tableView.cellForRowAtIndexPath(indexPath) as? PersonCell)?.person {
                CoreDataManager.sharedManager.managedObjectContext.deleteObject(person)
                CoreDataManager.sharedManager.saveContext()
            }
        case .Insert:
            NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: CoreDataManager.sharedManager.managedObjectContext) as! Person
        case .None:
            _ = 0
        }
    }
    
//  MARK: - navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let person = (sender as? PersonCell)?.person,
            let job = (sender as? PersonCell)?.job,
            let city = (sender as? PersonCell)?.city,
            let editPersonVC = segue.destinationViewController as? PersonVC {
                editPersonVC.person = person
                editPersonVC.job = job
                editPersonVC.city = city
        }
    }
}




