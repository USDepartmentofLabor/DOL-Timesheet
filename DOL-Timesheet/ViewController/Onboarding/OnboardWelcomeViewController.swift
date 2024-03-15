//
//  OnboardWelcomeViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardWelcomeViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var employeeLabel: UILabel!
    @IBOutlet weak var employeeButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var employerLabel: UILabel!
    @IBOutlet weak var employerButton: UIButton!
    
//    lazy var viewModel
    
    @IBOutlet weak var nextButton: NavigationButton!
//    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
        canMoveForward = true
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.offerSpanish()
        }
    }
    
    override func setupView() {
        title = "introduction".localized
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        titleLabel.text = "welcome_intro".localized
        employeeLabel.text = "onboard_welcome_employee".localized
        employeeButton.setTitle("onboard_welcome_employee_button".localized, for: .normal)
        orLabel.text = "or".localized
        employerLabel.text = "onboard_welcome_employer".localized
        employerButton.setTitle("onboard_welcome_employer_button".localized, for: .normal)
        
      //  titleLabel.scaleFont(forDataType: .introductionBoldText)
        //employeeLabel.scaleFont(forDataType: .italic)
      //  orLabel.scaleFont(forDataType: .introductionBoldText)
        //employerLabel.scaleFont(forDataType: .italic)
        
//        employeeButton.addBorder(cornerRadius: 10.0)
//        employerButton.addBorder(cornerRadius: 10.0)
        employeeSelected(employeeButton)

        setupAccessibility()
    }
    
    override func saveData() -> Bool {
        print("OnboardWelcomeViewController SAVE DATA")
        return true
    }
    
    func setupAccessibility() {
        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    func displayInfo() {
//        label1.text = NSLocalizedString("introduction_text1", comment: "Introduction Text1")
//        label2.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
 //       nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "setupProfile",
//            let setupVC = segue.destination as? SetupProfileViewController {
//            setupVC.delegate = delegate
//        }
//    }
    
    @IBAction func employerSelected(_ sender: Any) {
        onboardingDelegate?.updateCanMoveForward(value:true)
        
        employerButton.tintColor = UIColor(named: "onboardEmployerButtonColor")
        employerButton.setBorderColor(named: "onboardEmployerButtonColor")
        employeeButton.tintColor = .white
        employeeButton.setBorderColor(named: "onboardEmployeeButtonColor")
        
        if let employee = profileViewModel!.profileModel.currentUser as? Employee {
            changeToEmployer(employee: employee)
        }
        
        onboardingDelegate?.updateUserType(newUserType: .employer)
        onboardingDelegate?.resetData()

        canMoveForward = true
    }
    
    @IBAction func employeeSelected(_ sender: Any) {
        onboardingDelegate?.updateCanMoveForward(value: true)
        
        employerButton.tintColor = .white
        employerButton.setBorderColor(named: "onboardEmployerButtonColor")
        employeeButton.tintColor = UIColor(named: "onboardEmployeeButtonColor")
        employeeButton.setBorderColor(named: "onboardEmployeeButtonColor")
        
        if let employer = profileViewModel?.profileModel.currentUser as? Employer {
            changeToEmployee(employer: employer)
        }
        
        onboardingDelegate?.updateUserType(newUserType: .employee)
        onboardingDelegate?.resetData()
        
        canMoveForward = true
    }
    
    fileprivate func changeToEmployee(employer: Employer) {
        toggleUserType()
    }
    
    fileprivate func changeToEmployer(employee: Employee) {
        toggleUserType()
    }
    
    func toggleUserType() {
        if let employer = profileViewModel!.profileModel.currentUser as? Employer {
            profileViewModel!.changeToEmployee(employer: employer)
            userType = .employee
        }
        else if let employee = profileViewModel!.profileModel.currentUser as? Employee {
            profileViewModel!.changeToEmployer(employee: employee)
            userType = .employer
        }
        
        if let empModel = employmentModel {
            empModel.managedObjectContext?.delete(empModel.employmentInfo)
            onboardingDelegate?.updateViewModels(
                profileViewModel: profileViewModel!,
                employmentModel: nil
            )
        }
        manageVC?.profileViewModel = ProfileViewModel(context: profileViewModel!.managedObjectContext.childManagedObjectContext())
    }
    
    func offerSpanish() {
        
        if Localizer.spanishOffered() == false {
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
                    self.onboardingDelegate?.displayTabs()
                 }
             )
             present(alertController, animated: true)
        }
     }
}
