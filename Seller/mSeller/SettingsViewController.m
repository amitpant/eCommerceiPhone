//
//  SettingsViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/11/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "SwitchCompanyDelagate.h"
#import "SCPCoreBluetoothCentralManager.h"

@interface SettingsViewController ()<SwitchCompanyDelagate,UIAlertViewDelegate>{
    NSIndexPath* lastIndexPath;
    NSMutableArray* searchArray;
    NSDictionary* selectedCompDic;
    NSMutableArray *arrSettings;
    NSArray *companyListArr;
    NSMutableDictionary *dicSettings;
    CBCentralManager *mgr;
    CBPeripheralManager *manager;
    BOOL isUserAlreadyLoggedIn;
    
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    
    
    
    
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;

@property (nonatomic, strong) SCPCoreBluetoothCentralManager *centralManger;
@property (nonatomic, strong) NSMutableArray *discoveredPeripherals;
@property (nonatomic, strong) NSMutableArray *peripheralsRSSI;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SettingsViewController
@synthesize tblSetting1;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=NSLocalizedString(@"Settings", @"Settings");

    
    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    NSDictionary *dicConfig=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dicConfig && ![[dicConfig objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dicConfig objectForKey:@"data"];

    
    
    //Init the properties
    self.centralManger = [[SCPCoreBluetoothCentralManager alloc] init];
    self.discoveredPeripherals = [@[] mutableCopy];
    self.peripheralsRSSI = [@[] mutableCopy];

    kAppDelegate.companyDelegate =self;

    //tblSetting1.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    [self.view setBackgroundColor:[UIColor lightGrayColor]];
//    
//    tblSetting1.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
//    tblSetting1.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
//    tblSetting1.backgroundColor=[UIColor clearColor];
//    tblSetting1.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tblSetting1.bounds.size.width, 0.01f)];

    // tblSetting1.contentInset = UIEdgeInsetsZero;

    arrSettings = [NSMutableArray array]; //initWithObjects:@"Customer Mode",@"Catalogue Scrolling",@"Price Display",@"Numeric Keyboard", nil];
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"customermode",@"identifier",@"Customer Mode",@"caption", nil];
    [arrSettings addObject:dic];

    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"catalogscrolling",@"identifier",@"Catalogs Scrolling",@"caption", nil];
    [arrSettings addObject:dic];

    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"pricedisplay",@"identifier",@"Price Display",@"caption", nil];
    [arrSettings addObject:dic];

    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"numkeyboard",@"identifier",@"Numeric Keyboard",@"caption", nil];
    [arrSettings addObject:dic];

    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"Bluetooth Controller",@"identifier",@"Bluetooth Controller",@"caption", nil];
    [arrSettings addObject:dic];

    dicSettings = [NSMutableDictionary dictionary];

    [dicSettings setObject:arrSettings forKey:[NSNumber numberWithInteger:0]];
    [dicSettings setObject:_discoveredPeripherals forKey:[NSNumber numberWithInteger:1]];

    NSDictionary *dicresult = [CommonHelper loadFileDataWithVirtualFilePath:(NSString *)kValidateLicenseFileName];
    companyListArr=[[dicresult objectForKey:@"data"]objectForKey:@"companies"];
    searchArray=[[NSMutableArray alloc]initWithArray:companyListArr];


    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyid == %li",kAppDelegate.selectedCompanyId];
    NSArray *filteredArray = [companyListArr filteredArrayUsingPredicate:predicate];
    selectedCompDic = [filteredArray firstObject];


    lastIndexPath=[NSIndexPath indexPathForRow:[searchArray indexOfObject:[filteredArray firstObject]] inSection:0] ;

    _searchBarTopConstraint.constant= [companyListArr count]>10?0:-44;
    _settingSearchBar.hidden = [companyListArr count]>10?NO:YES;

    if(_settingSearchBar.hidden){
        if([_settingSearchBar isFirstResponder]) [_settingSearchBar resignFirstResponder];
    }

    self.navigationItem.hidesBackButton = YES;
    
    
    //manage default values.
    
    
}

-(void)scan
{
    //Weak self to avoid retain cycle when using self inside a block
    __weak SettingsViewController *weakSelf = self;

    //Start up the central manager
    [_centralManger startUpSuccess:^{
        DebugLog(@"Core bluetooth manager successfully started.");

        //Once the central manager is successfully started, start scanning for peripherals
        [weakSelf scanForPeripherals];

    } failure:^(CBCentralManagerState CBCentralManagerState) {

        //Handel the error.

        NSString *message;

        switch (CBCentralManagerState) {
            case CBCentralManagerStateUnknown:
            {
                message = @"Unknown state";
                break;
            }
            case CBCentralManagerStateResetting:
            {
                message = @"Central manager is resetting";
                break;
            }
            case CBCentralManagerStateUnsupported:
            {
                message = @"Your device is not supported";
                DebugLog(@"Please note it will not work on a simulator");
                break;
            }
            case CBCentralManagerStateUnauthorized:
            {
                message = @"Unauthorized";
                break;
            }
            case CBCentralManagerStatePoweredOff:
            {
                message = @"Bluetooth is switched off";
                break;
            }
            default:
            {
                //Empty default to remove switch warning
                break;
            }
        }

        DebugLog(@"Message %@",message);
        //Remove any previously found peripheral
        [weakSelf.discoveredPeripherals removeAllObjects];
        [weakSelf.peripheralsRSSI removeAllObjects];

        dispatch_sync(dispatch_get_main_queue(), ^{
//            [SVProgressHUD showErrorWithStatus:message];
            [weakSelf searchTextWithString:@""];
        });

        DebugLog(@"Error %d", CBCentralManagerState);
    }];

    //Set the did disconnect block to handel if the peripheral disconnects anytime during the app
    [_centralManger setDidDisconnectFromPeripheralBlock:^(CBPeripheral *peripheral) {
        DebugLog(@"Did disconnect");

        //Remove any previously found peripheral
        [weakSelf.discoveredPeripherals removeAllObjects];
        [weakSelf.peripheralsRSSI removeAllObjects];

        //Call it on the main thread to pop to root view
        dispatch_sync(dispatch_get_main_queue(), ^{
//            [SVProgressHUD showErrorWithStatus:@"Disconnected from\nperipheral"];
            [weakSelf searchTextWithString:@""];
            [weakSelf performSelector:@selector(scanForPeripherals) withObject:nil afterDelay:1.0];
        });
    }];
}

- (void)scanForPeripherals
{
//    [SVProgressHUD showWithStatus:@"Searching for peripherals"];
    __weak SettingsViewController *weakSelf = self;

    //Remove any previously found peripheral
    [_discoveredPeripherals removeAllObjects];
    [_peripheralsRSSI removeAllObjects];
    [self.tblSetting1 reloadData];

    //Check that the central manager is ready to scan
    if([_centralManger isReady])
    {
        //Tell the central manager to start scanning
        [_centralManger scanForPeripheralsWithServices:nil //If an array of CBUUIDs is given it will only look for the peripherals with that CBUUID
                                       allowDuplicates:NO
                                 didDiscoverPeripheral:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
                                     //A peripheral has been found
//                                     [peripheral readRSSI];
                                     DebugLog(@"Discovered Peripheral '%@' with RSSI of %@", [peripheral name], RSSI);

                                     //To ensure we don't have duplicates
                                     if(![weakSelf.discoveredPeripherals containsObject:peripheral])
                                     {
                                         //Add it to the discoveredPeripherals array and update the UI on the main thread
                                         [weakSelf.discoveredPeripherals addObject:peripheral];
                                         [weakSelf.peripheralsRSSI addObject:RSSI];
                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                             [weakSelf searchTextWithString:@""];
//                                             [SVProgressHUD dismiss];
                                         });
                                     }
                                 }];
        DebugLog(@"Scanning started");
    }
    else
    {
        NSLog(@"Central manager not ready to scan");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_segmentControl1.selectedSegmentIndex==1) {
        return [searchArray count];
    }else
    {
        return 1;
    }
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_segmentControl1.selectedSegmentIndex==1) {
        return [[dicSettings objectForKey:[NSNumber numberWithInteger:section]] count];
    }else{
        return [searchArray count];
        
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if (_segmentControl1.selectedSegmentIndex==1) {
        if (indexPath.section==0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellsetting"];

            UISwitch *switchView = (UISwitch *)cell.accessoryView;
            if(!switchView){
                switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 49, 31)];
                cell.accessoryView = switchView;
                switchView.tag=indexPath.row;
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            }
            switchView.tag = indexPath.row;
            switchView.on=NO;
            
            if (indexPath.row==0 &&  [kUserDefaults  integerForKey:@"CustomerMode"] ==2) {
                switchView.on=YES;
            }else if (indexPath.row==1 &&  [kUserDefaults  integerForKey:@"CatalogeScrolling"]==2) {
                switchView.on=YES;
            }else if (indexPath.row==2 &&  [kUserDefaults  integerForKey:@"PriceDisplay"]==2) {
                switchView.on=YES;
            }else  if (indexPath.row==3 &&  [kUserDefaults  integerForKey:@"NumericKeyboard"]==2) {
                switchView.on=YES;
            }
            

            NSDictionary *dicinfo=[[dicSettings objectForKey:[NSNumber numberWithInteger:indexPath.section]] objectAtIndex:indexPath.row];
            cell.textLabel.text = [dicinfo objectForKey:@"caption"];
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"celldevice"];
            CBPeripheral *deviceinfo = [[dicSettings objectForKey:[NSNumber numberWithInteger:indexPath.section]] objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",deviceinfo.name];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.accessoryType = (indexPath.row == lastIndexPath.row && lastIndexPath != nil) ?
        UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

        NSDictionary *dicinfo=[searchArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dicinfo objectForKey:@"tradename"];
        cell.detailTextLabel.text=nil;

        if (![[dicinfo objectForKey:@"tradename"] isEqualToString:[dicinfo objectForKey:@"companyname"]]) {
            cell.detailTextLabel.text= [dicinfo objectForKey:@"companyname"];
        }

    }
    return  cell;
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    } else {
        return 25.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 60.0f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_segmentControl1.selectedSegmentIndex==0) {
        NSUInteger newRow = [indexPath row];
        NSUInteger oldRow = [lastIndexPath row];
        if (newRow != oldRow)
        {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            selectedCompDic=[searchArray objectAtIndex:indexPath.row];
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: lastIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            
            lastIndexPath = indexPath;
        }
        else
        {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            lastIndexPath = indexPath;
            
        }
        
        selectedCompDic=[searchArray objectAtIndex:indexPath.row];
    }
    
    //When companySwitch Notification Called
    [kNSNotificationCenter postNotificationName:kCompanySwitch object:nil];

}



#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchTextWithString:searchText];
}

-(void)searchTextWithString:(NSString *)searchedStr{
    [searchArray removeAllObjects];
    if([searchedStr length]>0){
        if(_segmentControl1.selectedSegmentIndex==1){
            NSArray *settArray = [dicSettings objectForKey:[NSNumber numberWithInteger:0]];
            NSArray *deviceArray = [dicSettings objectForKey:[NSNumber numberWithInteger:1]];

            NSArray *settFound= [settArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.identifier CONTAINS [cd] %@",searchedStr]];

            NSArray *deviceFound = [deviceArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS [cd] %@",searchedStr]];

            [dicSettings setObject:settFound forKey:[NSNumber numberWithInteger:0]];
            [dicSettings setObject:deviceFound forKey:[NSNumber numberWithInteger:1]];

            [searchArray addObjectsFromArray:[dicSettings allKeys]];
        }
        else{
            NSArray *compFound = [companyListArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tradename CONTAINS [cd] %@ || self.companyname CONTAINS [cd] %@",searchedStr,searchedStr]];
            [searchArray addObjectsFromArray:compFound];

            if(_segmentControl1.selectedSegmentIndex==0)
                lastIndexPath=[NSIndexPath indexPathForRow:[searchArray indexOfObject:selectedCompDic] inSection:0] ;
        }

        [tblSetting1 reloadData];
        return;
    }


    if(_segmentControl1.selectedSegmentIndex==1){
        [dicSettings setObject:arrSettings forKey:[NSNumber numberWithInteger:0]];
        [dicSettings setObject:_discoveredPeripherals forKey:[NSNumber numberWithInteger:1]];
        [searchArray addObjectsFromArray:[dicSettings allKeys]];
    }
    else
        [searchArray addObjectsFromArray:companyListArr];

    [tblSetting1 reloadData];
    return;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
   [self searchTextWithString:searchBar.text];
    [searchBar resignFirstResponder];
}




-(void) switchChanged:(UISwitch *)sender
{
    if (sender.tag==4) {
        if ([sender isOn]) {
            [self scan];
        } else {
            [_discoveredPeripherals removeAllObjects];
        }
    }else if (sender.tag==3){
        
        if ([sender isOn])
            [kUserDefaults  setInteger:2 forKey: @"NumericKeyboard"];
        else
            [kUserDefaults  setInteger:1  forKey:@"NumericKeyboard"];

        
    }else if (sender.tag==2){
        
        if ([sender isOn])
            [kUserDefaults  setInteger:2 forKey: @"PriceDisplay"];
        else
            [kUserDefaults  setInteger:1  forKey:@"PriceDisplay"];
        
        
    }else if (sender.tag==1){
        
        if ([sender isOn])
            [kUserDefaults  setInteger:2 forKey: @"CatalogeScrolling"];
        else
            [kUserDefaults  setInteger:1  forKey:@"CatalogeScrolling"];
        
        
    }else if (sender.tag==0){
        
        if ([sender isOn])
            [kUserDefaults  setInteger:2  forKey: @"CustomerMode"];
        else
            [kUserDefaults  setInteger:1  forKey:@"CustomerMode"];
        
        
        
    }
    
    [kUserDefaults  synchronize];
    [self searchTextWithString:@""];

}


-(void) showInfo:( id)sender
{
    
    
}


-(IBAction)done_clicked{
    if (selectedCompDic && ([[selectedCompDic objectForKey:@"companyid"]integerValue] !=kAppDelegate.selectedCompanyId)) {
        
        [_activityIndicator startAnimating];
        
        // to set all tabs to root view controller
        [kNSNotificationCenter postNotificationName:kRedirectToRootViewController object:nil];

        kAppDelegate.selectedCompanyId = [[selectedCompDic objectForKey:@"companyid"] integerValue];

        // To check if user already selected any company so that we can load that comapany again
//        NSArray *companyFound = nil;
//        if(kAppDelegate.selectedCompanyId){
//            companyFound = [companyListArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.companyid==%i",kAppDelegate.selectedCompanyId]]; // To validate if that comapany still associated with current license
//        }

        [kAppDelegate loadSelectedCompanyWithData:selectedCompDic];
       
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];//without change any company.
     [_activityIndicator stopAnimating];
    }
}

#pragma mark - SwitchCompanyDelagate
-(void)loadingOfCompanyUsersFinishedSuccessfully:(BOOL)issuccessful Error:(nullable NSString *)error{
    if(issuccessful){
        NSDictionary *dicuserinfo =  [CommonHelper loadFileDataWithVirtualFilePath:CompanyUsersFileName];
        if(dicuserinfo){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@ && password==%@",[kUserDefaults  objectForKey:@"username"],[kUserDefaults  objectForKey:@"password"]];

            NSArray *filteredArray = [[[dicuserinfo objectForKey:@"data"] objectForKey:@"users"] filteredArrayUsingPredicate:predicate];
            if([filteredArray count]>0){
                NSDictionary *dicdata=[filteredArray firstObject];
                kAppDelegate.repId = [dicdata objectForKey:@"repid"];
                kAppDelegate.loginUserId = [[dicdata objectForKey:@"userid"] integerValue];

                // to set user config directory
                NSString *strtempuserfile = [[[UserConfigFileName lastPathComponent] componentsSeparatedByString:@"_"] firstObject];
                NSString *strtempuserfileext = [UserConfigFileName pathExtension];

                UserConfigFileName = [NSString stringWithFormat:@"%li/%@_%@.%@",(long)kAppDelegate.selectedCompanyId,[strtempuserfile stringByDeletingPathExtension],kAppDelegate.repId,strtempuserfileext];

                [kUserDefaults  setObject:[NSNumber numberWithInteger:kAppDelegate.loginUserId] forKey:@"loginUserId"];
                [kUserDefaults  synchronize];


                if([kAppDelegate isAllConfigFileDownloaded]){
                    isUserAlreadyLoggedIn = YES;

                    [kAppDelegate saveDeviceUsesLogs];

                    // reload config files if company switched successfully
                    [kNSNotificationCenter postNotificationName:kRefreshConfigData object:nil];

                    [kNSNotificationCenter postNotificationName:kRefreshTabItems object:nil];

                    [_activityIndicator stopAnimating];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    kAppDelegate.customerInfo = nil;
                    [kAppDelegate loadCustomerInfo];
                }

                // download & reload config
                [kAppDelegate reloadConfigurationData];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Invalid user name or password, you will be redirected to the login page." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert setDelegate:self];
                [alert setTag:3];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Invalid user name or password, you will be redirected to the login page." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert setDelegate:self];
            [alert setTag:3];
            [alert show];
        }
        
    }else{
        if(!error){
            error = @"Unable to load configuration data. Please try again.";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry",nil];
        alert.tag = 2;
        [alert show];
    }
}

-(void)ConfigDownloadFinishedSuccessfully:(BOOL)issuccessful Error:(NSString *)error{
    if(![kAppDelegate isAllConfigFileDownloaded]){
        [kAppDelegate showCustomAlertWithModule:@"Login" Message:@"Unable to get all configuration from server"];
        [kNSNotificationCenter postNotificationName:kRedirectToLogin object:nil];

        [_activityIndicator stopAnimating];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else{
        if(!isUserAlreadyLoggedIn){
            [kAppDelegate saveDeviceUsesLogs];

            // reload config files if company switched successfully
            [kNSNotificationCenter postNotificationName:kRefreshConfigData object:nil];

            [kNSNotificationCenter postNotificationName:kRefreshTabItems object:nil];

            [_activityIndicator stopAnimating];
            [self dismissViewControllerAnimated:YES completion:nil];

            isUserAlreadyLoggedIn = YES;
            
            kAppDelegate.customerInfo = nil;
            [kAppDelegate loadCustomerInfo];
            
        }
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView.tag==3){
        if (buttonIndex == 0){
            kAppDelegate.repId = nil;
            kAppDelegate.loginUserId = -1;
            [kUserDefaults  removeObjectForKey:@"password"];
            [kUserDefaults  removeObjectForKey:@"loginUserId"];
            [kUserDefaults  synchronize];

            //POP Home view to login when company Change and userid mismatch
            //[ self.navigationController popViewControllerAnimated:YES];

            [kNSNotificationCenter postNotificationName:kRedirectToLogin object:nil];

            [_activityIndicator stopAnimating];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
    else if(alertView.tag==2){ // if user download failed
        if (buttonIndex == 0) {
            exit(0);
        }
        else if (buttonIndex == 1)
            [kAppDelegate downloadCompanyUsersWithCompanyId:[NSString stringWithFormat:@"%li",(long)kAppDelegate.selectedCompanyId]];
    }
    
}

- (IBAction)valueChanged:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex==1){
        _searchBarTopConstraint.constant= [arrSettings count]>10?0:-44;
        _settingSearchBar.hidden = [arrSettings count]>10?NO:YES;
    }
    else{
        _searchBarTopConstraint.constant= [companyListArr count]>10?0:-44;
        _settingSearchBar.hidden = [companyListArr count]>10?NO:YES;
    }

    if(_settingSearchBar.hidden){
        if([_settingSearchBar isFirstResponder]) [_settingSearchBar resignFirstResponder];
    }

    [self searchTextWithString:@""];
}

@end
