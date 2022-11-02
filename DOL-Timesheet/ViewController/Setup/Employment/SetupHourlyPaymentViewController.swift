//
//  SetupHourlyPaymentViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/18/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SetupHourlyPaymentViewController: SetupBaseEmploymentViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var saveButton: NavigationButton!
    weak var hourlyPaymentVC: HourlyPaymentViewController?
    weak var minimumWageVC: MinimumWageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func setupView() {
        super.setupView()
        
        title = "hourly_payment_title".localized
        saveButton.setTitle("save".localized, for: .normal)
        scrollView.keyboardDismissMode = .onDrag
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
        if segue.identifier == "minimumWage", let destVC = segue.destination as? MinimumWageViewController {
            destVC.view.translatesAutoresizingMaskIntoConstraints = false
            destVC.overtimeEligible = viewModel?.overtimeEligible ?? true
            destVC.minimumWage = viewModel?.minimumWage ?? 0
            destVC.paymentType = viewModel?.paymentType
            destVC.isProfileEmployer = viewModel?.isProfileEmployer ?? false
            minimumWageVC = destVC
        }
        else if segue.identifier == "hourlyPayment", let destVC = segue.destination as? HourlyPaymentViewController {
            destVC.viewModel = viewModel
            destVC.view.translatesAutoresizingMaskIntoConstraints = false
            destVC.paymentViewDelegate = self
            hourlyPaymentVC = destVC
        }
    }
    
    @IBAction func saveClick(_ sender: Any) {
        if !validateInput() {
            return
        }
        
        if let minimumWageVC = minimumWageVC {
            viewModel?.overtimeEligible = minimumWageVC.overtimeEligible
            viewModel?.minimumWage = minimumWageVC.minimumWage
        }

        viewModel?.save()
        delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }
    
}

extension SetupHourlyPaymentViewController {
    func validateInput() -> Bool {
        var errorStr: String? = nil
        
        if let minimumWageVC = minimumWageVC,
            let minimumWageErr = minimumWageVC.validateInput() {
            errorStr = minimumWageErr
        }
        else if let hourlyPaymentVC = hourlyPaymentVC,
            let hourlyRateErr = hourlyPaymentVC.validateInput() {
            errorStr = hourlyRateErr
        }
        
        if let errorStr = errorStr {
            displayError(message: errorStr)
            return false
        }
        
        return true
    }
}

extension SetupHourlyPaymentViewController: SetupPaymentViewDelegate {
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
