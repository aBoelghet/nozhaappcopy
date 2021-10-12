//
//  AddEditAddressVC.swift
//  NozhaClient
//
//  Created by mac book air on 2/9/21.
//


import UIKit
import GoogleMaps
import IBAnimatable

class AddEditAddressVC: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var addressDetailsLbl: UILabel!
    

    var location:GMSCameraPosition?
    
    
    
    var geocoder = CLGeocoder()
    let annotiation = GMSMarker()
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        manager.delegate = self
        initLocation()
     
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
 
    @IBAction func SaveAction(_ sender: Any) {
        self.pop()
    }
    
    
}

extension AddEditAddressVC {
    
    func initLocation(){
      
        if !hasLocationPermission() {
            self.showCustomAlert(title: "Location Permission Required".localized, message: "Please enable location permissions in settings.".localized, okTitle: "Ok".localized, cancelTitle: "Cancel".localized) { (result) in
                if result {
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                }
            }
    
        }
        manager.startUpdatingLocation()
        self.location = GMSCameraPosition(latitude: Global.share.new_Service.lat ?? 0.0, longitude: Global.share.new_Service.lng ?? 0.0, zoom: 15)
        self.mapView.camera = self.location!
    }
    func hasLocationPermission() -> Bool {
        var hasPermission = false
        let manager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                switch manager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    hasPermission = false
                case .authorizedAlways, .authorizedWhenInUse:
                    hasPermission = true
                @unknown default:
                    break
                }
            } else {
                manager.requestWhenInUseAuthorization()
            }
        } else {
            hasPermission = false
        }
        
        return hasPermission
    }
   
    
    
}


extension AddEditAddressVC: CLLocationManagerDelegate {
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            
            guard
                let address = response?.firstResult(),
                let lines = address.lines
                else {
                    self.addressDetailsLbl.text = ""
                    return
            }
            self.addressDetailsLbl.text = lines.joined(separator: "\n")
            if self.hasLocationPermission() {
            Global.share.new_Service.lng = coordinate.longitude
            Global.share.new_Service.lat = coordinate.latitude
            Global.share.new_Service.address =  lines.joined(separator: "\n")
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
 
            guard let location = locations.last else {
                return
            }
            
            setCurrentPostion(location: location)
            let position = GMSCameraPosition(
                target: location.coordinate,
                zoom: 15,
                bearing: 0,
                viewingAngle: 0)
            reverseGeocode(coordinate: position.target)
       
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription);
      }
    
    
    
    func setCurrentPostion(location :CLLocation){
        let cordicator = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition(latitude: cordicator.latitude, longitude: cordicator.longitude, zoom: 17)))
        
        
    }
    
    
}

// MARK: - GMSMapViewDelegate
extension AddEditAddressVC: GMSMapViewDelegate
{
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {

        annotiation.title = "current_location".localized
        annotiation.icon = UIImage(named: "ic_map_point")
        annotiation.map = mapView
        
        
        UIView.animate(withDuration: 1, animations: {
            self.annotiation.position = mapView.camera.target
        }, completion:  { success in
            if success {
                // handle a successfully ended animation
            } else {
                // handle a canceled animation, i.e move to destination immediately
                self.annotiation.position = mapView.camera.target
            }
        })
        
        reverseGeocode(coordinate: position.target)
        
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
    }
    
    
}




