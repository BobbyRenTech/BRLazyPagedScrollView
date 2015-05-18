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
        [self setupScrollViewWithPageWidth:self.view.frame.size.width size:self.view.frame.size];
    }
}

-(void)setupScrollViewWithPageWidth:(CGFloat)pageWidth size:(CGSize)size {
    // default: programmatically creates scrollview. If subclassing with an interface builder scene, can override this func and connect an IBOutlet (like @IBOutlet weak var myScrollView) to self.scrollView
    self.pageWidth = pageWidth;
    self.scrollViewWidth = size.width;
    self.scrollViewHeight = size.height;
    if (self.scrollViewWidth > pageWidth) {
        border = 20;
    }
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
    int content_size_width = self.pageWidth * 3 + border * 2;
    if (!self.canGoLeft && !self.canGoRight) {
        content_size_width = self.scrollViewWidth;
    }
    else if (![self canGoLeft]) {
        content_size_width = self.pageWidth * 2 + border;
    }
    else if (![self canGoRight]) {
        content_size_width = self.pageWidth * 2 + border;
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
    int offset_x = 0;
    if (pos == LazyPagePositionLeft)
        offset_x = 0;
    else if (pos == LazyPagePositionCenter)
        offset_x = [self left_offset_x];
    else if (pos == LazyPagePositionRight)
        offset_x = [self right_offset_x];
    
    CGRect rect = CGRectMake(offset_x, content_offset_y, self.pageWidth, self.scrollViewHeight - content_offset_y);
    return rect;
}

-(CGFloat)center_offset_x {
    if (!self.canGoLeft && !self.canGoRight) {
        return 0;
    }
    else if (![self canGoLeft]) {
        return 0;
    }
    else if (![self canGoRight]) {
        return (self.pageWidth + border) + (self.pageWidth / 2) - (self.scrollViewWidth / 2);
    }
    else {
        return (self.pageWidth + border) + (self.pageWidth / 2) - (self.scrollViewWidth / 2);
    }
}
-(CGFloat)left_offset_x {
    return self.pageWidth + border;
}

-(CGFloat)right_offset_x {
    return self.pageWidth * 2 + border * 2;
}

#pragma mark Movement
-(void)pageLeft {
    // shift views to the left, then reset content offset to center
    [rightPage.view removeFromSuperview];
    rightPage = currentPage;
    currentPage = leftPage;
    leftPage = nil;
    
    [self performSelector:@selector(setupPages) withObject:nil afterDelay:LAZY_LOAD_CURRENT_DELAY];
}

-(void)pageRight {
    // shift views to the right, then reset content offset
    [leftPage.view removeFromSuperview];
    leftPage = currentPage;
    currentPage = rightPage;
    rightPage = nil;
    
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
    [self snap];
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
    if (scrollView.contentOffset.x < [self center_offset_x] + SCROLL_OFFSET_PAST_PAGE) {
        [self pageLeft];
    }
    else if (scrollView.contentOffset.x > [self center_offset_x] + SCROLL_OFFSET_NEXT_PAGE) {
        [self pageRight];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
