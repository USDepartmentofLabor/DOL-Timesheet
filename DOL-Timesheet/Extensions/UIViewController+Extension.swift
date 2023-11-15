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
        let popoverViewController: UIViewController
        
        if info == .regularRate {
            popoverViewController = RegularRateInfoViewController.instantiateFromStoryboard()
        }
        else {
            let infoViewController = InfoPopupViewController.instantiateFromStoryboard()
            infoViewController.infoValue = info
            infoViewController.delegate = self
            infoViewController.completionHandler = {
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: sender)
            }
            
            popoverViewController = infoViewController
        }

        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = (sender as! UIView)
        popoverViewController.popoverPresentationController?.sourceRect = (sender as! UIView).bounds
        present(popoverViewController, animated: true, completion: nil)
    }
    
    func displayRegularRateInfo() {
        let controller = RegularRateInfoViewController.instantiateFromStoryboard()
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


//MARK: UIPopoverPresentationController Delegate
extension UIViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if let sourceView = popoverPresentationController.sourceView {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: sourceView)
        }
    }
    
}

// MARK: Error Handling
extension UIViewController {
    func displayError(message: String, title: String? = "err_title".localized) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default))
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


extension UIViewController {
    func setupNavigationBarSettings() {
        let appearance = UINavigationBarAppearance()
        
//        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "blackTextColor") ?? UIColor.black]
        appearance.backgroundColor = UIColor.systemGray6
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: Style.scaledFont(forDataType: .appTitle)]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font : Style.scaledFont(forDataType: .barButtonTitle),
            NSAttributedString.Key.foregroundColor: UIColor.black],
                                                            for: .normal)
        
        let systemGray6 = UIColor.systemGray6
        let hexColor = systemGray6.toHex()

        print("Hex Color: \(hexColor)")
    }
}

extension UIColor {
    func toHex() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redInt = Int(red * 255.0)
        let greenInt = Int(green * 255.0)
        let blueInt = Int(blue * 255.0)

        return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
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
