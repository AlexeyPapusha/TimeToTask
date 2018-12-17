//
//  TasksTableViewController.swift
//  TimeToTask
//
//  Created by  Alexey Papusha on 16.12.2018.
//  Copyright © 2018  Alexey Papusha. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController, TaskTableViewCellDelegate {
    
    var tasks: [Task] = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tasksData = UserDefaults.standard.data(forKey: "taskList") {
            tasks = try! JSONDecoder().decode([Task].self, from: tasksData)
        } else {
            tasks = [Task]()
        }
//        restoreStatus()
    }
    
    func saveTasks() {
        let tasksData = try! JSONEncoder().encode(tasks)
        UserDefaults.standard.set(tasksData, forKey: "taskList")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        let task = tasks[indexPath.row]
        let textStop = "Pause"
        
        cell.label.text = task.name
        if task.totalTime != 0 {
            if task.stopWatchIsOn {
                cell.playButton.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
                cell.btimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(TasksTableViewController.change(sender:)), userInfo: indexPath, repeats: true)
                cell.playButton.setTitle(textStop, for: UIControl.State.normal)
            } else {
                let displayTime = task.totalTime
                cell.display.text = covertTimeInterval(interval: TimeInterval(displayTime))
            }
        } else if task.stopWatchIsOn {
            cell.playButton.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            cell.btimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(TasksTableViewController.change(sender:)), userInfo: indexPath, repeats: true)
            cell.playButton.setTitle(textStop, for: UIControl.State.normal)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            saveTasks()
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(itemToMove, at: destinationIndexPath.row)
        saveTasks()
    }

    @IBAction func startEditing(_ sender: Any) {
        setEditing(!isEditing, animated: true)
    }
    
    @IBAction func deleteRows(_ sender: Any) {
        
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for indexPath in selectedRows {
                tasks.remove(at: indexPath.row)
                saveTasks()
            }
            
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @IBAction func cancel(segue: UIStoryboardSegue) {}
    
    @IBAction func done(segue: UIStoryboardSegue) {
        let taskVC = segue.source as! TaskViewController
        let newTask: Task = Task(taskName: taskVC.name)
        
        tasks.append(newTask)
        saveTasks()
        tableView.reloadData()
    }
    
    func taskTableViewCellDidTapPlay(_ sender: TaskTableViewCell) {
        
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let task = tasks[tappedIndexPath.row]
        
        sender.btimer?.invalidate()
        if !task.stopWatchIsOn {
            sender.playButton.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            task.stopWatchIsOn = true
            task.startTime = Date()
            sender.btimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(TasksTableViewController.change(sender:)), userInfo: tappedIndexPath, repeats: true)
            let textStop = "Pause"
            sender.playButton.setTitle(textStop, for: UIControl.State.normal)
        } else {
            task.stopWatchIsOn = false
            let textStart = "Play"
            sender.playButton.setTitle(textStart, for: UIControl.State.normal)
            sender.playButton.backgroundColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
            task.totalTime += Date().timeIntervalSince(task.startTime)
        }
    }
    
    func covertTimeInterval(interval: TimeInterval) -> String {
        
        let absInterval = abs(Int(interval))
        let seconds = absInterval % 60
        let minutes = (absInterval / 60) % 60
        let hours = (absInterval / 3600)
        
        let msec = interval.truncatingRemainder(dividingBy: 1)
        return String(format: "%.2d", hours) + ":" + String(format: "%.2d", minutes) + ":" + String(format: "%.2d", seconds) + "." + String(format: "%.2d", Int(msec * 100))
    }
    
    @objc func change(sender: Timer) {
        
        let tappedIndexPath = sender.userInfo as! IndexPath
        let cell = tableView.cellForRow(at: tappedIndexPath) as! TaskTableViewCell
        let task = tasks[tappedIndexPath.row]
        let displayTime = Date().timeIntervalSince(task.startTime) + task.totalTime
    
        cell.display.text = covertTimeInterval(interval: TimeInterval(displayTime))
        saveTasks()
    }
}

