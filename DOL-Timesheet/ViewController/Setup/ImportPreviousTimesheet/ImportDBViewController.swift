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
    
    @IBOutlet weak var importView: ShadowView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelBtn: NavigationButton!
    @IBOutlet weak var logsTextView: UITextView!

    var detailLogs = ""
    private var timer: Timer?
    private var workItem: DispatchWorkItem?
    let queue = DispatchQueue(label: "Import DB queue")

    weak var importDelegate: ImportDBProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Create Timer to cancel Service if it takes too long
        createTimer()
        importDB()
    }
    
    func setupView() {
        importView.addBorder(borderColor: .borderColor, borderWidth: 1.0, cornerRadius: 12.0)
        logsTextView.scaleFont(forDataType: .aboutText)
        cancelBtn.backgroundColor = .systemRed
    }
    
    func importDB() {
        // Set a flag to indicate DB Import has started
        let startedDBImport = "StartedDBImport"
        UserDefaults.standard.set(true, forKey: startedDBImport)
        activityIndicator.startAnimating()

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
        activityIndicator.startAnimating()
        timer?.invalidate()
        importDelegate?.importDBSuccessful()
    }

    func importTimedOut() {
        activityIndicator.startAnimating()
        importDelegate?.importDBTimedOut()
        writeDetailLogs()
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
        activityIndicator.startAnimating()
        timer?.invalidate()
        updateTimer()
    }
    
}

extension ImportDBViewController: ImportDBLogProtocol {
    func appendLog(logStr: String) {
        DispatchQueue.main.async { [weak self] in
            var logs = self?.logsTextView.text ?? ""
            logs.append("\n\(logStr)")
            self?.logsTextView.text = logs
            self?.logsTextView.scrollToBottom()
        }
    }
    
    func addDetailLogs(logStr: String) {
        detailLogs.append("\n\(logStr)")
    }
    
    func writeDetailLogs() {
        guard !detailLogs.isEmpty else { return }
        
        let importLogFile = ImportDBService.importLogPath
        
        do {
            try detailLogs.write(to: importLogFile, atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Unable to write to Log File: \(error)")
        }
    }
}

