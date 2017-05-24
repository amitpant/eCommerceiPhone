//
//  MailOptionsViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol MailOptionsViewControllerDelegate <NSObject>
@optional
-(void)finished_LayoutWithOption:(NSDictionary*)retString;
@end


@interface MailOptionsViewController : UIViewController<MFMailComposeViewControllerDelegate,UIPrintInteractionControllerDelegate>
{

}
@property(weak,nonatomic)IBOutlet UIBarButtonItem *btnSend;
@property(weak,nonatomic)IBOutlet UITableView *tblMailOptions;
@property(readwrite,nonatomic) NSInteger optionStatus;
@property (nonatomic,strong) NSManagedObject *Headrecorddata;
@property(nonatomic,unsafe_unretained) NSInteger selectedOption;
@property (nonatomic,strong) NSString *selStr;

@property (nonatomic,assign) BOOL isEmailHOSts;
@property(weak,nonatomic) id<MailOptionsViewControllerDelegate> delegate;

@end
