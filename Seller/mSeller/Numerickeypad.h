//
//  Numerickeypad.h
//  mSeller
//
//  Created by WCT iMac on 04/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumericKeypadDelegate <NSObject>
@optional
-(void)retuenkeyClickwithOption:(NSString *)values Button:(UIButton* )btn;
-(void)cancelkeyClick;
@end


@interface Numerickeypad : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtnumberpad;
@property (strong, nonatomic) UIButton *clickBtn;

- (IBAction)keyboard_click:(id)sender;

@property (nonatomic)id<NumericKeypadDelegate> delegate;

@end
