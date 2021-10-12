//
//  ServicesVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/15/21.
//

import UIKit
import IBAnimatable

class ServicesVC: UIViewController ,editServiceDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addServiceLbl: UILabel!
    @IBOutlet weak var addServiceBtn: AnimatableButton!
    @IBOutlet weak var emptyView: UIView!
    
    
    var services:[Service]?
    var catId:Int?
    var services_tag: Int?
    var category: Category?
    var refreshControl :UIRefreshControl = UIRefreshControl()
    var paginate:Paginate?
    var isLoadMore = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.category != nil {
            self.catId = self.category?.id ?? 0
        }
        self.collectionView.invalidateIntrinsicContentSize()
        if NozhaUtility.isCustomer()  || !NozhaUtility.isLogin(){
            addServiceLbl.text = ""
            addServiceBtn.isHidden = true
            if category != nil {
                titleLbl.text =  category?.name ?? ""
            }else {
                if  services_tag == 1 {
                    titleLbl.text =  "Near of you activities".localized
                }else{
                    titleLbl.text =  "Most ordered activities".localized
                }
            }
        }
        startReqestGetServices()
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateServiceFavouraite"), object: nil, queue: nil) { (notification) in
            if (notification.userInfo as? [String: Any]) != nil
            {
                
                let isFav = notification.userInfo?["is_favorite"] as? Bool
                let service_id = notification.userInfo?["service_id"] as? Int
                
                self.services?.forEach { (service) in
                    if service.id == service_id{
                        service.favorited = isFav ?? false
                        self.collectionView.reloadData()
                        return
                    }
                }
                
            }
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        
    }
    
    @objc func refreshData(){
        isLoadMore = false
        refreshControl.beginRefreshing()
        startReqestGetServices()
        
    }
    
    func dialogDissmised(service: Service) {
        startReqestGetServices()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    @IBAction func addServiceAction(_ sender: Any) {
        let vc = UIStoryboard(name: "CreateService", bundle: nil).instantiateViewController(withIdentifier: "addServiceVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ServicesVC :UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.services?.count ?? 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCVC", for: indexPath) as! ServiceCVC
        if services?.count ?? 0 > 0{
            cell.service =  self.services![indexPath.row]
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionView.invalidateIntrinsicContentSize()
        
        let padding: CGFloat = 5
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2 , height: 260)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.services?.count ?? 0 > 0 {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ServiceDetailsVC = mainStoryboard.instanceVC()
        if self.services?.count ?? 0 > 0{
            vc.service_obj =  self.services?[indexPath.item]
        }
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    
    
}

extension ServicesVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = collectionView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY + 180)  > contentHeight - scrollView.frame.size.height {
            loadMoreDataFromServer()
        }
    }
    
    func startReqestGetServices()
    {
        if NozhaUtility.isCustomer() || !NozhaUtility.isLogin(){
            var params = [String:String]()
            if catId != nil {
                params["category_id"] = self.catId?.description
            }else {
                if services_tag == 2 {
                    params["most_ordered"] = "1"
                }
                if !NozhaUtility.isLogin() {
                    params["city_id"] = NozhaUtility.cityId().description
                }else {
                    params["city_id"] = NozhaUtility.loadUser()?.city?.id?.description
                }
            }
            API.C_SERVICES.startRequest(params:params, completion: response)
        }else {
            API.SP_SERVICES.startRequest(completion: response)
        }
    }
    
    func response(api :API,statusResult :StatusResult){
        self.hideIndicator()
        refreshControl.endRefreshing()
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                let value = statusResult.data as! [String:Any]
                
                if !(value["items"] is NSNull) {
                    let data_servicess = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
                    let servcices = try! JSONDecoder().decode([Service].self, from: data_servicess)
                    
                    let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
                    let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
                    
                    self.paginate = paging
                    if servcices.count > 0 {
                        self.services?.removeAll()
                        self.services = servcices
                        self.emptyView.isHidden  = true
                    }else {
                        self.emptyView.isHidden  = false
                    }
                    self.collectionView.reloadData()
                }
                
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
        
    }
    
    func loadMoreDataFromServer(){
        if !isLoadMore {
            isLoadMore.toggle()
            var params = [String:Any]()
            let page  = ((paginate?.currentPage ?? 1) + 1)
            params["page"] = "\(page)"
          
            if NozhaUtility.isCustomer() || !NozhaUtility.isLogin(){
                if category != nil {
                    params["category_id"] = self.category?.id?.description
                }else {
                    if services_tag == 2 {
                        params["most_ordered"] = "1"
                    }
                }
                API.C_SERVICES.startRequest(params:params, completion: responseLoadMore)
            }else {
                API.SP_SERVICES.startRequest(params:params,completion: responseLoadMore)
            }
        }
    }
    func responseLoadMore(api :API,response :StatusResult){
        
        if response.isSuccess {
            isLoadMore.toggle()
            let value = response.data as! [String:Any]
            let data_servicess = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
            let servcices = try! JSONDecoder().decode([Service].self, from: data_servicess)
            
            if !servcices.isEmpty {
                self.services! += servcices
            }
            let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
            let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
            self.paginate = paging
            if (paginate?.currentPage ?? 1 == paginate?.lastPage ?? 1){
                isLoadMore = true
            }
            
            
            self.collectionView.reloadData()
        }else{
            print(response.message)
        }
    }
}



