//
//  NavigationControllerExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/27/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController
{
    enum ViewControllerPosition { case first, last }
    enum ViewControllersGroupPosition { case first, last, all }

   
    func removeControllers(_ position: ViewControllersGroupPosition, animated: Bool = true,
                           where closure: (UIViewController) -> Bool) {
        var range: Range<Int>?
        switch position {
            case .first: range = viewControllers.firstRange(where: closure)
            case .last:
                guard let _range = viewControllers.reversed().firstRange(where: closure) else { return }
                let count = viewControllers.count - 1
                range = .init(uncheckedBounds: (lower: count - _range.min()!, upper: count - _range.max()!))
            case .all:
                let viewControllers = self.viewControllers.filter { !closure($0) }
                setViewControllers(viewControllers, animated: animated)
                return
        }
        if let range = range { removeControllers(animated: animated, in: range) }
    }

    func removeControllers(animated: Bool = true, in range: Range<Int>) {
        var viewControllers = self.viewControllers
        viewControllers.removeSubrange(range)
        setViewControllers(viewControllers, animated: animated)
    }

    func removeControllers(animated: Bool = true, in range: ClosedRange<Int>) {
        removeControllers(animated: animated, in: Range(range))
    }
}

private extension Array {
    func firstRange(where closure: (Element) -> Bool) -> Range<Int>? {
        guard var index = firstIndex(where: closure) else { return nil }
        var indexes = [Int]()
        while index < count && closure(self[index]) {
            indexes.append(index)
            index += 1
        }
        if indexes.isEmpty { return nil }
        return Range<Int>(indexes.min()!...indexes.max()!)
    }
}
