//
//  BRLazyPagedScrollViewController.h
//  Pods
//
//  Created by Bobby Ren on 5/15/15.
//
//

#import <UIKit/UIKit.h>

#define LAZY_LOAD_CURRENT_DELAY .01
#define LAZY_LOAD_DELAY 2

typedef enum LazyPagePositionType {
    LazyPagePositionLeft,
    LazyPagePositionCenter,
    LazyPagePositionRight
} LazyPagePosition;

@interface BRLazyPagedScrollViewController : UIViewController <UIScrollViewDelegate>
{
    int pagingWidth; // size of page plus border
    int content_offset_y;
    BOOL goingLeft, goingRight;
    
    BOOL isSetup;
}

@property (nonatomic) IBOutlet UIScrollView *scrollView;

// sizing
@property (nonatomic) CGFloat border; // any separation between pages; cannot exceed difference between page width and scrollview width
@property (nonatomic) CGFloat pageWidth; // size of the page content - not the paging width
@property (nonatomic) CGFloat scrollViewWidth; // size of the scrollView
@property (nonatomic) CGFloat scrollViewHeight;

// content pages
@property (nonatomic) UIViewController *currentPage;
@property (nonatomic) UIViewController *leftPage;
@property (nonatomic) UIViewController *rightPage;

// set up the page size and bounds of scrollview if it is not full screen
-(void)setupScrollViewWithPageWidth:(CGFloat)pageWidth size:(CGSize)size;

// start loading pages
-(void)setupPages;

-(BOOL)canGoLeft;
-(BOOL)canGoRight;
-(void)loadCurrentPage;
-(void)loadLeftPage;
-(void)loadRightPage;

-(void)pageLeft;
-(void)pageRight;
@end

