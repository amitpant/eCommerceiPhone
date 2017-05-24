//
//  AddNewCustomerViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 10/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddNewCustomerMultipleOptionViewController.h"

@interface AddNewCustomerViewController : UIViewController<AddNewCustomerMultipleOptionViewController,UITextFieldDelegate>
{
}
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIScrollView *addNewCustomerScrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnPriceBand;
@property (weak, nonatomic) IBOutlet UILabel *lblPriceBandCaption;
@property (weak, nonatomic) IBOutlet UIButton *btnCurrencyType;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrencyCaption;
@property (weak, nonatomic) IBOutlet UIButton *btnRepID;
@property (weak, nonatomic) IBOutlet UILabel *lblRepIDCaption;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldFax;
@property (weak, nonatomic) IBOutlet UILabel *lblFaxCaption;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailCaption;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldMobile;
@property (weak, nonatomic) IBOutlet UILabel *lblMobileCaption;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneCaption;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldContact;
@property (weak, nonatomic) IBOutlet UILabel *lblContactCaption;

@property (weak, nonatomic) IBOutlet UITextField *txtfieldPostCode;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldAddress3;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldAddress2;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldAddress1;
@property (weak, nonatomic) IBOutlet UILabel *lblAddressCaption;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldName;
@property (weak, nonatomic) IBOutlet UILabel *lblNameCaption;
@property (weak, nonatomic) IBOutlet UITextField *txtfieldAccount;
@property (weak, nonatomic) IBOutlet UILabel *lblAccountCaption;
-(IBAction)btncancel_Clicked:(UIBarButtonItem *)sender;
-(IBAction)repID_currencyType_priceBand_clicked:(UIButton *)sender;

@property (nonatomic, strong) NSManagedObject *customerInfo;
@property (nonatomic, assign) BOOL editStatus;
@end
