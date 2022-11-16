//
//  IntroductionViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var nextButton: NavigationButton!
    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Localizer.initialize()  
        setupNavigationBarSettings()
        setupView()
        displayInfo()
        offerSpanish()
    }
    
    func setupView() {
        title = "introduction".localized
        label1.scaleFont(forDataType: .introductionBoldText)
        label2.scaleFont(forDataType: .introductionText)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        displayLogo.accessibilityLabel = "whd_logo".localized
    }

    func displayInfo() {
        label1.text = "introduction_text1".localized
        label2.text = "introduction_text2".localized
        nextButton.setTitle("next".localized, for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupProfile",
            let setupVC = segue.destination as? SetupProfileViewController {
            setupVC.delegate = delegate
        }
    }
    
    func offerSpanish() {
        
        if Localizer.spanishOffered() == false {
            let langUpdate = (Localizer.currentLanguage == Localizer.ENGLISH) ? Localizer.SPANISH : Localizer.ENGLISH
            
            let alertController =
                UIAlertController(title: " \n\n \("spanish_support".localized)",
                                  message: nil,
                                  preferredStyle: .alert)
            let imgViewTitle = UIImageView(frame: CGRect(x: 270/2-36.5, y: 10, width: 73, height: 50))
            imgViewTitle.image = UIImage(named:"holaHello")
            alertController.view.addSubview(imgViewTitle)
             
             alertController.addAction(
                 UIAlertAction(title: "No", style: .cancel))
             alertController.addAction(
                UIAlertAction(title: "yes_si".localized, style: .destructive) { _ in
                    Localizer.updateCurrentLanguage(lang: langUpdate)
                    self.setupView()
                    self.displayInfo()
                 }
             )
             present(alertController, animated: true)
        }
     }
}

