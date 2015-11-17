//
//  AlbumsTableVC.swift
//  ResultsFetcher
//
//  Created by Admin on 01.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit
import GenericCoreData

class AlbumTableVCell: UITableViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        albumImageView.layer.borderWidth = 1.0
        albumImageView.layer.masksToBounds = false
        albumImageView.layer.borderColor = UIColor.whiteColor().CGColor
        albumImageView.layer.cornerRadius = 13
        albumImageView.layer.cornerRadius = albumImageView.frame.size.height/2
        albumImageView.clipsToBounds = true
    }
}

class AlbumsTableVC: UITableViewController {
    var albums: [Album]?
    let coreDataManager = CoreDataManager<AppConfig>(contextType: .PrivateQueue)
    
    var artist: Artist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80
        let predicate = NSPredicate(format: "artist = %@", (artist?.objectID)!)
        coreDataManager.executeAsyncRequest(predicate, sortDescriptors: nil, errorHandler: ConsoleErrorHandler) { (albums: [Album]) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.albums = albums
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("AlbumCellId")!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = cell as! AlbumTableVCell
        guard let album = self.albums?[indexPath.row] else {
            return
        }
        cell.albumField?.text = album.name
        cell.albumImageView.image = UIImage(data: album.image!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let pathForSelectedRow = tableView.indexPathForSelectedRow
        
        if segue.identifier == "toSongs" {
            (segue.destinationViewController as! SongsTableVC).album = self.albums![(pathForSelectedRow?.row)!]
        }
    }
}
