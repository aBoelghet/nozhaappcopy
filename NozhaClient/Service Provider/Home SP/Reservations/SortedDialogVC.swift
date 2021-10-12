//
//  SortedDialogVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/16/21.
//

import UIKit

protocol  SortedDialogVCDelegate {
    func dialogDissmised()
}


class SortedDialogVC: UIViewController {
    
    
    static let all = ""
    static let today = "day"
    static let week = "week"
    static let month = "month"
   
    
    @IBOutlet var all: UIView!
    @IBOutlet var today: UIView!
    @IBOutlet weak var week :UIView!
    @IBOutlet weak var month :UIView!
   
    var inputViews :[UIView] = []
    
    
    var delegate :SortedDialogVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputViews = [all,today,week,month]
        
        addGesterToAll()
        all.tag = 1
        today.tag = 2
        week.tag = 3
        month.tag = 4
       
        
        unCheckAll()
        
        switch AppDelegate.shared.sortedBy {
        case "all":
            checkView(view: all)
            
        case "day":
            checkView(view: today)
            
        case "week":
            checkView(view: week)
            
        case "month":
            checkView(view: month)
            
      
        default:
            checkView(view: all)
        }
        
    }
    
    
    func addGesterToAll()
    {
        inputViews.forEach { (v) in
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        }
    }
    
    @objc func handleTapGesture(gesture : UITapGestureRecognizer)
    {
        
        let v = gesture.view!
        
        switch v.tag {
        case 1:
            AppDelegate.shared.sortedBy = SortedDialogVC.all
        case 2:
            AppDelegate.shared.sortedBy = SortedDialogVC.today
        case 3:
            AppDelegate.shared.sortedBy = SortedDialogVC.week
        case 4:
            AppDelegate.shared.sortedBy = SortedDialogVC.month
        
            
        default:
            AppDelegate.shared.sortedBy = SortedDialogVC.all
        }
        
        dismiss(animated: true) {
            self.delegate?.dialogDissmised()
        }
        
        
        unCheckAll()
        checkView(view: v)
        
    }
    
    func checkView(view :UIView){
        for v in view.subviews {
            
            if v is UICheckBox {
                (v as! UICheckBox).isChecked = true
            }else if v is UILabel{
                (v as! UILabel).textColor = Constants.black_main_color
                (v as! UILabel).font = Constants.appFont14Medium
            }
        }
    }
    
    @IBAction func dismissDialogAction(_ sender: Any) {
        self.dismiss()
    }
    
    func unCheckView(view :UIView){
        for v in view.subviews {
            if v is UICheckBox {
                (v as! UICheckBox).isChecked = false
            }else if v is UILabel{
                (v as! UILabel).textColor = UIColor.black
            }
        }
    }
    
    func unCheckAll(){
        for v in inputViews {
            unCheckView(view :v)
        }
    }
    
}
