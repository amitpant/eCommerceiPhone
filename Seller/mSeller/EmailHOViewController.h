//
//  EmailHOViewController.h
//  mSeller
//
//  Created by WCT iMac on 26/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmailHOViewControllerDelegate <NSObject>
@optional
-(void)saveClickWithOption:(NSDictionary*)selDictionary;
-(void)cancelClickWithOption;
@end

@interface EmailHOViewController : UIViewController

@property(weak,nonatomic) id<EmailHOViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObject *oHeadInfo;

- (IBAction)Saveclick:(id)sender;

@end
