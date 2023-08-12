//  OnboardPageViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardPageViewController: UIPageViewController {
    
    weak var onboardDelegate: OnboardPageViewControllerDelegate?
    
    public lazy var orderedViewControllers: [OnboardBaseViewController] = {
        // The view controllers will be shown in this order
        return [
            self.newOnboardViewController("OnboardWelcomeViewController"),
            self.newOnboardViewController("OnboardIntroductionViewController"),
            self.newOnboardViewController("OnboardWorkViewController"),
            self.newOnboardViewController("OnboardPayViewController"),
            self.newOnboardViewController("OnboardReviewViewController")
        ]
    }()
    
    public var currentVC: OnboardBaseViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let initialViewController = orderedViewControllers.first {
            currentVC = initialViewController
            scrollToViewController(viewController: initialViewController)
        }
        
        onboardDelegate?.onboardPageViewController(onboardPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        
        // Disable swiping by removing gesture recognizers
            for view in self.view.subviews {
                if let gestureRecognizers = view.gestureRecognizers {
                    for gestureRecognizer in gestureRecognizers {
                        view.removeGestureRecognizer(gestureRecognizer)
                    }
                }
            }
    }
    
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first as? OnboardBaseViewController,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
                currentVC = nextViewController as? OnboardBaseViewController
                scrollToViewController(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the previous view controller.
     */
    func scrollToPreviousViewController() {
        if let visibleViewController: OnboardBaseViewController = viewControllers?.first as? OnboardBaseViewController,
            let nextViewController = pageViewController(self, viewControllerBefore: visibleViewController) {
                currentVC = nextViewController as? OnboardBaseViewController
            scrollToViewController(viewController: nextViewController, direction: .reverse)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first as? OnboardBaseViewController,
            let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
                let nextViewController = orderedViewControllers[newIndex]
                currentVC = nextViewController as OnboardBaseViewController
                scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    func newOnboardViewController(_ vcid: String) -> OnboardBaseViewController {
        return UIStoryboard(name: "Onboarding", bundle: nil) .
            instantiateViewController(withIdentifier: vcid) as! OnboardBaseViewController
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
            direction: direction,
            animated: true,
            completion: { (finished) -> Void in
                // Setting the view controller programmatically does not fire
                // any delegate methods, so we have to manually notify the
                // 'tutorialDelegate' of the new index.
                self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    private func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first as? OnboardBaseViewController,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            onboardDelegate?.onboardPageViewController(onboardPageViewController: self, didUpdatePageIndex: index)
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension OnboardPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController as! OnboardBaseViewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            // User is on the first view controller and swiped left to loop to
            // the last view controller.
            guard previousIndex >= 0 else {
                return orderedViewControllers.last
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController as! OnboardBaseViewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                return orderedViewControllers.first
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
}

extension OnboardPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

protocol OnboardPageViewControllerDelegate: AnyObject {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func onboardPageViewController(onboardPageViewController: OnboardPageViewController,
        didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func onboardPageViewController(onboardPageViewController: OnboardPageViewController,
        didUpdatePageIndex index: Int)
    
}
