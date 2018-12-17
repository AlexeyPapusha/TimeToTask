//
//  TaskViewController.swift
//  TimeToTask
//
//  Created by  Alexey Papusha on 16.12.2018.
//  Copyright © 2018  Alexey Papusha. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {

    @IBOutlet weak var taskName: UITextField!
    
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSegue" {
            name = taskName.text!
        }
    }
}
