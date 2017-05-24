//
//  BaseContentViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 10/20/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "BaseContentViewController.h"
#import "CustomerDetailMultipleViewController.h"
@interface BaseContentViewController ()

@end

@implementation BaseContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)loadScrollEnable{
    //Manage pageviewController Swipe
    for (UIView *view in self.parentViewController.view.subviews ) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)view;
            scroll.scrollEnabled = YES;
        }
    }
    
    
}

-(void)loadLeft{
    [self.delegate loadSegment];
}

@end
