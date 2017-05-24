//
//  TeamTalkViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/11/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "TeamTalkViewController.h"

@interface TeamTalkViewController (){
    NSDictionary* featureDict;
    NSString* downloadpath;
    NSUserDefaults *defaults;

    BOOL isSalesMessage;
}
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *segmentTopConstraint;
@property (nonatomic,weak) IBOutlet UITableView *tableTeamTalk;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *viewMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UITextView *txtViewMessage;
@property(nonatomic,strong) NSMutableArray *arrRows;
@property (nonatomic,strong) NSMutableArray *fileData;
@end

@implementation TeamTalkViewController
@synthesize segmentedControl;

-(void)reloadConfigData{
    //  Mahendra fetch Feature config
        featureDict = nil;
        NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
        if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
            featureDict = [dic objectForKey:@"data"];

    // code added/modified by Satish 12-11-2015
    segmentedControl.hidden = YES;
    _segmentTopConstraint.constant = -40;
    if (featureDict !=nil) {
        if([[featureDict valueForKey:@"salesmessageenabled"] boolValue] && [[featureDict valueForKey:@"customertasksenabled"] boolValue]){
            segmentedControl.hidden = NO;
            _segmentTopConstraint.constant = 6;
            self.title=@"Teamtalk";
        }
        else{
            if([[featureDict valueForKey:@"salesmessageenabled"] boolValue])
                self.title=@"Sales Messages";
            else
                self.title=@"Customer Tasks";
        }

        if(![[featureDict valueForKey:@"salesmessageenabled"] boolValue] && ![[featureDict valueForKey:@"customertasksenabled"] boolValue]){
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    //End

    if(!segmentedControl.hidden)
        [self loadDataForSalesMessage:YES];
    else{
        if(featureDict && [[featureDict valueForKey:@"salesmessageenabled"] boolValue]){
            [self loadDataForSalesMessage:YES];
        }
        else{
            [self loadDataForSalesMessage:NO];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _fileData = [[NSMutableArray alloc]init];
    _arrRows = [[NSMutableArray alloc]init];


    
//    _viewMessage.layer.borderColor=[UIColor grayColor].CGColor;
//    _viewMessage.layer.borderWidth=2.0;
//    _viewMessage.layer.cornerRadius=4.0;


    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];

    defaults = kUserDefaults ;
    NSMutableArray *arrReadMessage = (NSMutableArray *)[defaults objectForKey:@"readSalesMessage"];
    if(!arrReadMessage)
    {
        arrReadMessage = [[NSMutableArray alloc] init];
    }
    if(_arrRows.count > 0)
    {
        for (NSInteger i=0; i<_arrRows.count; i++) {
            if(![arrReadMessage containsObject:_arrRows[i]])
            {
                [_tableTeamTalk selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self showDetailByIndex:i];
                break;
            }
        }
        if (arrReadMessage.count==_arrRows.count)
        {
            [_tableTeamTalk selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self showDetailByIndex:0];
        }
    }
    else{
    }

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
_txtViewMessage.textContainerInset = UIEdgeInsetsMake(-30.0,0.0, 0.0, 0.0);
}

-(IBAction)segmentBtnPressed:(UISegmentedControl*)sender{
    [self loadDataForSalesMessage:sender.selectedSegmentIndex==0];
}

-(void)loadDataForSalesMessage:(BOOL)issalesmessage
{
    if (segmentedControl.selectedSegmentIndex==1)
        _viewMessage.hidden=YES;
    else
        _viewMessage.hidden=NO;
   
    [_arrRows removeAllObjects];

    if(issalesmessage){
        [_fileData removeAllObjects];
        NSError *err;
        downloadpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/localdata",kAppDelegate.selectedCompanyId];
        NSArray  *file= [[[NSFileManager defaultManager]
                         contentsOfDirectoryAtPath:downloadpath error:&err] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH [cd] 'info'"]];

        for(NSString *str in file)
        {
            if([[[str pathExtension] lowercaseString] isEqualToString:@"txt"])
            {

                NSString* fileContents =
                [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",downloadpath,str]
                                          encoding:NSUTF8StringEncoding error:nil];

                // first, separate by new line
                NSArray* allLinedStrings =
                [fileContents componentsSeparatedByCharactersInSet:
                 [NSCharacterSet newlineCharacterSet]];

                // then break down even further
                NSString* strsInOneLine =
                [allLinedStrings objectAtIndex:0];

                [_fileData addObject:strsInOneLine];
                [_arrRows addObject:str];
                
            }
            
        }
    }
    
    [_tableTeamTalk reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
/*    if ([tableView indexPathsForSelectedRows].count) {
        
        if ([[tableView indexPathsForSelectedRows] indexOfObject:indexPath] != NSNotFound) {
            return 111.0; // Expanded height
        }
        
        return 46.0; // Normal height
    }*/
    
    return 46.0; // Normal height
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TeamTalkTableViewCell";

    if (segmentedControl.selectedSegmentIndex==0) {
        TeamTalkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

        if (cell == nil) {
            cell = [[TeamTalkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        cell.lblFileName.text=[_arrRows objectAtIndex:indexPath.row];
        cell.lblFileData.text=[_fileData objectAtIndex:indexPath.row];
        NSString* fileContents =
        [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",downloadpath,[_arrRows objectAtIndex:indexPath.row]]encoding:NSUTF8StringEncoding error:nil];

        NSString *trimmedString = [fileContents stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        NSMutableString *stringSalesMessage = [NSMutableString stringWithString:trimmedString];
        if (stringSalesMessage.length>0) {
            [stringSalesMessage replaceCharactersInRange: [stringSalesMessage rangeOfString:[_fileData objectAtIndex:indexPath.row]] withString: @""];
        }

        //cell.txtViewSalesMessage.text=stringSalesMessage;
        NSMutableArray *arrReadMessage = [defaults objectForKey:@"readSalesMessage"];
        if([arrReadMessage containsObject:_arrRows[indexPath.row]])
        {
           // cell.imageView.image = nil;
            cell.lblFileName.font=[UIFont fontWithName:@"Helvetica" size:14];
            cell.lblFileData.font=[UIFont fontWithName:@"Helvetica" size:13];

        }
        else{
           // cell.imageView.image = [UIImage imageNamed:@"bluedot.png"];
            cell.lblFileName.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
            cell.lblFileData.font=[UIFont fontWithName:@"Helvetica-Bold" size:13];

        }
        
        
        return cell;
    }
    else
        return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showDetailByIndex:indexPath.row];
   // [self updateTableView];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [self updateTableView];
}
- (void)updateTableView
{
    [_tableTeamTalk beginUpdates];
    [_tableTeamTalk endUpdates];
}

-(void) showDetailByIndex:(NSInteger) index
{
    if(index >=0)
    {
        _lblMessage.text = [_fileData objectAtIndex:index];
        
        NSString* fileContents =
        [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",downloadpath,[_arrRows objectAtIndex:index]]encoding:NSUTF8StringEncoding error:nil];
        
        NSString *trimmedString = [fileContents stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSMutableString *strMessage = [NSMutableString stringWithString:trimmedString];
        if (strMessage.length>0) {
            [strMessage replaceCharactersInRange: [strMessage rangeOfString:[_fileData objectAtIndex:index]] withString: @""];
        }
        
        _txtViewMessage.text = strMessage;

        NSMutableArray *arrReadMessage =(NSMutableArray *) [defaults objectForKey:@"readSalesMessage"];
        NSMutableArray *arrtemp = [[NSMutableArray alloc] init];
        [arrtemp addObjectsFromArray:arrReadMessage];
        if(![arrtemp containsObject:_arrRows[index]])
        {
            [arrtemp addObject:_arrRows[index]];
        }
        [defaults setObject:arrtemp forKey:@"readSalesMessage"];
        [defaults synchronize];

        
        TeamTalkTableViewCell *cell = [_tableTeamTalk cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.lblFileName.font=[UIFont fontWithName:@"Helvetica" size:14];
        cell.lblFileData.font=[UIFont fontWithName:@"Helvetica" size:13];

    }
    else{
        _lblMessage.text = nil;
        _txtViewMessage.text = nil;
    }
    
    
    
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirmation:" message:@"Do you really want to delete selected message?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    alert.tag = indexPath.row;
    [alert show];
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 1)
    {
        NSString *fullpath = [downloadpath stringByAppendingPathComponent:[_arrRows objectAtIndex:alertView.tag]];
        NSError *err;
        [_arrRows removeObjectAtIndex:alertView.tag];
        [_fileData removeObjectAtIndex:alertView.tag];
        [[NSFileManager defaultManager] removeItemAtPath:fullpath error:&err];
        [_tableTeamTalk reloadData];
    }
    
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
