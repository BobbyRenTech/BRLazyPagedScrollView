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
    
    [self setupScrollView];
    
    [scrollView setPagingEnabled:YES];

    // todo: these should not be defaults
    [scrollView setDirectionalLockEnabled:YES];
    [scrollView setBounces:NO];
    [scrollView setScrollEnabled:YES];
    
    [self setupPages];
}

-(void)setupScrollView {
    // default: programmatically creates scrollview. If subclassing with an interface builder scene, can override this func and connect an IBOutlet (like @IBOutlet weak var myScrollView) to self.scrollView
    self.scrollView = [[UIScrollView alloc] init];
}

#pragma mark Setup
-(void)setupPages {
    [self loadCurrentPage];
    
    [self loadRightPage];
    
    [self loadLeftPage];
}

-(void)layoutCurrentPage {
    // update content size and content offset if we reached end
    current_offset_x = scrollView.frame.size.width;
    int content_size_width = scrollView.frame.size.width * 3;
    if (!self.canGoLeft && !self.canGoRight) {
        current_offset_x = 0;
        content_size_width = scrollView.frame.size.width;
    }
    else if (![self canGoLeft]) {
        current_offset_x = 0;
        content_size_width = scrollView.frame.size.width * 2;
    }
    else if (![self canGoRight]) {
        content_size_width = scrollView.frame.size.width * 2;
    }
    
    // set frames for current week
    currentPage.view.frame = [self frameInScrollviewForPosition:LazyPagePositionCenter];
    
    // force layout for subviews
    // makes sure the subviews are correctly resized, because autolayout doesn't happen until viewDidAppear triggers, and there are several layers of subviews (scrollview->workoutDetailView->bargraph)
    // this must be done after the currentPage frame is changed. but if done later, it doesn't work.
    [self forceLayoutForController:currentPage];
    
    [currentPage.view removeFromSuperview];
    [scrollView addSubview:currentPage.view];
    
    [scrollView setContentOffset:CGPointMake(current_offset_x, 0) animated:NO];
    [scrollView setContentSize:CGSizeMake(content_size_width, scrollView.frame.size.height)];
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
        offset_x = current_offset_x;
    else if (pos == LazyPagePositionRight)
        offset_x = current_offset_x + scrollView.frame.size.width;
    
    CGRect rect = CGRectMake(offset_x, content_offset_y, scrollView.frame.size.width, scrollView.frame.size.height - content_offset_y);
    return rect;
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
    if (scrollView.contentOffset.x < current_offset_x + SCROLL_OFFSET_PAST_PAGE)
        [self pageLeft];
    else if (scrollView.contentOffset.x > current_offset_x + SCROLL_OFFSET_NEXT_PAGE)
        [self pageRight];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // nothing special to do
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
