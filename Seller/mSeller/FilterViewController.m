//
//  FilterViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/14/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "FilterViewController.h"
#import "TransactionFilterCell.h"
#import "Constants.h"
#import "CommonHelper.h"

@interface FilterViewController (){
    
    NSMutableArray *filterArray;
    NSMutableArray *stsArray;
   
    NSIndexPath *lastSelectindex;
    NSDictionary* featureDict;
    NSDictionary* companyConfigDict;
}
@property (strong,nonatomic) NSDictionary *retDict;
@property (weak,  nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (weak,  nonatomic) IBOutlet UITableView *tblFilter;
@property (weak,  nonatomic) IBOutlet UISegmentedControl *filterSegmentController;
@property (weak,  nonatomic) IBOutlet NSLayoutConstraint *segmentHeightLayoutConst;
@property (weak,  nonatomic) IBOutlet NSLayoutConstraint *segmentTopLayoutConst;
@property (weak,  nonatomic) IBOutlet NSLayoutConstraint *segmentBottomLayoutConst;

@end

@implementation FilterViewController

-(void)reloadConfigData{
    //  Mahendra fetch Feature config
    featureDict = nil;
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        featureDict = [dic objectForKey:@"data"];

    //  Mahendra fetch CompanyConfig
    //    companyConfigDict = nil;
    //    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    //    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
    //        companyConfigDict = [dic objectForKey:@"data"];

    //  Mahendra fetch Feature config **SUBTITUDE PERFORMA WITH INVOICE

    if(!filterArray) filterArray = [NSMutableArray array];
    if(!stsArray) stsArray = [NSMutableArray array];
    
    
    [filterArray removeAllObjects];
    [stsArray removeAllObjects];
//    NSString *strdefordtype = @"";
    NSDictionary *pricingConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]]){
        pricingConfigDict = [dic objectForKey:@"data"];

        if(pricingConfigDict){
            [filterArray addObjectsFromArray:[[[pricingConfigDict objectForKey:@"orderconfigs"] objectForKey:@"transactiontypes"] mutableCopy]];
        }
    }

    if (_filterStatus!=1){
      
        if ([_returnDictionary count]>0) {
            
            filterArray=[_returnDictionary objectForKey:@"Type"];
            stsArray=[_returnDictionary objectForKey:@"Status"];
            
        }else{
            
        //Type Array
        NSMutableArray *temptransactions = [NSMutableArray array];
        [filterArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *dictmp = [obj mutableCopy];
           
            if ([[dictmp valueForKey:@"isdefault"] intValue]>0) {
                [dictmp setObject:@"1" forKey:@"status"];
            }else
                [dictmp setObject:@"0" forKey:@"status"];
            [temptransactions addObject:dictmp];
        }];
        [filterArray removeAllObjects];
        [filterArray addObjectsFromArray:temptransactions];

        
        //Define StatusArray
        stsArray=[[NSMutableArray alloc]initWithCapacity:5];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        
        [dict setObject:@"0" forKey:@"status"];
        [dict setObject:@"All" forKey:@"label"];
        [dict setObject:@"A" forKey:@"code"];
        [stsArray addObject:dict];
        
        dict=[[NSMutableDictionary alloc]init];
        [dict setObject:@"0" forKey:@"status"];
        [dict setObject:@"Sent" forKey:@"label"];
        [dict setObject:@"S" forKey:@"code"];
        [stsArray addObject:dict];
        
        dict=[[NSMutableDictionary alloc]init];
        [dict setObject:@"0" forKey:@"status"];
        [dict setObject:@"Unsent" forKey:@"label"];
        [dict setObject:@"U" forKey:@"code"];
        [stsArray addObject:dict];
        
        dict=[[NSMutableDictionary alloc]init];
        [dict setObject:@"0" forKey:@"status"];
        [dict setObject:@"Pending" forKey:@"label"];
        [dict setObject:@"P" forKey:@"code"];
        [stsArray addObject:dict];
        
        dict=[[NSMutableDictionary alloc]init];
        [dict setObject:@"0" forKey:@"status"];
        [dict setObject:@"Held" forKey:@"label"];
        [dict setObject:@"H" forKey:@"code"];
        [stsArray addObject:dict];
    
    }
    }else{
        
        NSMutableArray *temptransactions = [NSMutableArray array];
        [filterArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *dictmp = [obj mutableCopy];
            if (_callLogStatus && [[[dictmp valueForKey:@"code"] lowercaseString] isEqualToString:@"c"]) {
                
            }else
            [temptransactions addObject:dictmp];
        }];
        [filterArray removeAllObjects];
        [filterArray addObjectsFromArray:temptransactions];
        
    }
}

-(BOOL) navigationShouldPopOnBackButton
{
    if (_filterStatus==1) {
        return YES;
    }else{
        [self barBtnClick:nil];
        return NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_filterStatus==1)
        self.title=NSLocalizedString(@"Select", @"Select");
    else
        self.title=NSLocalizedString(@"Filter", @"Filter");
    
    
    _callLogStatus=YES;
    
    self.tblFilter.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tblFilter.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];

    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];

    
    
    if (_filterStatus==1) {
        //update constraints
        _segmentBottomLayoutConst.constant = 0;
        _segmentHeightLayoutConst.constant=0;
        _segmentTopLayoutConst.constant=0;
        [self.view setNeedsUpdateConstraints];
        
        self.navigationItem.rightBarButtonItem = nil;
        
        UIBarButtonItem *chkmanuaaly = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(barBtnClick:)];
        self.navigationItem.rightBarButtonItem=chkmanuaaly;
        
       // self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(barBtnClick:)];
        //ENDED
    }
    
}

-(IBAction)barBtnClick:(UIBarButtonItem *)sender
{
    if (_filterStatus==1)
        [self.delegate finishedTransactionFilterSelectionWithSingleOption:_retDict];
    else{
        NSDictionary *dict = @{ @"Type" : filterArray, @"Status" : stsArray };
        [self.delegate finishedTransactionFilterSelectionWithOption:dict];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)clearAllCheck:(UIBarButtonItem *)sender {
  if (self.filterSegmentController.selectedSegmentIndex==1){
      [stsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          NSMutableDictionary *dict1=[[NSMutableDictionary alloc]initWithDictionary:obj];
          [dict1 setValue:[NSNumber numberWithInteger:0] forKey:@"status"];
          [stsArray replaceObjectAtIndex:idx withObject:dict1];
      }];

  }
    else
    [filterArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dict1=[[NSMutableDictionary alloc]initWithDictionary:obj];
        [dict1 setValue:[NSNumber numberWithInteger:0] forKey:@"status"];
        [filterArray replaceObjectAtIndex:idx withObject:dict1];
    }];
    
  
    [_tblFilter reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.filterSegmentController.selectedSegmentIndex==1){
        return [stsArray count];
    }else
        return [filterArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_filterStatus==1){
        static NSString *simpleTableIdentifier = @"TransactionFilterCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        NSDictionary *dict=[filterArray objectAtIndex:indexPath.row];
        if([[[dict valueForKey:@"code"] lowercaseString] isEqualToString:[_retval lowercaseString]])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
     
       /* if ([[dict valueForKey:@"code"]isEqualToString:@"C"])
            cell.textLabel.textColor=[UIColor colorWithRed:25.0/255.0       green:161.0/255.0       blue:69.0/255.0       alpha:1.0];
        else if ([[dict valueForKey:@"code"]isEqualToString:@"P"])
            cell.textLabel.textColor=[UIColor blueColor];
        else if ([[dict valueForKey:@"code"]isEqualToString:@"Q"])
            cell.textLabel.textColor=[UIColor redColor];
        else if ([[dict valueForKey:@"code"]isEqualToString:@"O"])
            cell.textLabel.textColor=[UIColor blackColor];
        else
            cell.textLabel.textColor=[UIColor blackColor];*/

        cell.textLabel.textColor=[CommonHelper colorwithHexString:[dict valueForKey:@"colorcode"] alpha:1.0];
        cell.textLabel.text=[dict valueForKey:@"label"];

        return cell;
    }
    {
        TransactionFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TransactionFilterCell"];
        if (cell == nil){
            cell = [[TransactionFilterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TransactionFilterCell"] ;
        }
        if (_filterSegmentController.selectedSegmentIndex==1){
            NSDictionary *dict=[stsArray objectAtIndex:indexPath.row];
            if([[dict valueForKey:@"status"] integerValue]==0){
                [cell.btnCheck setImage:nil forState:UIControlStateNormal];
            }else if([[dict valueForKey:@"status"] integerValue]==1){
                [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
            }else if([[dict valueForKey:@"status"] integerValue]==2){
                [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
            }

            cell.lblFilterText.textColor=[UIColor blackColor];
            cell.lblFilterText.text=[dict valueForKey:@"label"];
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = NO;
            cell.lblFilterText.textColor=[UIColor blackColor];
            
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[filterArray objectAtIndex:indexPath.row ]];
            if([[dict valueForKey:@"status"] integerValue]==0){
                [cell.btnCheck setImage:nil forState:UIControlStateNormal];
            }else if([[dict valueForKey:@"status"] integerValue]==1){
                [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
            }else if([[dict valueForKey:@"status"] integerValue]==2){
                [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
            }
           
            if ([[dict valueForKey:@"code"]isEqualToString:@"C"])
                cell.lblFilterText.textColor=[UIColor colorWithRed:25.0/255.0       green:161.0/255.0       blue:69.0/255.0       alpha:1.0];
           else if ([[dict valueForKey:@"code"]isEqualToString:@"P"])
               cell.lblFilterText.textColor=[UIColor blueColor];
            else if ([[dict valueForKey:@"code"]isEqualToString:@"Q"])
                cell.lblFilterText.textColor=[UIColor redColor];
            else if ([[dict valueForKey:@"code"]isEqualToString:@"O"])
                cell.lblFilterText.textColor=[UIColor blackColor];
            else
                cell.lblFilterText.textColor=[UIColor blackColor];
            
                cell.lblFilterText.text=[dict valueForKey:@"label"];
            
        }
        
        return cell;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_filterStatus==1){
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        if(cell.accessoryType==UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _retval=[[filterArray objectAtIndex:indexPath.row] valueForKey:@"code"];
            _retDict=[filterArray objectAtIndex:indexPath.row];
        }
        
        for(NSIndexPath *ipath in [tableView indexPathsForVisibleRows]){
            if(![ipath isEqual:indexPath]){
                [tableView cellForRowAtIndexPath:ipath].accessoryType = UITableViewCellAccessoryNone;
            }
        }

        [self barBtnClick:nil];
        
    }
    else{
        
    if (self.filterSegmentController.selectedSegmentIndex==0){
        
        TransactionFilterCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[filterArray objectAtIndex:indexPath.row ]];
        if([[dict valueForKey:@"status"] integerValue]==0){
            [dict setValue:[NSNumber numberWithInt:1] forKey:@"status"];
            [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
        }else if([[dict valueForKey:@"status"] integerValue]==1){
            [dict setValue:[NSNumber numberWithInt:2] forKey:@"status"];
            [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
        }else if([[dict valueForKey:@"status"] integerValue]==2){
            [dict setValue:[NSNumber numberWithInt:0] forKey:@"status"];
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
        }
         [filterArray replaceObjectAtIndex:indexPath.row withObject:dict];
        
    }else{
    
        TransactionFilterCell *cell=[tableView cellForRowAtIndexPath:indexPath];
         [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row==0){
            
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[stsArray objectAtIndex:indexPath.row ]];
            if([[dict valueForKey:@"status"] integerValue]==0){
                [dict setValue:[NSNumber numberWithInt:1] forKey:@"status"];
                [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
            
                for(NSIndexPath *ipath in [tableView indexPathsForVisibleRows]){
                    if(![ipath isEqual:indexPath]){
                        if (ipath.row==0)
                            continue;
                        
                        NSMutableDictionary *dict2=[NSMutableDictionary dictionaryWithDictionary:[stsArray objectAtIndex:ipath.row ]];
                        [dict2 setValue:[NSNumber numberWithInt:0] forKey:@"status"];
                        [cell.btnCheck setImage:nil forState:UIControlStateNormal];
                        [stsArray replaceObjectAtIndex:ipath.row withObject:dict2];
                    }
                }

            
            }else if([[dict valueForKey:@"status"] integerValue]==1){
                [dict setValue:[NSNumber numberWithInt:0] forKey:@"status"];
                [cell.btnCheck setImage:nil forState:UIControlStateNormal];
            }
             [stsArray replaceObjectAtIndex:indexPath.row withObject:dict];
            
            
            
           // return;
        }else{
            NSIndexPath* ipath = [NSIndexPath indexPathForRow:0 inSection:0];
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[stsArray objectAtIndex:ipath.row ]];
//            [tableView cellForRowAtIndexPath:ipath].accessoryType = UITableViewCellAccessoryNone;
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
            [dict setValue:[NSNumber numberWithInt:0] forKey:@"status"];
            [stsArray replaceObjectAtIndex:ipath.row withObject:dict];

            //Except All
            dict=[NSMutableDictionary dictionaryWithDictionary:[stsArray objectAtIndex:indexPath.row ]];
            if([[dict valueForKey:@"status"] integerValue]==0){
                [dict setValue:[NSNumber numberWithInt:1] forKey:@"status"];
                [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
            }else if([[dict valueForKey:@"status"] integerValue]==1){
                [dict setValue:[NSNumber numberWithInt:2] forKey:@"status"];
                [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
            }else if([[dict valueForKey:@"status"] integerValue]==2){
                [dict setValue:[NSNumber numberWithInt:0] forKey:@"status"];
                [cell.btnCheck setImage:nil forState:UIControlStateNormal];
            }
            [stsArray replaceObjectAtIndex:indexPath.row withObject:dict];
        }
        
   }
    [_tblFilter reloadData];
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

- (IBAction)changeSegmentValue:(id)sender {
    [self.tblFilter reloadData];
}
@end
