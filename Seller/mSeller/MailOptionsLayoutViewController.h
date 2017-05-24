//
//  MailOptionsLayoutViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailOptionsLayoutViewController : UIViewController
{
}
@property(weak,nonatomic)IBOutlet UITableView *tblLayout;
@property(readwrite,nonatomic) NSInteger optionStatus;

@end
