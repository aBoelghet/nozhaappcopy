//
//  UserAddressVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/18/21.
//

import UIKit
import MOLH
class UserAddressVC: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    var customer_params = [String:String]()
    var supplier_params =  [String:String]()
    var supplier_Data =  [String:Data]()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Loader.isHidden = true
        self.collectionView.reloadData()
        let index = Constants.cities.firstIndex(where:{ $0.id ==  NozhaUtility.cityId() }) ?? 0
     
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition:.tap_none)
        NozhaUtility.setCityId(cityId: Constants.cities[ IndexPath(item: index, section: 0).item].id ?? 0)
           
     
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.navigationController?.viewControllers.count == 1 {
            self.BackBtn.isHidden = true
        }else {
            self.BackBtn.isHidden = false
        }
    }
    
    
    @IBAction func saveAction(_ sender: Any) {
        if NozhaUtility.cityId() != 0 {
            if self.navigationController?.viewControllers.count == 1 {
                routeToHomeCustomer()
               
            }else {
            self.startRegister()
            }
        }else{
            self.showBunnerAlert(title: "", message: "Please, select city!".localized)
        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
}



extension UserAddressVC :UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Constants.cities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCVC", for: indexPath) as! CityCVC
    
        cell.cityNameLbl.text = Constants.cities[indexPath.item].name ?? ""
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionView.invalidateIntrinsicContentSize()
        let collectionViewSize = collectionView.frame.size.width
        
        return CGSize(width: collectionViewSize/2 , height: 72)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CityCVC
        cell.content.backgroundColor = Constants.light_yellow
        cell.checked.isHidden = false
        cell.cityNameLbl.textColor = Constants.black_main_color
        NozhaUtility.setCityId(cityId: Constants.cities[indexPath.item].id ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CityCVC
        cell.content.backgroundColor = .white
        cell.checked.isHidden = true
        cell.cityNameLbl.textColor = Constants.gray_main_color
    }
    
    
}

extension UserAddressVC {
    
    
    func startRegister(){
        
        var params = [String:String]()
        var paramsData = [String:Data]()
        if customer_params.count > 0 {
            params = customer_params
            params["type"] =  "customer"
        }else {
            params = supplier_params
            params["type"] = "supplier"
            paramsData = supplier_Data
            
        }
        params["city_id"] = NozhaUtility.cityId().description
        print (params)
        Loader.startAnimating()
        Loader.isHidden = false
        API.REGISTER.startRequestWithFile(showIndicator: true,params:params ,data: paramsData)
        { (Api,response) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.Loader.isHidden = true
                self.Loader.stopAnimating()
            }
            if response.isSuccess {
                
                let value = response.data as! [String :Any]
                let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let user = try! JSONDecoder().decode(User.self, from: userData)
                
                NozhaUtility.saveUser(user :user)
                NozhaUtility.setCityId(cityId:user.city?.id ?? 0)
                NozhaUtility.setNotificationNo(notifcation_number:user.unreadNotifications ?? 0)
                UIApplication.shared.applicationIconBadgeNumber = user.unreadNotifications ?? 0
                NozhaUtility.setIsSubscribe(subscribe: true)
               self.subscribeToNotificationsTopic()
                
            
                if user.type == "supplier" {
                self.routeToHomeSP()
                }else {
                    self.routeToHomeCustomer()
                }
                
                
            }else{
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
    }
    
    
    
}


