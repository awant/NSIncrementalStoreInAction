//
//  NewArtistVC.swift
//  ResultsFetcher
//
//  Created by Roman Marakulin on 28.02.16.
//  Copyright © 2016 Artemiy Sobolev. All rights reserved.
//

import UIKit
import Kangaroo

class NewArtistVC: UIViewController {
    var coreDataManager = SimpleCoreDataManager<AppConfig>()
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveButtonPressed(sender: UIButton) {
        let artist: Artist = coreDataManager.insertNewObjectForEntityForName()
        artist.name = nameField.text
        artist.image =  UIImagePNGRepresentation(imageView.image!)
        coreDataManager.saveChanges()
    }
}
