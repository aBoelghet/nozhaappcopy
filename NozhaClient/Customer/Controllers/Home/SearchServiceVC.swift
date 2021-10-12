//
//  SearchServiceVC.swift
//  NozhaClient
//
//  Created by macbook on 18/02/2021.
//

import UIKit
import IBAnimatable

class SearchServiceVC: UIViewController {
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var searchTF: AnimatableTextField!
    @IBOutlet weak var collectionView :UICollectionView!
    
    var searchKeyword:String?
    let refreshControl = UIRefreshControl()
    var services :[Service]?
    var paginate:Paginate?
    var isLoadMore = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(startRefresh), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        
    }
    
    @objc func startRefresh(){
        refreshControl.beginRefreshing()
        
        startReqestSearch()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if searchKeyword?.count ?? 0 > 0 {
            self.searchTF.text = searchKeyword
            startReqestSearch()
        }
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
}


extension SearchServiceVC : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCVC", for: indexPath) as! ServiceCVC
        if services != nil {
            cell.service = services?[indexPath.row]
            cell.favBtn.tag = indexPath.row
            
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionView.invalidateIntrinsicContentSize()
        let padding: CGFloat = 8
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2 , height: 260)
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if services?.count ?? 0 > 0 {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ServiceDetailsVC = mainStoryboard.instanceVC()
        vc.service_obj = services?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}



extension SearchServiceVC {
    
    func showEmpty(){
        self.view.bringSubviewToFront(emptyView)
        emptyView.isHidden = false
        collectionView.isHidden = true
    }
    
    
    func hideEmpty(){
        self.view.bringSubviewToFront(collectionView)
        emptyView.isHidden = true
        collectionView.isHidden = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY + 180)  > contentHeight - scrollView.frame.size.height {
            loadMoreDataFromServer()
        }
    }
    
    func startReqestSearch()
    {
        var params = [String:String]()
        
        params["name"] = self.searchTF.text ?? ""
        params["city_id"] = NozhaUtility.cityId().description
       
        API.C_SERVICES.startRequest(params: params,completion: response)
    }
    
    func response(api :API,statusResult :StatusResult){
        self.hideIndicator()
        refreshControl.endRefreshing()
        
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                let value = statusResult.data as! [String:Any]
                if !(value["items"] is NSNull) {
                    let data_services = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
                    let services = try! JSONDecoder().decode([Service].self, from: data_services)
                    self.services?.removeAll()
                    self.services = services
                    self.collectionView.reloadData()
                    if self.services?.count ?? 0 > 0 {
                        self.hideEmpty()
                    }else {
                        self.showEmpty()
                    }
                    
                    let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
                    let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
                    self.paginate = paging
                    
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
            if !NozhaUtility.isLogin() {
                params["city_id"] = NozhaUtility.cityId().description
            }else {
                params["city_id"] = NozhaUtility.loadUser()?.city?.id?.description
            }
            params["name"] = self.searchTF.text ?? ""
            let page  = ((paginate?.currentPage ?? 1) + 1)
            params["page"] = "\(page)"
            API.C_SERVICES.startRequest(params: params,completion: responseLoadMore)
        }
    }
    func responseLoadMore(api :API,response :StatusResult){
        
        if response.isSuccess {
            isLoadMore.toggle()
            let value = response.data as! [String:Any]
            let data_services = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
            let services = try! JSONDecoder().decode([Service].self, from: data_services)
            
            if !services.isEmpty {
                self.services! += services
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

extension SearchServiceVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        startReqestSearch()
    }
    
}
