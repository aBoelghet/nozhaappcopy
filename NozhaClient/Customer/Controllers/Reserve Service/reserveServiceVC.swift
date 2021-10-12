//
//  reserveServiceVC.swift
//  NozhaClient
//
//  Created by macbook on 19/02/2021.
//

import UIKit
import IBAnimatable
import MOLH

class reserveServiceVC: UIViewController {
    
    @IBOutlet weak var questionsView: AnimatableView!
    @IBOutlet weak var QATableView: UITableView!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var no_peopleTF: AnimatableTextField!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var datesCollectionView: UICollectionView!
    
    var service:Service?
    var times:[WorkTime]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityLbl.text = self.service?.cityId?.name ?? ""
        priceLbl.text = self.service?.price?.description.Pricing.valueWithCurrency
        if MOLHLanguage.isArabic() {
            datesCollectionView.semanticContentAttribute = .forceRightToLeft
            timeCollectionView.semanticContentAttribute = .forceRightToLeft
            let flowLayout: UICollectionViewFlowLayout = CellCollectionFlow()
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumInteritemSpacing = 12 // for vertical spacing
            flowLayout.minimumLineSpacing = 12 // for horizontal spacing
            flowLayout.scrollDirection = .horizontal
            self.timeCollectionView.collectionViewLayout = flowLayout
        }else {
            datesCollectionView.semanticContentAttribute = .forceLeftToRight
            timeCollectionView.semanticContentAttribute = .forceLeftToRight
        }
        datesCollectionView.reloadData()
        
        if service?.type == "event" ||  service?.questions?.count == 0{
            self.questionsView.isHidden = true
        }else {
            self.questionsView.isHidden = false
        }
        if MOLHLanguage.isRTLLanguage() {
            datesCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .right)
            self.service?.selectedDate = self.service?.workTimes?.first?.workDate ?? ""
        }else{
            datesCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
            self.service?.selectedDate = self.service?.workTimes?.first?.workDate ?? ""
        }
        getServiceHours(date: self.service?.workTimes?.first?.workDate ?? "")
    }
    
    @IBAction func personNoValueChanged(_ sender: Any) {
        updateValue()
    }
    @IBAction func noPersonEdittingEndAction(_ sender: Any) {
        updateValue()
    }
    
    
    func updateValue(){
        let val = no_peopleTF.text ??  ""
        
        if ( Int(val) ?? 0 > self.service?.available_people ?? 0) ||
            ( Int(val) ?? 0 > NozhaUtility.loadSetting()?.reservations_count ?? 0)
        {
            if (Int(val) ?? 0 > self.service?.available_people ?? 0) {
                self.no_peopleTF.text = self.service?.available_people?.description ?? ""
                self.showBunnerAlert(title: "", message: "\("You can't add more than".localized) \( self.service?.available_people?.description ?? "") \("persons".localized)")
                
            }else{
                self.no_peopleTF.text = NozhaUtility.loadSetting()?.reservations_count?.description
                self.showBunnerAlert(title: "", message: "\("You can't add more than".localized) \(NozhaUtility.loadSetting()?.reservations_count?.description ?? "") \("persons".localized)")
            }
        }else if  Int(val) ?? 0 <= 0 {
            self.showBunnerAlert(title: "", message: "You must add at leat one person".localized)
        }else {
            self.service?.noPersons = Int(val) ?? 0
        }
        
        
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    @IBAction func addPersonsAction(_ sender: Any) {
        if (self.service?.noPersons ?? 0 < self.service?.available_people ?? 0) &&
            (self.service?.noPersons ?? 0 < NozhaUtility.loadSetting()?.reservations_count ?? 0) {
            self.service?.noPersons += 1
            self.no_peopleTF.text =  self.service?.noPersons.description
        }else {
            if (self.service?.noPersons ?? 0 == self.service?.available_people ?? 0) {
                self.no_peopleTF.text = self.service?.available_people?.description ?? ""
                self.showBunnerAlert(title: "", message: "\("You can't add more than".localized) \( self.service?.available_people?.description ?? "") \("persons".localized)")
                
            }else{
                self.no_peopleTF.text = NozhaUtility.loadSetting()?.reservations_count?.description
                self.showBunnerAlert(title: "", message: "\("You can't add more than".localized) \(NozhaUtility.loadSetting()?.reservations_count?.description ?? "") \("persons".localized)")
            }
            
        }
    }
    @IBAction func minusPersonAction(_ sender: Any) {
        if self.service?.noPersons ?? 0 > 0 {
            self.service?.noPersons -= 1
            self.no_peopleTF.text =  self.service?.noPersons.description
        }else {
            self.no_peopleTF.text = "1"
            self.showBunnerAlert(title: "", message: "You must add at leat one person".localized)
        }
        
    }
    @IBAction func continueReservationAction(_ sender: Any) {
        
        switch ValidationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            self.service?.noPersons = Int(self.no_peopleTF.text  ?? "") ?? 0
            let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
            let vc :CompleteOrderVC = mainStoryboard.instanceVC()
            vc.service = self.service
            self.navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
    
    
}

extension reserveServiceVC : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == datesCollectionView {
            return self.service?.workTimes?.count ?? 0
        }else {
            return times?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == datesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateResCVC", for: indexPath) as! DateResCVC
            if  self.service?.workTimes != nil {
                cell.workTime = self.service?.workTimes?[indexPath.row]
                
            }
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeResrCVC", for: indexPath) as! TimeResrCVC
            if  self.times != nil {
                if MOLHLanguage.isArabic() {
                    cell.timeLbl.text =    "\(self.times?[indexPath.row].to ?? "")-\(self.times?[indexPath.row].from ?? "")"
                }else{
                    cell.timeLbl.text =    "\(self.times?[indexPath.row].from ?? "")-\(self.times?[indexPath.row].to ?? "")"
                }
                
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == datesCollectionView {
            return CGSize(width: 50 , height: 110)
        }else {
            return CGSize(width: 120 , height: 40)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == datesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateResCVC", for: indexPath) as! DateResCVC
            cell.dateLbl.textColor = .white
            cell.dayLbl.textColor = .white
            cell.monthLbl.textColor = .white
            cell.container.backgroundColor = Constants.black_main_color
            getServiceHours(date:self.service?.workTimes?[indexPath.row].workDate ?? "")
            self.service?.selectedDate = self.service?.workTimes?[indexPath.row].workDate ?? ""
        }
        
        if collectionView == timeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeResrCVC", for: indexPath) as! TimeResrCVC
            cell.container.backgroundColor = Constants.black_main_color
            cell.timeLbl.textColor = .white
            
            self.service?.selectedTime = self.times?[indexPath.item].id ?? 0
            if MOLHLanguage.isArabic() {
                self.service?.selectedWorkTime = "\(self.times?[indexPath.item].to ?? "") - \(self.times?[indexPath.item].from ?? "")"
            }else{
                self.service?.selectedWorkTime = "\(self.times?[indexPath.item].from ?? "") - \(self.times?[indexPath.item].to ?? "")"
            }
           
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == datesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateResCVC", for: indexPath) as! DateResCVC
            cell.dateLbl.tintColor = Constants.black_main_color
            cell.dayLbl.tintColor = Constants.black_main_color
            cell.monthLbl.tintColor = Constants.black_main_color
            cell.container.backgroundColor = .clear
            
        }
        
        if collectionView == timeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeResrCVC", for: indexPath) as! TimeResrCVC
            cell.container.backgroundColor = .clear
            cell.timeLbl.textColor = Constants.black_main_color
            
        }
        
    }
    
    func getServiceHours(date:String){
        var params = [String:String]()
        params["service_id"] = self.service?.id?.description
        params["work_date"] = date
        API.SERVICE_HOURS.startRequest(showIndicator: false, params:params) { (api, response) in
            if response.isSuccess {
                let value = response.data
                let citiesData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let hours = try! JSONDecoder().decode([WorkTime].self, from: citiesData)
                if hours.count == 0 {
                    self.showBunnerAlert(title: "", message: response.message, completion: nil)
                }
                self.times = hours
                self.timeCollectionView.reloadData()
                if MOLHLanguage.isRTLLanguage() {
                    self.timeCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .right)
                    self.service?.selectedTime =  self.times?.first?.id ?? 0
                    if MOLHLanguage.isArabic() {
                        self.service?.selectedWorkTime = "\(self.times?.first?.to ?? "") - \(self.times?.first?.from ?? "")"
                    }else{
                        self.service?.selectedWorkTime = "\(self.times?.first?.from ?? "") - \(self.times?.first?.to ?? "")"
                    }
                }else{
                    self.timeCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
                    self.service?.selectedTime = self.times?.first?.id ?? 0
                    if MOLHLanguage.isArabic() {
                        self.service?.selectedWorkTime = "\(self.times?.first?.to ?? "") - \(self.times?.first?.from ?? "")"
                    }else{
                        self.service?.selectedWorkTime = "\(self.times?.first?.from ?? "") - \(self.times?.first?.to ?? "")"
                    }
                }
               
               
                if MOLHLanguage.isArabic() {
                    self.datesCollectionView.semanticContentAttribute = .forceRightToLeft
                    self.timeCollectionView.semanticContentAttribute = .forceRightToLeft
                    let flowLayout: UICollectionViewFlowLayout = CellCollectionFlow()
                    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    flowLayout.minimumInteritemSpacing = 12 // for vertical spacing
                    flowLayout.minimumLineSpacing = 12 // for horizontal spacing
                    flowLayout.scrollDirection = .horizontal
                    self.timeCollectionView.collectionViewLayout = flowLayout
                }else {
                    self.datesCollectionView.semanticContentAttribute = .forceLeftToRight
                    self.timeCollectionView.semanticContentAttribute = .forceLeftToRight
                }
       
            }
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
            
        }
    }
    func ValidationInput() -> Validation{
        
        if self.no_peopleTF.text?.isEmpty ?? true  {
            
            return .invalid("You must enter persons number".localized)
        }
        
        if self.service?.selectedTime == 0  {
            
            return .invalid("Please select time".localized)
        }
        if  self.service?.questions?.count ?? 0 > 0 {
            for qa in self.service!.questions!{
                if qa.answer.count == 0 {
                return .invalid("You must enter questions answers".localized)
            }
        }
        }
        return .valid
    }
}

extension reserveServiceVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.service?.questions?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: QAServiceTVC = tableView.dequeueReusableCell(withIdentifier: "QAServiceTVC", for: indexPath) as! QAServiceTVC
        if self.service?.questions?.count ?? 0 > 0 {
            cell.question = self.service?.questions?[indexPath.row]
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return   UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
}



class CellCollectionFlow: UICollectionViewFlowLayout {
  override var flipsHorizontallyInOppositeLayoutDirection: Bool {
    return MOLHLanguage.isArabic()
  }
}
