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
    var songs: [Song]?
    let coreDataManager = CoreDataManager<AppConfig>(contextType: .PrivateQueue)
    var album: Album?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80
        let predicate = NSPredicate(format: "album = %@", (album?.objectID)!)
        coreDataManager.executeAsyncRequest(predicate, sortDescriptors: nil, errorHandler: ConsoleErrorHandler) { (songs: [Song]) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.songs = songs
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs?.count ?? 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("SongCellId")!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = cell as! SongTableVCell
        guard let song = self.songs?[indexPath.row] else {
            return
        }
        cell.songField?.text = song.name
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let pathForSelectedRow = tableView.indexPathForSelectedRow
        if segue.identifier == "toSongVC" {
        }
        
        if segue.identifier == "toTexts" {
            let vcs = (segue.destinationViewController as! TextTabBarController).viewControllers
            let engVC = (vcs![0]  as! EngTextVC)
            let rusVC = (vcs![1] as! RusTextVC)
            engVC.text = self.songs![pathForSelectedRow!.row].textEng
            rusVC.text = self.songs![pathForSelectedRow!.row].textRus
        }
    }
}
