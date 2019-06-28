//
//  UIViewController+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/16/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

// MARK: Storyboard Insantiate
extension UIViewController {
    class func instantiateFromStoryboard(_ name: String = "Main") -> Self {
        return instantiateFromStoryboardHelper(name)
    }
    
    fileprivate class func instantiateFromStoryboardHelper<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: self)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return controller
    }
    
}

extension UIViewController: InfoViewDelegate {
    func displayInfoPopup(_ sender: Any, info: Info) {
        let popoverViewController = InfoPopupViewController.instantiateFromStoryboard()

        popoverViewController.infoValue = info
        popoverViewController.delegate = self
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = (sender as! UIView)
        popoverViewController.popoverPresentationController?.sourceRect = (sender as! UIView).bounds
        present(popoverViewController, animated: true, completion: nil)
        
//        self.addChild(popoverViewController)
//        popoverViewController.view.frame = self.view.frame
////        popoverViewController.view.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(popoverViewController.view)
//        popoverViewController.didMove(toParent: self)
    }
}


//MARK: UIPopoverPresentationController Delegate
extension UIViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

// MARK: Error Handling
extension UIViewController {
    func displayError(message: String, title: String? = NSLocalizedString("err_title", comment: "Error")) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        present(alertController, animated: false)
    }
}

extension UIViewController {
    func showPopup(popupController: UIViewController, sender: UIView) {
        popupController.modalPresentationStyle = UIModalPresentationStyle.popover
        popupController.popoverPresentationController!.delegate = self
        popupController.popoverPresentationController?.sourceRect = sender.bounds
        popupController.popoverPresentationController?.sourceView = sender
        present(popupController, animated: true, completion: nil)
    }
}



extension UIViewController: InfoPopupDelegate {
    func handle(url: URL, popupController: InfoPopupViewController?) {
        popupController?.dismiss(animated: false, completion: {
            self.displayRespources(url: url)
        })
    }
    
    func displayRespources(url: URL) {
        if url.absoluteString == "http://www.dol.gov/whd/contact_us.htm" {
            let resourcesVC = ResourcesViewController.instantiateFromStoryboard()
            navigationController?.pushViewController(resourcesVC, animated: true)
        }
        else {
            UIApplication.shared.open(url)
        }
    }
}
