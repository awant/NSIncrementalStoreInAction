//
//  TextVCs.swift
//  ResultsFetcher
//
//  Created by Admin on 03.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit

class EngTextVC: UIViewController {
    @IBOutlet weak var textField: UITextView!
    var text: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = text
    }
}

class RusTextVC: UIViewController {
    @IBOutlet weak var textField: UITextView!
    var text: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = text
    }
}