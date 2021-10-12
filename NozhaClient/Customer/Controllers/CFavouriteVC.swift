//
//  CFavouriteVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/19/21.
//

import UIKit
import IBAnimatable

class CFavouriteVC: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var closeSearchBtn: UIButton!
    @IBOutlet weak var searchTf: AnimatableTextField!
    @IBOutlet weak var collectionView :UICollectionView!
    @IBOutlet weak var emptyView :UIView!
    @IBOutlet weak var textForEmptyLbl :UILabel!
   
    
    let refreshControl = UIRefreshControl()
    var favoraites :[Service]?
    var paginate:Paginate?
    var isLoadMore = false
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        closeSearchBtn.isHidden = true
        searchTf.text = ""
        searchTf.isHidden = true
        titleLbl.isHidden = false
        emptyView.isHidden = true
       
        
        refreshControl.addTarget(self, action: #selector(startRefresh), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateServiceFavouraite"), object: nil, queue: nil) { (notification) in
            if (notification.userInfo as? [String: Any]) != nil
            {
                self.startReqestFavorate()
                
            }
        }
        
    }
    
    @objc func startRefresh(){
        refreshControl.beginRefreshing()
        startReqestFavorate()
    }
    
    @IBAction func closeSearchAction(_ sender: Any) {
        
        closeSearchBtn.isHidden = true
        searchTf.text = ""
        searchTf.isHidden = true
        titleLbl.isHidden = false
        startReqestFavorate()
    }
    @IBAction func searchAction(_ sender: Any) {
        if NozhaUtility.isLogin() {
        closeSearchBtn.isHidden = false
        searchTf.text = ""
        searchTf.isHidden = false
        titleLbl.isHidden = true
        }else {
            self.signIn()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if !NozhaUtility.isLogin() {
            showEmpty()
            
            textForEmptyLbl.text = "you must be logged in to view services in favorites".localized
          
        }else{
            startReqestFavorate()
          
            
        }
        
    }
    func updateView(){
        if self.favoraites?.isEmpty ?? true {
            self.showEmpty()
        }else{
            self.hideEmpty()
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.signIn()
    }
    
    func showEmpty(){
        self.view.bringSubviewToFront(emptyView)
        emptyView.isHidden = false
        collectionView.isHidden = true
        textForEmptyLbl.text = "No services in favorites".localized
        
    }
    
    
    func hideEmpty(){
        self.view.bringSubviewToFront(collectionView)
        emptyView.isHidden = true
        collectionView.isHidden = false
    }
    
}


extension CFavouriteVC : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoraites?.count ?? 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCVC", for: indexPath) as! ServiceCVC
        if favoraites != nil {
            cell.service = favoraites?[indexPath.row]
            cell.favBtn.tag = indexPath.row
            
            
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionView.invalidateIntrinsicContentSize()
        let padding: CGFloat = 0
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2 , height: 270)
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.favoraites?.count ?? 0 > 0 {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ServiceDetailsVC = mainStoryboard.instanceVC()
        vc.service_obj = favoraites?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

extension CFavouriteVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY + 180)  > contentHeight - scrollView.frame.size.height {
            loadMoreDataFromServer()
        }
    }
    
    func startReqestFavorate()
    {
        if NozhaUtility.isCustomer() || NozhaUtility.isLogin(){
            var params = [String:String]()
            params["name"] = searchTf.text
            API.MY_FAVORITES.startRequest(params:params, completion: response)
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
                        self.favoraites?.removeAll()
                        self.favoraites = servcices
                        self.hideEmpty()
                        
                    }else {
                        self.showEmpty()
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
            params["name"] = searchTf.text
            API.MY_FAVORITES.startRequest(params:params,completion: responseLoadMore)
        }
    }
    func responseLoadMore(api :API,response :StatusResult){
        
        if response.isSuccess {
            isLoadMore.toggle()
            let value = response.data as! [String:Any]
            let data_servicess = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
            let servcices = try! JSONDecoder().decode([Service].self, from: data_servicess)
            
            if !servcices.isEmpty {
                self.favoraites! += servcices
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

extension CFavouriteVC: UITextFieldDelegate {
    
   
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print( string.cString(using: String.Encoding.utf8)!)
        print( string)
        if string == "\n" {
            
            self.view.endEditing(true)
            if textField.text?.count ?? 0 > 0 {
                startReqestFavorate()
            }
        }
        
        return true
    }
    
}






