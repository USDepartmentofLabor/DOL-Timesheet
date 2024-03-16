//
//  TimeViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 9/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol TimeViewDelegate: class {
    func displayInfo()
}

class TimeViewController: UIViewController, TimeCardDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var employeeEmployerTitleLabel: UILabel!
    
    @IBOutlet weak var selectEmployerPopupButton: UIButton!
    @IBOutlet weak var selectEmployerPopupLabel: UILabel!
    
    @IBOutlet weak var timeContainerView: UIView!
    
    weak var currentTimeViewController: UIViewController?
    public var timesheetViewModel = TimesheetViewModel.shared()

    let lighterGrey = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard timesheetViewModel.userProfileExists else {
            //performSegue(withIdentifier: "setupProfile", sender: nil)
            performSegue(withIdentifier: "showOnboard", sender: nil)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
        displayInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func setupView() {
        

        selectEmployerPopupButton.isHidden = false
        selectEmployerPopupLabel.isHidden = false
        
        selectEmployerPopupButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)

        
        selectEmployerPopupButton.layer.borderWidth = 1.0 // Set the width of the border
        selectEmployerPopupButton.layer.borderColor = lighterGrey.cgColor // Set the color of the border
        selectEmployerPopupButton.layer.cornerRadius = 10.0
            
        
    }
    
    func displayInfo() {
        if currentTimeViewController is TimesheetSoftenViewController {
            title = "timesheet".localized
        } else {
            title = "timecard".localized
        }
        
        if timesheetViewModel.userProfileModel.isProfileEmployer {
            //    employeeEmployerTitleLabel.text = "employee".localized
            selectEmployerPopupLabel.text = "employee".localized
        }
        else {
            //    employeeEmployerTitleLabel.text = "employer".localized
            selectEmployerPopupLabel.text = "employer".localized
        }
        setupPopupButton()
        displayEmploymentInfo()
    }
    
    func gotoTimesheet() {
        displayTimeSheet()
    }
    
    func setupPopupButton(){
        let optionClosure = {(action : UIAction) in
            print(action.title)
        }
        
        var menuActions: [UIAction] = []
        
        let userProfileModel = timesheetViewModel.userProfileModel
        
        let users: [User] = userProfileModel.employmentUsers
        guard users.count > 0 else {
            return
        }
                
        let selectedUserName = timesheetViewModel.selectedUserName
        
        for user in users {
            var state: UIAction.State = .off
            if user.name == selectedUserName {
                state = .on
            }
            
            let action = UIAction(title: user.name!, state: state, handler: {_ in
                self.setCurrentUser(user: user)
            })
            menuActions.append(action)
        }
        let newUserAction = UIAction(title: userProfileModel.addNewUserTitle, handler: {_ in
            self.addNewUser()
        })
        
        menuActions.append(newUserAction)
        
        selectEmployerPopupButton.menu = UIMenu(children : menuActions)
        selectEmployerPopupButton.showsMenuAsPrimaryAction = true
        selectEmployerPopupButton.changesSelectionAsPrimaryAction = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showOnboard",
            let navVC = segue.destination as? UINavigationController,
            let introVC = navVC.topViewController as? OnboardPageNavigationViewController {
            introVC.delegate = self
        }
        else if segue.identifier == "setupProfile",
            let navVC = segue.destination as? UINavigationController,
            let introVC = navVC.topViewController as? IntroductionViewController {
            introVC.delegate = self
        }
        else if segue.identifier == "showProfile",
            let navVC = segue.destination as? UINavigationController,
            let profileVC = navVC.topViewController as? SetupProfileViewController {
            profileVC.profileViewModel = ProfileViewModel(context: timesheetViewModel.managedObjectContext.childManagedObjectContext())
            profileVC.delegate = self
        }
        else if segue.identifier == "manageUsers",
            let navVC = segue.destination as? UINavigationController,
            let manageUserVC = navVC.topViewController as? ManageUsersViewController {
            manageUserVC.profileViewModel = ProfileViewModel(context: timesheetViewModel.managedObjectContext.childManagedObjectContext())
            manageUserVC.delegate = self
        }
        else if segue.identifier == "addEmploymentInfo",
            let navVC = segue.destination as? UINavigationController,
            let employmentInfoVC = navVC.topViewController as? EmploymentInfoViewController {
            employmentInfoVC.employmentModel = timesheetViewModel.userProfileModel.newTempEmploymentModel()
            employmentInfoVC.delegate = self
        }
    }
}

//MARK : Actions
extension TimeViewController {
    
    func addNewUser() {
        performSegue(withIdentifier: "addEmploymentInfo", sender: self)
    }
    
    func setCurrentUser(user: User) {
        timesheetViewModel.setCurrentEmploymentModel(for: user)
        displayEmploymentInfo()
        
    }

    func displayEmploymentInfo() {
        let employmentModel =  timesheetViewModel.currentEmploymentModel
        
        if employmentModel == nil {
            let addUserTitle = timesheetViewModel.userProfileModel.addNewUserTitle
        }
        
        displayTime()
      //  paymentTypeLabel.text = employmentModel?.currentPaymentTypeTitle ?? ""
    }
}

extension TimeViewController: TimeViewControllerDelegate {
    func didUpdateUser() {
        if let user = timesheetViewModel.userProfileModel.employmentUsers.first {
            self.setCurrentUser(user: user)
        }
        displayInfo()
    }
    
    func didUpdateEmploymentInfo() {
        displayEmploymentInfo()
    }
    
    func didUpdateLanguageChoice() {
        displayInfo()
        displayEmploymentInfo()
    }
}


extension TimeViewController {
    
    func displayTime() {
        if let delegate = currentTimeViewController as? TimeViewDelegate {
            delegate.displayInfo()
            return
        }
        if timesheetViewModel.userProfileModel.isProfileEmployer {
            displayTimeSheet()
        }
        else {
            displayTimeCard()
        }
    }

    func displayTimeCard() {
        let timecardVC: TimeCardViewController
        
        if let vc = currentTimeViewController as? TimeCardViewController {
            timecardVC = vc
        }
        else {
            timecardVC = TimeCardViewController.instantiateFromStoryboard()
            timecardVC.timesheetViewModel = timesheetViewModel
            timecardVC.timeViewControllerDelegate = self
            addViewController(viewController: timecardVC)
//            timecardVC.commentsTextView.delegate = self
        }
    }

    func displayTimeSheet() {
        
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1 // 1 corresponds to the second tab, index starts from 0
        }
        
//        let timesheetVC: TimesheetSoftenViewController
//        
//        if let vc = currentTimeViewController as? TimesheetSoftenViewController {
//            timesheetVC = vc
//        }
//        else {
//            timesheetVC = TimesheetSoftenViewController.instantiateFromStoryboard()
//            timesheetVC.viewModel = viewModel
//            addViewController(viewController: timesheetVC)
//        }
    }

    func addViewController(viewController: UIViewController) {
        
        if let controller = currentTimeViewController {
            hideContentController(controller: controller)
            currentTimeViewController = nil
        }
        
        currentTimeViewController = viewController
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        timeContainerView.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: timeContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: timeContainerView.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: timeContainerView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: timeContainerView.bottomAnchor)
            ])
        
        viewController.didMove(toParent: self)
        let addedViewSize = viewController.view.frame.size
        let existingScrollViewContentSize = self.scrollView.contentSize
        self.scrollView.contentSize = CGSize(width: existingScrollViewContentSize.width, height: addedViewSize.height+200)
    }
    
    func hideContentController(controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}


extension TimeViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
}

    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 15, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}


extension TimeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let aRect = textView.convert(textView.frame, to: scrollView)
        scrollView.scrollRectToVisible(aRect, animated: true)
    }
}
