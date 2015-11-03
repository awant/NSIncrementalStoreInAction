//
//  ArtistsTableVC.swift
//  LyricsOfMusic
//
//  Created by Admin on 25.10.15.
//  Copyright © 2015 com.mipt. All rights reserved.
//

import UIKit
import GenericCoreData

class ArtistVC: UIViewController {
    var viewModel: FetchedListViewModel<Artist, AppConfig>!
    var artist: Artist?
    
    @IBOutlet var artistNameTF: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.artistNameTF.text = self.artist?.name
    }

    @IBAction func saveButtonPressed(sender: UIButton) {
    }
}


class ArtistTableVCell: UITableViewCell {
    
    //@IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class ArtistsTableVC: UITableViewController {
    var viewModel: FetchedListViewModel<Artist, AppConfig>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sds = [NSSortDescriptor(key: "name", ascending: true)]
        viewModel = FetchedListViewModel(tableView: tableView, predicate: nil, sortDescriptors: sds, sectionNameKeyPath: nil, cacheType: .RandomCache)
        viewModel.performFetch()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("ArtistCellId")!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = viewModel.item(indexPath)?.name
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let pathForSelectedRow = tableView.indexPathForSelectedRow
        
        if segue.identifier == "toArtistVC" {
        }
        
        if segue.identifier == "toAlbums" {
            (segue.destinationViewController as! AlbumsTableVC).artist = viewModel.item(pathForSelectedRow!)
        }
    }
}



