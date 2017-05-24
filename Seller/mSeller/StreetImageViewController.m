//
//  StreetImageViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 12/18/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "StreetImageViewController.h"

@interface StreetImageViewController ()

@end

@implementation StreetImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _scrollViewImage.delegate=self;
    _streetImageView.image=[UIImage imageWithContentsOfFile:_strImagePath];
}
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  _streetImageView;
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
