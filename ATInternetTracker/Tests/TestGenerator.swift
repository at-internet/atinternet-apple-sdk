//
//  Generator.swift
//  SmartTracker
//
//  Created by Théo Damaville on 17/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import Foundation

class TestGenerator {
    class func randomViewGenerator(filterViews:(UIView) -> (Bool) = {_ in return true} ) -> UIView {
        let allViews: [UIView] = [UIView(), UILabel(), UIButton(), UISegmentedControl(), UITextField(), UISlider(), UISwitch(), UIStepper(), UIImageView(), UITextView(), UIScrollView(), UIDatePicker(), UIWebView(), UINavigationBar(), UISearchBar()]
        let views = allViews.filter(filterViews)
        let aView = views[Int(arc4random_uniform(UInt32(views.count)))]
        let x = CGFloat(arc4random_uniform(300))
        let y = CGFloat(arc4random_uniform(300))
        let w = CGFloat(arc4random_uniform(300))
        let h = CGFloat(arc4random_uniform(300))
        aView.frame = CGRectMake(x,y,w,h)
        return aView
    }
}