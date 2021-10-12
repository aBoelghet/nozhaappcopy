//
//  HomeVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/13/21.
//

import UIKit
import IBAnimatable
import SkeletonView
import MOLH


class HomeVC: UIViewController {
   
    
    
    @IBOutlet var skeltonViews: [UIView]!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var notifiCountLbl: AnimatableLabel!
    @IBOutlet weak var welcomeUserLbl: UILabel!
    @IBOutlet weak var todayreservationLbl: UILabel!
    @IBOutlet weak var tableView: intrinsicTableView!
    
    var refreshControl :UIRefreshControl = UIRefreshControl()
    var services:[Service]?
    var lastBooking: Reservation?
    var balance:Double?
    var today_reservations:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeUserLbl.text = "\("Welcome".localized) \(NozhaUtility.loadUser()?.name ?? ""), \("Manage youe services directly".localized)."
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        for sk_view in skeltonViews {
            sk_view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
            sk_view.isHidden = false
            
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        scrollView.refreshControl = refreshControl
        
        
        if NozhaUtility.loadUser()?.unreadNotifications ?? 0 > 0 {
            self.notifiCountLbl.isHidden = false
            self.notifiCountLbl.text = "\(NozhaUtility.loadUser()?.unreadNotifications ?? 0)"
        }else {
            self.notifiCountLbl.isHidden = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateNotificationNumber"), object: nil, queue: nil) { (notification) in
            if (notification.userInfo as? [String: Any]) != nil
            {
                
               // let badge = notification.userInfo?["badge"] as? Int
                
                if NozhaUtility.getNotificationNo() == 0 {
                    self.notifiCountLbl.isHidden = true
                }else{
                    self.notifiCountLbl.isHidden = false
                    self.notifiCountLbl.text = "\(NozhaUtility.getNotificationNo())"
                    return
                }
            }
            
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "handelNotification"), object: nil, queue: nil) { (notification) in
            self.startReqestGetHome()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateHomeSupplier"), object: nil, queue: nil) { (notification) in
            self.startReqestGetHome()
        }

        
    }
    
  
    @objc func refreshData(){
        refreshControl.beginRefreshing()
        startReqestGetHome()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        startReqestGetHome()
        welcomeUserLbl.text = "\("Welcome".localized) \(NozhaUtility.loadUser()?.name ?? ""), \("Manage youe services directly".localized)."
       
        
    }
    
    
    @IBAction func routeToCurrency(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "ScanRS", bundle: nil)
        let vc :CurrencyVC = mainStoryboard.instanceVC()
        vc.balance = self.balance
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func browseTodayReservationsAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "CreateService", bundle: nil)
        let vc :S_reservationsListVC = mainStoryboard.instanceVC()
        vc.isToday = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func ServicesListAction(_ sender: Any) {
        routeService ()
    }
    
    @IBAction func allBookingsAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "CreateService", bundle: nil)
        let vc :S_reservationsListVC = mainStoryboard.instanceVC()
        vc.isToday = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func bookingsListAction(_ sender: Any) {
        routeReservations ()
    }
    
    @IBAction func routeNotificationsAction(_ sender: Any) {
    }
    func routeService (){
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ServicesVC = mainStoryboard.instanceVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func routeReservations (){
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ReservationsListVC = mainStoryboard.instanceVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.lastBooking != nil {
            return 2
        }else {
            return 1
        }
       
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: ServiceTVC = tableView.dequeueReusableCell(withIdentifier: "ServiceTVC", for: indexPath) as! ServiceTVC
            if self.services != nil {
                cell.services = self.services! 
            }
            return cell
        }else {
            let cell: BookingTVC = tableView.dequeueReusableCell(withIdentifier: "BookingTVC", for: indexPath) as! BookingTVC
            if (self.lastBooking != nil)  {
                cell.setupReservation(res:self.lastBooking!)
                cell.viewcontroller = self
                
            }
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 375
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if indexPath.row == 1 {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ReservationDetailsVC = mainStoryboard.instanceVC()
            vc.reservationId = self.lastBooking?.id
        self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}


extension HomeVC {
    func startReqestGetHome()
    {
        
        tableView.reloadData()
        API.SP_HOME.startRequest(completion: response)
    }
    func response(api :API,statusResult :StatusResult){
        self.hideIndicator()
        
        refreshControl.endRefreshing()
        
        if statusResult.isSuccess {
          
            if !(statusResult.data is NSNull)
            {
                let value = statusResult.data as! [String:Any]
                
                
                if !(value["services"] is NSNull) {
                    let data_servicess = try! JSONSerialization.data(withJSONObject: value["services"]!, options: [])
                    let servcices = try! JSONDecoder().decode([Service].self, from: data_servicess)
                    self.services = servcices
                    self.tableView.reloadData()
                    
                }
                if !(value["last_reservation"] is NSNull) {
                    let data_lastBooking = try! JSONSerialization.data(withJSONObject: value["last_reservation"]!, options: [])
                    let lastBooking = try! JSONDecoder().decode(Reservation.self, from: data_lastBooking)
                    self.lastBooking = lastBooking
                    self.tableView.reloadData()
                    
                }
                
                if !(value["reservations_today"] is NSNull) {
                    
                    let today_reservations = value["reservations_today"] as? Int
                    self.today_reservations = today_reservations
                    self.todayreservationLbl.text = "\("Today Reservations:".localized)\(today_reservations?.description.Pricing ?? "")"
                }
                if !(value["balance"] is NSNull) {
                    
                    let balance = value["balance"] as? Double
                    self.balance = balance
                    
                }
                
                for view in skeltonViews {
                    view.isHidden = true
                }
                
                self.tableView.reloadData()
                
                
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
        
    }
}
