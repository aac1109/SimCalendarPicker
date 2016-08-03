//
//  ViewController.swift
//  SimCalendarPicker
//
//  Created by LouisHuang on 2016/8/3.
//  Copyright © 2016年 LouisHuang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ScheduleCalendarPickDelegate {

    @IBOutlet weak var lbStartDate: UILabel!
    @IBOutlet weak var lbEndaDate: UILabel!
    
    var schCalendarPick: ScheduleCalendarPickDialogViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbStartDate.text = ""
        lbEndaDate.text = ""
        
        // Initialize calendar picker
        schCalendarPick = storyboard!.instantiateViewControllerWithIdentifier("ScheduleCalendarPickDialogViewController") as!
        ScheduleCalendarPickDialogViewController
        schCalendarPick.delegate = self
    }
    
    // MARK: Local method
    private func getDateStringFromNSDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Day, .Month, .Year], fromDate: date)
        return String(comp.year) + "." + String(comp.month) + "." + String(comp.day)
    }
    
    // MARK:- Action
    @IBAction func actionDisplayCalendar(sender: UIButton) {
        lbStartDate.text = ""
        lbEndaDate.text = ""
        // Display calendar
        schCalendarPick.displayCalendarPickDialog(self)
    }
    
    // MARK:- ScheduleCalendarPickDialogViewController delegate
    func scheduleCalendarPickOK(startDate: NSDate, endDate: NSDate) {
        lbStartDate.text = getDateStringFromNSDate(startDate)
        lbEndaDate.text = getDateStringFromNSDate(endDate)
    }

}

