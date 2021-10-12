//
//  ServiceDescreptionTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/15/21.
//

import UIKit
import WebKit
import GoogleMaps
import CoreLocation
import SafariServices

class ServiceDescreptionTVC: UITableViewCell, WKNavigationDelegate, UIScrollViewDelegate, SFSafariViewControllerDelegate
{
    
    @IBOutlet weak var hasVideo: UIStackView!
    @IBOutlet var descriptionWebView: WKWebView!
    @IBOutlet var webViewHieghtConstraint: NSLayoutConstraint!
    @IBOutlet var mapView: GMSMapView!
    
    
    var geocoder = CLGeocoder()
    let annotiation = GMSMarker()
    var manager = CLLocationManager()
    
    
    var serviceLocation:CLLocation? {
        didSet{
            self.setCurrentPostion(location: serviceLocation!)
        }
    }
    
    var videoUrl:String? {
        didSet {
            if self.videoUrl?.count ?? 0 > 0 {
                self.hasVideo.visibility = .visible
            }else {
                self.hasVideo.visibility = .invisible
            }
        }
    }
    
    
    
    var descriptionService :String = "" {
        didSet{
            
            let dir = AppDelegate.shared.language == "ar" ? "rtl" : "ltr"
            let htmlContent =  """
            <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
            <link rel=\"stylesheet\" type=\"text/css\" href=\"iPhone.css\">
            </header><body dir = '\(dir)'>\(descriptionService)</body>
            """
            
            descriptionWebView.loadHTMLString(htmlContent, baseURL: URL(fileURLWithPath:  Bundle.main.path(forResource: "iPhone", ofType: "css")!))
            
            descriptionWebView.isHidden = false
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionWebView.isOpaque = false
        descriptionWebView.navigationDelegate = self
        descriptionWebView.frame.size = descriptionWebView.scrollView.contentSize
        initLocation()
        mapView.delegate = self
    }
    func initLocation(){
      
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    @IBAction func openUrlAction(_ sender: Any) {
        
        let websiteURL = self.videoUrl ?? ""
       
        if let link = URL(string: websiteURL) {
            if  UIApplication.shared.canOpenURL(link) {
            let vc = SFSafariViewController(url: link)
            vc.delegate = self
                self.parentContainerViewController()?.present(vc, animated: true)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.descriptionWebView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.descriptionWebView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self.webViewHieghtConstraint.constant = (height as! CGFloat)+10
                })
            }
            
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        
        defer {
            decisionHandler(action ?? .allow)
        }
        
        guard let url = navigationAction.request.url else { return }
        
        if navigationAction.navigationType == .linkActivated {
            action = .cancel  // Stop in WebView
            UIApplication.shared.open(url)
        }
        
    }
    
}

extension ServiceDescreptionTVC: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let location = locations.last else {
            return
        }
        setCurrentPostion(location: location)
        
    }
    
    func setCurrentPostion(location :CLLocation){
        let cordicator = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition(latitude: cordicator.latitude, longitude: cordicator.longitude, zoom: 17)))
        
        
    }
    
    
}

// MARK: - GMSMapViewDelegate
extension ServiceDescreptionTVC: GMSMapViewDelegate
{
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        
        annotiation.title = "current_location".localized
        annotiation.icon = UIImage(named: "ic_pin")
        
        annotiation.map = mapView
        
        
        UIView.animate(withDuration: 1, animations: {
            self.annotiation.position = CLLocationCoordinate2D(latitude: self.serviceLocation?.coordinate.latitude ?? 0, longitude: self.serviceLocation?.coordinate.longitude ?? 0)
        }, completion:  { success in
            if success {
                // handle a successfully ended animation
            } else {
                // handle a canceled animation, i.e move to destination immediately
                self.annotiation.position = mapView.camera.target
            }
        })
        
    }
   
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let stringURL = "comgooglemaps://"
        // Checking Nil
        if !(self.serviceLocation?.coordinate.latitude == nil) || !(self.serviceLocation?.coordinate.longitude == nil) {
            if UIApplication.shared.canOpenURL(URL(string: stringURL)!) {
                // If have Google Map App Installed
                if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(self.serviceLocation?.coordinate.latitude ?? 0.0),\(self.serviceLocation?.coordinate.longitude ?? 0.0)&directionsmode=driving") {
                    print (url)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                // If have no Google Map App (Run Browser Instead)
                if let destinationURL = URL(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\( self.serviceLocation?.coordinate.latitude ?? 0.0),\(self.serviceLocation?.coordinate.longitude ?? 0.0)&directionsmode=driving") {
                    UIApplication.shared.open(destinationURL, options: [:], completionHandler: nil)
                }
            }
        } else {
            self.parentContainerViewController()?.showBunnerAlert(title: "", message: "There's no direction available for this location".localized)
            
        }
    }
    
    
    
}


