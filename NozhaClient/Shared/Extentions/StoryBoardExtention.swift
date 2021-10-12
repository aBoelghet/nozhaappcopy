//
//  StoryBoardExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/14/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    func instanceVC<T: UIViewController>() -> T {
        guard let vc = instantiateViewController(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("Could not locate viewcontroller with with identifier \(String(describing: T.self)) in storyboard.")
        }
        return vc
    }
}
