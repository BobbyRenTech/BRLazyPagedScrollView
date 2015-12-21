//
//  BRLazyPagedScrollViewController.m
//  Pods
//
//  Created by Bobby Ren on 5/15/15.
//
//

#import "BRLazyPagedScrollViewController.h"

@interface BRLazyPagedScrollViewController ()

@end

@implementation BRLazyPagedScrollViewController

@synthesize scrollView, currentPage, leftPage, rightPage;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [scrollView setPagingEnabled:NO];
    
    // todo: these should not be defaults
    [scrollView setDirectionalLockEnabled:YES];
    [scrollView setBounces:NO];
    [scrollView setScrollEnabled:YES];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!isSetup) {
        content_offset_y = 0; //self.scrollView.contentOffset.y;
        [self setupScrollViewWithPageWidth:self.view.frame.size.width size:self.view.frame.size border:0];
    }
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

-(void)setupScrollViewWithPageWidth:(CGFloat)pageWidth size:(CGSize)size border:(CGFloat)border {
    // default: programmatically creates scrollview. If subclassing with an interface builder scene, can override this func and connect an IBOutlet (like @IBOutlet weak var myScrollView) to self.scrollView
    self.pageWidth = pageWidth;
    self.scrollViewWidth = size.width;
    self.scrollViewHeight = size.height;
    
    if (self.pageWidth < self.scrollViewWidth && border == -1) {
        self.border = 20;
    }
    else {
        self.border = border;
    }
    
    pagingWidth = self.pageWidth + self.border;
    isSetup = true;
}

#pragma mark Setup
-(void)setupPages {
    [self loadCurrentPage];
    
    [self loadRightPage];
    
    [self loadLeftPage];
}

-(void)layoutCurrentPage {
    // update content size and content offset if we reached end
    CGFloat pagediff = (self.scrollViewWidth - self.pageWidth) / 2;
    int content_size_width = pagediff + self.pageWidth * 3 + self.border * 2 + pagediff;
    
    if (!self.canGoLeft && !self.canGoRight) {
        content_size_width = self.scrollViewWidth;
    }
    else if (![self canGoLeft]) {
        content_size_width = pagediff + self.pageWidth * 2 + self.border + pagediff;
    }
    else if (![self canGoRight]) {
        content_size_width = pagediff + self.pageWidth * 2 + self.border + pagediff;
    }
    
    // set frames for current week
    currentPage.view.frame = [self frameInScrollviewForPosition:LazyPagePositionCenter];
    
    // force layout for subviews
    // makes sure the subviews are correctly resized, because autolayout doesn't happen until viewDidAppear triggers, and there are several layers of subviews (scrollview->workoutDetailView->bargraph)
    // this must be done after the currentPage frame is changed. but if done later, it doesn't work.
    [self forceLayoutForController:currentPage];
    
    [currentPage.view removeFromSuperview];
    [scrollView addSubview:currentPage.view];
    
    [scrollView setContentOffset:CGPointMake([self center_offset_x], 0) animated:NO];
    [scrollView setContentSize:CGSizeMake(content_size_width, self.scrollViewHeight)];
}

-(void)layoutRightPage {
    rightPage.view.frame = [self frameInScrollviewForPosition:LazyPagePositionRight];
    [self forceLayoutForController:rightPage];
    if (!rightPage.view.superview)
        [scrollView addSubview:rightPage.view];
}

-(void)layoutLeftPage {
    leftPage.view.frame = [self frameInScrollviewForPosition:LazyPagePositionLeft];
    [self forceLayoutForController:leftPage];
    if (!leftPage.view.superview)
        [scrollView addSubview:leftPage.view];
}

#pragma mark Utilities
-(void)forceLayoutForController:(UIViewController *)page {
    for (UIView *subview in page.view.subviews) {
        [subview setNeedsLayout];
        [subview layoutIfNeeded];
    }
}

-(CGRect)frameInScrollviewForPosition:(LazyPagePosition)pos {
    CGFloat pagediff = (self.scrollViewWidth - self.pageWidth) / 2;
    
    CGFloat offset_x = self.border;
    if (pos == LazyPagePositionLeft)
        offset_x = pagediff;
    else if (pos == LazyPagePositionCenter) {
        if (!self.canGoLeft && !self.canGoRight) {
            offset_x = pagediff;
        }
        else if (![self canGoLeft]) {
            offset_x = pagediff;
        }
        else if (![self canGoRight]) {
            offset_x = pagediff + self.pageWidth + self.border;
        }
        else {
            offset_x = pagediff + self.pageWidth + self.border;
        }
    }
    else if (pos == LazyPagePositionRight) {
        if (!self.canGoLeft) {
            offset_x = pagediff + self.pageWidth + self.border;
        }
        else {
            offset_x = pagediff + self.pageWidth * 2 + self.border * 2;
        }
    }
    
    CGRect rect = CGRectMake(offset_x, content_offset_y, self.pageWidth, self.scrollViewHeight - content_offset_y);
    return rect;
}

-(CGFloat)center_offset_x {
    // content offset for center view
    if (!self.canGoLeft && !self.canGoRight) {
        return 0;
    }
    else if (![self canGoLeft]) {
        return 0;
    }
    else if (![self canGoRight]) {
        return pagingWidth;
    }
    else {
        return pagingWidth;
    }
}

#pragma mark Movement
-(void)pageLeft {
    // shift views to the left, then reset content offset to center
    [rightPage.view removeFromSuperview];
    rightPage = currentPage;
    currentPage = leftPage;
    leftPage = nil;
    
    goingLeft = false;
    goingRight = false;
    
    [self performSelector:@selector(setupPages) withObject:nil afterDelay:LAZY_LOAD_CURRENT_DELAY];
}

-(void)pageRight {
    // shift views to the right, then reset content offset
    [leftPage.view removeFromSuperview];
    leftPage = currentPage;
    currentPage = rightPage;
    rightPage = nil;
    
    goingLeft = false;
    goingRight = false;

    [self performSelector:@selector(setupPages) withObject:nil afterDelay:LAZY_LOAD_CURRENT_DELAY];
}

#pragma mark ScrollView Delegate
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // only triggered by didClickButton/scrollRectToVisible
    if (goingLeft) {
        [self performSelector:@selector(pageLeft) withObject:nil afterDelay:.01]; // give a slight delay to let animation complete, otherwise there is a hiccup
    }
    else if (goingRight) {
        [self performSelector:@selector(pageRight) withObject:nil afterDelay:.01];
    }
    goingLeft = NO;
    goingRight = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // if scrollview stops. can happen if scrollview pops back, or if fling motion happens
//    [self snap];
    if (scrollView.contentOffset.x < [self center_offset_x] - self.pageWidth/3) {
        [self pageLeft];
    }
    else if (scrollView.contentOffset.x > [self center_offset_x] + self.pageWidth/3) {
        [self pageRight];
    }
    else {
        [self snap];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // nothing special to do
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self snap];
    }
    else {
        // todo: if scrollview is scrolling very slowly, go ahead and stop it and snap
        // must prevent didEndDecelerating from being triggered
        [self snap];
    }
}

-(void)snap {
    if (scrollView.contentOffset.x < [self center_offset_x] - self.pageWidth/3) {
        [self.scrollView setContentOffset:CGPointMake(0, content_offset_y) animated:true];
        goingLeft = true;
//        [self pageLeft];
    }
    else if (scrollView.contentOffset.x > [self center_offset_x] + self.pageWidth/3) {
        [self.scrollView setContentOffset:CGPointMake([self center_offset_x] + self.pageWidth, content_offset_y) animated:true];
        goingRight = true;
//        [self pageRight];
    }
    else {
        [self.scrollView setContentOffset:CGPointMake([self center_offset_x], content_offset_y) animated:true];
    }
}

#pragma mark Implemented by subclasses
// loading pages: Load, generate or get from cache a UIViewController and set to current, left or right pages
-(void)loadCurrentPage {
    [self layoutCurrentPage];
}

-(void)loadRightPage {
    [self layoutRightPage];
}

-(void)loadLeftPage {
    [self layoutLeftPage];
}

-(BOOL)canGoLeft {
    return NO;
}

-(BOOL)canGoRight {
    return NO;
}

#pragma mark commands to change page
-(void)goToLeftPage:(BOOL)animated {
    if ([self canGoLeft]) {
        goingLeft = YES;
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:animated];
    }
}

-(void)goToRightPage:(BOOL)animated {
    if ([self canGoRight]) {
        goingRight = YES;
        [self.scrollView scrollRectToVisible:CGRectMake([self center_offset_x] + self.view.frame.size.width, content_offset_y, self.pageWidth, 1) animated:true];
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
