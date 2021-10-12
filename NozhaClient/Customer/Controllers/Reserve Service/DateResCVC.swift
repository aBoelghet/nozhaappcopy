//
//  DateResCVC.swift
//  NozhaClient
//
//  Created by macbook on 19/02/2021.
//

import UIKit
import IBAnimatable
import MOLH

class DateResCVC: UICollectionViewCell {
    @IBOutlet weak var container: AnimatableView!
    @IBOutlet weak var monthLbl: UILabel!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    var workTime:WorkTime? {
        didSet{
            let dateString = workTime?.workDate ?? ""
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            if MOLHLanguage.isArabic() {
                formatter.locale = Locale(identifier: "ar")
            }else{
                formatter.locale = Locale(identifier: "en_US_POSIX")
                
            }
            formatter.dateFormat = "yyyy-MM-dd"
            print(dateString)
            let date = formatter.date(from:dateString)
            formatter.dateFormat = "E, dd MMM yyyy"
            print(date)
            
            
            formatter.dateFormat = "yyyy"
            let year = formatter.string(from: date ?? Date())
            formatter.dateFormat = "MMMM"
            let month = formatter.string(from: date ?? Date())
            formatter.dateFormat = "dd"
            let day = formatter.string(from: date ?? Date())
            formatter.dateFormat = "EEEE"
            let dayName = formatter.string(from: date ?? Date())
            formatter.dateFormat = "d"
            print(year, month, day,dayName) // 2018 12 24
            dateLbl.text = day
            dayLbl.text = dayName
            monthLbl.text = month
            
        }
    }
    
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
            self.dateLbl.textColor = .white
            self.dayLbl.textColor = .white
            self.monthLbl.textColor = .white
            self.container.backgroundColor = Constants.black_main_color
            }else {
                self.dateLbl.textColor = Constants.black_main_color
                self.dayLbl.textColor = Constants.black_main_color
                self.monthLbl.textColor = Constants.black_main_color
                self.container.backgroundColor = .white
                
            }
            
        }
        
    }
    
}
