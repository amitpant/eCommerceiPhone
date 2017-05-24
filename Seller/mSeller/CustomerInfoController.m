//
//  CustomerInfoController.m
//  mSeller
//
//  Created by Ashish Pant on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CustomerInfoController.h"
#import <MessageUI/MessageUI.h>


@interface CustomerInfoController ()<UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>{
    NSArray *arrRows;
}
@property(nonatomic,weak)IBOutlet UITableView *custInfoTableView;

@end

@implementation CustomerInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.*/

    UIEdgeInsets inset = _custInfoTableView.separatorInset;
    inset.left = 10;
    _custInfoTableView.separatorInset = inset;
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    NSString *curr = [self.customerInfo valueForKey:@"curr"];
   
    NSArray *Arr=[[self.customerInfo valueForKey:@"iheads"]allObjects];
    //NSArray *ArrLine=[[Arr firstObject] valueForKey:@"invoicelines"];
 //   double lastinvoice=[[[Arr firstObject] valueForKey:@"invoicelines.@sum.sales_invoice_val"]doubleValue];
    NSManagedObject *mObj=[Arr firstObject];
     NSArray *Arr2=[[mObj valueForKey:@"invoicelines"]allObjects];
   __block double lastinvoice=0.0;
    [Arr2  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        lastinvoice +=[[obj valueForKey:@"sales_invoice_val"]doubleValue];
    }];
   
    
    
    Arr=[[self.customerInfo valueForKey:@"oheads"]allObjects];
    mObj=[Arr firstObject];
    Arr2=[[mObj valueForKey:@"orderlines"]allObjects];
    __block double lastOutStandingVal=0.0;
    [Arr2  enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        lastOutStandingVal +=[[obj valueForKey:@"price_ordered"]doubleValue];
    }];
    
    
    NSArray *arrCustOrder= [[self.customerInfo valueForKey:@"oheads"] allObjects];
    NSNumber *totalVal=[arrCustOrder valueForKeyPath:@"@sum.sales_ord_val_outst"];
                         
    NSDictionary *dic1=[[NSDictionary alloc]initWithObjectsAndKeys:@"Customer Code:",@"Value",[self.customerInfo valueForKey:@"acc_ref"],@"Detail", nil];
    NSDictionary *dic2=[[NSDictionary alloc]initWithObjectsAndKeys:@"Customer Name:",@"Value",[self.customerInfo valueForKey:@"name"],@"Detail", nil];
    NSDictionary *dic3=[[NSDictionary alloc]initWithObjectsAndKeys:@"Contact Name:",@"Value",[self.customerInfo valueForKey:@"contact"],@"Detail", nil];
    NSDictionary *dic4=[[NSDictionary alloc]initWithObjectsAndKeys:@"Phone Number:",@"Value",[self.customerInfo valueForKey:@"phone"],@"Detail", nil];
    NSDictionary *dic5=[[NSDictionary alloc]initWithObjectsAndKeys:@"Mobile Number:",@"Value",[self.customerInfo valueForKey:@"mobileno"],@"Detail", nil];
    NSDictionary *dic6=[[NSDictionary alloc]initWithObjectsAndKeys:@"Email Address:",@"Value",[self.customerInfo valueForKey:@"emailaddress"],@"Detail", nil];
    NSDictionary *dic7=[[NSDictionary alloc]initWithObjectsAndKeys:@"Currency Code:",@"Value",[self.customerInfo valueForKey:@"curr"],@"Detail", nil];
    NSDictionary *dic8=[[NSDictionary alloc]initWithObjectsAndKeys:@"Last Invoice:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:lastinvoice MaxFractionDigit:2],@"Detail", nil];
    NSDictionary *dic9=[[NSDictionary alloc]initWithObjectsAndKeys:@"Last Order:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:lastOutStandingVal MaxFractionDigit:2],@"Detail", nil];
    
    
    
    NSDictionary *dic10=[[NSDictionary alloc]initWithObjectsAndKeys:@"YTD Sales:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"ytd1"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    NSDictionary *dic11=[[NSDictionary alloc]initWithObjectsAndKeys:@"Outstanding Order Value:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[totalVal doubleValue] MaxFractionDigit:2],@"Detail", nil];
    NSDictionary *dic12=[[NSDictionary alloc]initWithObjectsAndKeys:@"Default Rep1:",@"Value",[self.customerInfo valueForKey:@"rep1"],@"Detail", nil];
    NSDictionary *dic13=[[NSDictionary alloc]initWithObjectsAndKeys:@"Rep2:",@"Value",[self.customerInfo valueForKey:@"rep2"],@"Detail", nil];
    NSDictionary *dic14=[[NSDictionary alloc]initWithObjectsAndKeys:@"Area:",@"Value",[self.customerInfo valueForKey:@"area"],@"Detail", nil];
    NSDictionary *dic15=[[NSDictionary alloc]initWithObjectsAndKeys:@"Customer Type:",@"Value",[self.customerInfo valueForKey:@"cust_shortname"],@"Detail", nil];
    NSDictionary *dic16=[[NSDictionary alloc]initWithObjectsAndKeys:@"Price List:",@"Value",[self.customerInfo valueForKey:@"pricegroup"],@"Detail", nil];
    NSDictionary *dic17=[[NSDictionary alloc]initWithObjectsAndKeys:@"Customer Group:",@"Value",[self.customerInfo valueForKey:@"cusgroup"],@"Detail", nil];
    NSDictionary *dic18=[[NSDictionary alloc]initWithObjectsAndKeys:@"Credit Limit:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"credit_limit"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    NSDictionary *dic19=[[NSDictionary alloc]initWithObjectsAndKeys:@"Current Balance:",@"Value",[CommonHelper  getCurrencyFormatWithCurrency:curr Value:[[self.customerInfo valueForKey:@"total_bal"] doubleValue] MaxFractionDigit:2],@"Detail", nil];
    
    arrRows=[NSArray arrayWithObjects:dic1,dic2,dic3,dic4,dic5,dic6,dic7,dic8,dic9,dic10,dic11,dic12,dic13,dic14,dic15,dic16,dic17,dic18,dic19, nil];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadScrollEnable];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [arrRows count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier=@"CustomerInfoTableViewCell";
    CustomerInfoTableViewCell *cell=(CustomerInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.lblFirstHeading.text =[[arrRows objectAtIndex:indexPath.row]objectForKey:@"Value"];
    cell.lblSecondHeading.text=[[arrRows objectAtIndex:indexPath.row]objectForKey:@"Detail"];
    
    if (indexPath.row==5) {
        [cell.lblSecondHeading setTextColor:[UIColor blueColor]];
        if ([CommonHelper IsValidEmail:cell.lblSecondHeading.text]) {
            UITapGestureRecognizer *singleFingerEmailTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [singleFingerEmailTap setDelegate:self];
            [cell.contentView addGestureRecognizer:singleFingerEmailTap];
        }
    }else
        [cell.lblSecondHeading setTextColor:[UIColor blackColor]];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    DebugLog(@"Open Mail");
    //Do stuff here...
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    [mailer setDelegate:self];
    [mailer setSubject:@""];
    NSString *to=[self.customerInfo valueForKey:@"emailaddress"];
    
    NSArray *toRecipients = [to componentsSeparatedByString:@";"];
    
    if([toRecipients count]>0)
        [mailer setToRecipients:toRecipients];
    if([[self repEmailAdd] length]>0){
        
            [mailer setCcRecipients:[[self repEmailAdd]componentsSeparatedByString:@","]];
    }
    
    mailer.modalPresentationStyle = UIModalPresentationPageSheet;
    [mailer setMessageBody:[NSString stringWithFormat:@"Dear %@\n",[self.customerInfo valueForKey:@"contact"]] isHTML:NO];
    [self presentViewController:mailer animated:YES completion:nil];
    
}

#pragma mark - MFMailComposeController delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //   DebugLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
            break;
        case MFMailComposeResultSaved:
            //   DebugLog(@"Mail saved: you saved the email message in the Drafts folder");
            break;
        case MFMailComposeResultSent:
            //   DebugLog(@"Mail send: the email message is queued in the outbox");
            break;
        case MFMailComposeResultFailed:
            //   DebugLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
            break;
        default:
            //   DebugLog(@"Mail not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(NSString*)repEmailAdd{
    
    NSString *emailAdd=@"";
    @try{
        NSDictionary *dic =  [CommonHelper loadFileDataWithVirtualFilePath:CompanyUsersFileName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@ && password==%@ ",[kUserDefaults  objectForKey:@"username"],[kUserDefaults  objectForKey:@"password"]];//&& repid==%@
        NSArray *filteredArray = [[[dic objectForKey:@"data"] objectForKey:@"users"] filteredArrayUsingPredicate:predicate];
        emailAdd=[[filteredArray lastObject]valueForKey:@"email"] ;
    }@catch (NSException *exception) {
        //   DebugLog(@"%@",exception);
    }
    
    @finally
    {
        
    }
    return emailAdd;
}




@end
