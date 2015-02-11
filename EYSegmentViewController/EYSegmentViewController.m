

#import "EYSegmentViewController.h"

static const CGFloat kHeightOfTopScrollView = 30.0f;

static const CGFloat kMinItemWidth = 70.0f;

static const NSUInteger TAG_DOT = 2002;

static const NSUInteger TAG_BUTTON_BASE = 100;

@implementation UIColor (EYGradient)

+ (UIColor *)gradient:(double)percent init:(UIColor*)init goal:(UIColor*)goal {
    double t = percent;
    
    t = MAX(0.0, MIN(t, 1.0));
    const CGFloat *cgInit = CGColorGetComponents(init.CGColor);
    const CGFloat *cgGoal = CGColorGetComponents(goal.CGColor);
    double r = cgInit[0] + t * (cgGoal[0] - cgInit[0]);
    double g = cgInit[1] + t * (cgGoal[1] - cgInit[1]);
    double b = cgInit[2] + t * (cgGoal[2] - cgInit[2]);
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}
@end


@interface EYSegmentViewController ()
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic)  BOOL isGestureOver;
@property (nonatomic) float gestureStartX;
-(float)tabItemWidth;
@end

@implementation EYSegmentViewController

- (id)initWithViewControllers:(NSArray *)vcs
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _currentIndex=0;
        
        _navItemsViews=[[NSMutableArray alloc] init];
        self.slideSwitchView=[[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        
        self.viewControllers=[NSMutableArray arrayWithArray:vcs];
        for (UIViewController* vc in _viewControllers) {
            [self addChildViewController:vc];
        }

        
        _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_WIDTH, kHeightOfTopScrollView)];
        _topScrollView.delegate = self;
        _topScrollView.backgroundColor = [UIColor clearColor];
        _topScrollView.pagingEnabled = NO;
        _topScrollView.showsHorizontalScrollIndicator = NO;
        _topScrollView.showsVerticalScrollIndicator = NO;
        _topScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_slideSwitchView addSubview:_topScrollView];
        
        UIView* vLine = [[UIView alloc]initWithFrame:CGRectMake(0, kHeightOfTopScrollView-0.5, self.tabItemWidth * _viewControllers.count, 0.5)];
        vLine.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        vLine.backgroundColor=COLORRGB(0xcccccc);
        [_topScrollView addSubview:vLine];
        
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kHeightOfTopScrollView, K_SCREEN_WIDTH, K_SCREEN_HEIGHT - kHeightOfTopScrollView)];
        _rootScrollView.delegate = self;
        _rootScrollView.pagingEnabled = YES;
        _rootScrollView.userInteractionEnabled = YES;
        _rootScrollView.bounces = NO;
        _rootScrollView.showsHorizontalScrollIndicator = NO;
        _rootScrollView.showsVerticalScrollIndicator = NO;
        _rootScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [_rootScrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
        [_slideSwitchView addSubview:_rootScrollView];
        
        self.slideSwitchView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _tabItemNormalColor = COLORRGB(0x7a7a7a);
        _tabItemSelectedColor = COLORRGB(0x5e9939);


        for (int i=0; i<_viewControllers.count; i++) {
            UIViewController *vc = _viewControllers[i];
            [_rootScrollView addSubview:vc.view];
        }
        
        _shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tabItemWidth, kHeightOfTopScrollView)];
        _shadowImageView.image=[[UIImage imageNamed:@"EYSegmentViewController.bundle/red_line_and_shadow.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(7, 2, 7, 2) resizingMode:UIImageResizingModeStretch];
        _shadowImageView.contentMode=UIViewContentModeScaleToFill;
        [_topScrollView addSubview:_shadowImageView];
        
        CGFloat xOffset = 0;
        for (int i = 0; i < _viewControllers.count; i++) {
            UIViewController *vc = _viewControllers[i];
            UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(xOffset, 0, self.tabItemWidth, kHeightOfTopScrollView)];
            lb.textColor=[UIColor grayColor];
            lb.font=[UIFont systemFontOfSize:12];
            lb.text=vc.title;
            lb.textAlignment=NSTextAlignmentCenter;
            lb.tag=i+TAG_BUTTON_BASE;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnHeader:)];
            [lb addGestureRecognizer:tap];
            [lb setUserInteractionEnabled:YES];
            [_navItemsViews addObject:lb];
            [_topScrollView addSubview:lb];
            
            UIView* vDot=[[UIView alloc]initWithFrame:CGRectMake(self.tabItemWidth*2/3, 8, 5, 5)];
            vDot.backgroundColor = [UIColor redColor];
            vDot.layer.cornerRadius = vDot.bounds.size.width/2.0;
            vDot.tag=TAG_DOT;
            vDot.hidden=YES;
            [lb addSubview:vDot];

            xOffset += self.tabItemWidth ;
        }
        
        _topScrollView.contentSize = CGSizeMake(self.tabItemWidth* _viewControllers.count, kHeightOfTopScrollView);
        _rootScrollView.contentSize = CGSizeMake(K_SCREEN_WIDTH * _viewControllers.count, 0);
        
        for (int i = 0; i < _viewControllers.count; i++) {
            UIViewController *vc = _viewControllers[i];
            vc.view.frame = CGRectMake(_rootScrollView.bounds.size.width *i, 0, _rootScrollView.bounds.size.width, _rootScrollView.bounds.size.height);
        }
        
        [self setCurrentIndex:_currentIndex animated:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.slideSwitchView];
}

-(void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated{
    NSAssert((index >= 0 && index < self.navItemsViews.count-1), @"Index out of range");
    
    _currentIndex=index;
    CGFloat xOffset = index * K_SCREEN_WIDTH;
    [self.rootScrollView setContentOffset:CGPointMake(xOffset, self.rootScrollView.contentOffset.y) animated:animated];
    [_shadowImageView setFrame:CGRectMake(index*self.tabItemWidth, 0,self.tabItemWidth, kHeightOfTopScrollView)];
    [self updateNavItemsColor];
}
-(float)tabItemWidth{
    CGFloat screenWidth= [[UIScreen mainScreen]bounds].size.width;
    return MAX(screenWidth/_viewControllers.count, kMinItemWidth);
}
-(void)viewControllerDidAppearWithIndex:(int)index{
    //move the topScrollView if the selected item is out of screen
    if (index* self.tabItemWidth -_topScrollView.contentOffset.x <0) {
        [_topScrollView setContentOffset:CGPointMake(0, _topScrollView.contentOffset.y) animated:YES];
    }else if(index* self.tabItemWidth -_topScrollView.contentOffset.x >(K_SCREEN_WIDTH-self.tabItemWidth)){
        [_topScrollView setContentOffset:CGPointMake(index* self.tabItemWidth  - K_SCREEN_WIDTH + self.tabItemWidth , _topScrollView.contentOffset.y) animated:YES];
    }

    {
        UIViewController *vc = [_viewControllers objectAtIndex:_currentIndex];
        if ([vc conformsToProtocol:@protocol(EYSegmentViewControllerDelegate)]
            && [vc respondsToSelector:@selector(qc_ViewDidDisappear)]) {
            [vc performSelector:@selector(qc_ViewDidDisappear)];
        }
    }
    _currentIndex=index;//change _currentIndex,must be here
    {
        UIViewController *vc = [_viewControllers objectAtIndex:_currentIndex];
        if ([vc conformsToProtocol:@protocol(EYSegmentViewControllerDelegate)]
            && [vc respondsToSelector:@selector(qc_ViewDidAppear)]) {
            [vc performSelector:@selector(qc_ViewDidAppear)];
        }
    }
}

-(void)setDotItems:(NSArray*)items{
    if (items.count!=_navItemsViews.count) {
        NSLog(@"items.count must equal to _navItemsViews.count !!!!! \n !!!!!!!!!!!!!!!");
        return;
    }
    _dotItems=[NSArray arrayWithArray:items];
    for (int i=0; i<_navItemsViews.count; i++) {
        UILabel* lb = _navItemsViews[i];
        NSNumber* num=_dotItems[i];
        UIView* vDot=[lb viewWithTag:TAG_DOT];
        if (num.intValue>=0) {
            vDot.hidden=num.intValue==0;
        }
    }
}



-(void)panLeftEdge:(UIPanGestureRecognizer*) panParam{
    LOGLINE
}
-(void)panRightEdge:(UIPanGestureRecognizer*) panParam{
    LOGLINE
}

-(void)scrollHandlePan:(UIPanGestureRecognizer*) panParam
{
    //handle the gesture to the super view
    switch (panParam.state) {
        case UIGestureRecognizerStateBegan:
        {
            _gestureStartX=[panParam locationInView:WINDOW].x;
            _isGestureOver=NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (!_isGestureOver) {
                float gestureX=[panParam locationInView:WINDOW].x;
                if (_rootScrollView.contentOffset.x <= 0  //in the left
                    && (gestureX-_gestureStartX)>40) {
                    _isGestureOver=YES;
                    [self panLeftEdge:panParam];
                }else if(_rootScrollView.contentOffset.x >= _rootScrollView.contentSize.width  // right
                         && (gestureX-_gestureStartX)<-40){
                    _isGestureOver=YES;
                    [self panRightEdge:panParam];
                }
            }
        }
            break;
        default:
            break;
    }
    
}
-(void)tapOnHeader:(UITapGestureRecognizer *)recognizer{
    UIView* sender = recognizer.view;
    [UIView animateWithDuration:0.25 animations:^{
        [_shadowImageView setFrame:CGRectMake(sender.frame.origin.x, 0, sender.frame.size.width, kHeightOfTopScrollView)];
        [_rootScrollView setContentOffset:CGPointMake((sender.tag - TAG_BUTTON_BASE)*self.view.bounds.size.width, 0) animated:YES];
    } completion:^(BOOL finished) {
        [self viewControllerDidAppearWithIndex:((int)sender.tag - TAG_BUTTON_BASE)];
    }];
}
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _rootScrollView) {
        [self updateNavItemsColor];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==_rootScrollView) {
        int index = (int)(scrollView.contentOffset.x/K_SCREEN_WIDTH);
        [self viewControllerDidAppearWithIndex:index];
    }
}

-(void)updateNavItemsColor{
    
    
    int leftIndex = (int)(_rootScrollView.contentOffset.x/K_SCREEN_WIDTH);
    UIView* leftView=nil;
    if (leftIndex<0) {
        leftView=nil;
    }else{
        leftView=[_navItemsViews objectAtIndex:leftIndex];
    }
    
    //get suitable percent
    int tmpScale=1000;
    float leftPercent=((int)(_rootScrollView.contentOffset.x*tmpScale))%((int)(K_SCREEN_WIDTH*tmpScale))/((float)tmpScale)/K_SCREEN_WIDTH;
    
    int rightIndex = (int)(_rootScrollView.contentOffset.x/K_SCREEN_WIDTH)+1;
    UIView* rightView=nil;
    if (rightIndex>=_navItemsViews.count) {
        rightView=nil;
    }else{
        rightView=[_navItemsViews objectAtIndex:rightIndex];
    }
    float rightPercent=1-leftPercent;
    
    
    ((UILabel*)leftView).textColor=[UIColor gradient:leftPercent init:_tabItemSelectedColor goal:_tabItemNormalColor];
    ((UILabel*)leftView).transform= CGAffineTransformMakeScale( 1+(1-leftPercent)/5, 1+(1-leftPercent)/5);
    
    
    ((UILabel*)rightView).textColor=[UIColor gradient:rightPercent init:_tabItemSelectedColor goal:_tabItemNormalColor];
    ((UILabel*)rightView).transform= CGAffineTransformMakeScale( 1+(1-rightPercent)/5, 1+(1-rightPercent)/5);
    
    
    float shadowX=leftIndex*self.tabItemWidth + leftPercent* self.tabItemWidth;
    [_shadowImageView setFrame:CGRectMake(shadowX, 0, self.tabItemWidth, kHeightOfTopScrollView)];
}

@end
