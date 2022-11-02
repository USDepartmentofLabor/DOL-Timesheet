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
    
    @IBOutlet weak var importView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logsTitleLabel: UILabel!
    @IBOutlet weak var logsStackView: UIStackView!
    @IBOutlet weak var logsScrollView: UIScrollView!
    
    var detailLogs = ""
    private var timer: Timer?
    private var workItem: DispatchWorkItem?
    let queue = DispatchQueue(label: "Import DB queue")

    weak var importDelegate: ImportDBProtocol?
    lazy var logDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Create Timer to cancel Service if it takes too long
        createTimer()
        importDB()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 8.0).cgPath
        shadowView.layer.shadowRadius = 8.0
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowOpacity = 1
    }

    func setupView() {
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        }
        
        titleLabel.scaleFont(forDataType: .headingTitle)
        logsTitleLabel.scaleFont(forDataType: .columnHeader)
        importView.addBorder(borderColor: .borderColor, borderWidth: 1.0, cornerRadius: 8.0)
    }
    
    func importDB() {
        // Set a flag to indicate DB Import has started
        let startedDBImport = "StartedDBImport"
        UserDefaults.standard.set(true, forKey: startedDBImport)
        
        let announcementMsg = "import started".localized
        logsTitleLabel.text = announcementMsg
        UIAccessibility.post(notification: .announcement, argument: announcementMsg)
        activityIndicator.startAnimating()
        
        workItem = DispatchWorkItem { [weak self] in
            let importDB = ImportDBService()
            importDB.logDelegate = self
            importDB.importDB()
            if self?.workItem!.isCancelled ?? true {
            }
            else {
                DispatchQueue.main.async {
                    self?.importSucecessful()
                }
            }
        }
        queue.async(execute: workItem!)
    }

    func importSucecessful() {
        activityIndicator.stopAnimating()
        
        let announcementMsg = "import finished".localized
        logsTitleLabel.text = announcementMsg
        UIAccessibility.post(notification: .announcement, argument: announcementMsg)
        
        timer?.invalidate()
        importDelegate?.importDBSuccessful()
    }

    @objc func importTimedOut() {
        activityIndicator.stopAnimating()
        workItem?.cancel()
        addDetailLogs(logStr: "Import Timed Out")
        writeDetailLogs()
        importDelegate?.importDBTimedOut()
    }
    
    private func createTimer() {
      if timer == nil {
        timer = Timer.scheduledTimer(timeInterval: 60.0,
                                     target: self,
                                     selector: #selector(importTimedOut),
                                     userInfo: nil,
                                     repeats: false)
        }
    }        
}

extension ImportDBViewController: ImportDBLogProtocol {
    func appendLog(logStr: String) {
        DispatchQueue.main.async { [weak self] in
            let label = UILabel()
            label.numberOfLines = 0
            label.scaleFont(forDataType: .aboutText)
            label.text = logStr
            self?.logsStackView.addArrangedSubview(label)
            
            if !Util.isVoiceOverRunning {
                self?.logsScrollView.scrollToBottom()
            }
        }
    }
    
    func addDetailLogs(logStr: String) {
        let strDate = logDateFormatter.string(from: Date())
        detailLogs.append("\n\(strDate): \(logStr)")
    }
    
    func writeDetailLogs() {
        guard !detailLogs.isEmpty else { return }
        
        let importLogFile = ImportDBService.importLogPath
        
        let systemVersion = "System Version: \(UIDevice.current.systemVersion)"
        let deviceType = "\nDevice Type: \(UIDevice.modelName)\n"
        detailLogs = systemVersion + deviceType + detailLogs
        
        do {
            try detailLogs.write(to: importLogFile, atomically: false, encoding: String.Encoding.utf8)
        } catch let _ as NSError {
//            print("Unable to write to Log File: \(error)")
        }
    }
}

