//
//  EmailHOViewController.m
//  mSeller
//
//  Created by WCT iMac on 26/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "EmailHOViewController.h"
#import "EmailHOCell.h"
#import "MailOptionsViewController.h"

#define cornerRadious 5.0
#define bWidth 1.0
#define bColor [UIColor blackColor]

@interface EmailHOViewController ()<UITextFieldDelegate,MailOptionsViewControllerDelegate>{
    
    NSInteger quotelayoutid;
    NSArray *optionArr;
}

@property (weak, nonatomic) IBOutlet UITableView *tblEmailHeadOffice;
@end

@implementation EmailHOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    quotelayoutid=[[_oHeadInfo valueForKey:@"quotelayoutid"] integerValue];
    optionArr=@[@"Text",@"Small Photo",@"Large Photos",@"Offer Sheet",@"Csv File",@"Photo Excel"];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 3;
    }else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"EmailHOCell";
    
    EmailHOCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
            cell = [[EmailHOCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.selectionStyle = NO;
    [cell.lbldivider setHidden:YES];
    [cell.lblLayoutType setHidden:YES];
    [cell.emailSwitch setHidden:YES];
    
    if (indexPath.section==0){
        NSString *str=[_oHeadInfo valueForKey:@"emailaddress"];
        NSArray *emailArr=[str componentsSeparatedByString:@";"];
        
        
        if(indexPath.row==0) {
            cell.lblTitle.text=@"Cust Email1:";
            if ([emailArr count]>0) {
                cell.textTitlevalue.text= [emailArr objectAtIndex:indexPath.row];
            }else
                cell.textTitlevalue.text= [[_oHeadInfo valueForKey:@"customer"]valueForKey:@"emailaddress"];
            cell.accessoryType=UITableViewCellAccessoryNone;
        }else if (  indexPath.row==1){
            cell.lblTitle.text=@"Cust Email2:";
            if ([emailArr count]>1) {
                cell.textTitlevalue.text= [emailArr objectAtIndex:indexPath.row];
            }
            cell.accessoryType=UITableViewCellAccessoryNone;
        }else if ( indexPath.row==2){
            cell.lblTitle.text=@"Cust Email3:";
            if ([emailArr count]>2) {
                cell.textTitlevalue.text= [emailArr objectAtIndex:indexPath.row];
            }
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.section==1) {
       cell.lblTitle.text=@"Layout";
        if ([_oHeadInfo valueForKey:@"quotelayoutid"] !=nil) {
            cell.lblLayoutType.text=[optionArr objectAtIndex:[[_oHeadInfo valueForKey:@"quotelayoutid"] integerValue]];
        }else
            cell.lblTitle.text=@"Layout:";
        [cell.lbldivider setHidden:NO];
        [cell.lblLayoutType setHidden:NO];
        [cell.textTitlevalue setHidden:YES];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
        
    }
    else if (indexPath.section==2) {
        
        cell.lblTitle.text=@"Email Copy To Sales Rep:";
        cell.titleLayoutWith.constant=180;
        [cell.textTitlevalue setHidden:YES];
        [cell.emailSwitch setHidden:NO];
        
        [cell.emailSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.emailSwitch.tag = indexPath.row;
        [cell.emailSwitch setOn:[[_oHeadInfo valueForKey:@"emailrep"] isEqualToString:@"Y"]];
        
    }
    else if ( indexPath.section==3) {
        
        cell.lblTitle.text=@"Email Credit Application:";
        cell.titleLayoutWith.constant=180;
        [cell.emailSwitch setHidden:NO];
        
        [cell.emailSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.emailSwitch.tag = indexPath.row;
        [cell.emailSwitch setOn:[[_oHeadInfo valueForKey:@"Creditemail"] isEqualToString:@"Y"]];
        
        
    }
    
    return cell;
}


#pragma mark - TableView delegate methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section==1 && indexPath.row==0){
       
        MailOptionsViewController *mailOpt = [self.storyboard instantiateViewControllerWithIdentifier:@"MailOptionsViewController"];
        [mailOpt setDelegate:self];
        mailOpt.optionStatus=1;
        [mailOpt setIsEmailHOSts:YES];
        [self.navigationController pushViewController:mailOpt animated:YES];
        
    }
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

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)Saveclick:(id)sender {
//    NSDictionary *selDictionary;
//    [self.delegate saveClickWithOption:(NSDictionary*)selDictionary];
//    [self.navigationController popViewControllerAnimated:YES];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    EmailHOCell *cellE1=(EmailHOCell *)[_tblEmailHeadOffice cellForRowAtIndexPath:indexPath];
    
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    EmailHOCell *cellE2=(EmailHOCell *)[_tblEmailHeadOffice cellForRowAtIndexPath:indexPath];
     indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    EmailHOCell *cellE3=(EmailHOCell *)[_tblEmailHeadOffice cellForRowAtIndexPath:indexPath];
    
    NSString *str=@"";
    if (cellE1.textTitlevalue.text!=nil && [cellE1.textTitlevalue.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
        str=cellE1.textTitlevalue.text;
    if (cellE2.textTitlevalue.text!=nil && [cellE2.textTitlevalue.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
        str=str.length>0?[str stringByAppendingFormat:@";%@",cellE2.textTitlevalue.text]:cellE2.textTitlevalue.text;
    if (cellE3.textTitlevalue.text!=nil && [cellE3.textTitlevalue.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
        str=str.length>0?[str stringByAppendingFormat:@";%@",cellE3.textTitlevalue.text]:cellE3.textTitlevalue.text;
    
    
    
    
    indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    EmailHOCell *cell=(EmailHOCell *)[_tblEmailHeadOffice cellForRowAtIndexPath:indexPath];
    
    indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    EmailHOCell *cell2=(EmailHOCell *)[_tblEmailHeadOffice cellForRowAtIndexPath:indexPath];
    
    [_oHeadInfo setValue:[NSNumber numberWithInteger:quotelayoutid] forKey:@"quotelayoutid"];
    if ([cell.emailSwitch isOn]) {
        [_oHeadInfo setValue:@"Y" forKey:@"emailrep"];
    }else
        [_oHeadInfo setValue:@"N" forKey:@"emailrep"];
    
    if ([cell2.emailSwitch isOn]) {
        [_oHeadInfo setValue:@"Y" forKey:@"Creditemail"];
    }else
        [_oHeadInfo setValue:@"N" forKey:@"Creditemail"];
    
    
    [_oHeadInfo setValue:str forKey:@"emailaddress"];
    
    [_oHeadInfo setValue:@"Y" forKey:@"emailconfirm"];
    
    NSError *error = nil;
    if (![kAppDelegate.managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) switchChanged:(UISwitch *)sender
{
    
    
}


//Navigation Bar buttons
- (IBAction)cancelClicked:(id)sender {
    //[self.delegate cancelClickWithOption];
    
//    [_oHeadInfo setValue:[NSNumber numberWithInteger:0] forKey:@"quotelayoutid"];
//    [_oHeadInfo setValue:@"N" forKey:@"emailrep"];
//    [_oHeadInfo setValue:@"N" forKey:@"Creditemail"];
//    [_oHeadInfo setValue:@"" forKey:@"emailaddress"];
//    [_oHeadInfo setValue:@"N" forKey:@"emailconfirm"];

    [self.navigationController popViewControllerAnimated:YES];
}



-(IBAction)btnSwitchClicked:(UISwitch *)sender{
    
    
}//ENDed

//MailOptionsViewController delegate method
-(void)finished_LayoutWithOption:(NSDictionary*)retString{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    EmailHOCell *cell=(EmailHOCell *)[_tblEmailHeadOffice cellForRowAtIndexPath:indexPath];
    cell.lblLayoutType.text=[retString valueForKey:@"layout"];
    
    quotelayoutid=[[retString valueForKey:@"id"]integerValue];
    
}


@end
