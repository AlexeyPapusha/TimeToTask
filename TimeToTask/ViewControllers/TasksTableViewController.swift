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
    var timers: [Timer?] = [Timer?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTasks()
    }
    
    func loadTasks() {
        if let tasksData = UserDefaults.standard.data(forKey: "taskList") {
            tasks = try! JSONDecoder().decode([Task].self, from: tasksData)
            if tasks.count > 0 {
                for _ in 1...tasks.count {
                    timers.append(Timer())
                }
            }
        } else {
            tasks = [Task]()
            timers = [Timer?]()
        }
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
        let zeroTime = "00:00:00.00"
        let task = tasks[indexPath.row]
        let textStop = "Pause"
        
        cell.label.text = task.name
        
        if task.stopWatchIsOn {
            cell.playButton.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            
            if timers[indexPath.row] == nil {
                timers[indexPath.row] = Timer.scheduledTimer(
                    timeInterval: 0.01,
                    target: self,
                    selector: #selector(TasksTableViewController.change(sender:)),
                    userInfo: indexPath,
                    repeats: true)
            }
            cell.playButton.setTitle(textStop, for: UIControl.State.normal)
        } else {
            if task.totalTime != 0 {
                let displayTime = task.totalTime
                cell.display.text = covertTimeInterval(interval: TimeInterval(displayTime))
            } else {
                cell.display.text = zeroTime
            }
        }
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            pauseTimers()
            
            tasks.remove(at: indexPath.row)
            timers.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            tableView.endUpdates()
            
            saveTasks()
            
            refreshTimers()
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        pauseTimers()
        
        let task = tasks[sourceIndexPath.row]
        let timer = timers[sourceIndexPath.row]
        
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        
        timers.remove(at: sourceIndexPath.row)
        timers.insert(timer, at: destinationIndexPath.row)
        
        saveTasks()
        
        refreshTimers()
    }

    @IBAction func startEditing(_ sender: Any) {
        setEditing(!isEditing, animated: true)
    }
    
    @IBAction func deleteRows(_ sender: Any) {
        
        if let selectedRows = tableView.indexPathsForSelectedRows {
            
            pauseTimers()
            
            for indexPath in selectedRows {
                tasks.remove(at: indexPath.row)
                timers.remove(at: indexPath.row)
                saveTasks()
            }
            
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .automatic)
            tableView.endUpdates()
            
            refreshTimers()
        }
    }
    
    @IBAction func cancel(segue: UIStoryboardSegue) {}
    
    @IBAction func done(segue: UIStoryboardSegue) {
        let taskVC = segue.source as! TaskViewController
        let newTask: Task = Task(taskName: taskVC.name)
        
        tasks.append(newTask)
        timers.append(Timer())
        saveTasks()
        
        tableView.reloadData()
    }
    
    func taskTableViewCellDidTapPlay(_ sender: TaskTableViewCell) {
        
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let task = tasks[tappedIndexPath.row]
        
        timers[tappedIndexPath.row]?.invalidate()
        if !task.stopWatchIsOn {
            sender.playButton.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            task.stopWatchIsOn = true
            task.startTime = Date()
            timers[tappedIndexPath.row] = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(TasksTableViewController.change(sender:)), userInfo: tappedIndexPath, repeats: true)
            let textStop = "Pause"
            sender.playButton.setTitle(textStop, for: UIControl.State.normal)
        } else {
            task.stopWatchIsOn = false
            let textStart = "Play"
            sender.playButton.setTitle(textStart, for: UIControl.State.normal)
            sender.playButton.backgroundColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
            task.totalTime += Date().timeIntervalSince(task.startTime)
        }
        saveTasks()
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
    
    func pauseTimers() {
        timers.forEach { timer in
            timer?.invalidate()
        }
    }
    
    func refreshTimers() {
        for indexPath in tableView.indexPathsForVisibleRows! {
            if tasks[indexPath.row].stopWatchIsOn {
                timers[indexPath.row] = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(TasksTableViewController.change(sender:)), userInfo: indexPath, repeats: true)
            } else {
                timers[indexPath.row] = Timer()
            }
        }
    }
}

