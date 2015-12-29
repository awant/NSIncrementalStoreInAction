//
//  TextVCs.swift
//  ResultsFetcher
//
//  Created by Admin on 03.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit

class SongTextVC: UIViewController {
    var songCO: SongConfigObject!
    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        textField.text = songCO.texts[.English]
        super.viewDidLoad()
        
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        if sender.title == "Eng" {
            textField.text = songCO.texts[.English]
        }
        if sender.title == "Rus" {
            textField.text = songCO.texts[.Russian]
        }
    }
    
    
}