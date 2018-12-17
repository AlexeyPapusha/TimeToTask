//
//  TaskTableViewCell.swift
//  TimeToTask
//
//  Created by  Alexey Papusha on 17.12.2018.
//  Copyright © 2018  Alexey Papusha. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var display: UILabel!
    
    weak var delegate: TaskTableViewCellDelegate?
    
    var btimer: Timer?
    
    @IBAction func playTapped(_ sender: UIButton) {
        delegate?.taskTableViewCellDidTapPlay(self)
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editingStyle != .delete {
            if editing {
                playButton.isHidden = true
            } else {
                playButton.isHidden = false
            }
        }
    }
}

protocol TaskTableViewCellDelegate : class {
    func taskTableViewCellDidTapPlay(_ sender: TaskTableViewCell)
}
