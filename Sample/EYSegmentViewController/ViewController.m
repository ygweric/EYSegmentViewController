//
//  ViewController.m
//  EYSegmentViewController
//
//  Created by ericyang on 2/11/15.
//  Copyright (c) 2015 www.appcpu.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
    lb.textColor=[UIColor blueColor];
    lb.backgroundColor=[UIColor clearColor];
    [self.view addSubview:lb];
    lb.text=self.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
