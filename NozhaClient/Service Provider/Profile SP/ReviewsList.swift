//
//  ReviewsList.swift
//  NozhaClient
//
//  Created by mac book air on 1/18/21.
//

import UIKit

class ReviewsList: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var emptyView: UIView!
    var reservations:[Reservation]?
    var serviceId:Int?
    var paginate:Paginate?
    var isLoadMore = false
    var refreshControl :UIRefreshControl = UIRefreshControl()
    
    var rating:Ratings?
    var rates:[Rate]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        tableview.refreshControl = refreshControl
        self.startReqestGetRatings()
    }
    
    @objc func refreshData(){
        isLoadMore = false
        refreshControl.beginRefreshing()
        self.startReqestGetRatings()
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    
}


extension ReviewsList :UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.rates?.count ?? 0 > 0 {
            return  (self.rates?.count ?? 0) + 1
        }else {
            return 5
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 &&  self.rates?.count ?? 0 > 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceReviewTVC") as! ServiceReviewTVC
            
            if self.rating != nil {
                cell.total.text =  NozhaUtility.loadUser()?.countRate?.description.Pricing ?? ""
                cell.rate.text = NozhaUtility.loadUser()?.avgRate?.description.Pricing ?? ""
                cell.setUpRatings(rateings:self.rating!)
            }
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceRateTVC") as! ServiceRateTVC
            if self.rates?.count ?? 0 > 0 {
                cell.setUpRate(rate:(self.rates?[indexPath.row-1])!)
            }
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
}
extension ReviewsList
{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY + 180)  > contentHeight - scrollView.frame.size.height {
            loadMoreDataFromServer()
        }
    }
    func startReqestGetRatings()
    {
        
        API.SP_RATINGS.startRequest(completion: response)
    }
    
    func response(api :API,statusResult :StatusResult){
        self.hideIndicator()
        
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                let value = statusResult.data as! [String:Any]
                
                let data_ratings = try! JSONSerialization.data(withJSONObject: value, options: [])
                let ratings = try! JSONDecoder().decode(Ratings.self, from: data_ratings)
                self.rating = ratings
                self.rates?.removeAll()
                self.rates  = ratings.items
                
                if self.rates?.count ?? 0 > 0 {
                    self.emptyView.isHidden = true
                    self.tableview.reloadData()
                }else {
                    self.emptyView.isHidden = false
                }
                
                let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
                let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
                self.paginate = paging
                
                
                
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
            API.SP_RATINGS.startRequest(params: params,completion: responseLoadMore)
        }
    }
    func responseLoadMore(api :API,response :StatusResult){
        refreshControl.endRefreshing()
        if response.isSuccess {
            
            isLoadMore.toggle()
            let value = response.data as! [String:Any]
            let data_ratings = try! JSONSerialization.data(withJSONObject: value, options: [])
            let ratings = try! JSONDecoder().decode(Ratings.self, from: data_ratings)
            
            if !(ratings.items?.isEmpty ?? true) {
                self.rates! += ratings.items!
            }
            let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
            let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
            self.paginate = paging
            if (paginate?.currentPage ?? 1 == paginate?.lastPage ?? 1){
                isLoadMore = true
            }
            
            
            self.tableview.reloadData()
        }else{
            print(response.message)
        }
    }
}
