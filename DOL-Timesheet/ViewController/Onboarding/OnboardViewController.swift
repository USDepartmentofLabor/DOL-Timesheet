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

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var onboardPageViewController: OnboardPageViewController? {
        didSet {
            onboardPageViewController?.onboardDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.addTarget(self, action: Selector(("didChangePageControlValue")), for: .valueChanged)
        
        let profileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
        if let vcs = onboardPageViewController?.orderedViewControllers {
            for (index, element) in vcs.enumerated() {
                element.onboardingDelegate = self
                element.vcIndex = index
                element.profileViewModel = profileViewModel
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardPageViewController = segue.destination as? OnboardPageViewController {
            self.onboardPageViewController = onboardPageViewController
        }
    }

    @IBAction func didTapNextButton(_ sender: Any) {
        onboardPageViewController?.currentVC?.saveData()
        onboardPageViewController?.scrollToNextViewController()
    }
    
    @IBAction func didTapPreviousButton(_ sender: Any) {
        onboardPageViewController?.scrollToPreviousViewController()
    }
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
        onboardPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension OnboardViewController: OnboardPageViewControllerDelegate {
    
    func onboardPageViewController(onboardPageViewController: OnboardPageViewController,
        didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func onboardPageViewController(onboardPageViewController: OnboardPageViewController,
        didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        if onboardPageViewController.currentVC?.canMoveForward == true {
            nextButton.isHidden = false
        } else {
            nextButton.isHidden = true
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
