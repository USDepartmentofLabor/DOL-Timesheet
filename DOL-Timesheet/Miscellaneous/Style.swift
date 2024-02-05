//
//  Style.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/31/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

struct Style {
    
    static let CORNER_ROUNDING: CGFloat = 8
    
    enum DataType {
        case appTitle
        case barButtonTitle
        case radioButton
        case actionButton
        case subActionButton
        case navigationButton
        case questionTitle
        case subTitle
        case sectionTitle
        case columnHeader
        case nameValueTitle
        case nameValueText
        case profileCellTitle1
        case profileCellTitle2
        case headingTitle
        case timesheetPaymentTypeTitle
        case timesheetSectionTitle
        case timesheetSelectedUser
        case timesheetPeriod
        case timesheetTimeTable
        case timesheetTimeTotal
        case timesheetWorkweekTitle
        case summaryTotalTitle
        case summaryTotalValue
        case earningsTitle
        case earningsValue
        case timesheetEarningsTitle
        case enterTimePaymentType
        case enterTimeTitle
        case enterTimeValue
        case enterCommentsValue
        case infoSection
        case glossaryTitle
        case glossaryText
        case aboutText
        case resourcesTitleText
        case resourcesText
        case resourcesFooterText
        case introductionText
        case introductionBoldText
        case timeCounterText
        case breakTimeCounterText
        case footerText
        case timecardInfoText
        case contactUsLabel
    }

    fileprivate static let styleMap: [DataType: (String, CGFloat, UIFont.TextStyle)] =
        [.appTitle: ("AvenirNext-Medium", 17, .title1),
         .barButtonTitle: ("AvenirNext-Regular", 17, .title1),
        .radioButton: ("AvenirNext-Medium", 15, .body),
        .actionButton: ("AvenirNext-Regular", 16, .headline),
         .subActionButton: ("AvenirNext-Medium", 16, .title2),
         .navigationButton: ("AvenirNext-Medium", 16, .headline),
         .questionTitle: ("AvenirNext-Bold", 17, .headline),
         .subTitle: ("AvenirNext-Regular", 15, .subheadline),
        .sectionTitle: ("AvenirNext-DemiBold", 17, .headline),
        .columnHeader: ("AvenirNext-Medium", 15, .subheadline),
        .nameValueTitle: ("AvenirNext-Medium", 15, .body),
         .nameValueText: ("AvenirNext-Regular", 16, .body),
         .profileCellTitle1: ("AvenirNext-Medium", 15, .body),
         .profileCellTitle2: ("AvenirNext-Regular", 15, .body),
         .headingTitle: ("AvenirNext-Medium", 24, .title2),
         .timesheetPaymentTypeTitle: ("AvenirNext-Medium", 17, .title3),
         .timesheetSectionTitle: ("AvenirNext-Regular", 20, .title3),
         .timesheetSelectedUser: ("AvenirNext-DemiBold", 15, .title3),
         .timesheetPeriod: ("AvenirNext-DemiBold", 15, .title3),
         .timesheetTimeTable: ("AvenirNext-Medium", 15, .caption1),
         .timesheetTimeTotal: ("AvenirNext-Medium", 14, .title3),
         .timesheetWorkweekTitle: ("AvenirNext-Medium", 13, .subheadline),
         .summaryTotalTitle: ("AvenirNext-Medium", 13, .subheadline),
         .summaryTotalValue: ("AvenirNext-Medium", 13, .subheadline),
         .earningsTitle: ("AvenirNext-Medium", 13, .subheadline),
         .earningsValue: ("AvenirNext-Regular", 13, .subheadline),
         .timesheetEarningsTitle: ("AvenirNext-Medium", 15, .title2),
         .enterTimePaymentType: ("AvenirNext-Medium", 24, .title3),
         .enterTimeTitle: ("AvenirNext-Medium", 20, .body),
         .enterTimeValue: ("AvenirNext-Regular", 13, .body),
         .enterCommentsValue: ("AvenirNext-Regular", 14, .body),
         .infoSection: ("AvenirNext-Regular", 17, .subheadline),
         .glossaryTitle: ("AvenirNext-Medium", 16, .headline),
         .glossaryText: ("AvenirNext-Regular", 15, .caption2),
         .aboutText: ("AvenirNext-Regular", 15, .caption2),
         .resourcesTitleText: ("AvenirNext-Medium", 15, .subheadline),
         .resourcesText: ("AvenirNext-Regular", 15, .subheadline),
         .resourcesFooterText: ("AvenirNext-AvenirNext", 15, .headline),
         .introductionText: ("AvenirNext-Regular", 15, .body),
        .introductionBoldText: ("AvenirNext-DemiBold", 15, .body),
        .timeCounterText:  ("AvenirNext-Medium", 50, .largeTitle),
        .breakTimeCounterText: ("AvenirNext-Medium", 30, .largeTitle),
        .footerText: ("AvenirNext-Regular", 13, .body),
        .timecardInfoText: ("AvenirNext-Italic", 14, .body),
        .contactUsLabel: ("AvenirNext-Light", 17, .body)]

    static func scaledFont(forDataType type: DataType) -> UIFont {
        let (fontName, fontSize, textStyle) = styleMap[type]!
        
        guard let font = UIFont(name: fontName, size: fontSize) else {
            return UIFont.preferredFont(forTextStyle: textStyle)
        }
        
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        return fontMetrics.scaledFont(for: font)        
    }
}


