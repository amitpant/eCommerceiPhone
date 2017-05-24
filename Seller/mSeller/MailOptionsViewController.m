//
//  MailOptionsViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "MailOptionsViewController.h"
#import "OrderFormats.h"
#import "MailOpCell.h"


@interface MailOptionsViewController ()<MailOptionsViewControllerDelegate>{
    NSArray*  optionArray;
    NSMutableArray *arrPdfSetting;

}

@end

@implementation MailOptionsViewController
@synthesize optionStatus,btnSend;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // self.navigationItem.hidesBackButton=YES;
    arrPdfSetting=[[NSMutableArray alloc] init];
    if (_selectedOption==0)
    {
    self.title=NSLocalizedString(@"Mail Options", @"Mail Options");
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];
    }
    else
    {
        self.title=NSLocalizedString(@"Print Options", @"Print Options");
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStylePlain target:self action:@selector(barBtnClick:)];
    }
    
    self.tblMailOptions.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tblMailOptions.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
    
    if (optionStatus==0){
        optionArray=@[@"Layout Type",@"Sort By",@"With Values",@"Include T&C file"];
    }else if (optionStatus==1){
        self.title=@"Layout";
       [self.navigationItem setRightBarButtonItems:nil animated:NO];
        optionArray=@[@"Text",@"Small Photo",@"Large Photos",@"Offer Sheet",@"Csv File",@"Photo Excel"];
    }else if (optionStatus==2){
        self.title=@"Sort By";
        [self.navigationItem setRightBarButtonItems:nil animated:NO];
        optionArray=@[@"Entered Sequence",@"Numeric",@"Alphabetic"];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}
-(IBAction)barBtnClick:(UIBarButtonItem *)sender
{
    DebugLog(@"Arr %@",arrPdfSetting);
    //code added by Amit pant 20160209
    BOOL blincludeNewForm=0;
    BOOL isNewCust=0;
    BOOL isNewCustFileExist = 0;
    int includetc=0;
    int seloption = 0;//cvc.SelectedOption;
    int selformat = 0;//cvc.SelectedLayout;
    int selvalidx = 1;//cvc.blActionWithValue;
    int selsortidx = 0;//cvc.SelectedSortBy;
    NSMutableData* emailData;
    
    if ([[arrPdfSetting objectAtIndex:0] isEqualToString:@"Text"]) {
        if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Entered Sequence"])
            selsortidx=0;
       else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Numeric"])
        selsortidx=1;
       else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Alphabetic"])
           selsortidx=2;
        if ([[arrPdfSetting objectAtIndex:2] isEqualToNumber:[NSNumber numberWithInt:0]])
            selvalidx=0;
        else
            selvalidx=1;
        if ([[arrPdfSetting objectAtIndex:3] isEqualToNumber:[NSNumber numberWithInt:0]])
            includetc=0;
        else
            includetc=1;

        
        emailData = [OrderFormats CreateOrderFormat:self.Headrecorddata Format:OrderTextFormat SortIndex:selsortidx ValueIndex:selvalidx];
   
    }
    else if ([[arrPdfSetting objectAtIndex:0] isEqualToString:@"Small Photo"])
    {
        if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Entered Sequence"])
            selsortidx=0;
        else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Numeric"])
            selsortidx=1;
        else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Alphabetic"])
            selsortidx=2;
        if ([[arrPdfSetting objectAtIndex:2] isEqualToNumber:[NSNumber numberWithInt:0]])
            selvalidx=0;
        else
            selvalidx=1;
        if ([[arrPdfSetting objectAtIndex:3] isEqualToNumber:[NSNumber numberWithInt:0]])
            includetc=0;
        else
            includetc=1;


        emailData = [OrderFormats CreateOrderFormat:self.Headrecorddata Format:OrderSmallPhotos SortIndex:selsortidx ValueIndex:selvalidx];

    }
    else if ([[arrPdfSetting objectAtIndex:0] isEqualToString:@"Large Photos"])
    {
        if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Entered Sequence"])
            selsortidx=0;
        else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Numeric"])
            selsortidx=1;
        else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Alphabetic"])
            selsortidx=2;
        if ([[arrPdfSetting objectAtIndex:2] isEqualToNumber:[NSNumber numberWithInt:0]])
            selvalidx=0;
        else
            selvalidx=1;
        if ([[arrPdfSetting objectAtIndex:3] isEqualToNumber:[NSNumber numberWithInt:0]])
            includetc=0;
        else
            includetc=1;


        emailData = [OrderFormats CreateOrderFormat:self.Headrecorddata Format:OrderLargePhotos SortIndex:selsortidx ValueIndex:selvalidx];

    }
    else if ([[arrPdfSetting objectAtIndex:0] isEqualToString:@"Offer Sheet"])
    {
      /*  if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Entered Sequence"])
            selsortidx=0;
        else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Numeric"])
            selsortidx=1;
        else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Alphabetic"])
            selsortidx=2;
        if ([arrPdfSetting objectAtIndex:2]==0)
            selvalidx=0;
        else
            selvalidx=1;
        if ([arrPdfSetting objectAtIndex:3]==0)
            includetc=0;
        else
            includetc=1;


        emailData = [OrderFormats CreateOrderFormat:self.Headrecorddata Format:OrderOfferSheet SortIndex:selsortidx ValueIndex:selvalidx];*/
        
    }
    else if ([[arrPdfSetting objectAtIndex:0] isEqualToString:@"Csv File"] && [sender.title isEqualToString:@"Send"])
    {
        if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Entered Sequence"])
            selsortidx=0;
        else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Numeric"])
            selsortidx=1;
        else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Alphabetic"])
            selsortidx=2;
        if ([[arrPdfSetting objectAtIndex:2] isEqualToNumber:[NSNumber numberWithInt:0]])
            selvalidx=0;
        else
            selvalidx=1;
        if ([[arrPdfSetting objectAtIndex:3] isEqualToNumber:[NSNumber numberWithInt:0]])
            includetc=0;
        else
            includetc=1;


        emailData = [OrderFormats CreateOrderFormat:self.Headrecorddata Format:OrderCSVFile SortIndex:selsortidx ValueIndex:selvalidx];
        
    }
    else if ([[arrPdfSetting objectAtIndex:0] isEqualToString:@"Photo Excel"])
   {
    /*   if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Entered Sequence"])
           selsortidx=0;
       else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Numeric"])
           selsortidx=1;
       else if ([[arrPdfSetting objectAtIndex:1] isEqualToString:@"Alphabetic"])
           selsortidx=2;
       if ([arrPdfSetting objectAtIndex:2]==0)
           selvalidx=0;
       else
           selvalidx=1;
       if ([arrPdfSetting objectAtIndex:3]==0)
           includetc=0;
       else
           includetc=1;

    emailData = [OrderFormats CreateOrderFormat:self.Headrecorddata Format:OrderPhotoExcel SortIndex:selsortidx ValueIndex:selvalidx];*/
    

   }
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;

    NSString* strbrochurepath=[[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/brochure",(long)kAppDelegate.selectedCompanyId];
    
    NSDictionary* companyConfigDict;
    NSString *strTandC;
    NSString* strNewForm;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    if (isNewCustFileExist) {
       strNewForm= [[companyConfigDict valueForKey:@"associatedpathinfo"] valueForKey:@"termsandconditionfilename"];
    }
    if(isNewCust &&  [strNewForm length]>0 && [[NSFileManager defaultManager] fileExistsAtPath:[strbrochurepath stringByAppendingPathComponent:strNewForm]])
    {
        isNewCustFileExist = YES;
        blincludeNewForm=YES;
        
    }

    if (includetc) {
        strTandC=[[companyConfigDict valueForKey:@"associatedpathinfo"] valueForKey:@"termsandconditionfilename"];
        if([strTandC length]>0){
            NSString* pdfPath2 = [strbrochurepath stringByAppendingPathComponent:strTandC];
            //Embed_transaction_pdf
            if([[companyConfigDict valueForKey:@"Embed_transaction_pdf"] boolValue] && [[strTandC pathExtension] isEqualToString:@"pdf"]){
    NSString* pdfPath1 = [strbrochurepath stringByAppendingPathComponent:[[self.Headrecorddata valueForKey:@"orderid"] stringByAppendingPathExtension:@"pdf"]];
                [emailData writeToFile:pdfPath1 atomically:NO];
                
                NSString* pdfPathOutput = [strbrochurepath stringByAppendingPathComponent:[[[self.Headrecorddata valueForKey:@"orderid"] stringByAppendingPathExtension:@"_new"] stringByAppendingPathExtension:@"pdf"]];
                
                // File URLs
                CFURLRef pdfURL1 = (__bridge_retained CFURLRef)[[NSURL alloc] initFileURLWithPath:pdfPath1];
                CFURLRef pdfURL2 = (__bridge_retained CFURLRef)[[NSURL alloc] initFileURLWithPath:pdfPath2];
                CFURLRef pdfURLOutput = (__bridge_retained CFURLRef)[[NSURL alloc] initFileURLWithPath:pdfPathOutput];
                
                CGPDFDocumentRef pdfRef1 = CGPDFDocumentCreateWithURL((CFURLRef) pdfURL1);
                CGPDFDocumentRef pdfRef2 = CGPDFDocumentCreateWithURL((CFURLRef) pdfURL2);
                
                // Number of pages
                NSInteger numberOfPages1 = CGPDFDocumentGetNumberOfPages(pdfRef1);
                NSInteger numberOfPages2 = CGPDFDocumentGetNumberOfPages(pdfRef2);
                
                // Create the output context
                CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);
                
                // Loop variables
                CGPDFPageRef page;
                CGRect mediaBox;
                
                // Read the first PDF and generate the output pages
                //DebugLog(@"Pages from pdf 1 (%i)", numberOfPages1);
                for (int i=1; i<=numberOfPages1; i++) {
                    page = CGPDFDocumentGetPage(pdfRef1, i);
                    mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
                    CGContextBeginPage(writeContext, &mediaBox);
                    CGContextDrawPDFPage(writeContext, page);
                    CGContextEndPage(writeContext);
                }
                
                // Read the second PDF and generate the output pages
                //DebugLog(@"Pages from pdf 2 (%i)", numberOfPages2);
                for (int i=1; i<=numberOfPages2; i++) {
                    page = CGPDFDocumentGetPage(pdfRef2, i);
                    mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
                    CGContextBeginPage(writeContext, &mediaBox);
                    CGContextDrawPDFPage(writeContext, page);
                    CGContextEndPage(writeContext);
                }
                //DebugLog(@"Done");
                
                // Finalize the output file
                CGPDFContextClose(writeContext);
                
                // Release from memory
                CFRelease(pdfURL1);
                CFRelease(pdfURL2);
                CFRelease(pdfURLOutput);
                CGPDFDocumentRelease(pdfRef1);
                CGPDFDocumentRelease(pdfRef2);
                CGContextRelease(writeContext);
                
                emailData = [NSMutableData dataWithContentsOfFile:pdfPathOutput];
                [[NSFileManager defaultManager] removeItemAtPath:pdfPath1 error:NULL];
                //                    [[NSFileManager defaultManager] removeItemAtPath:pdfPath2 error:NULL];
                [[NSFileManager defaultManager] removeItemAtPath:pdfPathOutput error:NULL];
            }
            else
            {
                NSMutableData *dataAppForm = [NSMutableData dataWithContentsOfFile:pdfPath2];
                if (dataAppForm !=nil && [dataAppForm length]>1){
                    if([[strTandC pathExtension] isEqualToString:@"pdf"])
                        [mailComposer addAttachmentData:dataAppForm mimeType:@"application/pdf" fileName:strTandC];
                    else
                        [mailComposer addAttachmentData:dataAppForm mimeType:[NSString stringWithFormat:@"text/%@",[strTandC pathExtension]] fileName:strTandC];
                }
            }
        }

    }


    if ([sender.title isEqualToString:@"Send"]) {
        if ([MFMailComposeViewController canSendMail])
        {
            
            //code ended here
            [mailComposer setToRecipients:[NSArray arrayWithObjects: [self.Headrecorddata valueForKey:@"emailaddress"],nil]];

            
            [mailComposer setSubject:[NSString stringWithFormat:@"%@ Order/Quote acknowledgement %@",[companyConfigDict valueForKey:@"companyname"],[self.Headrecorddata valueForKey:@"orderid"]]];
            
            [mailComposer setMessageBody:[NSString stringWithFormat:@"Dear Customer\nPlease find attached a copy of your transaction %@ placed with %@.  ",[self.Headrecorddata valueForKey:@"orderid"],[companyConfigDict valueForKey:@"companyname"]] isHTML:NO];
           
            
            if ([[arrPdfSetting objectAtIndex:0] isEqualToString:@"Csv File"])
                [mailComposer addAttachmentData:emailData mimeType:@"csv" fileName:[[self.Headrecorddata valueForKey:@"orderid"] stringByAppendingPathExtension:@"csv"]];
            else
            {
                NSInteger emaildataLength=[emailData length];
                if (kAppDelegate.pageCount>1){
                    NSString *msg=[NSString stringWithFormat:@"Dear Customer\nPlease find attached a copy of your transaction %@ placed with %@. \n\nThe attachment size is %.2f MB.",[self.Headrecorddata valueForKey:@"orderid"],[companyConfigDict valueForKey:@"companyname"],(float)(emaildataLength/1024)/1024 ];
                    
                    [mailComposer setMessageBody:msg isHTML:NO];
                    [mailComposer addAttachmentData:emailData mimeType:@"application/pdf" fileName:[[self.Headrecorddata valueForKey:@"orderid"] stringByAppendingPathExtension:@"pdf"]];
                }
                else
                {
                    if ([[companyConfigDict valueForKey:@"isSinglePagePdfAsAttachment"] boolValue])
                        [mailComposer addAttachmentData:emailData mimeType:@"application/pdf" fileName:[[self.Headrecorddata valueForKey:@"orderid"] stringByAppendingPathExtension:@"pdf"]];
                    else
                        [mailComposer addAttachmentData:emailData mimeType:@"image/pdf" fileName:[[self.Headrecorddata valueForKey:@"orderid"] stringByAppendingPathExtension:@"pdf"]];
                }
            }
            if (isNewCust && isNewCustFileExist && blincludeNewForm)
            {
                NSMutableData *dataAppForm = [NSMutableData dataWithContentsOfFile:[strbrochurepath stringByAppendingPathComponent:strNewForm]];
                if (dataAppForm !=nil && [dataAppForm length]>1){
                    if([[strNewForm pathExtension] isEqualToString:@"pdf"])
                        [mailComposer addAttachmentData:dataAppForm mimeType:@"application/pdf" fileName:strNewForm];
                    else
                        [mailComposer addAttachmentData:dataAppForm mimeType:[NSString stringWithFormat:@"text/%@",[strNewForm pathExtension]] fileName:strNewForm];
                }
            }
            
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                            message:@"Your device doesn't support the composer sheet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        
    }
    else
    {
    UIPrintInteractionController *pic=[UIPrintInteractionController sharedPrintController];
        pic.delegate = self;
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = @"Report";
        pic.printInfo = printInfo;
        pic.printingItem=emailData;
        pic.showsPageRange = YES;
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                DebugLog(@"Printing could not complete because of error: %@", error);
            }
            if (completed)
            {
                DebugLog(@"Done.");
            }
            
        };
        
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [optionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"MailOpCell";
    MailOpCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (optionStatus==0) {
        if ([[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"with values"] || [[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"include t&c file"]) {
            cell.selectionStyle = NO;
           
            [cell.lblDescription setHidden:YES];
            [cell.switchView setHidden:NO];
            if ([cell.switchView isOn])
                [arrPdfSetting addObject:[NSNumber numberWithInt:1]];
            else
                [arrPdfSetting addObject:[NSNumber numberWithInt:0]];
            
            [cell.switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.switchView setTag:indexPath.row];
            cell.lbltitle.text = [optionArray objectAtIndex:indexPath.row];
            if ([[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"include t&c file"]) {
                if ([cell.switchView isOn])
                    [cell.switchView setOn:NO];
                [cell.switchView setEnabled:NO];
            }
            return  cell;
        }else {
           
            [cell.lblDescription setHidden:NO];
            [cell.switchView setHidden:YES];
            
            if (indexPath.row==0)
            {
                cell.lblDescription.text=@"Text";
                //[cell.contentView addSubview:[self create_Label:@"Text" frame:CGRectMake(cell.contentView.frame.size.width-100, (cell.contentView.frame.size.height-21)/2, 120, 21)]];
            [arrPdfSetting addObject:cell.lblDescription.text];
            }
            else if (indexPath.row==1)
            {
                 cell.lblDescription.text=@"Entered Sequence";
            [arrPdfSetting addObject:cell.lblDescription.text];
            }
            
                //[cell.contentView addSubview:[self create_Label:@"Entered Sequence" frame:CGRectMake(cell.contentView.frame.size.width-100, (cell.contentView.frame.size.height-21)/2, 120, 21)]];
            
            //cell.contentView.backgroundColor=[UIColor grayColor];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.lbltitle.text = [optionArray objectAtIndex:indexPath.row];
            return  cell;
        }
        
    }else if (optionStatus==1 ||optionStatus==2) {
        [cell.lblDescription setHidden:YES];
        [cell.switchView setHidden:YES];
        cell.titleHeightLayoutConstraint.constant=280;
        cell.lbltitle.text = [optionArray objectAtIndex:indexPath.row];
        
        if ([_selStr isEqualToString:[optionArray objectAtIndex:indexPath.row]]) {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }else
            cell.accessoryType=UITableViewCellAccessoryNone;
        
        
        return  cell;
    }else
        return 0;
}


- (UILabel *)create_Label:(NSString *)title frame:(CGRect)frm{
    UILabel *lblTemp=[[UILabel alloc]initWithFrame:frm];
    lblTemp.textAlignment=NSTextAlignmentRight;
    lblTemp.text=title;
    lblTemp.font=[UIFont systemFontOfSize:12.0];
    lblTemp.textColor=[UIColor lightGrayColor];
    return lblTemp;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (_isEmailHOSts && optionStatus==1) {
        
        NSDictionary* dict = @{
                                      @"layout": [optionArray objectAtIndex:indexPath.row],
                                      @"id": [NSString stringWithFormat:@"%li",(long)indexPath.row]
                                      };

        [self.delegate finished_LayoutWithOption:dict];
        [self.navigationController popViewControllerAnimated:YES];
        
    }else   if (optionStatus==0 && !([[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"with values"] || [[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"include t&c file"])) {
        
        MailOptionsViewController *mailOpt = [self.storyboard instantiateViewControllerWithIdentifier:@"MailOptionsViewController"];
        [mailOpt setDelegate:self];
        
        if (indexPath.row==0)
            mailOpt.optionStatus=1;
        else if (indexPath.row==1)
            mailOpt.optionStatus=2;
        
        MailOpCell *tempCell=(MailOpCell *)[_tblMailOptions cellForRowAtIndexPath:indexPath];
        
        [mailOpt setSelStr:tempCell.lblDescription.text];
        [self.navigationController pushViewController:mailOpt animated:YES];
   
    }else if (optionStatus==1 || optionStatus==2){
        
     //   UITableViewCell *tempCell=(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        /*if (tempCell.accessoryType==UITableViewCellAccessoryCheckmark) {
            *tempCell.accessoryType=UITableViewCellAccessoryDetailButton;
        }else if (tempCell.accessoryType==UITableViewCellAccessoryDetailButton) {*
            tempCell.accessoryType=UITableViewCellAccessoryNone;
        }else if (tempCell.accessoryType==UITableViewCellAccessoryNone) {
            tempCell.accessoryType=UITableViewCellAccessoryCheckmark;
        }*/
        
       
//        if(tempCell.accessoryType==UITableViewCellAccessoryNone){
//            tempCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
//        
//        for(NSIndexPath *ipath in [tableView indexPathsForVisibleRows]){
//            if(![ipath isEqual:indexPath]){
//                [tableView cellForRowAtIndexPath:ipath].accessoryType = UITableViewCellAccessoryNone;
//            }
//        }
//

        NSDictionary* dict = @{ @"optionStatus":[NSNumber numberWithInt: (self.optionStatus -1)],
                                  @"orderType": [optionArray objectAtIndex:indexPath.row],
                                  };
        

        
        [self.delegate finished_LayoutWithOption:dict];
        [self.navigationController popViewControllerAnimated:YES];
        
        
    }
    
}


-(void) switchChanged:(UISwitch *)sender
{
    
    if (sender.tag==2) {
        if (sender.isOn)
        {
            [arrPdfSetting removeObjectAtIndex:2];
            [arrPdfSetting insertObject:[NSNumber numberWithInt:1] atIndex:2];
        }
        else
        {
            [arrPdfSetting removeObjectAtIndex:2];
            [arrPdfSetting insertObject:[NSNumber numberWithInt:0] atIndex:2];
            
        }
    }
    
    if (sender.tag==3) {
        if (sender.isOn)
        {
            [arrPdfSetting removeObjectAtIndex:3];
            [arrPdfSetting insertObject:[NSNumber numberWithInt:1] atIndex:3];
        }
        else
        {
            [arrPdfSetting removeObjectAtIndex:3];
            [arrPdfSetting insertObject:[NSNumber numberWithInt:0] atIndex:3];
            
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//Maintain delegate
-(void)finished_LayoutWithOption:(NSDictionary*)retString{
    DebugLog(@"%@",retString);
    
    NSIndexPath *indexPath=  [NSIndexPath indexPathForRow:[[retString valueForKey:@"optionStatus" ] integerValue] inSection:0];
    [arrPdfSetting removeObjectAtIndex:indexPath.row];
    MailOpCell *cell = (MailOpCell *)[_tblMailOptions cellForRowAtIndexPath:indexPath];
    cell.lblDescription.text=[retString valueForKey:@"orderType"];
    [arrPdfSetting insertObject:cell.lblDescription.text atIndex:indexPath.row];
    
//    if(){
//       
//    }else{
//        
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    }
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
