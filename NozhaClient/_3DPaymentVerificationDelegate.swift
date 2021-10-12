//
//  _3DPaymentVerificationDelegate.swift
//  NozhaClient
//
//  Created by macbook on 22/02/2021.
//

import Foundation
import UIKit
import WebKit

struct TapResult: Codable {
    let status: Bool
    let message: String
    let statusCode: Int
    let tapID: String

    enum CodingKeys: String, CodingKey {
        case status, message
        case statusCode = "status_code"
        case tapID = "tap_id"
    }
}


protocol _3DPaymentVerificationDelegate {
    func resultAfterVerification(tapResult :TapResult)
}


class _3DPaymentVerification: UIViewController, WKNavigationDelegate{

    
    @IBOutlet weak var webView :WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    var delegate :_3DPaymentVerificationDelegate?
    var urlValue = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.load(NSURLRequest(url: URL(string: urlValue)!) as URLRequest);
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);

    
        webView.navigationDelegate = self
    }
    
 
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
             self.progressView.progress = Float(self.webView.estimatedProgress);
            if self.webView.estimatedProgress != 1 {
                progressView.isHidden = false
            }else{
                progressView.isHidden = true
            }

            
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    
    
    //this the magic things that well accept 3D payment or not :)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.getElementsByTagName('pre')[0].innerHTML", completionHandler: { (res, error) in
                 if let json = res {
                      // Fingerprint will be a string of JSON. Parse here...
                    
                    do{
                        let jsonString = json as! String

                        let tapReseult = try JSONDecoder().decode(TapResult.self, from: jsonString.data(using: .utf8)!)
                       
                        self.dismiss(animated: true) {
                            self.delegate?.resultAfterVerification(tapResult: tapReseult)
                        }
                        
                    }catch(let error){
                        let tapReseult = TapResult(status: false, message: error.localizedDescription, statusCode: 500, tapID: "")
                        self.dismiss(animated: true) {
                                                   self.delegate?.resultAfterVerification(tapResult: tapReseult)
                                               }
                    }
                    print(json)
                 }
            })
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    @IBAction func goBack(_ sender :UIButton){
        if self.navigationController != nil && (self.navigationController?.viewControllers.count)! > 1 {
            self.pop()
        }else{
            dismiss(animated: true, completion: nil)
        }
        
    }
}





