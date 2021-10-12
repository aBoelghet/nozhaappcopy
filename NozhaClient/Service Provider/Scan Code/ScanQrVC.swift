//
//  ScanQrVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/13/21.
//

import UIKit
import AVFoundation
import MercariQRScanner

class ScanQrVC: UIViewController , AVCaptureMetadataOutputObjectsDelegate {
    
    
    @IBOutlet var qrScannerView: QRScannerView! {
        didSet {
            qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        qrScannerView.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrScannerView.startRunning()
    }
    
}

// MARK: - QRScannerViewDelegate
extension ScanQrVC: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error.localizedDescription)
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        
        startScanApi(code:code)
        
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didChangeTorchActive isOn: Bool) {
        
    }
}

// MARK: - Private
private extension ScanQrVC {
    
    
    func startScanApi(code:String){
        var params = [String:String]()
        params["uuid"] = code
        API.SCAN_RESERVATION.startRequest(showIndicator: true,params: params) { (api, response) in
            self.qrScannerView.rescan()
            if response.isSuccess {
                let value = response.data as! [String:Any]
                
                let data_reservation = try! JSONSerialization.data(withJSONObject: value, options: [])
                let reservation_obj = try! JSONDecoder().decode(Reservation.self, from: data_reservation)
                if reservation_obj.status == "completed"{
                    self.routeComplete(res:reservation_obj)
                }else {
                    self.routeReservation(res:reservation_obj)
                }
            }
            else
            {
                self.routeInvalid()
            }
        }
    }
    
    func routeComplete(res:Reservation) {
        let mainStoryboard = UIStoryboard(name: "ScanRS", bundle: nil)
        let vc : CompleteOrder = mainStoryboard.instanceVC()
        vc.reservation = res
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    func routeReservation(res:Reservation){
        let mainStoryboard = UIStoryboard(name: "ScanRS", bundle: nil)
        let vc : attendanceVC = mainStoryboard.instanceVC()
        vc.reservation = res
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func routeInvalid(){
        let mainStoryboard = UIStoryboard(name: "ScanRS", bundle: nil)
        let vc : invalidCodeVC = mainStoryboard.instanceVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}
