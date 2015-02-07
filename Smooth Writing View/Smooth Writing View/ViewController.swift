//
//  ViewController.swift
//  Smooth Writing View
//
//  Created by Solomon Li on 2/7/15.
//  Copyright (c) 2015 Maid in China. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // add border to test width and height equalty
        if let smoothView = self.view.subviews[0] as? SmoothWritingView {
            smoothView.layer.borderColor = UIColor.blackColor().CGColor
            smoothView.layer.borderWidth = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if let smoothView = self.view.subviews[0] as? SmoothWritingView {
            smoothView.clear()
        }
    }
}

