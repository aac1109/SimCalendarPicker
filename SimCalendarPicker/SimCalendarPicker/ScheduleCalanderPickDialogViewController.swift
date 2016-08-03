//
//  ScheduleCalendarPickDialogViewController.swift
//  HomeSecurity
//
//  Created by LouisHuang on 2016/5/23.
//  Copyright © 2016年 Gemtek. All rights reserved.
//

import UIKit

protocol ScheduleCalendarPickDelegate {
    func scheduleCalendarPickOK(startDate: NSDate, endDate: NSDate)
}

class ScheduleCalendarPickDialogViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK:- Property
    @IBOutlet weak var viGreenBarStart: UIView!
    @IBOutlet weak var viGreenBarEnd: UIView!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var lbMonthYearTitle: UILabel!
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var delegate: ScheduleCalendarPickDelegate!
    var currentTab = TabType.Start
    var displayComp = NSDateComponents()
    var displayMonthFirstWeekDay: Int = 0
    var displayMonthTotalDays: Int = 0
    var displayMonthDayArray = [DayInfo]()
    var myCurrentDate: MyDate = MyDate(year: 2000, month: 1, day: 1)
    var myDisplayDate: MyDate = MyDate(year: 2000, month: 1, day: nil)
    var mySelectStartDate: MyDate?
    var mySelectEndDate: MyDate?
    
    let arrayWeek = [Week.Sun, Week.Mon, Week.Tue, Week.Wed, Week.Thu, Week.Fri, Week.Sat]
    let kNumOfDaysInAWeek: Int = 7
    let kMaxRowNum: Int = 7
    
    enum TabType {
        case Start
        case End
    }
    
    enum MonthType {
        case Previous
        case Next
    }
    
    enum Week {
        case Sun
        case Mon
        case Tue
        case Wed
        case Thu
        case Fri
        case Sat
    }
    
    struct MyDate {
        var year: Int
        var month: Int
        var day: Int?
    }
    
    struct DayInfo {
        var day: Int
        var isChosen: Bool
    }
    
    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initEnv()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentDateInfo()
        setThisMonthAndYearTitle()
        currentTab = .Start
        showFocusTab(TabType.Start)
        calendarCollectionView.reloadData()
    }
    
    // MARK:- Local method
    private func clearDisplayMonthChosenState() {
        for i in 0...displayMonthTotalDays-1 {
            displayMonthDayArray[i].isChosen = false
        }
    }
    
    private func dayBeforeToday(displayDate: MyDate, day: Int) -> Bool {
        // Compare two date in integer format, Ex. 2016.5.26 -> 20160526
        let displayDateInt: Int32 = Int32(displayDate.year)*10000 + Int32(displayDate.month)*100 + Int32(day)
        let currentDateInt: Int32 = Int32(myCurrentDate.year)*10000 + Int32(myCurrentDate.month)*100 + Int32(myCurrentDate.day!)
        
        if displayDateInt < currentDateInt {
            return true
        } else {
            return false
        }
    }
    
    private func firstDayOfMonth (date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let dateComponent = calendar.components([.Year, .Month, .Day ], fromDate: date)
        dateComponent.day = 1
        return calendar.dateFromComponents(dateComponent)!
    }
    
    private func getMonthComponent(type: MonthType) -> NSDateComponents {
        switch type {
        case .Previous:
            myDisplayDate.month -= 1
            if myDisplayDate.month <= 0 {
                myDisplayDate.month = 12
                myDisplayDate.year -= 1
            }
        case .Next:
            myDisplayDate.month += 1
            if myDisplayDate.month >= 13 {
                myDisplayDate.month = 1
                myDisplayDate.year += 1
            }
        }
        let dateComponent = NSDateComponents()
        dateComponent.year = myDisplayDate.year
        dateComponent.month = myDisplayDate.month
        dateComponent.day = 1
        return dateComponent
    }
    
    private func getTotalDaysInThisMonth(comp: NSDateComponents) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let date = calendar.dateFromComponents(comp)!
        let range = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        return range.length
    }
    
    private func getWeekday(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let dateComponent = calendar.components(.Weekday, fromDate: date)
        return dateComponent.weekday
    }
    
    private func getCurrentDateInfo() {
        let currentCalendar = NSCalendar.currentCalendar()
        let comp = currentCalendar.components([.Year, .Month, .Day], fromDate: NSDate())
        
        myDisplayDate = MyDate(year: comp.year, month: comp.month, day: nil)
        myCurrentDate = MyDate(year: comp.year, month: comp.month, day: comp.day)
        
        // Set day to 1 to get the correct data
        comp.day = 1
        displayComp = comp
        getDisplayMonthInfo(comp)
    }
    
    private func getFirstWeekDayInThisMonth(comp: NSDateComponents) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let date = NSDate(timeInterval: 0, sinceDate: calendar.dateFromComponents(comp)!)
        let weekdayInt = getWeekday(date)
        let firstWeekDay = weekdayInt - calendar.firstWeekday
        return firstWeekDay
    }
    
    private func getDisplayMonthInfo(comp: NSDateComponents) {
        displayMonthDayArray.removeAll()
        displayMonthFirstWeekDay = getFirstWeekDayInThisMonth(comp)
        displayMonthTotalDays = getTotalDaysInThisMonth(comp)
        for i in 1...displayMonthTotalDays {
            displayMonthDayArray.append(DayInfo(day: i, isChosen: false))
        }
    }
    
    private func hideDialog() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    private func initEnv() {
        viGreenBarStart.hidden = false
        viGreenBarEnd.hidden = true
    }
    
    private func monthMapping(month: Int) -> String {
        var monthString = ""
        
        switch month {
        case 1:
            monthString = "JAN"
        case 2:
            monthString = "FEB"
        case 3:
            monthString = "MAR"
        case 4:
            monthString = "APR"
        case 5:
            monthString = "MAY"
        case 6:
            monthString = "JUN"
        case 7:
            monthString = "JUL"
        case 8:
            monthString = "AUG"
        case 9:
            monthString = "SEP"
        case 10:
            monthString = "OCT"
        case 11:
            monthString = "NOV"
        case 12:
            monthString = "DEC"
        default:
            break
        }
        return monthString
    }
    
    private func setThisMonthAndYearTitle() {
        lbMonthYearTitle.text = monthMapping(myDisplayDate.month) + " " + String(myDisplayDate.year)
    }
    
    private func showFocusTab(type: TabType) {
        switch type {
        case .Start:
            viGreenBarStart.hidden = false
            viGreenBarEnd.hidden = true
            btnStartDate.backgroundColor = UIColor(red: 64.0/255.0, green: 108.0/255.0, blue: 139.0/255.0, alpha: 1.0)
            btnEndDate.backgroundColor = UIColor.clearColor()
        case .End:
            viGreenBarStart.hidden = true
            viGreenBarEnd.hidden = false
            btnStartDate.backgroundColor = UIColor.clearColor()
            btnEndDate.backgroundColor = UIColor(red: 64.0/255.0, green: 108.0/255.0, blue: 139.0/255.0, alpha: 1.0)
        }
    }
    
    private func updateChosenDay(day: Int, tab: TabType) {
        clearDisplayMonthChosenState()
        
        displayMonthDayArray[day-1].isChosen = true
        
        if tab == .Start {
            mySelectStartDate = MyDate(year: displayComp.year, month: displayComp.month, day: day)
        } else if tab == .End {
            mySelectEndDate = MyDate(year: displayComp.year, month: displayComp.month, day: day)
        }
    }
    
    private func violateEndTabRule(chosenDate: MyDate, startDate: MyDate) -> Bool {
        let chosenEndDateInt: Int32 = Int32(chosenDate.year)*10000 + Int32(chosenDate.month)*100 + Int32(chosenDate.day!)
        let chosenStartDateInt: Int32 = Int32(startDate.year)*10000 + Int32(startDate.month)*100 + Int32(startDate.day!)
        
        if chosenEndDateInt < chosenStartDateInt {
            return true
        } else {
            return false
        }
    }
    
    private func weekMapping(week: Week) -> String{
        var weekString = ""
        
        switch week {
        case .Sun:
            weekString = "Sun"
        case .Mon:
            weekString = "Mon"
        case .Tue:
            weekString = "Tue"
        case .Wed:
            weekString = "Wed"
        case .Thu:
            weekString = "Thu"
        case .Fri:
            weekString = "Fri"
        case .Sat:
            weekString = "Sat"
        }
        return weekString
    }
    
    // MARK:- Instance method
    func displayCalendarPickDialog(parentViewController: UIViewController) {
        parentViewController.addChildViewController(self)
        parentViewController.view.addSubview(self.view)
        self.didMoveToParentViewController(parentViewController)
    }
    
    // MARK:- Action
    @IBAction func actionCancel(sender: UIButton) {
        mySelectStartDate = nil
        mySelectEndDate = nil
        hideDialog()
    }

    @IBAction func actionOK(sender: UIButton) {
        print("selectStartDate = \(mySelectStartDate), selectEndDate = \(mySelectEndDate)")
        if currentTab == .Start {
            if mySelectStartDate != nil {
                currentTab = .End
                showFocusTab(.End)
                clearDisplayMonthChosenState()
                calendarCollectionView.reloadData()
            } else {
                showAlert("Please select start date.", sec: 1)
            }
        } else if currentTab == .End{
            if mySelectEndDate != nil {
                hideDialog()
                let startDate = NSCalendar.currentCalendar().dateWithEra(1, year: mySelectStartDate!.year, month: mySelectStartDate!.month, day: mySelectStartDate!.day!, hour: 0, minute: 0, second: 0, nanosecond: 0)
                let endDate = NSCalendar.currentCalendar().dateWithEra(1, year: mySelectEndDate!.year, month: mySelectEndDate!.month, day: mySelectEndDate!.day!, hour: 0, minute: 0, second: 0, nanosecond: 0)
                self.delegate?.scheduleCalendarPickOK(startDate!, endDate: endDate!)
                mySelectStartDate = nil
                mySelectEndDate = nil
            } else {
                showAlert("Please select end date.", sec: 1)
            }
        }
    }
    
    private func showAlert(msg: String, sec: Int64) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * sec), dispatch_get_main_queue(), {
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    @IBAction func actionStartDate(sender: UIButton) {
//        currentTab = .Start
//        showFocusTab(TabType.Start)
    }

    @IBAction func actionEndDate(sender: UIButton) {
//        currentTab = .End
//        showFocusTab(TabType.End)
    }
    @IBAction func actionPreviousMonth(sender: UIButton) {
        displayComp = getMonthComponent(.Previous)
        getDisplayMonthInfo(displayComp)
        calendarCollectionView.reloadData()
        setThisMonthAndYearTitle()
    }
    @IBAction func actionNextMonth(sender: UIButton) {
        displayComp = getMonthComponent(.Next)
        getDisplayMonthInfo(displayComp)
        calendarCollectionView.reloadData()
        setThisMonthAndYearTitle()
    }
    
    // MARK:- UICollectionView delegate and datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return kNumOfDaysInAWeek
        } else {
            return kNumOfDaysInAWeek*(kMaxRowNum-1)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ScheduleCalendarPickDialogCollectionViewCell
        
        if indexPath.section == 0 {
            cell.lbDate.text = weekMapping(arrayWeek[indexPath.item])
            cell.viSeparator.hidden = false
            cell.viCellBackground.hidden = true
            cell.userInteractionEnabled = false
            cell.lbDate.textColor = UIColor.whiteColor()
        } else {
            if indexPath.item < displayMonthFirstWeekDay {
                cell.lbDate.text = ""
                cell.viSeparator.hidden = true
                cell.viCellBackground.hidden = true
                cell.userInteractionEnabled = false
            } else if indexPath.item > displayMonthFirstWeekDay + displayMonthTotalDays - 1 {
                cell.lbDate.text = ""
                cell.viSeparator.hidden = true
                cell.viCellBackground.hidden = true
                cell.userInteractionEnabled = false
            } else {
                let day: Int = indexPath.item - displayMonthFirstWeekDay + 1
                cell.lbDate.text = String(day)
                cell.viSeparator.hidden = false
                if dayBeforeToday(myDisplayDate, day: day) {
                    cell.userInteractionEnabled = false
                    cell.lbDate.textColor = UIColor.lightTextColor()
                } else {
                    cell.userInteractionEnabled = true
                    cell.lbDate.textColor = UIColor.whiteColor()
                }
                if displayMonthDayArray[indexPath.item-displayMonthFirstWeekDay].isChosen {
                    cell.viCellBackground.hidden = false
                    cell.viCellBackground.layer.cornerRadius = 5
                } else {
                    cell.viCellBackground.hidden = true
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionViewWidth = (calendarCollectionView.frame.size.width-1) / CGFloat(kNumOfDaysInAWeek)
        let collectionViewHeight = (calendarCollectionView.frame.size.height-1) / CGFloat(kMaxRowNum)
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let chosenDay = indexPath.item - displayMonthFirstWeekDay + 1
        if currentTab == .Start {
            updateChosenDay(chosenDay, tab: .Start)
        } else if currentTab == .End {
            let chosenDate = MyDate(year: myDisplayDate.year, month: myDisplayDate.month, day: chosenDay)
            if violateEndTabRule(chosenDate, startDate: mySelectStartDate!) {
                showAlert("Can not earlier than start date", sec: 1)
            } else {
                updateChosenDay(chosenDay, tab: .End)
            }
        }
        collectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
}
