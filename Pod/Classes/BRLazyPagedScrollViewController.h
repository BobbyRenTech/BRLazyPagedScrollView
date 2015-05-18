//
//  BRLazyPagedScrollViewController.h
//  Pods
//
//  Created by Bobby Ren on 5/15/15.
//
//

#import <UIKit/UIKit.h>

#define SCROLL_OFFSET_PAST_PAGE -50
#define SCROLL_OFFSET_NEXT_PAGE 50
#define LAZY_LOAD_CURRENT_DELAY .01
#define LAZY_LOAD_DELAY 2

typedef enum LazyPagePositionType {
    LazyPagePositionLeft,
    LazyPagePositionCenter,
    LazyPagePositionRight
} LazyPagePosition;

@interface BRLazyPagedScrollViewController : UIViewController <UIScrollViewDelegate>
{
    int content_offset_y;
    int border; // space between two pages
    BOOL goingLeft, goingRight;
    
    BOOL isSetup;
}

@property (nonatomic) IBOutlet UIScrollView *scrollView;

// sizing
@property (nonatomic) CGFloat pageWidth;
@property (nonatomic) CGFloat scrollViewWidth;
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

