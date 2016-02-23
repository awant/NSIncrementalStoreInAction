//
//  ArtistsTableVC.swift
//  LyricsOfMusic
//
//  Created by Admin on 25.10.15.
//  Copyright © 2015 com.mipt. All rights reserved.
//

import UIKit
import Kangaroo
import CloudKit

class ArtistTableVCell: UITableViewCell {
    
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artistImageView.layer.borderWidth = 1.0
        artistImageView.layer.masksToBounds = false
        artistImageView.layer.borderColor = UIColor.whiteColor().CGColor
        artistImageView.layer.cornerRadius = 13
        artistImageView.layer.cornerRadius = artistImageView.frame.size.height/2
        artistImageView.clipsToBounds = true
    }
}

class ArtistsTableVC: UITableViewController {
    var artists: [Artist]?
    var coreDataManager = SimpleCoreDataManager<AppConfig>()
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.rowHeight = 80
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataManager.executeAsyncFetchRequest(nil, sortDescriptors: nil) { (artists: [Artist]) -> Void in
            self.artists = artists
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTable:", name: fNotificationName, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateTable(notification: NSNotification) {
        self.artists! += (notification.userInfo![fNewObjectsName] as! [Artist])
        self.tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artists?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("ArtistCellId")!
    }
    
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! ArtistTableVCell
        guard let artist = self.artists?[indexPath.row] else {
            return
        }
        cell.artistField?.text = artist.name
        cell.artistImageView.image = UIImage(data: artist.image!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let pathForSelectedRow = tableView.indexPathForSelectedRow
        
        if segue.identifier == "toAlbums" {
            (segue.destinationViewController as! AlbumsTableVC).artist = self.artists![(pathForSelectedRow?.row)!]
        }
    }
}












































