//
//  CustomerTaskViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 10/20/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerTaskViewController.h"

@interface CustomerTaskViewController ()

@end

@implementation CustomerTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadScrollEnable];
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

@end
