//
//  ViewController.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var menu : TabbarMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        menu = TabbarMenu(texture: .withBlur(blurStyle: .dark) ,tabbarHeight: 40.0, toTop: 200)
    }
    
}

