//
//  FSLAInfoViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 12/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class FSLAInfoViewController: UIViewController {

    static let fslaURL = "https://webapps.dol.gov/elaws/whd/flsa/overtime/"
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel1: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    @IBOutlet weak var infoTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let guide = view.safeAreaLayoutGuide
        let viewHeight = guide.layoutFrame.size.height
        
        if contentView.frame.height < viewHeight {
            viewTopConstraint.constant = (view.frame.height - contentView.frame.height)/2
        }
        else {
            viewTopConstraint.constant = 10
        }
    }

    func setupView() {
        titleLabel.scaleFont(forDataType: .sectionTitle)
        
        infoLabel1.scaleFont(forDataType: .aboutText)
        infoLabel2.scaleFont(forDataType: .aboutText)
        
        infoTextView.textContainerInset = UIEdgeInsets.zero
        
        let fslaInfoStr = NSMutableAttributedString(string: NSLocalizedString("fsla_info", comment: "fsla_info"))
        let linkedText = NSLocalizedString("fsla_linked_text", comment: "fsla_linked_text")
        _ = fslaInfoStr.setAsLink(textToFind: linkedText, linkURL: FSLAInfoViewController.fslaURL)
        
        fslaInfoStr.addAttribute(.font, value: Style.scaledFont(forDataType: .aboutText), range: NSRange(location: 0, length: fslaInfoStr.length))
        infoTextView.attributedText = fslaInfoStr
    }
    
    @IBAction func okClicked(_ sender: Any) {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
