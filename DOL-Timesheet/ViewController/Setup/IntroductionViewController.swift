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
        setupNavigationBarSettings()
        setupView()
        displayInfo()
        offerSpanish()
    }
    
    func setupView() {
        title = NSLocalizedString("introduction", comment: "Introduction")
        label1.scaleFont(forDataType: .introductionBoldText)
        label2.scaleFont(forDataType: .introductionText)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    func displayInfo() {
        label1.text = NSLocalizedString("introduction_text1", comment: "Introduction Text1")
        label2.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupProfile",
            let setupVC = segue.destination as? SetupProfileViewController {
            setupVC.delegate = delegate
        }
    }
    
    func offerSpanish() {
         
         guard let langStr = Locale.current.languageCode else { return }
         if !langStr.contains("es") {
             let alertController =
                 UIAlertController(title: " ",
                                   message: "This app now has spanish support, click Yes below to update your settings for Spanish.",
                                   preferredStyle: .alert)
             //alertController.view.center.x
             let imgViewTitle = UIImageView(frame: CGRect(x: 270/2-15, y: 0, width: 30, height: 30))
             imgViewTitle.image = UIImage(named:"holaHello")
             
//             imgViewTitle.setTranslatesAutoresizingMaskIntoConstraints(false)
             alertController.view.addSubview(imgViewTitle)
             
             alertController.addAction(
                 UIAlertAction(title: "No", style: .cancel))
             alertController.addAction(
                 UIAlertAction(title: "Yes", style: .destructive) { _ in
                     if let url = URL(string: UIApplication.openSettingsURLString) {
                         UIApplication.shared.open(url, completionHandler: .none)
                     }
                 }
             )
             present(alertController, animated: true)
             let defaults = UserDefaults.standard
             defaults.set(true, forKey: "Seen")
         }
     }
}

