//
//  SongsTableVC.swift
//  ResultsFetcher
//
//  Created by Admin on 03.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit
import GenericCoreData

class SongVC: UIViewController {
    
    @IBOutlet var songNameTF: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
    }
}

class SongTableVCell: UITableViewCell {
    
    @IBOutlet weak var songField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class SongsTableVC: UITableViewController {
    var viewModel: FetchedListViewModel<Song, AppConfig>!
    var album: Album?

    override func viewDidLoad() {
        super.viewDidLoad()
        let predicate = NSPredicate(format: "album = %@", (album?.objectID)!)
        let sds = [NSSortDescriptor(key: "name", ascending: true)]
        viewModel = FetchedListViewModel(tableView: tableView, predicate: predicate, sortDescriptors: sds, sectionNameKeyPath: nil, cacheType: .RandomCache)
        viewModel.performFetch()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("SongCellId")!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = viewModel.item(indexPath)?.name
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let pathForSelectedRow = tableView.indexPathForSelectedRow
        if segue.identifier == "toSongVC" {
        }
        
        if segue.identifier == "toTexts" {
            let vcs = (segue.destinationViewController as! TextTabBarController).viewControllers
            let engVC = (vcs![0]  as! EngTextVC)
            let rusVC = (vcs![1] as! RusTextVC)
            engVC.text = viewModel.item(pathForSelectedRow!)?.songEng
            rusVC.text = viewModel.item(pathForSelectedRow!)?.songRus
        }
    }
}
