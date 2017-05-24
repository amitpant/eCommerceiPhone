//
//  CustomerNewDeliveryAddressViewController.m
//  mSeller
//
//  Created by Ashish Pant on 11/16/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerNewDeliveryAddressViewController.h"

@interface CustomerNewDeliveryAddressViewController ()
{
    UITextField *activeField;
    NSMutableArray *arrCustDel_Address;
    NSString *strDeliveryID_ADD;
}
@property (weak, nonatomic) IBOutlet UIView *deliveryHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerCode;
@property (weak, nonatomic) IBOutlet UILabel *lblProductCode;
@property (weak, nonatomic) IBOutlet UILabel *lblTempCustomerID;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UILabel *lblLine1;
@property (weak, nonatomic) IBOutlet UITextField *line1Text;
@property (weak, nonatomic) IBOutlet UILabel *lblLine2;
@property (weak, nonatomic) IBOutlet UITextField *line2Text;
@property (weak, nonatomic) IBOutlet UILabel *lblLine3;
@property (weak, nonatomic) IBOutlet UITextField *line3Text;
@property (weak, nonatomic) IBOutlet UILabel *lblLine4;
@property (weak, nonatomic) IBOutlet UITextField *line4Text;
@property (weak, nonatomic) IBOutlet UILabel *lblLine5;
@property (weak, nonatomic) IBOutlet UITextField *line5Text;
@property (weak, nonatomic) IBOutlet UILabel *lblPcode;
@property (weak, nonatomic) IBOutlet UITextField *pcodeText;
@property (weak, nonatomic) IBOutlet UILabel *lblContact;
@property (weak, nonatomic) IBOutlet UITextField *contactText;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UILabel *lblFax;
@property (weak, nonatomic) IBOutlet UITextField *faxText;
@property (weak, nonatomic) IBOutlet UIScrollView *deliveryScrollView;

@end

@implementation CustomerNewDeliveryAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.lblCustomerCode.text=[self.customerInfo valueForKey:@"acc_ref"];
//
//    self.lblProductCode.text=[self.customerInfo valueForKey:@"name"];
//
//     self.lblTempCustomerID.text= [CommonHelper getNewDeliveryNumberWithRepId:kAppDelegate.repId CustomerId:self.lblCustomerCode.text];
//
    [kNSNotificationCenter
     addObserver:self
     selector:@selector (keyboardDidShow:)
     name: UIKeyboardDidShowNotification
     object:nil];
    [kNSNotificationCenter
     addObserver:self
     selector:@selector (keyboardWillBeHidden:)
     name: UIKeyboardDidHideNotification
     object:nil];
    
    if (_editStatus) {
        self.lblCustomerCode.text=[_customerDelivery valueForKey:@"acc_ref"];
        self.lblProductCode.text=[_customerDelivery valueForKey:@"name"];
        self.lblTempCustomerID.text=[_customerDelivery valueForKey:@"delivery_address"];//[CommonHelper getNewDeliveryNumberWithRepId:kAppDelegate.repId CustomerId:self.lblCustomerCode.text];

        [self  loadDeliverAddData:_customerDelivery];
    }else{
        
        self.lblCustomerCode.text=[self.customerInfo valueForKey:@"acc_ref"];
        self.lblProductCode.text=[self.customerInfo valueForKey:@"name"];
        self.lblTempCustomerID.text= [CommonHelper getNewDeliveryNumberWithRepId:kAppDelegate.repId CustomerId:self.lblCustomerCode.text];
        
 
    }
    
    //Tap anywhere in View keyboard dismiss
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self   action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.navigationController.navigationBar addGestureRecognizer:tap];
    [self.view addGestureRecognizer:tap];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.deliveryScrollView.contentSize = CGSizeMake(320, 425);
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];

    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
    
    
}
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _deliveryScrollView.contentInset = contentInsets;
    _deliveryScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
/*    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [_deliveryScrollView setContentOffset:scrollPoint animated:YES];
    }*/
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _deliveryScrollView.contentInset = contentInsets;
    _deliveryScrollView.scrollIndicatorInsets = contentInsets;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}
- (IBAction)cancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonClick:(id)sender {
    
    
    NSString* strCustomerName = [_nameText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([strCustomerName length]==0)
    {
        UIAlertView *av1=[[UIAlertView alloc] initWithTitle:@"Validation Error:" message:@"Please input customer name!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av1 show];
    }
    else
    {
        if (_editStatus)//update delivery info if this is a new delivery add in this ipad and not associated with any order
        {
            
            [_customerDelivery setValue: [self.nameText.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
            [_customerDelivery setValue:[self.line1Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr1"];
            [_customerDelivery setValue:[self.line2Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr2"];
            [_customerDelivery setValue:[self.line3Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr3"];
            [_customerDelivery setValue:[self.line4Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr4"];
            [_customerDelivery setValue: [self.line5Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr5"];
            [_customerDelivery setValue: [self.pcodeText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"postcode"];
            [_customerDelivery setValue:[self.contactText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"contact"];
            [_customerDelivery setValue: [self.phoneText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"phone"];
            [_customerDelivery setValue: [self.emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"emailaddress"];
            [_customerDelivery setValue: [self.faxText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"fax"];
            
            NSError *error = nil;
            // Save the object to persistent store
            if (![kAppDelegate.managedObjectContext save:&error]) {
                DebugLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        }else{
            arrCustDel_Address=[[NSMutableArray alloc]init];
            self.lblTempCustomerID.text= [CommonHelper getNewDeliveryNumberWithRepId:kAppDelegate.repId CustomerId:self.lblCustomerCode.text];
            NSManagedObject *deliveryAddress = [NSEntityDescription insertNewObjectForEntityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
            
            [deliveryAddress setValue: [self.nameText.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
            [deliveryAddress setValue:[self.line1Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr1"];
            [deliveryAddress setValue:[self.line2Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr2"];
            [deliveryAddress setValue:[self.line3Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr3"];
            [deliveryAddress setValue:[self.line4Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr4"];
            [deliveryAddress setValue: [self.line5Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr5"];
            [deliveryAddress setValue: [self.pcodeText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"postcode"];
            [deliveryAddress setValue:[self.contactText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"contact"];
            [deliveryAddress setValue: [self.phoneText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"phone"];
            [deliveryAddress setValue: [self.emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"emailaddress"];
            [deliveryAddress setValue: [self.faxText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"fax"];
            // [deliveryAddress setValue: [NSNumber numberWithBool:YES] forKey:@"iseditdeliveryaddress"];
            
            [deliveryAddress setValue:self.lblCustomerCode.text forKey:@"acc_ref"];
            [deliveryAddress setValue:[NSNumber numberWithBool:YES] forKey:@"isaddedondevice"];
            [deliveryAddress setValue:self.lblTempCustomerID.text forKey:@"delivery_address"];
            [deliveryAddress setValue:@"Y" forKey:@"newdeliveryaddr"];
            
            NSError *error = nil;
            // Save the object to persistent store
            if (![kAppDelegate.managedObjectContext save:&error]) {
                DebugLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        }
        
        NSString *strAddress;
        if (_line1Text.text.length>0) {
            if ([strAddress length]>0)
                strAddress=[strAddress stringByAppendingFormat:@", %@",_line1Text.text];
            else
                strAddress=_line1Text.text;
        }
        if (_line2Text.text.length>0) {
            if ([strAddress length]>0)
                strAddress=[strAddress stringByAppendingFormat:@", %@",_line2Text.text];
            else
                strAddress=_line2Text.text;

        }
        if (_line3Text.text.length>0) {
            if ([strAddress length]>0)
                strAddress=[strAddress stringByAppendingFormat:@", %@",_line3Text.text];
            else
                strAddress=_line3Text.text;
        }
        if (_line4Text.text.length>0) {
            if ([strAddress length]>0)
                strAddress=[strAddress stringByAppendingFormat:@", %@",_line4Text.text];
            else
                strAddress=_line4Text.text;

        }
        strDeliveryID_ADD=[NSString stringWithFormat:@"%@_%@",self.lblTempCustomerID.text,strAddress];
        
        [arrCustDel_Address addObject:strDeliveryID_ADD];

        if ([self.delegate respondsToSelector:@selector(finishNewDeliverySaveDone)]) {
            [self.delegate finishNewDeliverySaveDone];
            //[self.delegate finishedDeliverySaveDone:arrCustDel_Address];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)loadDeliverAddData:(NSManagedObject*)addObj{
    
    _nameText.text  =[addObj valueForKey:@"name"];
    _line1Text.text =[addObj valueForKey:@"addr1"];
    _line2Text.text =[addObj valueForKey:@"addr2"];
    _line3Text.text =[addObj valueForKey:@"addr3"];
    _line4Text.text =[addObj valueForKey:@"addr4"];
    _line5Text.text =[addObj valueForKey:@"addr5"];
    _pcodeText.text =[addObj valueForKey:@"postcode"];
    _contactText.text=[addObj valueForKey:@"contact"];
    _phoneText.text =[addObj valueForKey:@"phone"];
    _emailText.text =[addObj valueForKey:@"emailaddress"];
    _faxText.text   =[addObj valueForKey:@"fax"];
    _lblCustomerCode.text=[addObj valueForKey:@"acc_ref"];
    _lblTempCustomerID.text=[addObj valueForKey:@"delivery_address"];
    
}


-(void)dismissKeyboard:(UIGestureRecognizer*)tapGestureRecognizer {
    [[self view] endEditing:TRUE];
}

@end
