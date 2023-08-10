//  OnboardViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//
//  This controls the forward / back / progress indicators
//
//  Interfaces with the pager to control movement
//
//  It has to know if we can move forward from the current STATE
//
//  When we can move forward let the lower VCs know to SAVE
//      The lower VCs tell this one you can move forward
//

import UIKit

class OnboardViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var progress1: UIImageView!
    @IBOutlet weak var progress2: UIImageView!
    @IBOutlet weak var progress3: UIImageView!
    @IBOutlet weak var progress4: UIImageView!
    @IBOutlet weak var progress5: UIImageView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var payLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var progressImages: [UIImageView] = []
    
    var currentPage = 0
    var maxPageVisited = 0
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    weak var delegate: TimeViewControllerDelegate?
    
    var onboardPageViewController: OnboardPageViewController? {
        didSet {
            onboardPageViewController?.onboardDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
        let user = profileViewModel.profileModel.newProfile(type: .employee, name: "")
 
        if let vcs = onboardPageViewController?.orderedViewControllers {
            for (index, element) in vcs.enumerated() {
                element.onboardingDelegate = self
                element.vcIndex = index
                element.profileViewModel = profileViewModel
                element.timeSheetDelegate = delegate
            }
        }
        progressImages = [progress1, progress2, progress3, progress4, progress5]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayInfo()
    }
    
    func displayInfo() {
        welcomeLabel.text = "welcome".localized
        introLabel.text = "intro".localized
        workLabel.text = "work".localized
        payLabel.text = "pay".localized
        summaryLabel.text =  "summary".localized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardPageViewController = segue.destination as? OnboardPageViewController {
            self.onboardPageViewController = onboardPageViewController
        }
    }

    @IBAction func didTapNextButton(_ sender: Any) {
        
        displayInfo()
        
        nextButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.nextButton.isUserInteractionEnabled = true
        }
        
        guard let onboardVC = onboardPageViewController,
              let onboardVCcurrentVC = onboardPageViewController?.currentVC else { return }
        
        if onboardVCcurrentVC.saveData() {
            onboardVC.scrollToNextViewController()
        }
        
    }
    
    @IBAction func didTapPreviousButton(_ sender: Any) {
        previousButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.previousButton.isUserInteractionEnabled = true
        }
        
     //   guard let onboardVCcurrentVC = onboardPageViewController?.currentVC else { return }
      //  if onboardVCcurrentVC.saveData() {
            onboardPageViewController?.scrollToPreviousViewController()
      //  }
        
        
    }
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
//        onboardPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension OnboardViewController: OnboardPageViewControllerDelegate {
    
    func onboardPageViewController(onboardPageViewController: OnboardPageViewController,
        didUpdatePageCount count: Int) {
    }
    
    func onboardPageViewController(onboardPageViewController: OnboardPageViewController,
        didUpdatePageIndex index: Int) {
        currentPage = index
        
        if index > maxPageVisited {
            maxPageVisited = index - 1
        }
        updateDots()
        
        if onboardPageViewController.currentVC?.canMoveForward == true && index != 4 {
            nextButton.isHidden = false
        } else {
            nextButton.isHidden = true
        }
        if index == 0 {
            previousButton.isHidden = true
        } else {
            previousButton.isHidden = false
        }
        
    }
    
    func updateDots() {
        for (index, element) in progressImages.enumerated() {
            element.tintColor = UIColor.gray
            if index == currentPage {
                element.image = UIImage(systemName: "circle.fill")
                element.tintColor = UIColor(named: "appBackgroundColor")
            } else if index <= maxPageVisited {
                element.image = UIImage(systemName: "checkmark.circle")
            } else {
                element.image = UIImage(systemName: "circle")
            }
        }
    }
    
}

extension OnboardViewController: OnboardingProtocol {
    func updateViewModels(profileViewModel: ProfileViewModel,
                          employmentModel: EmploymentModel) {
        if let vcs = onboardPageViewController?.orderedViewControllers {
            for (_, element) in vcs.enumerated() {
                element.employmentModel = employmentModel
                element.profileViewModel = profileViewModel
            }
        }
    }
    
    func updateCanMoveForward(value: Bool) {
        nextButton.isHidden = !value
    }
    
    func updateUserType(newUserType: UserType) {
        if let vcs = onboardPageViewController?.orderedViewControllers {
            for (_, element) in vcs.enumerated() {
                element.userType = newUserType
            }
        }
    }
}
