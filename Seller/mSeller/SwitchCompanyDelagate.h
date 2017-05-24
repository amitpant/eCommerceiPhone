//
//  SwitchCompanyDelagate.h
//  mSeller
//
//  Created by Satish Kr Singh on 06/10/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SwitchCompanyDelagate <NSObject>
@optional
-(void)loadingOfCompanyUsersFinishedSuccessfully:(BOOL)issuccessful Error:(nullable NSString *)error;
-(void)ConfigDownloadFinishedSuccessfully:(BOOL)issuccessful Error:(nullable NSString *)error;
@end
