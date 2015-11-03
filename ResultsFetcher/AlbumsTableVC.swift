//
//  AlbumsTableVC.swift
//  ResultsFetcher
//
//  Created by Admin on 01.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit
import GenericCoreData

class AlbumVC: UIViewController {
    
    @IBOutlet var albumNameTF: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
    }
}

class AlbumTableVCell: UITableViewCell {
    
    //@IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class AlbumsTableVC: UITableViewController {
    var viewModel: FetchedListViewModel<Album, AppConfig>!
    var artist: Artist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let predicate = NSPredicate(format: "artist = %@", (artist?.objectID)!)
        let sds = [NSSortDescriptor(key: "name", ascending: true)]
        viewModel = FetchedListViewModel(tableView: tableView, predicate: predicate, sortDescriptors: sds, sectionNameKeyPath: nil, cacheType: .RandomCache)
        viewModel.performFetch()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("AlbumCellId")!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = viewModel.item(indexPath)?.name
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let pathForSelectedRow = tableView.indexPathForSelectedRow
        
        if segue.identifier == "toAlbumVC" {
        }
        
        if segue.identifier == "toSongs" {
            (segue.destinationViewController as! SongsTableVC).album = viewModel.item(pathForSelectedRow!)
        }
    }
}
