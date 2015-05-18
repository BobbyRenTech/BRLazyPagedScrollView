//
//  BrowserViewController.swift
//  DialDemo
//
//  Created by Bobby Ren on 5/15/15.
//  Copyright (c) 2015 FwdCommit. All rights reserved.
//

import UIKit

class BrowserViewController: BRLazyPagedScrollViewController, UIScrollViewDelegate {

//    @IBOutlet weak var myScrollView: UIScrollView!
    var currentPageNumber: Int = 0
    var allPages: [Int:PageViewController] = [Int:PageViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let width_ratio:CGFloat = 0.8
        self.setupScrollViewWithPageWidth(self.view.frame.size.width * width_ratio, size: CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - 100))
        self.setupPages()
    }

    override func loadCurrentPage() {
        var controller: PageViewController? = allPages[self.currentPageNumber]
        if controller == nil {
            controller = storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as? PageViewController
            controller!.setNumber(self.currentPageNumber)
            self.allPages[self.currentPageNumber] = controller
        }
        self.currentPage = controller
        super.loadCurrentPage()
        
        println("current page \(controller!.currentNumber) offset \(controller!.view.frame.origin.x)")
    }
    
    override func loadLeftPage() {
        var controller: PageViewController? = allPages[self.currentPageNumber-1]
        if controller == nil {
            controller = storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as? PageViewController
            controller!.setNumber(self.currentPageNumber-1)
            self.allPages[self.currentPageNumber-1] = controller
        }
        self.leftPage = controller
        super.loadLeftPage()

        println("<-left page \(controller!.currentNumber) offset \(controller!.view.frame.origin.x)")
    }
    
    override func loadRightPage() {
        var controller: PageViewController? = allPages[self.currentPageNumber+1]
        if controller == nil {
            controller = storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as? PageViewController
            controller!.setNumber(self.currentPageNumber+1)
            self.allPages[self.currentPageNumber+1] = controller
        }
        self.rightPage = controller
        super.loadRightPage()

        println("->right page \(controller!.currentNumber) offset \(controller!.view.frame.origin.x)")
    }
    
    override func canGoLeft() -> Bool {
        return true
    }
    
    override func canGoRight() -> Bool {
        return true
    }
    
    override func pageLeft() {
        self.currentPageNumber = self.currentPageNumber - 1
        super.pageLeft()
    }
    
    override func pageRight() {
        self.currentPageNumber = self.currentPageNumber + 1
        super.pageRight()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
