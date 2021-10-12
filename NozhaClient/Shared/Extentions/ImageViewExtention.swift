//
//  ImageViewExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/20/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage



extension UIImage {

    func imageWithColorOld(color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

 

}

extension UIImageView {
    func fetchingImageWithPlaceholder(url: String,placeholder:String) {
           if let url = URL(string: url) {

               self.sd_setImage(with: url, placeholderImage: UIImage(named: placeholder), options: .refreshCached)
           }else{
               self.image = UIImage(named: "image_placholder")
           }
       }
    
func fetchingImage(url: String) {
    if let url = URL(string: url) {

        self.sd_setImage(with: url, placeholderImage: UIImage(named: "image_placholder"), options: .refreshCached)
    }else{
        self.image = UIImage(named: "image_placholder")
    }
}
    func fetchingProfileImage(url: String) {
        if let url = URL(string: url) {

            self.sd_setImage(with: url, placeholderImage: UIImage(named: "img_profile"), options: .refreshCached)
        }else{
            self.image = UIImage(named: "img_profile")
        }
    }
    func fetchingProfileImageFemale(url: String) {
        if let url = URL(string: url) {

            self.sd_setImage(with: url, placeholderImage: UIImage(named: "female_avatar"), options: .refreshCached)
        }else{
            self.image = UIImage(named: "female_avatar")
        }
    }
    func fetchingProfileImageSupplier(url: String) {
        if let url = URL(string: url) {

            self.sd_setImage(with: url, placeholderImage: UIImage(named: "supplier_avatar"), options: .refreshCached)
        }else{
            self.image = UIImage(named: "supplier_avatar")
        }
    }
   

    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
           contentMode = mode
           URLSession.shared.dataTask(with: url) { data, response, error in
               guard
                   let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                   let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                   let data = data, error == nil,
                   let image = UIImage(data: data)
                   else { return }
               DispatchQueue.main.async() {
                   self.image = image
               }
           }.resume()
       }
       func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
           guard let url = URL(string: link) else { return }
           downloaded(from: url, contentMode: mode)
       }
       
}
