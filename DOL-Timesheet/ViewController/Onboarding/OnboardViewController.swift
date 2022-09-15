//  OnboardViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    var onboardPageViewController: OnboardPageViewController? {
        didSet {
            onboardPageViewController?.onboardDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.addTarget(self, action: Selector(("didChangePageControlValue")), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardPageViewController = segue.destination as? OnboardPageViewController {
            self.onboardPageViewController = onboardPageViewController
        }
    }

    @IBAction func didTapNextButton(_ sender: Any) {
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
    }
    
}
