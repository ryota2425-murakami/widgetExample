//
//  ViewController.swift
//  widgetExample
//
//  Created by ryota on 2021/02/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("a")

        NewsClient.fetchSummary {a in
            print( a)
         
        }
        // Do any additional setup after loading the view.
    }


}

