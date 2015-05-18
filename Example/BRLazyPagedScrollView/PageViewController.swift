//
//  PageViewController.swift
//  DialDemo
//
//  Created by Bobby Ren on 5/15/15.
//  Copyright (c) 2015 FwdCommit. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    var currentNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = self.randomColor()
        self.label.text = "\(self.currentNumber)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNumber(number: Int) {
        self.currentNumber = number
    }
    
    func randomColor() -> UIColor {
        let colors = [UIColor.redColor(), UIColor.blueColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.brownColor()] as Array
        let index = arc4random_uniform(UInt32(colors.count))
        return colors[Int(index)]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
