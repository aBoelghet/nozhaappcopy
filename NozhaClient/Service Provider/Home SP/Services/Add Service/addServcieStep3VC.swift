//
//  addServcieStep3VC.swift
//  NozhaClient
//
//  Created by mac book air on 1/17/21.
//

import UIKit

class addServcieStep3VC: UIViewController {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var tableView: intrinsicTableView!
    
    var questions:[String] = []
    var en_questions:[String] = []
    var q_count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        q_count = questions.count
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    @IBAction func savaAtion(_ sender: Any) {
        switch Step3ValidatonInput()
        {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
        case .valid:
            
            saveService ()
            
            break
        }
    }
    
    
    @IBAction func addQuestionAction(_ sender: Any) {
        
        q_count = q_count + 1
        questions.append("")
        en_questions.append("")
        tableView.reloadData()
    }
    
}

extension addServcieStep3VC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return questions.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: QuestionTVC = tableView.dequeueReusableCell(withIdentifier: "QuestionTVC", for: indexPath) as! QuestionTVC
        cell.deleteBtn.tag = indexPath.row
        cell.questionTF.tag = indexPath.row
        cell.en_questionTF.tag = indexPath.row
        cell.viewController = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        
    }
    
}


extension addServcieStep3VC {
    func Step3ValidatonInput() -> Validation{
        
        
        for q in questions {
            print(q)
            if !q.isEmpty{
                Global.share.new_Service.questions?.append(q)
            }
        }
        for q in en_questions {
            print(q)
            if !q.isEmpty{
                Global.share.new_Service.en_questions?.append(q)
            }
        }
        
        
        return .valid
    }
    
    func saveService (){
        var params = [String:String]()
        params["name_ar"] =  Global.share.new_Service.name ?? ""
        params["name_en"] =  Global.share.new_Service.en_name ?? ""
        params["type"] = Global.share.new_Service.type ?? ""
        params["price"] = Global.share.new_Service.price?.description ?? ""
        params["city_id"] = Global.share.new_Service.city_id?.description ?? "0"
        params["total_duration"] = Global.share.new_Service.total_duration?.description ?? "0"
        
        
        params["duration_id"] =  Global.share.new_Service.duration_id?.description ?? ""
        params["video_url"] = Global.share.new_Service.video_url ?? ""
        params["organisers"] = Global.share.new_Service.organiser?.description ?? ""
        params["people_number"] = Global.share.new_Service.people_number?.description ?? "0"
        params["category_id"] = Global.share.new_Service.category_id?.description ?? "0"
        params["description_ar"] = Global.share.new_Service.description_str ?? ""
        params["description_en"] = Global.share.new_Service.en_description_str ?? ""
        
        
        params["address"] =  Global.share.new_Service.address?.description ?? ""
        params["lat"] = Global.share.new_Service.lat?.description ?? "0"
        params["lng"] = Global.share.new_Service.lng?.description ?? "0"
        params["has_permission"] = Global.share.new_Service.has_permission?.description ?? "0"
        
        for (index,date_str) in Global.share.new_Service.work_date!.enumerated(){
            params["work_date[\(index)]"] = date_str
        }
        for (index,from_str) in Global.share.new_Service.from!.enumerated(){
            params["from[\(index)]"] = from_str
        }
        for (index,to_str) in Global.share.new_Service.to!.enumerated(){
            params["to[\(index)]"] = to_str
        }
        for (index,q_str) in Global.share.new_Service.questions!.enumerated(){
            params["questions_ar[\(index)]"] = q_str
        }
        for (index,q_str) in Global.share.new_Service.en_questions!.enumerated(){
            params["questions_en[\(index)]"] = q_str
        }
        var paramsData = [String:Data]()
        for (index,image) in Global.share.new_Service.images.enumerated(){
            
            let imgData: NSData = NSData(data: (image).jpegData(compressionQuality: 1)!)
            let imageSize: Int = imgData.length
            print("size of image modified in MB: %f ", Double(imageSize) / 1024.0/1024.0)
            if imageSize <= 2 {
                paramsData["images[\(index)]"] = image.jpegData(compressionQuality: 1)
            }else {
                paramsData["images[\(index)]"] = image.jpegData(compressionQuality: 0.5)
            }
        }
        
        loader.startAnimating()
        loader.isHidden = false
        API.CREATE_SERVICE.startRequestWithFile(showIndicator: true,params:params ,data: paramsData) { (api, statusResult) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
            if statusResult.isSuccess {
                self.showOkAlert(title: "", message: statusResult.message,completion: {
                    self.routeToHomeSP()
                })
                
            }
            else
            {
                self.showBunnerAlert(title: "", message: statusResult.message)
            }
        }
    }
}
