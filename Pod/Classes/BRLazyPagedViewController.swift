//
//  BRLazyPagedViewController.swift
//  Pods
//
//  Created by Bobby Ren on 5/15/15.
//
//

import UIKit

enum LazyPagePosition {
    case Left
    case Center
    case Right
}

let SCROLL_OFFSET_PAST_PAGE:CGFloat = -50
let SCROLL_OFFSET_NEXT_PAGE:CGFloat = 50
let LAZY_LOAD_CURRENT_DELAY:Double = 0.01 // allows other UI to update before taking up all resources to load/render current view
let LAZY_LOAD_DELAY:Double = 2 // pages beyond which to load

class BRLazyPagedViewController: UIViewController, UIScrollViewDelegate {

    var current_offset_x: CGFloat = 0.0
    var content_offset_y: CGFloat = 0.0
    var goingLeft: Bool = false
    var goingRight: Bool = false
    
    var currentPage: UIViewController?
    var leftPage: UIViewController?
    var rightPage: UIViewController?
    
    var scrollView: UIScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupScrollView()

        self.scrollView!.pagingEnabled = true
        
        // todo: these should not be defaults
        self.scrollView!.directionalLockEnabled = true
        self.scrollView!.bounces = false
        self.scrollView!.scrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupScrollView() {
        // default: programmatically creates scrollview. If subclassing with an interface builder scene, can override this func and connect an IBOutlet (like @IBOutlet weak var myScrollView) to self.scrollView
        self.scrollView = UIScrollView()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Setup
    func setupPages() {
        self.loadCurrentPage()
        
        self.loadRightPage()
        
        self.loadLeftPage()
    }
    
    func layoutCurrentPage() {
        assert(self.currentPage != nil)
        
        // update content size and content offset if we reached end
        current_offset_x = self.scrollView!.frame.size.width
        var content_size_width = self.scrollView!.frame.size.width * 3;
        if !self.canGoLeft() && !self.canGoRight() {
            current_offset_x = 0;
            content_size_width = self.scrollView!.frame.size.width;
        }
        else if !self.canGoLeft() {
            current_offset_x = 0;
            content_size_width = self.scrollView!.frame.size.width * 2;
        }
        else if !self.canGoRight() {
            content_size_width = self.scrollView!.frame.size.width * 2;
        }
        
        // set frames for current week
        self.currentPage!.view.frame = self.frameInScrollViewForPosition(LazyPagePosition.Center)
        
        // force layout for subviews
        // makes sure the subviews are correctly resized, because autolayout doesn't happen until viewDidAppear triggers, and there are several layers of subviews (scrollview->workoutDetailView->bargraph)
        // this must be done after the currentPage frame is changed. but if done later, it doesn't work.
        self.forceLayoutForController(self.currentPage!)
        
        self.currentPage!.view.removeFromSuperview()
        self.scrollView!.addSubview(self.currentPage!.view)
        
        self.scrollView!.contentOffset = CGPointMake(current_offset_x, 0)
        self.scrollView!.contentSize = CGSizeMake(content_size_width, self.scrollView!.frame.size.height)
    }
    
    func layoutLeftPage() {
        self.leftPage!.view.frame = self.frameInScrollViewForPosition(LazyPagePosition.Left)
        self.forceLayoutForController(self.leftPage!)
        if self.leftPage!.view.superview == nil {
            self.scrollView!.addSubview(self.leftPage!.view)
        }
    }
    
    func layoutRightPage() {
        self.rightPage!.view.frame = self.frameInScrollViewForPosition(LazyPagePosition.Right)
        self.forceLayoutForController(self.rightPage!)
        if self.rightPage!.view.superview == nil {
            self.scrollView!.addSubview(self.rightPage!.view)
        }
    }
    
    // MARK: - Utilities
    func frameInScrollViewForPosition(pos:LazyPagePosition) -> CGRect {
        var offset_x: CGFloat = 0
        if pos == LazyPagePosition.Left {
            offset_x = 0
        }
        else if pos == LazyPagePosition.Center {
            offset_x = self.current_offset_x
        }
        else if pos == LazyPagePosition.Right {
            offset_x = self.current_offset_x + self.scrollView!.frame.size.width
        }
        
        return CGRectMake(offset_x, self.content_offset_y, self.scrollView!.frame.size.width, self.scrollView!.frame.size.height - self.content_offset_y);
    }
    
    func forceLayoutForController(page:UIViewController) {
        for subview in page.view.subviews {
            subview.setNeedsLayout()
            subview.layoutIfNeeded()
        }
    }
    
    // MARK: movement
    func pageLeft() {
        // shift views to the left, then reset content offset to center
        self.rightPage!.view.removeFromSuperview()
        self.rightPage = self.currentPage
        self.currentPage = self.leftPage
        self.leftPage = nil
        
        // perform this after a delay
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(LAZY_LOAD_CURRENT_DELAY * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.setupPages()
        }
    }
    
    func pageRight() {
        // shift views to the right, then reset content offset to center
        self.leftPage!.view.removeFromSuperview()
        self.leftPage = self.currentPage
        self.currentPage = self.rightPage
        self.rightPage = nil
        
        // perform this after a delay
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(LAZY_LOAD_CURRENT_DELAY * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.setupPages()
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // only triggered by didClickButton/scrollRectToVisible

        if self.goingLeft {
            // give a slight delay to let animation complete, otherwise there is a hiccup
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(LAZY_LOAD_CURRENT_DELAY * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                self.pageLeft()
            }
        }
        else if self.goingRight {
            // give a slight delay to let animation complete, otherwise there is a hiccup
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(LAZY_LOAD_CURRENT_DELAY * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                self.pageRight()
            }
        }
        
        goingLeft = false
        goingRight = false
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // if scrollview stops. can happen if scrollview pops back, or if fling motion happens
        if (scrollView.contentOffset.x < current_offset_x + SCROLL_OFFSET_PAST_PAGE) {
            self.pageLeft()
        }
        else if (scrollView.contentOffset.x > current_offset_x + SCROLL_OFFSET_NEXT_PAGE) {
            self.pageRight()
        }
    }
    
    // MARK: - Implemented by subclasses
    // Loading pages: Load, generate or get from cache a UIViewController and set it to currentPage, leftPage or rightPage
    func loadCurrentPage() {
        self.layoutCurrentPage()
    }
    
    func loadLeftPage() {
        self.layoutLeftPage()
    }
    
    func loadRightPage() {
        self.layoutRightPage()
    }
    
    // Scroll conditions: Determine whether there are more pages that should be lazy loaded to the left or right
    func canGoLeft() -> Bool {
        return false
    }
    
    func canGoRight() -> Bool {
        return false
    }
}
