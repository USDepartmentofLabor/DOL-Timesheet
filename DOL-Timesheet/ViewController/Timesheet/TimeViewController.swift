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

class TimeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var employeeEmployerTitleLabel: UILabel!
    @IBOutlet weak var selectUserDropDownView: DropDownView!

    @IBOutlet weak var timeContainerView: UIView!
    
    weak var currentTimeViewController: UIViewController?
    var viewModel: TimesheetViewModel?
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var timesheetToggleBtn: UIBarButtonItem!
    
    @IBOutlet weak var contactUsBtn: UIBarButtonItem!
    var exportBtn: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        viewModel = TimesheetViewModel()
        setupView()
        displayInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let viewModel = viewModel, viewModel.userProfileExists else {
            performSegue(withIdentifier: "setupProfile", sender: nil)
            return
        }
        offerSpanish()
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
    
    func offerSpanish() {
        print("GGG: Offer Spanish?")
        if Localizer.spanishOffered() == false {
            print("GGG: Offering Spanish!")
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
                    self.setupNavigationBarSettings()
                    self.setupView()
                    self.displayInfo()
                   // self.employeeEmployerTitleLabel.text = "employer".localized
                    self.performSegue(withIdentifier: "showProfile", sender: self)
                 }
             )
             present(alertController, animated: true)
        }
     }


    func setupView() {
        let infoItem = UIBarButtonItem.infoButton(target: self, action: #selector(infoClicked(sender:)))
        navigationItem.rightBarButtonItem = infoItem
        
        let useNameTapGesture = UITapGestureRecognizer(target: self, action: #selector(userBtnClick(_:)))
        useNameTapGesture.cancelsTouchesInView = false
        selectUserDropDownView.addGestureRecognizer(useNameTapGesture)
        
        editBtn.titleLabel?.scaleFont(forDataType: .actionButton)
        userNameLabel.scaleFont(forDataType: .headingTitle)
        paymentTypeLabel.scaleFont(forDataType: .timesheetPaymentTypeTitle)
        employeeEmployerTitleLabel.scaleFont(forDataType: .timesheetSectionTitle)
        selectUserDropDownView.titleLabel.scaleFont(forDataType: .timesheetSelectedUser)
        selectUserDropDownView.titleLabel.textColor = UIColor(named: "darkTextColor")
        
    }
    
    func displayInfo() {
        if currentTimeViewController is TimesheetViewController {
            title = "timesheet".localized
        } else {
            title = "timecard".localized
        }
        
        let profileUser = viewModel?.userProfileModel.profileModel.currentUser
        userNameLabel.text = profileUser?.name
        
        let profileImage = profileUser?.image?.normalizedImage() ?? #imageLiteral(resourceName: "profile")
        
        let profileBtn = UIButton(type: .custom)
        profileBtn.setBackgroundImage(profileImage, for: .normal)
        profileBtn.clipsToBounds = true
        profileBtn.contentMode = .scaleAspectFill
        profileBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        profileBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileBtn.addBorder(borderColor: .white, borderWidth: 0.5, cornerRadius: profileBtn.bounds.size.width / 2)
        
        profileBtn.accessibilityHint = "profile_hint".localized
        profileBtn.addTarget(self, action: #selector(profileClicked(sender:)), for: UIControl.Event.touchDown)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileBtn)
        
        editBtn.setTitle("edit".localized, for: .normal)
        
        if viewModel?.userProfileModel.isProfileEmployer ?? false {
            employeeEmployerTitleLabel.text = "employee".localized
            selectUserDropDownView.accessibilityHint = "employee_user_hint".localized
        }
        else {
            employeeEmployerTitleLabel.text = "employer".localized
            selectUserDropDownView.accessibilityHint = "employer_user_hint".localized
        }
        
        displayEmploymentInfo()
    }
    
    
    @IBAction func timeToggleClicked(_ sender: Any) {
        if currentTimeViewController is TimesheetViewController {
            displayTimeCard()
        }
        else {
            displayTimeSheet()
        }
    }
    
    @IBAction func exportClicked(_ sender: Any) {
        if let vc = currentTimeViewController as? TimesheetViewController {
            vc.export(sender)
        }
    }
    
    @IBAction func contactWHDClick(_ sender: Any) {
        contactWHD()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "setupProfile",
            let navVC = segue.destination as? UINavigationController,
            let introVC = navVC.topViewController as? IntroductionViewController {
            introVC.delegate = self
        }
        else if segue.identifier == "showProfile",
            let navVC = segue.destination as? UINavigationController,
            let profileVC = navVC.topViewController as? SetupProfileViewController,
            let viewModel = viewModel {
            profileVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
            profileVC.delegate = self
        }
        else if segue.identifier == "manageUsers",
            let navVC = segue.destination as? UINavigationController,
            let manageUserVC = navVC.topViewController as? ManageUsersViewController,
            let viewModel = viewModel {
            manageUserVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
            manageUserVC.delegate = self
        }
        else if segue.identifier == "addEmploymentInfo",
            let navVC = segue.destination as? UINavigationController,
            let employmentInfoVC = navVC.topViewController as? EmploymentInfoViewController,
            let viewModel = viewModel {
            employmentInfoVC.viewModel = viewModel.userProfileModel.newTempEmploymentModel()
            employmentInfoVC.delegate = self
        }
//        else if segue.identifier == "enterTime",
//            let navVC = segue.destination as? UINavigationController,
//            let enterTimeVC = navVC.topViewController as? EnterTimeViewController,
//            let currentDate = sender as? Date,
//            let viewModel = viewModel {
//            enterTimeVC.viewModel = viewModel.createEnterTimeViewModel(forDate: currentDate)
//            enterTimeVC.delegate = self
//        }
    }

}

//MARK : Actions
extension TimeViewController {
    
    @objc fileprivate func infoClicked(sender: Any?) {
//        Localizer.clearUserLocale()
//        Localizer.clearSpanishOffered()
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
        
        performSegue(withIdentifier: "showInfo", sender: self)
    }
    
    @objc fileprivate func profileClicked(sender: Any?) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }

    @IBAction func userBtnClick(_ sender: Any) {
        guard let userProfileModel = viewModel?.userProfileModel else { return }
        
        let users: [User]? = userProfileModel.employmentUsers
        guard users?.count ?? 0 > 0 else {
            addNewUser()
            return
        }
        
        let newRowTitle: String = userProfileModel.addNewUserTitle
        let vc = OptionsListViewController(options: users!,
                                           title: "", addRowTitle: newRowTitle)
        vc.didSelect = { [weak self] (popVC: UIViewController, user: User?) in
            popVC.dismiss(animated: true, completion: nil)
            guard let strongSelf = self else { return }
            if let user = user {
                strongSelf.selectUserDropDownView.title = user.title
                strongSelf.setCurrentUser(user: user)
            }
            else {
                strongSelf.addNewUser()
            }
        }
        
        showPopup(popupController: vc, sender: selectUserDropDownView)
    }
    
    func addNewUser() {
        performSegue(withIdentifier: "addEmploymentInfo", sender: self)
    }
    
    func setCurrentUser(user: User) {
        viewModel?.setCurrentEmploymentModel(for: user)
        displayEmploymentInfo()
        
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: selectUserDropDownView)
    }

    func displayEmploymentInfo() {
        let employmentModel =  viewModel?.currentEmploymentModel
        
        if employmentModel == nil {
            let addUserTitle = viewModel?.userProfileModel.addNewUserTitle
            selectUserDropDownView.title = addUserTitle ?? ""
        }
        else {
            selectUserDropDownView.title = viewModel?.selectedUserName ?? ""
        }
        
        displayTime()
        paymentTypeLabel.text = employmentModel?.currentPaymentTypeTitle ?? ""
    }
}

// MARK: Toolbar Actions
extension TimeViewController {
    func contactWHD() {
        let resourcesVC = ResourcesViewController.instantiateFromStoryboard()
        resourcesVC.title = "contact_us".localized
        navigationController?.pushViewController(resourcesVC, animated: true)
    }
}

extension TimeViewController: TimeViewControllerDelegate {
    func didUpdateUser() {
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
        if viewModel?.userProfileModel.isProfileEmployer ?? false {
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
            timecardVC.viewModel = viewModel
            addViewController(viewController: timecardVC)
            timecardVC.commentsTextView.delegate = self
        }
        
        title = "timecard".localized
        timesheetToggleBtn.image = #imageLiteral(resourceName: "timesheet")
        timesheetToggleBtn.title = "timesheet".localized
        
        var items = toolbar.items
        
        if let exportBtn = exportBtn {
            items?.removeAll {$0 == exportBtn}
            toolbar.setItems(items, animated: false)
        }
    }

    func displayTimeSheet() {
        let timesheetVC: TimesheetViewController
        
        if let vc = currentTimeViewController as? TimesheetViewController {
            timesheetVC = vc
        }
        else {
            timesheetVC = TimesheetViewController.instantiateFromStoryboard()
            timesheetVC.viewModel = viewModel
            addViewController(viewController: timesheetVC)
        }
        
        title = "timesheet".localized
        timesheetToggleBtn.image = #imageLiteral(resourceName: "timecard")
        timesheetToggleBtn.title = "timecard".localized

        if exportBtn == nil {
            exportBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportClicked(_:)))
        }
        
        var items = toolbar.items
        items?.insert(exportBtn!, at: 2)
        toolbar.setItems(items, animated: false)
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
