//
//  Task.swift
//  TimeToTask
//
//  Created by  Alexey Papusha on 17.12.2018.
//  Copyright © 2018  Alexey Papusha. All rights reserved.
//

import Foundation

class Task: Codable {
    
    let name: String
    var startTime: Date = Date()
    var totalTime: Double = 0.0
    var stopWatchIsOn: Bool = false
    
    init(taskName: String) {
        name = taskName
    }
}
