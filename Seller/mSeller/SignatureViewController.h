//
//  SignatureViewController.h
//  mSeller
//
//  Created by WCT iMac on 25/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignView.h"


@interface SignatureViewController : UIViewController{
     SignView *signView;
}
@property (nonatomic,strong) NSString* ordnumber;
@property (weak, nonatomic) IBOutlet UIView *signatureView;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIImageView *signImgView;
@end
