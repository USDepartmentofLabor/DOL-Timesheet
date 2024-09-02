//
//  UpdateEmploymentTypeViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class UpdateLanguageViewController: UIViewController {
    
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var englishImage: UIImageView!
    @IBOutlet weak var englishView: UIView!
    
    @IBOutlet weak var spanishLabel: UILabel!
    @IBOutlet weak var spanishImage: UIImageView!
    @IBOutlet weak var spanishView: UIView!
    
    @IBOutlet weak var languageWarningLabel: UILabel!
    
    
    weak var manageVC: ManageUsersViewController?
    lazy var profileViewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        self.navigationController?.navigationBar.tintColor = .linkColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        englishView.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
        spanishView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
        
    }
    
    func setupView() {
        setupLabels()
        
        title = "language_preference".localized
        
        englishImage.isHidden = true
        spanishImage.isHidden = false
        
        if (Localizer.currentLanguage == Localizer.ENGLISH) {
            englishImage.isHidden = false
            spanishImage.isHidden = true
        }
    }
    
    func setupLabels() {
        englishLabel.text = "english".localized
        spanishLabel.text = "spanish".localized
        
        languageWarningLabel.text = "language_warning".localized
    }
    
    @IBAction func englishViewPressed(_ sender: Any) {
        if (Localizer.currentLanguage == Localizer.SPANISH) {
            offerSpanish()
        }
    }
    
    
    @IBAction func spanishViewPressed(_ sender: Any) {
        if (Localizer.currentLanguage == Localizer.ENGLISH) {
            offerSpanish()
        }
    }
    
    func offerSpanish() {
        let langUpdate = (Localizer.currentLanguage == Localizer.ENGLISH) ? Localizer.SPANISH : Localizer.ENGLISH
        
        let alertController =
            UIAlertController(title: " \n\n \("spanish_support".localized)",
                              message: nil,
                              preferredStyle: .alert)
        let imgViewTitle = UIImageView(frame: CGRect(x: 270/2-36.5, y: 10, width: 52.8, height: 50))
        imgViewTitle.image = UIImage(named:"holaHello")
        alertController.view.addSubview(imgViewTitle)
         
         alertController.addAction(
             UIAlertAction(title: "No", style: .destructive))
         alertController.addAction(
            UIAlertAction(title: "yes_si".localized, style: .default) { _ in
                Localizer.updateCurrentLanguage(lang: langUpdate)
                self.setupView()
             }
         )
         present(alertController, animated: true)
     }
    
}
