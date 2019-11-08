//
//  ImportDBViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 11/6/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol ImportDBProtocol: class {
    func importDBSuccessful()
    func importDBTimedOut()
    func importDBFinish()
    func emailOldDB()
}

class ImportDBViewController: UIViewController {
    private var timer: Timer?
    private var workItem: DispatchWorkItem?
    let queue = DispatchQueue(label: "Import DB queue")

    weak var importDelegate: ImportDBProtocol?
    @IBOutlet weak var logsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Create Timer to cancel Service if it takes too long
        createTimer()
        importDB()
    }
    
    func importDB() {
        // Set a flag to indicate DB Import has started
        let startedDBImport = "StartedDBImport"
        UserDefaults.standard.set(true, forKey: startedDBImport)
        workItem = DispatchWorkItem { [weak self] in
            let importDB = ImportDBService()
            importDB.logDelegate = self
            importDB.importDB()
            self?.appendLog(logStr: "Sleeping for 30 Seconds")
            sleep(30)
            if self?.workItem!.isCancelled ?? true {
                print("Work Item Cancelled")
            }
            else {
                print("Finished import")
                DispatchQueue.main.async {
                    self?.importSucecessful()
                }
            }
        }
        queue.async(execute: workItem!)
    }

    func importSucecessful() {
        timer?.invalidate()
        importDelegate?.importDBSuccessful()
    }

    func importTimedOut() {
        importDelegate?.importDBTimedOut()
    }
    
    private func createTimer() {
      if timer == nil {
        timer = Timer.scheduledTimer(timeInterval: 40.0,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: false)
        }
    }
    
    @objc func updateTimer() {
        print("Updated Timer")
        workItem?.cancel()
        importTimedOut()
    }

    deinit {
        print("viewController deinit")
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        timer?.invalidate()
        updateTimer()
    }
    
}

extension ImportDBViewController: ImportDBLogProtocol {
    func appendLog(logStr: String) {
        DispatchQueue.main.async { [weak self] in
            print(logStr)
            var logs = self?.logsTextView.text ?? ""
            logs.append("\n")
            logs.append(logStr)
            self?.logsTextView.text = logs
            self?.logsTextView.scrollToBottom()
        }
    }
}

