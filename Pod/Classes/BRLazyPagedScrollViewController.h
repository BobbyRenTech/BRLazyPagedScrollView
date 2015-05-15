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
    int current_offset_x;
    int content_offset_y;
    BOOL goingLeft, goingRight;
    
}

@property (nonatomic) UIScrollView *scrollView;

// content pages
@property (nonatomic) UIViewController *currentPage;
@property (nonatomic) UIViewController *leftPage;
@property (nonatomic) UIViewController *rightPage;

-(void)setupScrollView;

-(BOOL)canGoLeft;
-(BOOL)canGoRight;
-(void)loadCurrentPage;
-(void)loadLeftPage;
-(void)loadRightPage;

@end

