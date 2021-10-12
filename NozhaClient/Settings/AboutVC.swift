//
//  AboutVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/18/21.
//

import UIKit
import SafariServices
class AboutVC: UIViewController
               ,SFSafariViewControllerDelegate {
    
    
    @IBOutlet weak var tikTikBtn: UIButton!
    @IBOutlet weak var whatsappBtn: UIButton!
    @IBOutlet var instagramBtn: UIButton!
    @IBOutlet var twitterBtn: UIButton!
    @IBOutlet var aboutLbl: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNoLbl: UILabel!
    
    
    var settings:Settings?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.showAnimatedGradientSkeleton()
        self.settings = NozhaUtility.loadSetting()
        phoneNoLbl.text = "\("Contact us: ".localized)\(NozhaUtility.loadSetting()?.mobile ?? "")"
        emailLbl.text = "\("Messaging us by: ".localized)\(NozhaUtility.loadSetting()?.email ?? "")"
        startRequestAbout()
        
    }
    
    
    func startRequestAbout(){
        API.ABOUT.startRequest() { (api, response) in
            if response.isSuccess {
                let value = response.data as! [String:Any]
                
                let data_content = try! JSONSerialization.data(withJSONObject: value, options: [])
                let content = try! JSONDecoder().decode(Content.self, from: data_content)
                
                self.aboutLbl.text = content.content?.htmlAttributedString?.string ?? ""
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    
                    self.scrollView.hideSkeleton()
                }
                
            }
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
        }
        
    }
    
    
    
    @IBAction func goToIbtikaratAction(_ sender: Any) {
        let websiteURL = "https://ibtikarat.sa/"
       
        if let link = URL(string: websiteURL) {
            if  UIApplication.shared.canOpenURL(link) {
            let vc = SFSafariViewController(url: link)
            vc.delegate = self
            present(vc, animated: true)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    @IBAction func instagramAction(_ sender: Any) {
        let appURL = URL(string: "https://instagram.com/\(self.settings?.instagram ?? "")")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            let webURL = URL(string: "https://instagram.com/\(self.settings?.instagram ?? "")")!
            application.open(webURL)
            
        }
    }
    
    @IBAction func twitterAction(_ sender: Any) {
        
        guard let url = URL(string:self.settings?.twitter ?? "" )  else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else {
            
            guard let webpageURL = URL(string: "https://twitter.com/\(self.settings?.twitter ?? "")") else {
                return
            }
            UIApplication.shared.open(webpageURL, options: [:], completionHandler: nil)
        }
    }
    @IBAction func tikTokAction(_ sender: Any) {
        guard let url = URL(string: "https://www.tiktok.com/@\(self.settings?.tiktok ?? "")")  else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else {
            
            guard let webpageURL = URL(string: "https://www.tiktok.com/@\(self.settings?.tiktok ?? "")") else {
                return
            }
            UIApplication.shared.open(webpageURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func whatsappAction(_ sender: Any) {
        var whatsAppNumber = self.settings?.whatsApp ?? ""
        if whatsAppNumber.contains("+") {
            whatsAppNumber.removeFirst()
        }
      
        guard let whatsAppUrl = URL(string: "whatsapp://send?phone=\(whatsAppNumber)&text="),
              case let application = UIApplication.shared, application.canOpenURL(whatsAppUrl)
        else {
            self.showOkAlert(title: "", message: "Whatsapp  number invalid".localized)
            return
        }
        
        UIApplication.shared.open(whatsAppUrl, options: [:], completionHandler: nil)
    }
    
    
}

