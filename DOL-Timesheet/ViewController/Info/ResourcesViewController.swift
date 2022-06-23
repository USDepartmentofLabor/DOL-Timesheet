//
//  ResourcesViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ResourcesViewController: UIViewController {

    let emailLink = "https://webapps.dol.gov/contactwhd/"
    let contactOfficeLink = "https://www.dol.gov/whd/local/"
    let whdWebsiteLink = "http://www.dol.gov/whd"
    let webadminEmail = "webmaster@dol.gov"
    
    @IBOutlet weak var copyDatabase: UIButton!
    @IBOutlet weak var contactTitleLabel: UILabel!
    @IBOutlet weak var phoneTextView1: UITextView!
    @IBOutlet weak var phoneTextView2: UITextView!
    @IBOutlet weak var phoneHoursLabel: UILabel!
//    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var contactTextView: UITextView!
//    @IBOutlet weak var whdWebsiteTextView: UITextView!
    
    @IBOutlet weak var submitIssuesTitleLabel: UILabel!
    @IBOutlet weak var webadminTextView: UITextView!
    @IBOutlet weak var gitHubTextView: UITextView!
    @IBOutlet weak var secondGitHubTextView: UITextView!
    @IBOutlet weak var servicesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        displayInfo()
    }

    func setupView() {
        title = NSLocalizedString("contact_us", comment: "Contact Us")
//        contactTitleLabel.scaleFont(forDataType: .resourcesTitleText)
        phoneTextView1.scaleFont(forDataType: .resourcesText)
        phoneTextView2.scaleFont(forDataType: .resourcesText)
        phoneHoursLabel.scaleFont(forDataType: .contactUsLabel)
//        emailTextView.scaleFont(forDataType: .resourcesTitleText)
        contactTextView.scaleFont(forDataType: .resourcesTitleText)
//        whdWebsiteTextView.scaleFont(forDataType: .resourcesTitleText)
        
//        submitIssuesTitleLabel.scaleFont(forDataType: .resourcesTitleText)
        webadminTextView.scaleFont(forDataType: .resourcesText)
        gitHubTextView.scaleFont(forDataType: .resourcesText)
        secondGitHubTextView.scaleFont(forDataType: .resourcesText)
        servicesLabel.scaleFont(forDataType: .contactUsLabel)
        
        phoneTextView1.textContainerInset = UIEdgeInsets.zero
        phoneTextView1.textContainer.lineFragmentPadding = 0
        phoneTextView2.textContainerInset = UIEdgeInsets.zero
        phoneTextView2.textContainer.lineFragmentPadding = 0
//        emailTextView.textContainerInset = UIEdgeInsets.zero
//        emailTextView.textContainer.lineFragmentPadding = 0
        contactTextView.textContainerInset = UIEdgeInsets.zero
        contactTextView.textContainer.lineFragmentPadding = 0
        webadminTextView.textContainerInset = UIEdgeInsets.zero
        webadminTextView.textContainer.lineFragmentPadding = 0
        gitHubTextView.textContainerInset = UIEdgeInsets.zero
        gitHubTextView.textContainer.lineFragmentPadding = 0
        secondGitHubTextView.textContainerInset = UIEdgeInsets.zero
        secondGitHubTextView.textContainer.lineFragmentPadding = 0
//        whdWebsiteTextView.textContainerInset = UIEdgeInsets.zero
//        whdWebsiteTextView.textContainer.lineFragmentPadding = 0
        
        phoneTextView1.linkTextAttributes = [NSAttributedString.Key.underlineStyle: 0, NSAttributedString.Key.foregroundColor:  UIColor(named: "linkColor")!]
        phoneTextView2.linkTextAttributes = [NSAttributedString.Key.underlineStyle: 0, NSAttributedString.Key.foregroundColor:  UIColor(named: "linkColor")!]
        
        webadminTextView.linkTextAttributes = [NSAttributedString.Key.underlineStyle: 0, NSAttributedString.Key.foregroundColor:  UIColor(named: "linkColor")!]
        gitHubTextView.linkTextAttributes = [NSAttributedString.Key.underlineStyle: 0, NSAttributedString.Key.foregroundColor:  UIColor(named: "linkColor")!]
        secondGitHubTextView.linkTextAttributes = [NSAttributedString.Key.underlineStyle: 0, NSAttributedString.Key.foregroundColor:  UIColor(named: "linkColor")!]
    }
    
    func displayInfo() {
//        let emailText = NSAttributedString(string: "Send an email to the Wage and Hour Division", attributes: [NSAttributedString.Key.link: ResourcesViewController.emailLink, NSAttributedString.Key.font: Style.scaledFont(forDataType: .resourcesText),
//            NSAttributedString.Key.underlineStyle: 1])
//        emailTextView.attributedText = emailText
        
        //let contactText = NSAttributedString(string: "Contact the office nearest you", attributes: [NSAttributedString.Key.link: ResourcesViewController.contactOfficeLink,
            //NSAttributedString.Key.font: Style.scaledFont(forDataType: .resourcesText),
            //NSAttributedString.Key.underlineStyle: 0])
        //contactTextView.attributedText = contactText

//        let websiteText = NSAttributedString(string: "Wage and Hour Division website", attributes: [NSAttributedString.Key.link: ResourcesViewController.whdWebsiteLink,
//            NSAttributedString.Key.font: Style.scaledFont(forDataType: .resourcesText),
//            NSAttributedString.Key.underlineStyle: 1])
//        whdWebsiteTextView.attributedText = websiteText        
    }
    
    @IBAction func phone1Pressed(_ sender: Any) {
        let number = "1-886-487-9243"
        guard let phoneNumber = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(phoneNumber)
    }
    
    @IBAction func phone2Pressed(_ sender: Any) {
        let number = "1-877-889-5627"
        guard let phoneNumber = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(phoneNumber)
    }
  
    @IBAction func onlineFormPressed(_ sender: Any) {
        //emailLink
        guard let url = URL(string: emailLink) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func emailPressed(_ sender: Any) {
        //WHDappFeedback@dol.gov
        if let url = URL(string: "mailto:\("WHDappFeedback@dol.gov")") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    
    @IBAction func web1Pressed(_ sender: Any) {
        //websiteText
        guard let url = URL(string: whdWebsiteLink) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func web2Pressed(_ sender: Any) {
        //contactText
        guard let url = URL(string: contactOfficeLink) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func copyDatabase(_ sender: Any) {
//        let fileName1 = "DOL_Timesheet.sqlite"
//        let fileName2 = "DOL_Timesheet.sqlite-shm"
//        let fileName3 = "DOL_Timesheet.sqlite-wal"
        
        CoreDataManager.populateDBData()
        
        let dialogMessage = UIAlertController(title: "Info", message: "After changing the database you will need to restart the app for it to take effect", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            exit(0)
          })
        
        dialogMessage.addAction(confirm)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
}

extension CoreDataManager {
    class func populateDBData() {
        // If SQL file version file and loadData has been run and the DB has been updated, increase the seedVersionValue
        let seedVersionKey = "SeedVersion"
        let seedVersionValue = 1
        let seedVersion = UserDefaults.standard.integer(forKey: seedVersionKey)
        if seedVersion != seedVersionValue {
            copySeedDB()
            UserDefaults.standard.set(seedVersionValue, forKey: seedVersionKey)
        }
    }
    
    static var storeDirectory = NSPersistentContainer.defaultDirectoryURL().relativePath
    
    static var storeName = "DOL_Timesheet"
    
    class func copySeedDB() {
        let storeURL = "\(storeDirectory)/\(storeName).sqlite"
        if FileManager.default.fileExists(atPath: storeURL) {
            let enumerator = FileManager.default.enumerator(atPath: storeDirectory)
            while let file = enumerator?.nextObject() as? String {
                if !file.hasPrefix(storeName) { continue }
                do {
                    try FileManager.default.removeItem(atPath: "\(storeDirectory)/\(file)")
                } catch  {
                    NSLog("Error deleting file %s", file)
                }
            }
        }
        
        guard let sqlitePath = Bundle.main.path(forResource: "DOL_Timesheet", ofType: "sqlite") else { return }
        let sqlitePath_shm = Bundle.main.path(forResource: "DOL_Timesheet", ofType: "sqlite-shm")
        let sqlitePath_wal = Bundle.main.path(forResource: "DOL_Timesheet", ofType: "sqlite-wal")
        
        let URL1 = URL(fileURLWithPath: sqlitePath)
        let URL2 = URL(fileURLWithPath: sqlitePath_shm!)
        let URL3 = URL(fileURLWithPath: sqlitePath_wal!)
        let URL4 = URL(fileURLWithPath: "\(storeDirectory)/\(storeName).sqlite")
        let URL5 = URL(fileURLWithPath: "\(storeDirectory)/\(storeName).sqlite-shm")
        let URL6 = URL(fileURLWithPath: "\(storeDirectory)/\(storeName).sqlite-wal")
        
        // Copy 3 files
        do {
            try FileManager.default.copyItem(at: URL1, to: URL4)
            try FileManager.default.copyItem(at: URL2, to: URL5)
            try FileManager.default.copyItem(at: URL3, to: URL6)
            
        } catch {
            print("Error copying seed files")
        }
    }
}
