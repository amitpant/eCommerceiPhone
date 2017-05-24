//
//  StreetImageViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 12/18/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreetImageViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImage;
@property (weak, nonatomic) IBOutlet UIImageView *streetImageView;
@property (nonatomic, strong) NSString* strImagePath;
@end
