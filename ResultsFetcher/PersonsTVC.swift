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
            self.textLabel?.text = self.person!.firstName + " " + self.person!.secondName
        }
    }
}

class PersonVC: UIViewController {
    var person: Person?
    
    @IBOutlet var firstNameTF: UITextField!
    @IBOutlet var secondNameTF: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.firstNameTF.text = self.person?.firstName
        self.secondNameTF.text = self.person?.secondName
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        if self.person == nil {
            self.person = CoreDataManager.sharedManager.personInsertion()
        }
        self.person?.firstName = self.firstNameTF.text!
        self.person?.secondName = self.secondNameTF.text!
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
        let sortDescriptors = [NSSortDescriptor(key: "secondName", ascending: true)]
        self.fetchresultsController = CoreDataManager.sharedManager.fetchedResultsController("Person", cacheName: "Root", sortDescriptors: sortDescriptors)
        self.fetchresultsController?.delegate = self
        do {
            try self.fetchresultsController?.performFetch()
        } catch _ {}
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
            CoreDataManager.sharedManager.personInsertion()
        case .None:
            _ = 0
        }
    }
    
//  MARK: - navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let person = (sender as? PersonCell)?.person,
            let editPersonVC = segue.destinationViewController as? PersonVC {
            editPersonVC.person = person
        }
    }
}
