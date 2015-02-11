


#import <UIKit/UIKit.h>

#define WINDOW  [self.view superview]
#define LOGLINE NSLog(@"info %s,%d",__FUNCTION__,__LINE__);
#define LOGINFO(format,value)  NSLog([NSString stringWithFormat:@"%@ ; info %%s,%%d",format],value,__FUNCTION__,__LINE__);
#define K_SCREEN_HEIGHT ([[UIScreen mainScreen ] bounds ].size.height)
#define K_SCREEN_WIDTH ([[UIScreen mainScreen ] bounds ].size.width)

#define COLORRGBA(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/255.0	\
green:((c>>8)&0xFF)/255.0	\
blue:(c&0xFF)/255.0         \
alpha:a]

#define COLORRGB(c)    [UIColor colorWithRed:((c>>16)&0xFF)/255.0	\
green:((c>>8)&0xFF)/255.0	\
blue:(c&0xFF)/255.0         \
alpha:1.0]

@interface UIColor (SLAddition)

+ (UIColor *)gradient:(double)percent init:(UIColor*)init goal:(UIColor*)goal;

@end


@protocol EYSegmentViewControllerDelegate <NSObject>
@optional
-(void)qc_ViewDidAppear;
-(void)qc_ViewDidDisappear;
@end

@class EYSegmentViewController;
@protocol EYSegmentViewControllerGestureDelegate <NSObject>
@optional
- (void)slideViewController:(EYSegmentViewController *)vc panLeftEdge:(UIPanGestureRecognizer*) panParam;
- (void)slideViewController:(EYSegmentViewController *)vc panRightEdge:(UIPanGestureRecognizer*) panParam;
@end


@interface EYSegmentViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *navItemsViews;
@property (nonatomic, strong) UIScrollView *rootScrollView;
@property (nonatomic, strong) UIScrollView *topScrollView;

@property (nonatomic, weak) EYSegmentViewController* slideViewControllerDelegate;
@property (nonatomic, strong) UIColor *tabItemNormalColor;
@property (nonatomic, strong) UIColor *tabItemSelectedColor;
@property (nonatomic, strong) UIImageView *shadowImageView;

@property (nonatomic, strong) UIView* slideSwitchView;

/*
 * dotItems contains some NSNumber
 * is number<0, will do nothing about the nav item
 * number==0 , will disappera the red dot
 * number>0 , will show the red dot
 */
@property (strong,nonatomic)NSArray* dotItems;

@property (nonatomic, strong) NSMutableArray* viewControllers;


- (id)initWithViewControllers:(NSArray *)vcs;
-(void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated;

-(void)setDotItems:(NSArray*)items;

-(void)viewControllerDidAppearWithIndex:(int)index;

-(void)panLeftEdge:(UIPanGestureRecognizer*) panParam;
-(void)panRightEdge:(UIPanGestureRecognizer*) panParam;

@end

