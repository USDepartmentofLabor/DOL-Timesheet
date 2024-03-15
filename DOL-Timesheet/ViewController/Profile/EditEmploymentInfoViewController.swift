//
//  EditEmploymentInfoViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/6/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class EditEmploymentInfoViewController: UIViewController {

    var employmentModel: EmploymentModel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var paymentTypeContainerView: UIView!
    @IBOutlet weak var paymentFrequencyTitleLabelInfo: LabelInfoView!
    @IBOutlet weak var selectWorkWeekView: DropDownView!
    @IBOutlet weak var selectPaymentFrequency: DropDownView!
    
    @IBOutlet weak var workWeekTitleLabelInfo: LabelInfoView!
    weak var minimumWageVC: MinimumWageViewController?
    weak var paymentController: UIViewController?
    
    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        displayInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView() {
        title = "edit_employment".localized
        let saveBtn = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(saveClicked(_:)))
        navigationItem.rightBarButtonItem = saveBtn
        
        let workWeekTapGesture = UITapGestureRecognizer(target: self, action: #selector(workWeekClick(_:)))
        workWeekTapGesture.cancelsTouchesInView = false
        selectWorkWeekView.addGestureRecognizer(workWeekTapGesture)

        let paymentFrequencyTapGesture = UITapGestureRecognizer(target: self, action: #selector(paymentFrequencyClick(_:)))
        paymentFrequencyTapGesture.cancelsTouchesInView = false
        selectPaymentFrequency.addGestureRecognizer(paymentFrequencyTapGesture)

        scrollView.keyboardDismissMode = .onDrag
        
        paymentFrequencyTitleLabelInfo.delegate = self
        workWeekTitleLabelInfo.delegate = self
        if employmentModel.isProfileEmployer {
            paymentFrequencyTitleLabelInfo.title = "payment_frequency_employer".localized
            paymentFrequencyTitleLabelInfo.infoType = .employer_paymentFrequency
            workWeekTitleLabelInfo.title = "work_week_employer".localized
            workWeekTitleLabelInfo.infoType = .employer_workweek
        }
        else {
            paymentFrequencyTitleLabelInfo.title = "payment_frequency_employee".localized
            paymentFrequencyTitleLabelInfo.infoType = .employee_paymentFrequency
            workWeekTitleLabelInfo.title = "work_week_employee".localized
            workWeekTitleLabelInfo.infoType = .employee_workweek
        }
        
        setupPaymentType()
        setupAccessibility()
    }

    func setupAccessibility() {
        selectWorkWeekView.accessibilityHint = "work_week_hint".localized
        selectPaymentFrequency.accessibilityHint = "payment_frequency_hint".localized
    }
    
    func displayInfo() {
        selectPaymentFrequency.title = employmentModel.paymentFrequency.title
        selectWorkWeekView.title = employmentModel.workWeekStartDay.title
    }

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? MinimumWageViewController {
            destVC.view.translatesAutoresizingMaskIntoConstraints = false
            destVC.overtimeEligible = employmentModel.overtimeEligible
            destVC.minimumWage = employmentModel.minimumWage
            destVC.isProfileEmployer = employmentModel?.isProfileEmployer ?? false
            minimumWageVC = destVC
        }
        else {
            segue.destination.view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupPaymentType() {
        let controller: UIViewController
        
        switch employmentModel.paymentType {
        case .hourly:
            let hourlyController = HourlyPaymentViewController.instantiateFromStoryboard("Profile")
            hourlyController.employmentModel = employmentModel
            hourlyController.paymentViewDelegate = self
            controller = hourlyController
        case .salary:
            let salaryController = SalaryPaymentViewController.instantiateFromStoryboard("Profile")
            salaryController.employmentModel = employmentModel
            salaryController.paymentViewDelegate = self
            controller = salaryController
        }
        
        addPaymentView(controller: controller)
    }
    
    private func addPaymentView(controller: UIViewController) {
        paymentController = controller
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        paymentTypeContainerView.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: paymentTypeContainerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: paymentTypeContainerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: paymentTypeContainerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: paymentTypeContainerView.bottomAnchor)
            ])

        controller.didMove(toParent: self)
    }
    
    // MARK: Actions
    
    @IBAction func paymentFrequencyClick(_ sender: Any) {
        let vc = OptionsListViewController(options: PaymentFrequency.allCases,
                                                              title: "")
        vc.didSelect = { [weak self] (popVC: UIViewController, paymentFrquency: PaymentFrequency?) in
            guard let strongSelf = self else { return }
            if let paymentFrquency = paymentFrquency {
                strongSelf.selectPaymentFrequency.title = paymentFrquency.title
                strongSelf.employmentModel.paymentFrequency = paymentFrquency
            }
            popVC.dismiss(animated: true, completion: nil)
        }
        showPopup(popupController: vc, sender: selectPaymentFrequency)
    }
    
    @IBAction func workWeekClick(_ sender: Any) {
        let vc = OptionsListViewController(options: Weekday.allCases,
                                                              title: "")
        vc.didSelect = { [weak self] (popVC: UIViewController, weekday: Weekday?) in
            guard let strongSelf = self else { return }
            if let weekday = weekday {
                strongSelf.selectWorkWeekView.title = weekday.title
                strongSelf.employmentModel.workWeekStartDay = weekday
            }
            popVC.dismiss(animated: true, completion: nil)
        }

        showPopup(popupController: vc, sender: selectWorkWeekView)
    }
    
    @objc func saveClicked(_ sender: Any) {
        guard validateInput() else { return }
        
        if let minimumWageVC = minimumWageVC {
            employmentModel.overtimeEligible = minimumWageVC.overtimeEligible
            employmentModel.minimumWage = minimumWageVC.minimumWage
        }
        if let salaryController = paymentController as? SalaryPaymentViewController {
            employmentModel.salary = (salaryController.salaryAmount, salaryController.salaryType)
            
        }
        employmentModel.save()
        delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }
    
    func validateInput() -> Bool {
        var errorStr: String? = nil
        
        if let minimumWageVC = minimumWageVC, let minimumWageErr = minimumWageVC.validateInput() {
            errorStr = minimumWageErr
        }
        else {
            if let paymentController = paymentController as? HourlyPaymentViewController,
                let hourlyErr = paymentController.validateInput() {
                errorStr = hourlyErr
            }
            else if let paymentController = paymentController as? SalaryPaymentViewController,
                let salaryErr = paymentController.validateInput() {
                errorStr = salaryErr
            }
        }
        if let errorStr = errorStr {
            displayError(message: errorStr)
            return false
        }
        
        return true
    }
}

extension EditEmploymentInfoViewController: SetupPaymentViewDelegate {
    func displayFSLARule() {
        let controller = FSLAInfoViewController.instantiateFromStoryboard()
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(controller.view)

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        controller.didMove(toParent: self)
        self.view.accessibilityElements = [controller.view as Any]
        UIAccessibility.post(notification: .layoutChanged, argument: controller.view)
    }
}
