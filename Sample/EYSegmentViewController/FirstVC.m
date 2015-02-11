//
//  FirstVC.m
//  EYSegmentViewController
//
//  Created by ericyang on 2/11/15.
//  Copyright (c) 2015 www.appcpu.com. All rights reserved.
//

#import "FirstVC.h"
#import "SecondVC.h"
#import "ViewController.h"

@interface FirstVC ()

@end

@implementation FirstVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = COLORRGB(0x339933);
    self.navigationController.navigationBar.translucent = NO;
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBar.titleTextAttributes =
    @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    UIButton* bt=[UIButton buttonWithType:UIButtonTypeSystem];
    [bt setTitle:@"next view" forState:UIControlStateNormal];
    bt.frame=CGRectMake(100, 100, 100, 50);
    [bt addTarget:self action:@selector(forwardNextVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)forwardNextVC:(id)sender{
    NSMutableArray* vcs=[NSMutableArray new];
    for (int i=0; i<10; i++) {
        ViewController* vc=[[ViewController alloc]init];
        vc.title=[NSString stringWithFormat:@"vc %d",i];
        [vcs addObject:vc];
    }

    SecondVC* segVC=[[SecondVC alloc] initWithViewControllers:vcs];
    
    NSMutableArray* dots=[NSMutableArray new];
    for (int i=0; i<10; i++) {
        [dots addObject:[NSNumber numberWithInt:(i-2)]];
    }
    [segVC setDotItems:dots];
    
    [self.navigationController pushViewController:segVC animated:YES];
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
