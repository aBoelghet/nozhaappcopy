//
//  ScheduleServiceVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/17/21.
//

import UIKit
import FSCalendar
import IBAnimatable
import MOLH


class ScheduleServiceVC: UIViewController {
    
    @IBOutlet weak var content: AnimatableView!
    @IBOutlet weak var toTF: AnimatableTextField!
    @IBOutlet weak var fromTF: AnimatableTextField!
    @IBOutlet weak var calender: FSCalendar!
    @IBOutlet weak var timesCollectionView: UICollectionView!
    
    var service_dates:[String] = []
    let FromPicker = UIDatePicker()
    let ToPicker = UIDatePicker()
    
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }()
    fileprivate let formatterAPI: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var currentPage: Date?
    private lazy var today: Date = {
        return Date()
    }()
    
    
    var datesWithEvent:[String] = []
    
    var selectedIndex : Int = -1
    var dateStr : String = ""
    var dateStrAPI : String = ""
    var timeFrom : Date = Date()
    var timeTo : Date = Date()
    var  timeFromStr : String = ""
    var  timeToStr : String = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ToPicker.semanticContentAttribute = .forceLeftToRight
        FromPicker.semanticContentAttribute = .forceLeftToRight
        self.service_dates =  Global.share.new_Service.service_dates ?? []
        self.view.addBlurredBackground(style: UIBlurEffect.Style.light)
        calender.appearance.headerTitleFont      = Constants.appFont14Medium
        calender.appearance.titleFont = Constants.appFont14Medium
        calender.appearance.weekdayFont = Constants.appFont14Medium
        calender.appearance.weekdayTextColor = Constants.black_main_color
        calender.appearance.headerTitleColor     = Constants.black_main_color
        calender.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calender.appearance.headerMinimumDissolvedAlpha = 0.0 // Hide Left Right Month Name
        currentPage = Date()
        // datesWithEvent = self.getDates(forLastNDays: 7)
        
        calender.scope = .week
        self.calender.select(Date())
        self.calender.appearance.todayColor = Constants.black_main_color
        dateStr = self.formatter.string(from: Date())
        dateStrAPI = self.formatterAPI.string(from: Date())
        let currentPageDate = currentPage
        
        let month = Calendar.current.component(.month, from: currentPageDate!)
        let year = Calendar.current.component(.year, from: currentPageDate!)
        
        print( String(month) + "/" + String(year))
        
        //        fromTF = self.getDate(date: fromPicker.date)
        //        toTF = self.getDate(date: toPicker.date)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        ToPicker.semanticContentAttribute = .forceLeftToRight
        FromPicker.semanticContentAttribute = .forceLeftToRight
        
        for currentView in ToPicker.subviews {
            currentView.semanticContentAttribute = .forceLeftToRight
        }
        for currentView in FromPicker.subviews {
            currentView.semanticContentAttribute = .forceLeftToRight
        }
        
    }
    
    
    
    
    
    
    
    
    
    @IBAction func saveAction(_ sender: Any) {
        
        if Global.share.new_Service.work_date?.count ?? 0 > 0 {
            Global.share.new_Service.service_dates = self.service_dates
            self.dismiss()
        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.dismiss()
    }
    
}


extension ScheduleServiceVC :UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return service_dates.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCVC", for: indexPath) as! timeCVC
        if service_dates.count > 0 {
            cell.timeLbl.text = service_dates[indexPath.item]
            cell.deleteBtn.tag = indexPath.item
            cell.viewController = self
            
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionView.invalidateIntrinsicContentSize()
        
        
        let padding: CGFloat = 20
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize , height: 50)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.toTF.text = ""
        self.fromTF.text = ""
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    
    
    
}


extension ScheduleServiceVC : FSCalendarDataSource, FSCalendarDelegate , FSCalendarDelegateAppearance
{
    private func moveCurrentPage(moveUp: Bool) {
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1
        
        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calender.setCurrentPage(self.currentPage!, animated: true)
        
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        let today = Date()
        return today
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.formatter.string(from: date))")
        dateStr = self.formatter.string(from: date)
        dateStrAPI = self.formatterAPI.string(from: date)
        
        self.configureVisibleCells()
        self.toTF.text = ""
        self.fromTF.text = ""
    }
    
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did deselect date \(self.formatter.string(from: date))")
        self.configureVisibleCells()
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: monthPosition)
        if cell.dateIsToday {
            cell.titleLabel.textColor = Constants.black_main_color
        }
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        if datesWithEvent.contains(self.formatter.string(from: date))
        
        {
            return UIColor.gray
        }
        else{
            return nil
        }
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        
        let currentPageDate = calendar.currentPage
        
        let month = Calendar.current.component(.month, from: currentPageDate)
        let year = Calendar.current.component(.year, from: currentPageDate)
        
        //  monthLbl.text = String(month) + "/" + String(year)
        
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: position)
    }
    
    private func configureVisibleCells() {
        calender.visibleCells().forEach { (cell) in
            let date = calender.date(for: cell)
            let position = calender.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
        let diyCell = (cell as! DIYCalendarCell)
        if datesWithEvent.contains(self.formatter.string(from: date))
        {
            cell.isUserInteractionEnabled = false
        }
        
        else
        {
            cell.isUserInteractionEnabled = true
        }
        cell.backgroundColor = .white
        
        if position == .current {
            
            var selectionType = SelectionType.none
            
            if calender.selectedDates.contains(date) {
                
                if calender.selectedDates.contains(date) {
                    
                    selectionType = .single
                    
                }
            }
            else {
                selectionType = .none
            }
            if selectionType == .none {
                diyCell.selectionLayer.isHidden = true
                return
            }
            diyCell.selectionType = selectionType
            diyCell.selectionLayer.isHidden = false
            
            
        } else {
            diyCell.selectionLayer.isHidden = true
        }
    }
    
    
}


extension ScheduleServiceVC : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fromTF {
            fromTF.resignFirstResponder()
            toTF.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == fromTF {
            fromTF.resignFirstResponder()
            toTF.becomeFirstResponder()
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(self.updatedToTimeField))
            toolbar.setItems([donebtn], animated: true)
            toTF.inputAccessoryView = toolbar
            ToPicker.date = Date()
            ToPicker.datePickerMode = .time
            
            if #available(iOS 13.4, *) {
                ToPicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
            }
            
            toTF.inputView = ToPicker
            toTF.text = formatDateForDisplay(date: ToPicker.date)
            
        }
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == fromTF {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(updateFromTimeField))
            toolbar.setItems([donebtn], animated: true)
            textField.inputAccessoryView = toolbar
            FromPicker.date = Date()
            FromPicker.datePickerMode = .time
            
            
            if #available(iOS 13.4, *) {
                FromPicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
            }
            
            textField.inputView = FromPicker
            textField.text = formatDateForDisplay(date: FromPicker.date)
            
        }
        if textField == toTF {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(updatedToTimeField))
            toolbar.setItems([donebtn], animated: true)
            textField.inputAccessoryView = toolbar
            ToPicker.date = Date()
            ToPicker.datePickerMode = .time
            
            if #available(iOS 13.4, *) {
                ToPicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
            }
            
            textField.inputView = ToPicker
            textField.text = formatDateForDisplay(date: ToPicker.date)
            
        }
        
    }
    
    
    @objc func updateFromTimeField() {
        timeFrom =  FromPicker.date
        timeFromStr = self.getDate(date: FromPicker.date)
        print("timeTo\(FromPicker.date)")
        print("timeFromStr\(timeFromStr)")
        fromTF?.text = formatDateForDisplay(date: FromPicker.date)
        fromTF.endEditing(true)
        
    }
    
    func getDate(date: Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        let time = dateFormatter.string(from: date)
        print(time)
        return time
        
    }
    
    @objc  func  updatedToTimeField (){
        timeTo =  ToPicker.date
        timeToStr = self.getDate(date: ToPicker.date)
        print("timeTo\(ToPicker.date)")
        print("timeToStr\(timeToStr)")
        toTF?.text = formatDateForDisplay(date: ToPicker.date)
        toTF.endEditing(true)
        
        //let ended = FromPicker.date.addingTimeInterval(3600)
        
        service_dates.append("\(dateStr),\(timeFromStr)-\(timeToStr)")
        
        print(dateStrAPI)
        Global.share.new_Service.work_date?.append("\(dateStrAPI)")
        Global.share.new_Service.from?.append("\(timeFromStr)")
        Global.share.new_Service.to?.append("\(timeToStr)")
        self.timesCollectionView.reloadData()
        self.toTF.text = ""
        self.fromTF.text = ""
        
        
    }
    
    
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

