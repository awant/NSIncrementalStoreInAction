//
//  SongsTableVC.swift
//  ResultsFetcher
//
//  Created by Admin on 03.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit
import Kangaroo

class SongVC: UIViewController {
    @IBOutlet var songNameTF: UITextField!
}

class SongTableVCell: UITableViewCell {
    @IBOutlet weak var songField: UILabel!
}

enum SupportedLanguages {
    case English
    case Russian
}

class SongConfigObject {
    var song: Song!
    var texts: [SupportedLanguages: String]!
    
    init(song: Song) {
        self.song = song
        texts = [SupportedLanguages: String]()
        texts[.English] = song.textEng
        texts[.Russian] = song.textRus
    }
}

class SongsTableVC: UITableViewController {
    var songCO: SongConfigObject!
    var coreDataManager = SimpleCoreDataManager<AppConfig>()
    
    var album: Album?
    var songs = [Song]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80
        let predicate = NSPredicate(format: "album = %@", (album?.objectID)!)
        
        coreDataManager.executeAsyncFetchRequest(predicate, sortDescriptors: nil) { [weak self] (songs: [Song]) -> Void in
            self!.songs = songs
            self!.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("SongCellId")!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! SongTableVCell
        guard let songName = self.songs[indexPath.row].name else {
            return
        }
        cell.songField?.text = songName
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let pathForSelectedRow = tableView.indexPathForSelectedRow
        
        if segue.identifier == "toTexts" {
            let vc = segue.destinationViewController as! SongTextVC
            vc.songCO = SongConfigObject(song: songs[(pathForSelectedRow?.row)!])
        }
    }
}



















































