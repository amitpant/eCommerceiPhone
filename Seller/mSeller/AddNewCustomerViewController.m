//
//  AddNewCustomerViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 10/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "AddNewCustomerViewController.h"

@interface AddNewCustomerViewController ()
{
    NSInteger optionSelected;
    UITextField *activeField;
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    NSDictionary *featureDict;
    
}
@property (weak, nonatomic) IBOutlet UILabel *lblpricebandMandatoryStar;
@property (weak, nonatomic) IBOutlet UIButton *btnOverlay;
- (IBAction)dismissKeyboard:(id)sender;


@end

@implementation AddNewCustomerViewController



#pragma mark - Custom Methods
-(void)reloadConfigData{
    //  Mahendra fetch Feature config
    featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];
    
    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    
    
    if (([[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"IsPriceBand"] boolValue])) {
        [_lblpricebandMandatoryStar setHidden:NO];
    }else
        [_lblpricebandMandatoryStar setHidden:YES];
    
    
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.navigationItem.hidesBackButton=YES;
    
    
    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    //END
    
    
    
    
    
    self.txtfieldFax.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.txtfieldPhone.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.txtfieldMobile.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    self.txtfieldPostCode.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    //Set the contentHorizontalAlignment
    _btnRepID.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _btnCurrencyType.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _btnPriceBand.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //adjust the content left inset otherwise the text will touch the left border
    
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
    

    
    UITapGestureRecognizer *tapOnbtnRepID = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    UITapGestureRecognizer *tapOnbtnCurrencyType = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    UITapGestureRecognizer *tapOnbtnPriceBand = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    tapOnbtnRepID.cancelsTouchesInView = NO;
    tapOnbtnCurrencyType.cancelsTouchesInView = NO;
    tapOnbtnPriceBand.cancelsTouchesInView = NO;
    
    [_btnRepID addGestureRecognizer:tapOnbtnRepID];
    [_btnCurrencyType addGestureRecognizer:tapOnbtnCurrencyType];
    [_btnPriceBand addGestureRecognizer:tapOnbtnPriceBand];
    
    if (_editStatus) {
        [self  loadEditCustomer:_customerInfo];
    }else  {
        [CommonHelper getNewCustomerNumberWithRepId:kAppDelegate.repId Company:kAppDelegate.selectedCompanyId CompletionBlock:^(NSString * _Nullable newcustomernumber) {
            _txtfieldAccount.text = newcustomernumber;
        }];
    }
    
    //Tap anywhere in View keyboard dismiss
    [self.navigationController.navigationBar addGestureRecognizer:tapOnbtnPriceBand];
    [self.view addGestureRecognizer:tapOnbtnPriceBand];
}

-(void)loadEditCustomer:(NSManagedObject*)addObj{
    
    [_btnPriceBand setTitle:[addObj valueForKey:@"pricegroup"] forState:UIControlStateNormal];
    [_btnCurrencyType setTitle:[addObj valueForKey:@"curr"] forState:UIControlStateNormal];
    [_btnRepID setTitle:[addObj valueForKey:@"rep1"] forState:UIControlStateNormal];

    _txtfieldFax.text=[addObj valueForKey:@"fax"];
    _txtfieldEmail.text=[addObj valueForKey:@"emailaddress"];
    _txtfieldMobile.text=[addObj valueForKey:@"mobileno"];
    _txtfieldPhone.text=[addObj valueForKey:@"phone"];
    _txtfieldContact.text=[addObj valueForKey:@"contact"];
    _txtfieldPostCode.text=[addObj valueForKey:@"postcode"];
    _txtfieldAddress3.text=[addObj valueForKey:@"addr3"];
    _txtfieldAddress2.text=[addObj valueForKey:@"addr2"];
    _txtfieldAddress1.text=[addObj valueForKey:@"addr1"];
    _txtFieldName.text=[addObj valueForKey:@"name"];
    _txtfieldAccount.text=[addObj valueForKey:@"acc_ref"];
    
}

-(void)dismissKeyboard:(UIGestureRecognizer*)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    _addNewCustomerScrollView.contentSize=CGSizeMake(320, 485);
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btncancel_Clicked:(UIBarButtonItem *)sender
{
    if (sender.tag==1) {
        NSString* strCustomerName = [_txtFieldName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([[_txtfieldAccount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0)
        {
            UIAlertView *av1=[[UIAlertView alloc] initWithTitle:@"Validation Error:" message:@"Please fill up Customer Code" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av1 setTag:3];
            [av1 show];
        }
        else  if([strCustomerName length]==0)
        {
            UIAlertView *av1=[[UIAlertView alloc] initWithTitle:@"Validation Error:" message:@"Please input customer name!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av1 setTag:4];
            [av1 show];
        }
        else  if([[_btnRepID.titleLabel.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0)
        {
            UIAlertView *av1=[[UIAlertView alloc] initWithTitle:@"Validation Error:" message:@"Please select rep id!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av1 setTag:5];
            [av1 show];
        }
        else  if([[_btnCurrencyType.titleLabel.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0)
        {
            UIAlertView *av1=[[UIAlertView alloc] initWithTitle:@"Validation Error:" message:@"Please select currency" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av1 setTag:6];
            [av1 show];
        }
        else  if([_btnPriceBand.titleLabel.text length]==0 && ([[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"IsPriceBand"] boolValue]))
        {
            //price band mendatory field depend on web config key IsPriceBand
            UIAlertView *av1=[[UIAlertView alloc] initWithTitle:@"Validation Error:" message:@"Please select price band!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av1 setTag:7];
            [av1 show];
        }

        else{
            
            if (_editStatus) {//update delivery info if is is a new delivery add in this ipad and not associated with any order
                
                [_customerInfo setValue:[_txtfieldAccount.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"acc_ref"];
                [_customerInfo setValue: [_txtFieldName.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
                [_customerInfo setValue:[_txtfieldAddress1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr1"];
                [_customerInfo setValue:[_txtfieldAddress2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr2"];
                [_customerInfo setValue:[_txtfieldAddress3.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr3"];
                [_customerInfo setValue: [_txtfieldPostCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"postcode"];
                [_customerInfo setValue:[_txtfieldContact.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"contact"];
                [_customerInfo setValue: [_txtfieldPhone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"phone"];
                [_customerInfo setValue: [_txtfieldMobile.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"mobileno"];
                [_customerInfo setValue: [_txtfieldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"emailaddress"];
                [_customerInfo setValue: [_txtfieldFax.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"fax"];
                [_customerInfo setValue:[_btnRepID.titleLabel.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"rep1"];
                [_customerInfo setValue:[_btnCurrencyType.titleLabel.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"curr"];
                [_customerInfo setValue:[_btnPriceBand.titleLabel.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"pricegroup"];
                
                /*[newCustomer setValue:@"000" forKey:@"delivery_address"];
                [newCustomer setValue:@"Y" forKey:@"isnew"];
                [newCustomer setValue:[NSNumber numberWithBool:YES] forKey:@"isaddedondevice"];*/
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![kAppDelegate.managedObjectContext save:&error]) {
                    DebugLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
                else
                    [self.navigationController popViewControllerAnimated:YES];
            }else{
                [CommonHelper getNewCustomerNumberWithRepId:kAppDelegate.repId Company:kAppDelegate.selectedCompanyId CompletionBlock:^(NSString * _Nullable newcustomernumber) {
                    _txtfieldAccount.text = newcustomernumber;
                    
                    NSManagedObject *newCustomer = [NSEntityDescription insertNewObjectForEntityForName:@"CUST" inManagedObjectContext:kAppDelegate.managedObjectContext];
                    
                    [newCustomer setValue:[_txtfieldAccount.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"acc_ref"];
                    [newCustomer setValue: [_txtFieldName.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
                    [newCustomer setValue:[_txtfieldAddress1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr1"];
                    [newCustomer setValue:[_txtfieldAddress2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr2"];
                    [newCustomer setValue:[_txtfieldAddress3.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"addr3"];
                    [newCustomer setValue: [_txtfieldPostCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"postcode"];
                    [newCustomer setValue:[_txtfieldContact.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"contact"];
                    [newCustomer setValue: [_txtfieldPhone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"phone"];
                    [newCustomer setValue: [_txtfieldMobile.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"mobileno"];
                    [newCustomer setValue: [_txtfieldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"emailaddress"];
                    [newCustomer setValue: [_txtfieldFax.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"fax"];
                    [newCustomer setValue:[_btnRepID.titleLabel.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"rep1"];
                    [newCustomer setValue:[_btnCurrencyType.titleLabel.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"curr"];
                    [newCustomer setValue:[_btnPriceBand.titleLabel.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"pricegroup"];
                  //  [newCustomer setValue:[NSNumber numberWithBool:YES] forKey:@"iseditdeliveryaddress"];
                    
                    
                    [newCustomer setValue:@"000" forKey:@"delivery_address"];
                    [newCustomer setValue:@"Y" forKey:@"isnew"];
                    [newCustomer setValue:[NSNumber numberWithBool:YES] forKey:@"isaddedondevice"];
                    
                    NSError *error = nil;
                    // Save the object to persistent store
                    if (![kAppDelegate.managedObjectContext save:&error]) {
                        DebugLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                    }
                    else
                        [self.navigationController popViewControllerAnimated:YES];
                
                    
                    
                    if([CommonHelper checkIfCustomerNoAlreadyExistWithCustomerNo:newcustomernumber]){
                        NSInteger nextCustseq = [[newcustomernumber substringFromIndex:[kAppDelegate.repId length]+1] integerValue];
                        [CommonHelper setNextCustomerNumberWithRepId:kAppDelegate.repId CompanyId:kAppDelegate.selectedCompanyId NextCustomerSequence:nextCustseq+1];
                        
                    }
                    
                    
                }];
            }
        }
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag]==4 && buttonIndex == 0) {
        [_txtFieldName becomeFirstResponder];
    }else if([alertView tag]==5 && buttonIndex == 0){
        
    }
    
}



-(IBAction)repID_currencyType_priceBand_clicked:(UIButton *)sender
{
    if ([sender tag]==1)
        optionSelected=1;
    else if ([sender tag]==2)
        optionSelected=2;
    else
        optionSelected=3;
    
    [self performSegueWithIdentifier:@"toAddNewCustomerMultipleOptionViewController" sender:self];
    
}

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
         [_btnOverlay setHidden:YES];
    }
    return NO; // We do not want UITextField to insert line-breaks.


}

- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _addNewCustomerScrollView.contentInset = contentInsets;
    _addNewCustomerScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = _viewMain.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [_addNewCustomerScrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _addNewCustomerScrollView.contentInset = contentInsets;
    _addNewCustomerScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_btnOverlay setHidden:NO];
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

#pragma mark - AddNewCustomerMultipleOptionViewController Delegate
-(void)selectedIndexValue:(NSString *)selectedValue Option:(NSInteger)option
{
    if (option==1)
        [_btnRepID setTitle:selectedValue forState:UIControlStateNormal];
    else if (option==2)
        [_btnCurrencyType setTitle:selectedValue forState:UIControlStateNormal];
    else if (option==3)
        [_btnPriceBand setTitle:selectedValue forState:UIControlStateNormal];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toAddNewCustomerMultipleOptionViewController"]) {
        AddNewCustomerMultipleOptionViewController *addNewCustomerMultipleOptionViewController = segue.destinationViewController;
        addNewCustomerMultipleOptionViewController.selectedOption=optionSelected;
        addNewCustomerMultipleOptionViewController.delegate=self;
    }

}


/*- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:TRUE];
    [_btnOverlay setHidden:YES];
}*/
@end
