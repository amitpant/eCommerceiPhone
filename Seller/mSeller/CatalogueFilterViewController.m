//
//  CatalogueFilterViewController.m
//  mSeller
//
//  Created by WCT iMac on 28/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CatalogueFilterViewController.h"
#import "quartzview.h"
#import "GroupCell.h"
#import "FilterCell.h"
#import "FilterCatCell.h"
#import "Constants.h"
#import "commonMethods.h"

#define lblX 17
//seloption 0 group
//seloption 1 filter
//seloption 2 Stock
//seloption 3 Category
//seloption 4 subcategory



@interface CatalogueFilterViewController()<UITextFieldDelegate>{
    NSInteger selectedOption; // 0 - Groups, 1 - Filter, 2 - Stock  3 - Cat, 4 - SubCat
    NSMutableArray *arrRows;
    NSArray* filterArr;
    NSArray* colrFiltrArr;
    UITableViewCell *pickerCell;
    NSString *pickerLabel;
    
    NSIndexPath * editIndexPath;
    NSInteger selectIndex;
    NSInteger mainIndex;
    UITextField *txtfield;
    
    BOOL selectTextField;
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
    NSDictionary* priceConfigDict;//   fetch PriceConfig
    
    UIToolbar* doneToolbar;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentFilter;
@property (weak, nonatomic) IBOutlet UITableView *tblCatalogueFilter;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;
- (IBAction)done_Click:(id)sender;
- (IBAction)clearAllCheck:(id)sender;
- (IBAction)pickerDoneClick:(id)sender;
@end

@implementation CatalogueFilterViewController
@synthesize returnDictionary;
@synthesize tblCatalogueFilter;



-(void)reloadConfigData{
    
    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    NSDictionary *dic =[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    
    //  Mahendra fetch priceConfig
    priceConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];
    
    
   // _selectedStock=[[NSMutableArray alloc]initWithObjects:@"Select",@"Select",@"Select",@"Select",@"",@"",@"",@"",@"",@"", nil];
    NSArray *arr = [[priceConfigDict objectForKey:@"pricetablabels"] valueForKey:@"field"] ;
   
    NSString *selectprice=@"Select";
    if ([arr count]>0) {
        selectprice=[arr objectAtIndex:0];
    }
    _selectedStock=[[NSMutableArray alloc]initWithObjects:@"All",@"Select",selectprice,@"Select",@"",@"",@"",@"",@"",@"", nil];
    
    
    
    if ([[companyConfigDict valueForKey:@"additionalfilters"]length]>0)
        _selectedStock=[[NSMutableArray alloc]initWithObjects:@"All",@"Select",selectprice,[companyConfigDict valueForKey:@"additionalfilters"],@"",@"",@"",@"",@"",@"", nil];
    
    
}

-(BOOL) navigationShouldPopOnBackButton
{
    [self done_Click:nil];
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    doneToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard:)],
                           nil];
    [doneToolbar sizeToFit];
    
    
    
    
    
    selectTextField=NO;
    
    self.title = @"Filters";
    arrRows = [NSMutableArray array];
    // filterArr= [returnDictionary  valueForKey:@"filter"];
    // _segmentFilter.selectedSegmentIndex = 1;

    
    tblCatalogueFilter.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    tblCatalogueFilter.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
    
    // check for App, company and user level configuration (privileges)
    [self reloadConfigData];
    [kNSNotificationCenter addObserver:self selector:@selector(reloadConfigData) name:kRefreshConfigData object:nil];
    
    _segmentFilter.apportionsSegmentWidthsByContent=YES;
    
   //desable subCat
    NSInteger categoryLevels = 1;
    if(companyConfigDict && [companyConfigDict objectForKey:@"generalconfig"]){
        categoryLevels =[[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"categorylevels"] integerValue];
    }
    if(categoryLevels<=1)
        [_segmentFilter setEnabled:NO forSegmentAtIndex:1];
    //end
    
    
    if (returnDictionary) {
        
        if([returnDictionary valueForKey:@"category"]){
            _selectedCategory=(NSMutableArray*) [returnDictionary valueForKey:@"category"] ;
        }
        
        if([returnDictionary valueForKey:@"sub-cat"]){
            _selectedSubCat=(NSMutableArray*) [returnDictionary valueForKey:@"sub-cat"] ;
        }
        
        if([returnDictionary valueForKey:@"filter"]){
            _selectedFilters=(NSMutableArray*) [returnDictionary valueForKey:@"filter"] ;
        }
        
        if([returnDictionary valueForKey:@"promotionalcode"]){
            _selectedPromotionalCodes=(NSMutableArray*) [returnDictionary valueForKey:@"promotionalcode"] ;
        }
        
        
        if ([returnDictionary valueForKey:@"stock"]) {
            _selectedStock=[[NSMutableArray alloc]init];
            _selectedStock=(NSMutableArray*) [returnDictionary valueForKey:@"stock"];
        }
        
       /*if([[returnDictionary valueForKey:@"category"] count]>0) {
           selectedOption = 3;
           arrRows=[NSMutableArray arrayWithArray:_selectedCategory] ;
       }else*/
       {
           selectedOption = 3;
           [self loadDataWithSelectedOption:selectedOption];
       }
        
        
    }else{
        selectedOption = 3;
        [self loadDataWithSelectedOption:selectedOption];
    }
    
    
        [kNSNotificationCenter addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        [kNSNotificationCenter addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
}

-(void)loadDataWithSelectedOption:(NSInteger)seloption{
    [arrRows removeAllObjects];
    NSString *predicateStr = @"";
    
    if(seloption==2){
        arrRows = [[NSMutableArray alloc]initWithObjects:@"Type",@"Sort",@"Price Range", nil];
        if ([[companyConfigDict valueForKey:@"additionalfilters"]length]>0)
            arrRows = [[NSMutableArray alloc]initWithObjects:@"Type",@"Sort",@"Price Range",[companyConfigDict valueForKey:@"additionalfilters"], nil];
        
        
        return;
    }
    
    NSManagedObjectContext *context = [kAppDelegate managedObjectContext];
    NSError *err = nil;
    
    // to remove segment group if extra (promotional) group codes not available & IsProductFamilyTags=false from app config
    
    
    // to load general filter option
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity;// = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];
    NSSortDescriptor *sortDes;
    if(seloption==3) {//Cat & Sub-cat
        entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];
        sortDes=[[NSSortDescriptor alloc]initWithKey:@"gdescription" ascending:YES];
        [fetch setEntity:entity];
        NSMutableArray *predicatesArr=[[NSMutableArray alloc] init];
        
        //Check SubCategory
        if (_selectedSubCat){
            
            //Sub Category
            NSPredicate * PredicateconStr1;
            NSString *conStr1=@"";
            for(NSString *catID in [[_selectedSubCat filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
                conStr1= [conStr1 stringByAppendingString:[NSString stringWithFormat:@"%@,",catID]];
            }
            
            if([conStr1 length]>0){
                conStr1 = [conStr1 substringToIndex:[conStr1 length] - 1];//remove last ,
                NSArray *tempArray=[conStr1 componentsSeparatedByString:@","];
                PredicateconStr1 =[NSPredicate predicateWithFormat:@" grp2 in %@",tempArray];
                [predicatesArr addObject:PredicateconStr1];
            }
            
            //NOT
            NSString *conStr2=@"";
            NSPredicate * PredicateconStr2;
            for(NSString *catID in [[_selectedSubCat filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){
                conStr2= [conStr2 stringByAppendingString:[NSString stringWithFormat:@"%@,",catID]];
            }
            
            if([conStr2 length]>0){
                conStr2 = [conStr2 substringToIndex:[conStr2 length] - 1];//remove last ,
                NSArray *tempArray=[conStr2 componentsSeparatedByString:@","];
                PredicateconStr2 =[NSPredicate predicateWithFormat:@" NOT (grp2 in %@)",tempArray];
                [predicatesArr addObject:PredicateconStr2];
            }
        }//end
        //Extra Group
        if (_selectedPromotionalCodes){
            
            NSMutableArray *compPredArry1=[[NSMutableArray alloc]init];
            NSMutableArray *compPredArry2=[[NSMutableArray alloc]init];
            NSPredicate *compPredicate1;
            NSPredicate *compPredicate2;
            
            for(NSString *groupID in [[_selectedPromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
                
                // if([compPredArry1 count]==0){
                NSPredicate *predicateExt=nil;
                
                if ([groupID isEqualToString:@"Multiple Groups"]) {
                    
                    predicateExt=[NSPredicate predicateWithFormat:@"((extracode1!='' and extracode2!='' and extracode3!='' and (extracode1!=extracode2 and extracode1!=extracode3))  or (extracode1!='' and extracode2!=''  and extracode1!=extracode2) or (extracode1!=''  and extracode3!='' and extracode1!=extracode3)  or (extracode2!='' and extracode3!='' and extracode2!=extracode3))"];
                }else
                    predicateExt=[NSPredicate predicateWithFormat:@"extracode1 = %@ or extracode2 = %@ or extracode3 = %@ ",groupID,groupID,groupID];
                
                [compPredArry1 addObject:predicateExt];
                
            }
            
            if ([compPredArry1 count]>0){
                compPredicate1 =[NSCompoundPredicate orPredicateWithSubpredicates:compPredArry1];
                [predicatesArr addObject:compPredicate1];
            }
            
            
            //NOT IN
            for(NSString *groupID in [[_selectedPromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){
                
                // if([compPredArry2 count]){
                NSPredicate *predicateExt=nil;
                if ([groupID isEqualToString:@"Multiple Groups"]) {
                    predicateExt=[NSPredicate predicateWithFormat:@"((extracode1!='' && extracode2!='' && extracode3!='' and (extracode1=extracode2 and extracode1=extracode3)) or (extracode1!='' and extracode2!=''  and extracode1=extracode2) or (extracode1!=''  and extracode3!='' and extracode1=extracode3) or (extracode2!='' and extracode3!='' and extracode2=extracode3) or (extracode1='' and extracode2='') or (extracode2='' and extracode3='') or (extracode1='' and extracode3=''))"];
                   
                }else
                    predicateExt=[NSPredicate predicateWithFormat:@"extracode1 != %@ && extracode2 != %@ && extracode3 != %@ ",groupID,groupID,groupID];
                
                if (predicateExt)
                    [compPredArry2 addObject:predicateExt];
                
               
                
            }
            
            if ([compPredArry2 count]>0){
                compPredicate2 =[NSCompoundPredicate andPredicateWithSubpredicates:compPredArry2];
                [predicatesArr addObject:compPredicate2];
            }
            
            
        }//end
        
        // Add predicates to array
        NSPredicate *compoundPredicate = nil;
        if([predicatesArr count]==1)
            compoundPredicate = [predicatesArr lastObject];
        else if ([predicatesArr count]>1)
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArr];
        
        if (compoundPredicate){
            [fetch setPredicate:compoundPredicate];
        }
        
        
        
        
        
    }else if(seloption==4){
        sortDes=[[NSSortDescriptor alloc]initWithKey:@"gdescription" ascending:YES];
       
        
        
        NSMutableArray *predicatesArr=[[NSMutableArray alloc] init];
        entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];
        [fetch setEntity:entity];
        //Check Category
        if (_selectedCategory){
            
            //Category
            NSPredicate * PredicateconStr1;
            NSString *conStr1=@"";
            for(NSString *catID in [[_selectedCategory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
                conStr1= [conStr1 stringByAppendingString:[[NSString stringWithFormat:@"%@,",catID]stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceCharacterSet]]];
            }
            
            if([conStr1 length]>0){
                conStr1 = [conStr1 substringToIndex:[conStr1 length] - 1];//remove last ,
                NSArray *tempArray=[conStr1 componentsSeparatedByString:@","];
                PredicateconStr1 =[NSPredicate predicateWithFormat:@" category in %@",tempArray];
                [predicatesArr addObject:PredicateconStr1];
                
            }
            
            //NOT
            NSString *conStr2=@"";
            NSPredicate * PredicateconStr2;
            for(NSString *catID in [[_selectedCategory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){
                conStr2= [conStr2 stringByAppendingString:[[NSString stringWithFormat:@"%@,",catID]stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceCharacterSet]]];
            }
            
            if([conStr2 length]>0){
                conStr2 = [conStr2 substringToIndex:[conStr2 length] - 1];//remove last ,
                NSArray *tempArray=[conStr2 componentsSeparatedByString:@","];
                PredicateconStr2 =[NSPredicate predicateWithFormat:@" NOT (category in %@)",tempArray];
                [predicatesArr addObject:PredicateconStr2];
            }
        }
        
        //Extra Group
        if (_selectedPromotionalCodes){
            
            NSMutableArray *compPredArry1=[[NSMutableArray alloc]init];
            NSMutableArray *compPredArry2=[[NSMutableArray alloc]init];
            NSPredicate *compPredicate1;
            NSPredicate *compPredicate2;
            
            for(NSString *groupID in [[_selectedPromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
                
                NSPredicate *predicateExt=nil;
                
                if ([groupID isEqualToString:@"Multiple Groups"]) {
                    
                    predicateExt=[NSPredicate predicateWithFormat:@"((extracode1!='' and extracode2!='' and extracode3!='' and (extracode1!=extracode2 and extracode1!=extracode3))  or (extracode1!='' and extracode2!=''  and extracode1!=extracode2) or (extracode1!=''  and extracode3!='' and extracode1!=extracode3)  or (extracode2!='' and extracode3!='' and extracode2!=extracode3))"];
                }else
                    predicateExt=[NSPredicate predicateWithFormat:@"extracode1 = %@ or extracode2 = %@ or extracode3 = %@ ",groupID,groupID,groupID];
                
                [compPredArry1 addObject:predicateExt];
                
            }
            
            if ([compPredArry1 count]>0){
                compPredicate1 =[NSCompoundPredicate orPredicateWithSubpredicates:compPredArry1];
                [predicatesArr addObject:compPredicate1];
            }
            
            //NOT IN
            for(NSString *groupID in [[_selectedPromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){
                
                
                NSPredicate *predicateExt=nil;
                if ([groupID isEqualToString:@"Multiple Groups"]) {
                    predicateExt=[NSPredicate predicateWithFormat:@"((extracode1!='' && extracode2!='' && extracode3!='' and (extracode1=extracode2 and extracode1=extracode3)) or (extracode1!='' and extracode2!=''  and extracode1=extracode2) or (extracode1!=''  and extracode3!='' and extracode1=extracode3) or (extracode2!='' and extracode3!='' and extracode2=extracode3) or (extracode1='' and extracode2='') or (extracode2='' and extracode3='') or (extracode1='' and extracode3=''))"];
                }else
                    predicateExt=[NSPredicate predicateWithFormat:@"extracode1 != %@ && extracode2 != %@ && extracode3 != %@ ",groupID,groupID,groupID];
                
                if (predicateExt)
                    [compPredArry2 addObject:predicateExt];
                
            }
            
            if ([compPredArry2 count]>0){
                compPredicate2 =[NSCompoundPredicate andPredicateWithSubpredicates:compPredArry2];
                [predicatesArr addObject:compPredicate2];
            }
            
            
        }
        
        
        // Add predicates to array
        NSPredicate *compoundPredicate = nil;
        if([predicatesArr count]==1)
            compoundPredicate = [predicatesArr lastObject];
        else if ([predicatesArr count]>1)
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArr];
        
        if (compoundPredicate){
            [fetch setPredicate:compoundPredicate];
        }
        
        
        //select * from ZProd where zcategory IN ('DIY')
        
        
        
        
        
    }
    else if(seloption==0){
        
        NSMutableArray *predicatesArr=[[NSMutableArray alloc] init];
        sortDes=[[NSSortDescriptor alloc]initWithKey:@"gdescription" ascending:YES];
        entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];
        [fetch setEntity:entity];
        //Check Category
        if (_selectedCategory){
            
            //Category
            NSPredicate * PredicateconStr1;
            NSString *conStr1=@"";
            for(NSString *catID in [[_selectedCategory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
                conStr1= [conStr1 stringByAppendingString:[[NSString stringWithFormat:@"%@,",catID]stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceCharacterSet]]];
            }
            
            if([conStr1 length]>0){
                conStr1 = [conStr1 substringToIndex:[conStr1 length] - 1];//remove last ,
                NSArray *tempArray=[conStr1 componentsSeparatedByString:@","];
                PredicateconStr1 =[NSPredicate predicateWithFormat:@" category in %@",tempArray];
                [predicatesArr addObject:PredicateconStr1];
                
            }
            
            //NOT
            NSString *conStr2=@"";
            NSPredicate * PredicateconStr2;
            for(NSString *catID in [[_selectedCategory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){
                conStr2= [conStr2 stringByAppendingString:[[NSString stringWithFormat:@"%@,",catID]stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceCharacterSet]]];
            }
            
            if([conStr2 length]>0){
                conStr2 = [conStr2 substringToIndex:[conStr2 length] - 1];//remove last ,
                NSArray *tempArray=[conStr2 componentsSeparatedByString:@","];
                PredicateconStr2 =[NSPredicate predicateWithFormat:@" NOT (category in %@)",tempArray];
                [predicatesArr addObject:PredicateconStr2];
            }
        }
        
        //Check SubCategory
        if (_selectedSubCat){
            
            //Category
            NSPredicate * PredicateconStr1;
            NSString *conStr1=@"";
            for(NSString *catID in [[_selectedSubCat filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1"] ]valueForKey:@"identifier"] ){
                conStr1= [conStr1 stringByAppendingString:[[NSString stringWithFormat:@"%@,",catID]stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceCharacterSet]]];
            }
            
            if([conStr1 length]>0){
                conStr1 = [conStr1 substringToIndex:[conStr1 length] - 1];//remove last ,
                NSArray *tempArray=[conStr1 componentsSeparatedByString:@","];
                PredicateconStr1 =[NSPredicate predicateWithFormat:@" grp2 in %@",tempArray];
                [predicatesArr addObject:PredicateconStr1];
            }
            
            //NOT
            NSString *conStr2=@"";
            NSPredicate * PredicateconStr2;
            for(NSString *catID in [[_selectedSubCat filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2"] ]valueForKey:@"identifier"] ){
                conStr2= [conStr2 stringByAppendingString:[[NSString stringWithFormat:@"%@,",catID] stringByTrimmingCharactersInSet:
                                                           [NSCharacterSet whitespaceCharacterSet]]];
            }
            
            if([conStr2 length]>0){
                conStr2 = [conStr2 substringToIndex:[conStr2 length] - 1];//remove last ,
                NSArray *tempArray=[conStr2 componentsSeparatedByString:@","];
                PredicateconStr2 =[NSPredicate predicateWithFormat:@" NOT (grp2 in %@)",tempArray];
                [predicatesArr addObject:PredicateconStr2];
            }
        }//END SubCat
        
        
        
        // Add predicates to array
        NSPredicate *compoundPredicate = nil;
        if([predicatesArr count]==1)
            compoundPredicate = [predicatesArr lastObject];
        else if ([predicatesArr count]>1)
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArr];
        
        if (compoundPredicate){
            [fetch setPredicate:compoundPredicate];
        }
        
        
        
    }else{
        entity = [NSEntityDescription entityForName:@"PROD" inManagedObjectContext:context];
        [fetch setEntity:entity];
        
        if ([predicateStr length]>0){
            [fetch setPredicate:[NSPredicate predicateWithFormat:predicateStr]];
        }
    }
    
    
    
    NSArray *results;
    
    if(seloption==1){
        NSAttributeDescription* statusname = [entity.attributesByName objectForKey:@"status"];
        NSMutableArray *arrGroupBy = [NSMutableArray arrayWithObjects:statusname, nil];
        
        NSMutableArray *arrFetchList = [NSMutableArray arrayWithArray:arrGroupBy];
        
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"stock_code"]; // Does not really matter
        NSExpression *countExpression = [NSExpression expressionForFunction: @"count:"
                                                                  arguments: [NSArray arrayWithObject:keyPathExpression]];
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        [expressionDescription setName: @"count"];
        [expressionDescription setExpression: countExpression];
        [expressionDescription setExpressionResultType: NSInteger32AttributeType];
        [arrFetchList addObject:expressionDescription];
        
        [fetch setPropertiesToFetch:arrFetchList];
        [fetch setPropertiesToGroupBy:arrGroupBy];
        [fetch setResultType:NSDictionaryResultType];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetch setSortDescriptors:sortDescriptors];
        
        if (_predicateApplied) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.status!=null && self.status!=''"];
            NSArray *predicates = [NSArray arrayWithObjects:predicate,_predicateApplied, nil];
            
            [fetch setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
        }else
            [fetch setPredicate:[NSPredicate predicateWithFormat:@"self.status!=null && self.status!=''"]];
        
        
        results =[context executeFetchRequest:fetch error:&err];
    }
    else if(seloption==0){
        NSMutableArray *arrFetchList = [NSMutableArray arrayWithObjects:@"extracode1",@"extracode2",@"extracode3", nil];
        
        //        NSAttributeDescription* grpName1 = [entity.attributesByName objectForKey:@"extracode1"];
        //        NSAttributeDescription* grpName2 = [entity.attributesByName objectForKey:@"extracode2"];
        //        NSAttributeDescription* grpName3 = [entity.attributesByName objectForKey:@"extracode3"];
        //
        //        NSMutableArray *arrGroupBy = [NSMutableArray arrayWithObjects:grpName1,grpName2,grpName3, nil];
        //        NSMutableArray *arrFetchList = [NSMutableArray arrayWithArray:arrGroupBy];
        //
        
        
        //  [fetch setPropertiesToGroupBy:arrGroupBy];
        [fetch setResultType:NSDictionaryResultType];
        [fetch setPropertiesToFetch:arrFetchList];
        
        results =[[context executeFetchRequest:fetch error:&err] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(extracode1!=nil AND extracode1!='') || (extracode2!=nil AND extracode2!='') || (extracode3!=nil AND extracode3!='') "]]  ;
        
    }else if(seloption==4){
        //NSMutableArray *arrFetchList = [NSMutableArray arrayWithObjects:@"grp2", nil];
        
        NSAttributeDescription* grpName = [entity.attributesByName objectForKey:@"grp2"];
        NSMutableArray *arrGroupBy = [NSMutableArray arrayWithObjects:grpName, nil];
        NSMutableArray *arrFetchList = [NSMutableArray arrayWithArray:arrGroupBy];
        
        [fetch setPropertiesToFetch:arrFetchList];
        [fetch setPropertiesToGroupBy:arrGroupBy];
        [fetch setResultType:NSDictionaryResultType];
        
        //  results =[context executeFetchRequest:fetch error:&err];
        results =[[context executeFetchRequest:fetch error:&err] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"grp2!=nil AND grp2!=''"]]  ;
        
    }else if(seloption==3){
        
        NSAttributeDescription* grpName = [entity.attributesByName objectForKey:@"category"];
        NSMutableArray *arrGroupBy = [NSMutableArray arrayWithObjects:grpName, nil];
        NSMutableArray *arrFetchList = [NSMutableArray arrayWithArray:arrGroupBy];
        
        [fetch setPropertiesToFetch:arrFetchList];
        [fetch setPropertiesToGroupBy:arrGroupBy];
        [fetch setResultType:NSDictionaryResultType];
        
        // [fetch setSortDescriptors:[NSArray arrayWithObjects:sortDes, nil]];
        
        results =[[context executeFetchRequest:fetch error:&err] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category!=nil AND category!=''"]]  ;
    }
    
    //   results =[context executeFetchRequest:fetch error:&err];
    //DebugLog(@"%@ ",kAppDelegate.colorPool);
    
    if(!err && [results count]>0){
        if(seloption==1){
            [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //DebugLog(@"%@ = %li",[obj valueForKey:@"status"],[[obj valueForKey:@"count"] integerValue]);
                NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:[obj valueForKey:@"status"] forKey:@"identifier"];
                [dicinfo setObject:[obj valueForKey:@"status"] forKey:@"label"];
                [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"]; //Add Color
          //      [dicinfo setObject:[[obj valueForKey:@"status"] stringByAppendingFormat:@" (%li)",(long)[[obj valueForKey:@"count"] integerValue]] forKey:@"label"];
                
                NSArray *arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                NSArray *arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                
                if ([arr count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
                }else if ([arr2 count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
                }else
                     [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                
                
                [arrRows addObject:dicinfo];
            }];
            
            //ADD additional filter
            NSMutableDictionary *dicinfo;
            NSArray *arr;
            NSArray *arr2;
           
            if(_customerInfo){
                dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:@"Current" forKey:@"identifier"];
                [dicinfo setObject:@"Current" forKey:@"label"];
                [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                
                arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                
                if ([arr count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
                }else if ([arr2 count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
                }else
                    [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                
                [arrRows insertObject:dicinfo atIndex:0];
            }
            
            
            
            // config added by Satish on 20th Jan 16
            if ([[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"showinvoiceoutstandingninfilter"] boolValue] && _customerInfo){
                
                if ([[_customerInfo valueForKey: @"iheads"] count]>0) {
                    dicinfo = [NSMutableDictionary dictionary];
                    [dicinfo setObject:@"Invoiced" forKey:@"identifier"];
                    [dicinfo setObject:@"Invoiced" forKey:@"label"];
                    [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                    
                    NSArray *arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                    NSArray *arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                    
                    if ([arr count]>0) {
                        [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
                    }else if ([arr2 count]>0) {
                        [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
                    }else
                        [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                    
                    [arrRows insertObject:dicinfo atIndex:1];
                }
                
                if ([[_customerInfo valueForKey: @"oheads"] count]>0) {
                    dicinfo = [NSMutableDictionary dictionary];
                    [dicinfo setObject:@"Outstanding" forKey:@"identifier"];
                    [dicinfo setObject:@"Outstanding" forKey:@"label"];
                    [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                    
                    
                    arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                    arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                    
                    if ([arr count]>0) {
                        [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
                    }else if ([arr2 count]>0) {
                        [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
                    }else
                        [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                    
                    [arrRows insertObject:dicinfo atIndex:2];
                }
            }
            
            
            if ([commonMethods findTop20] >0) {
                dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:@"My Top 20" forKey:@"identifier"];
                [dicinfo setObject:@"My Top 20" forKey:@"label"];
                [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                
                arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                
                if ([arr count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
                }else if ([arr2 count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
                }else
                    [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                
                [arrRows addObject:dicinfo ];
            }
            
            dicinfo = [NSMutableDictionary dictionary];
            [dicinfo setObject:@"Out of Stock" forKey:@"identifier"];
            [dicinfo setObject:@"Out of Stock" forKey:@"label"];
            [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
            
            arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
            arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
            
            if ([arr count]>0) {
                [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
            }else if ([arr2 count]>0) {
                [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
            }else
            [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
            
            
            [arrRows addObject:dicinfo ];
            
            //quote manage by webconfig Should implemented
            if(_customerInfo){
                dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:@"Quote" forKey:@"identifier"];
                [dicinfo setObject:@"Quote" forKey:@"label"];
                [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                
                NSArray *arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                NSArray *arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                
                if ([arr count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
                }else if ([arr2 count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
                }else
                    [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                
                [arrRows addObject:dicinfo ];
            }
        }
        else if(seloption==0) {
            NSEntityDescription *entityextra = [NSEntityDescription entityForName:@"EXTRAGROUPCODES" inManagedObjectContext:context];
            NSFetchRequest *fetchExtra = [[NSFetchRequest alloc] init];
            [fetchExtra setEntity:entityextra];
            
            NSArray *resultsExtra = [context executeFetchRequest:fetchExtra error:&err];
            if(!err && [resultsExtra count]>0){
                [resultsExtra enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    
                    NSArray *arrProds = [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(extracode1==%@ || extracode2==%@ || extracode3==%@)",[obj valueForKey:@"extragroupcode"],[obj valueForKey:@"extragroupcode"],[obj valueForKey:@"extragroupcode"]]];
                    
                    NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                    [dicinfo setObject:[obj valueForKey:@"extragroupcode"] forKey:@"identifier"];
                    [dicinfo setObject:[obj valueForKey:@"gdescription"] forKey:@"label"];
                    //[dicinfo setObject:[[obj valueForKey:@"gdescription"] stringByAppendingFormat:@" (%li)",(long)[arrProds count]] forKey:@"label"];
                    if ([_selectedPromotionalCodes count]>0) {
                        
                        NSArray *arr=[[_selectedPromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@ ",[obj valueForKey:@"extragroupcode"]]] valueForKey:@"identifier"];
                        NSArray *arr2=[[_selectedPromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@ ",[obj valueForKey:@"extragroupcode"]]] valueForKey:@"identifier"];
                        
                        if ([arr count]>0) {
                            [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                        }else if ([arr2 count]>0) {
                            [dicinfo setValue:[NSNumber numberWithInt:2] forKey:@"state"];
                        }else
                            [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                        
                    }else
                        [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                    
                    //First time set default settings for ExtGroup
                    if ([_selectedPromotionalCodes count]==0 && [_ftSelExgroup length]>0 && [[dicinfo valueForKey:@"identifier"] isEqualToString:_ftSelExgroup]) {
                        [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                    }//end
                    
                    
                    [dicinfo setObject:[kAppDelegate.colorPoolGroup valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                   
                    if ([arrProds count]>0) {
                        [arrRows addObject:dicinfo];
                    }
                    
                }];
                
                
                
                NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:@"Multiple Groups" forKey:@"identifier"];
                [dicinfo setObject:@"Multiple Groups" forKey:@"label"];
                
                NSArray *arr=[[_selectedPromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@ ",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                NSArray *arr2=[[_selectedPromotionalCodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@ ",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                if ([arr count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                }else if ([arr2 count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInt:2] forKey:@"state"];
                }else
                    [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                [dicinfo setObject:[kAppDelegate.colorPoolGroup valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                [arrRows addObject:dicinfo];
                
            }else{
                
                [arrRows removeAllObjects];
            }
            
            
        }else if(seloption==3 && !err && [results count]>0){
            
            
            NSEntityDescription *entityextra = [NSEntityDescription entityForName:@"GROUP1CODES" inManagedObjectContext:context];
            NSFetchRequest *fetchExtra = [[NSFetchRequest alloc] init];
            [fetchExtra setEntity:entityextra];
            [fetchExtra setPredicate:[NSPredicate predicateWithFormat:@"group1code in %@",[results valueForKey:@"category"]]];
            [fetchExtra setSortDescriptors:[NSArray arrayWithObjects:sortDes, nil]];
            
            NSArray *resultsExtra = [context executeFetchRequest:fetchExtra error:&err];
            if(!err && [resultsExtra count]>0){
                
                [resultsExtra enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                    [dicinfo setObject:[obj valueForKey:@"group1code"] forKey:@"identifier"];
                    [dicinfo setObject:[obj valueForKey:@"gdescription"] forKey:@"label"];
                    
                    if ([_selectedCategory count]>0) {
                        
                        NSArray *arr=[[_selectedCategory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[obj valueForKey:@"group1code"]]] valueForKey:@"identifier"];
                        NSArray *arr2=[[_selectedCategory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[obj valueForKey:@"group1code"]]] valueForKey:@"identifier"];
                        
                        if ([arr count]>0) {
                            [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                        }else if ([arr2 count]>0) {
                            [dicinfo setValue:[NSNumber numberWithInt:2] forKey:@"state"];
                        }else
                            [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                        
                    }else
                        [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                    
                    //First time set default settings for Category
                    if ([_selectedCategory count]==0 && [_ftSelCat length]>0 && [[dicinfo valueForKey:@"identifier"] isEqualToString:_ftSelCat]) {
                        [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                    }

                    
                    // [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                    [arrRows addObject:dicinfo];
                }];
            }
            
            
            
            
            /*OLD [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
             [dicinfo setObject:[obj valueForKey:@"group1code"] forKey:@"identifier"];
             [dicinfo setObject:[obj valueForKey:@"gdescription"] forKey:@"label"];
             [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
             [arrRows addObject:dicinfo];
             }];*/
        }   else if(seloption==4 && !err && [results count]>0){
            
            
            /* __block NSString *predStr=@"";
             [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             
             if ([predStr length]>0) {
             predStr=[predStr stringByAppendingFormat:@" || group2code== '%@'",[obj valueForKey:@"grp2"]];
             }else
             predStr=[predStr stringByAppendingFormat:@"group2code== '%@'",[obj valueForKey:@"grp2"]];
             }];*/
            
            
            
            NSEntityDescription *entityextra = [NSEntityDescription entityForName:@"GROUP2CODES" inManagedObjectContext:context];
            NSFetchRequest *fetchExtra = [[NSFetchRequest alloc] init];
            [fetchExtra setEntity:entityextra];
            [fetchExtra setPredicate:[NSPredicate predicateWithFormat:@"group2code in %@",[results valueForKey:@"grp2"]]];
            [fetchExtra setSortDescriptors:[NSArray arrayWithObjects:sortDes, nil]];
            
            NSArray *resultsExtra = [context executeFetchRequest:fetchExtra error:&err];
            if(!err && [resultsExtra count]>0){
                
                [resultsExtra enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSMutableDictionary *dicinfo = [NSMutableDictionary dictionary];
                    [dicinfo setObject:[obj valueForKey:@"group2code"] forKey:@"identifier"];
                    [dicinfo setObject:[obj valueForKey:@"gdescription"] forKey:@"label"];
                    
                    if ([_selectedSubCat count]>0) {
                        
                        NSArray *arr=[[_selectedSubCat filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[obj valueForKey:@"group2code"]]] valueForKey:@"identifier"];
                        NSArray *arr2=[[_selectedSubCat filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[obj valueForKey:@"group2code"]]] valueForKey:@"identifier"];
                        
                        if ([arr count]>0) {
                            [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                        }else if ([arr2 count]>0) {
                            [dicinfo setValue:[NSNumber numberWithInt:2] forKey:@"state"];
                        }else
                            [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                        
                    }else
                        [dicinfo setValue:[NSNumber numberWithInt:0] forKey:@"state"];
                    
                    //First time set default settings for SubCat
                    if ([_selectedSubCat count]==0 && [_ftSelSubCat length]>0 && [[dicinfo valueForKey:@"identifier"] isEqualToString:_ftSelSubCat]) {
                        [dicinfo setValue:[NSNumber numberWithInt:1] forKey:@"state"];
                    }//end
                    //[dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                    [arrRows addObject:dicinfo];
                }];
            }
            
            
        }
        
    }
    else if ([results count]==0 && seloption==1){
        //ADD additional filter
        NSMutableDictionary *dicinfo;
        NSArray *arr;
        NSArray *arr2;
        
        if(_customerInfo){
            dicinfo = [NSMutableDictionary dictionary];
            [dicinfo setObject:@"Current" forKey:@"identifier"];
            [dicinfo setObject:@"Current" forKey:@"label"];
            [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
            
            arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
            arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
            
            if ([arr count]>0) {
                [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
            }else if ([arr2 count]>0) {
                [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
            }else
                [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
            
            [arrRows insertObject:dicinfo atIndex:0];
        }
        
        
        
        // config added by Satish on 20th Jan 16
        if ([[[companyConfigDict objectForKey:@"generalconfig"] objectForKey:@"showinvoiceoutstandingninfilter"] boolValue] && _customerInfo){
            
            
            if ([[_customerInfo valueForKey: @"iheads"] count]>0) {
                
                dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:@"Invoiced" forKey:@"identifier"];
                [dicinfo setObject:@"Invoiced" forKey:@"label"];
                [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                
                NSArray *arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                NSArray *arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                
                if ([arr count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
                }else if ([arr2 count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
                }else
                    [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                
                [arrRows insertObject:dicinfo atIndex:1];
            }
            
            
            if ([[_customerInfo valueForKey: @"oheads"] count]>0) {
                dicinfo = [NSMutableDictionary dictionary];
                [dicinfo setObject:@"Outstanding" forKey:@"identifier"];
                [dicinfo setObject:@"Outstanding" forKey:@"label"];
                [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
                
                
                arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
                
                if ([arr count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
                }else if ([arr2 count]>0) {
                    [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
                }else
                    [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
                
                [arrRows insertObject:dicinfo atIndex:2];
            }
        }
        
        if ([commonMethods findTop20] >0) {
            dicinfo = [NSMutableDictionary dictionary];
            [dicinfo setObject:@"My Top 20" forKey:@"identifier"];
            [dicinfo setObject:@"My Top 20" forKey:@"label"];
            [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
            
            arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
            arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
            
            if ([arr count]>0) {
                [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
            }else if ([arr2 count]>0) {
                [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
            }else
                [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
            
            [arrRows addObject:dicinfo ];
            
        }
        
        
        dicinfo = [NSMutableDictionary dictionary];
        [dicinfo setObject:@"Out of Stock" forKey:@"identifier"];
        [dicinfo setObject:@"Out of Stock" forKey:@"label"];
        [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
        
        arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
        arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
        
        if ([arr count]>0) {
            [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
        }else if ([arr2 count]>0) {
            [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
        }else
            [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
        
        
        [arrRows addObject:dicinfo ];
        
        //quote manage by webconfig Should implemented
        if(_customerInfo){
            dicinfo = [NSMutableDictionary dictionary];
            [dicinfo setObject:@"Quote" forKey:@"identifier"];
            [dicinfo setObject:@"Quote" forKey:@"label"];
            [dicinfo setObject:[kAppDelegate.colorPool valueForKey:[dicinfo valueForKey:@"identifier"]] forKey:@"color"];
            
            NSArray *arr=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =1 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
            NSArray *arr2=[[_selectedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state =2 && identifier ==[c] %@",[dicinfo valueForKey:@"identifier"]]] valueForKey:@"identifier"];
            
            if ([arr count]>0) {
                [dicinfo setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
            }else if ([arr2 count]>0) {
                [dicinfo setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
            }else
                [dicinfo setObject:[NSNumber numberWithInteger:0] forKey:@"state"]; // 0 - none selection, 1-include, 2-exclude
            
            [arrRows addObject:dicinfo ];
        }
    }
    
    //[tblCatalogueFilter reloadData];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (selectedOption==2){
        UILabel *lblheader=[[UILabel alloc]initWithFrame:CGRectMake(10, 2, 200, 20)];
        if(section==0)
            lblheader.text=@"Stock Status";
        else if (section==1)
            lblheader.text=@"";
        else if (section==2)
            lblheader.text=@"Price Range";
        else if (section==3 && [[companyConfigDict valueForKey:@"additionalfilters"]length]>0){
            lblheader.text=[companyConfigDict valueForKey:@"additionalfilters"];
            
        }
        UIView *headerView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
        [headerView addSubview:lblheader];
        
        headerView.backgroundColor=[UIColor lightGrayColor];
        return  headerView;
        //}else
        //  return  [[UIView alloc]initWithFrame:CGRectZero];
    }else
        return  [[UIView alloc]initWithFrame:CGRectZero];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (selectedOption==2){
        if (section==1)
            return 0.01;
        else
            return 25.0f;
        
    }else
        return 0.01;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedOption!=2){
        return 40.0;
    }else{
        if (indexPath.row==0) {
            return 45.0;
        }else
            return 80.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (selectedOption==2){
        return [arrRows count];
        
    }else
        return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (selectedOption==2){
        if (section==0 || section==2) {
            return 2;
        }else
            return 1;
        
    }else
        return [arrRows count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cellNEW forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    if(selectedOption == 1){
        
        FilterCell *cell =(FilterCell* )cellNEW;
        NSDictionary *dicinfo = [arrRows objectAtIndex:indexPath.row];
        cell.imageViewFilter.backgroundColor=[dicinfo valueForKey:@"color"];
    }
    else if(selectedOption==0){
        GroupCell *cell =(GroupCell* )cellNEW;
        NSDictionary *dicinfo = [arrRows objectAtIndex:indexPath.row];
        quartzview *q;
        q = [[quartzview alloc]initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
        [q setSelColor:[dicinfo valueForKey:@"color"]];
        [cell.imageViewGroup addSubview:q];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* ident = @"";
    if(selectedOption == 0){
        ident= @"GroupCell";
        
        GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (cell == nil){
            cell = [[GroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident] ;
        }
        NSDictionary *dicinfo = [arrRows objectAtIndex:indexPath.row];
        
        cell.lblTitle.text = [dicinfo objectForKey:@"label"];
        cell.selectionStyle = NO;
        
        if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue] ==0){
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==1) {
            [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==2){
            [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
        }
        
        return cell;
        
    }else  if(selectedOption == 1){
        ident= @"FilterCell";
        FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (cell == nil)
            cell = [[FilterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident] ;
        
        NSDictionary *dicinfo = [arrRows objectAtIndex:indexPath.row];
        cell.lblTitle.text = [dicinfo objectForKey:@"label"];
        
        
        if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue] ==0)
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
        else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==1) {
            [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==2){
            [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
        }
        
        cell.selectionStyle = NO;
        return cell;
        
        
    }else if(selectedOption == 2){
        ident = @"Cell3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident] ;
            //  cell.accessoryView =nil;
        }
            if (indexPath.section==0){
                
                if (indexPath.row==0) {
                    UIButton *btnType=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                    btnType.frame=CGRectMake(0, 0, 30, 22);
                    [btnType setTag:1001];
                    [btnType addTarget:self action:@selector(open_picker:) forControlEvents:UIControlEventTouchUpInside];
                    //[btnType setImage:[UIImage imageNamed:@"arrow-down.png"] forState:UIControlStateNormal];
                    // [cell setAccessoryView:btnType];
                    cell.textLabel.text=@"Select";
                    if ([_selectedStock count]>indexPath.section) {
                        cell.textLabel.text=[_selectedStock objectAtIndex:indexPath.section];
                    }
                    
                    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                }else{
                    
                    UILabel* lblFrm=[self createlabel:CGRectMake(lblX, 10, 40, 25)];
                    lblFrm.text=@"From";
                    [cell.contentView addSubview:lblFrm ];
                    
                    UILabel* lblTo=[self createlabel:CGRectMake(lblX, 45, 40, 25)];
                    lblTo.text=@"To";
                    [cell.contentView addSubview:lblTo ];
                    
                    UIView *uiview1=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 80)];
                    UITextField *txtFrm=[self createTextField:CGRectMake(0, 5, 70, 30)];
                    txtFrm.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
                    txtFrm.inputAccessoryView = doneToolbar;
                    [txtFrm setTag:2004];
                    if ([_selectedStock count]>4)
                        txtFrm.text=[_selectedStock objectAtIndex:4];
                    
                    [uiview1 addSubview:txtFrm ];
                    
                    
                    UITextField *txtTo=[self createTextField:CGRectMake(0, 45, 70, 30)];
                    txtTo.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
                    txtTo.inputAccessoryView = doneToolbar;
                    [txtTo setTag:2005];
                    if ([_selectedStock count]>5)
                        txtTo.text=[_selectedStock objectAtIndex:5];
                    
                    [uiview1 addSubview:txtTo ];
                    cell.accessoryView=uiview1;
                    
                }
                
            }else if (indexPath.section==1){
                
                
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                //cell.textLabel.text=@"Select";
                
                cell.textLabel.text=@"Select";
                if ([_selectedStock count]>indexPath.section) {
                    if ([[_selectedStock objectAtIndex:indexPath.section] isEqualToString:@"Select"]) {
                        cell.textLabel.text=@"Sort";
                    }else
                        cell.textLabel.text=[_selectedStock objectAtIndex:indexPath.section];
                }
            }
            else if (indexPath.section==2) {
                cell.textLabel.text = nil;
                if (indexPath.row==0) {
                    
                    UIButton *btnType=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                    btnType.frame=CGRectMake(0, 0, 30, 22);
                    [btnType setTag:1002];
                    [btnType addTarget:self action:@selector(open_picker:) forControlEvents:UIControlEventTouchUpInside];
                    //   [btnType setImage:[UIImage imageNamed:@"arrow-down.png"] forState:UIControlStateNormal];
                    //   [cell setAccessoryView:btnType];
                    cell.textLabel.text=@"Select";
                    if ([_selectedStock count]>indexPath.section) {
                        cell.textLabel.text=[_selectedStock objectAtIndex:indexPath.section];
                    }
                    
                    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                    
                }else{
                    //cell.accessoryView =nil;
                    
                    UILabel* lblFrm=[self createlabel:CGRectMake(lblX, 10, 40, 25)];
                    lblFrm.text=@"From";
                    [cell.contentView addSubview:lblFrm ];
                    
                    UILabel* lblTo=[self createlabel:CGRectMake(lblX, 45, 40, 25)];
                    lblTo.text=@"To";
                    [cell.contentView addSubview:lblTo ];
                    
                    
                    
                    UIView *uiview2=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 80)];
                    
                    UITextField *txtFrm=[self createTextField:CGRectMake(0, 5, 70, 30)];
                    txtFrm.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
                    txtFrm.inputAccessoryView = doneToolbar;
                    [txtFrm setDelegate:self];
                    [txtFrm setTag:2006];
                    if ([_selectedStock count]>6)
                        txtFrm.text=[_selectedStock objectAtIndex:6];
                    
                    
                    UITextField *txtTo=[self createTextField:CGRectMake(0, 45, 70, 30)];
                    txtTo.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
                    txtTo.inputAccessoryView = doneToolbar;
                    [txtTo setDelegate:self];
                    [txtTo setTag:2007];
                    if ([_selectedStock count]>7)
                        txtTo.text=[_selectedStock objectAtIndex:7];
                    
                    
                    [uiview2 addSubview:txtFrm];
                    [uiview2 addSubview:txtTo];
                    cell.accessoryView=uiview2;
                    
                    // cell.accessoryView.backgroundColor=[UIColor redColor];
                    
                }
                
                
            } else if ([[arrRows objectAtIndex:indexPath.section] isEqualToString:@"Colour"]){
                UILabel* lblFrm=[self createlabel:CGRectMake(lblX, 10, 40, 25)];
                lblFrm.text=@"From";
                [cell.contentView addSubview:lblFrm ];
                
                UILabel* lblTo=[self createlabel:CGRectMake(lblX, 45, 40, 25)];
                lblTo.text=@"To";
                [cell.contentView addSubview:lblTo ];
                
                UIView *uiview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 80)];
                UITextField *txtFrm=[self createTextField:CGRectMake(0, 5, 70, 25)];
                txtFrm.keyboardType=UIKeyboardTypePhonePad;
                txtFrm.inputAccessoryView = doneToolbar;
                [txtFrm setDelegate:self];
                [txtFrm setTag:2008];
                if ([_selectedStock count]>8)
                    txtFrm.text=[_selectedStock objectAtIndex:8];
                [uiview addSubview:txtFrm ];
                
                UITextField *txtTo=[self createTextField:CGRectMake(0, 5, 70, 25)];
                txtTo.keyboardType=UIKeyboardTypePhonePad;
                txtTo.inputAccessoryView = doneToolbar;
                [txtTo setDelegate:self];
                [txtTo setTag:2009];
                if ([_selectedStock count]>9)
                    txtTo.text=[_selectedStock objectAtIndex:9];
                [uiview addSubview:txtTo ];
                
                cell.accessoryView=uiview;
                
            } else
                cell.textLabel.text = [arrRows objectAtIndex:indexPath.section];
            
            cell.selectionStyle = NO;
       // }
        return cell;
        
    }if(selectedOption == 3 || selectedOption == 4){
        
        ident = @"FilterCatCell";
        FilterCatCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (cell == nil){
            cell = [[FilterCatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident] ;
            cell.accessoryView =nil;
        }
        NSDictionary *dicinfo = [arrRows objectAtIndex:indexPath.row];
        cell.lblTitle.text = [dicinfo objectForKey:@"label"];
        cell.selectionStyle = NO;
        
        
        if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue] ==0){
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==1) {
            [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==2){
            [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
        }
        
        return cell;
        
    }
    
    return  0;
}

NSIndexPath* lastIndexPath; // This as an ivar
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (selectedOption==0) {
        GroupCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *dict=[arrRows  objectAtIndex:indexPath.row];
        if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue] ==0){
            [dict setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==1) {
            [dict setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==2){
            [dict setValue:[NSNumber numberWithInteger:0] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
        }
    }
    else if (selectedOption==1){
        
        FilterCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *dict=[arrRows  objectAtIndex:indexPath.row];
        
        if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue] ==0){
            [dict setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==1) {
            [dict setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==2){
            [dict setValue:[NSNumber numberWithInteger:0] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
        }
    }
    else if (selectedOption==3){//Category
        
        FilterCatCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *dict=[arrRows  objectAtIndex:indexPath.row];
        if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue] ==0){
            [dict setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==1) {
            [dict setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==2){
            [dict setValue:[NSNumber numberWithInteger:0] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
        }
        
        
    }
    else if (selectedOption==4){//Sub Cat
        FilterCatCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *dict=[arrRows  objectAtIndex:indexPath.row];
        if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue] ==0){
            [dict setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:bluecheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==1) {
            [dict setValue:[NSNumber numberWithInteger:2] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:blueUnCheckImg forState:UIControlStateNormal];
        }else if ([[[arrRows objectAtIndex:indexPath.row]objectForKey:@"state"]integerValue]==2){
            [dict setValue:[NSNumber numberWithInteger:0] forKey:@"state"];
            [arrRows  replaceObjectAtIndex:indexPath.row withObject:dict];
            [cell.btnCheck setImage:nil forState:UIControlStateNormal];
        }
        
    }
    else if(selectedOption == 2){
        
        UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.section==0 && indexPath.row==0){
            [cell1 setTag:1001];
            [self open_picker:cell1];
            
        }else if (indexPath.section==1 && indexPath.row==0){
            [cell1 setTag:1002];
            [self open_picker:cell1];
        }else if (indexPath.section==2&& indexPath.row==0){
            [cell1 setTag:1003];
            [self open_picker:cell1];
        }
        
    }
}

- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 40, 7);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UITextField *)createTextField :(CGRect)frame{
    UITextField *txtField=[[UITextField alloc]initWithFrame:frame];
    txtField.textColor=[UIColor blackColor];
    txtField.font=[UIFont systemFontOfSize:13.0];
    txtField.layer.cornerRadius=5.0;
    txtField.layer.borderWidth=1.0;
    txtField.textAlignment=NSTextAlignmentCenter;
    txtField.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [txtField setDelegate:self];
    return txtField;
}

//******* Navigation buttons action
- (IBAction)done_Click:(id)sender{
    
    if (selectedOption==3) {
        _selectedCategory=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else if (selectedOption==4) {
        _selectedSubCat=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else   if (selectedOption==0) {
        _selectedPromotionalCodes=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else if(selectedOption==1){
        _selectedFilters=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else if(selectedOption==2){
        if (selectIndex>=0 && [txtfield.text length]>0) {
            [_selectedStock replaceObjectAtIndex:selectIndex withObject:txtfield.text];
        }
        [txtfield resignFirstResponder];
        
    }
    
    // if([self.delegate respondsToSelector:@selector(finishedFilterSelectionWithValues:)]){
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if(_selectedPromotionalCodes)
        [dic setObject:_selectedPromotionalCodes forKey:@"promotionalcode"];
    if(_selectedFilters)
        [dic setObject:_selectedFilters forKey:@"filter"];
    if(_selectedStock)
        [dic setObject:_selectedStock forKey:@"stock"];
    if(_selectedCategory)
        [dic setObject:_selectedCategory forKey:@"category"];
    if(_selectedSubCat)
        [dic setObject:_selectedSubCat forKey:@"sub-cat"];
    
    if([self.delegate respondsToSelector:@selector(finishedFilterSelectionWithValues:)]){
         [self.delegate finishedFilterSelectionWithValues:dic];
    }
   
    // }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clearAllCheck:(id)sender {
    
    [self dismissKeyboard:nil];
    
    
    if (selectedOption==2){
    
        [_selectedStock removeAllObjects];
        [arrRows removeAllObjects];
        
       // _selectedStock=[[NSMutableArray alloc]initWithObjects:@"Select",@"Select",@"Select",@"Select",@"",@"",@"",@"",@"",@"", nil];
        NSArray *arr = [[priceConfigDict objectForKey:@"pricetablabels"] valueForKey:@"field"] ;
        
        NSString *selectprice=@"Select";
        if ([arr count]>0) {
            selectprice=[arr objectAtIndex:0];
        }
        _selectedStock=[[NSMutableArray alloc]initWithObjects:@"All",@"Select",selectprice,@"Select",@"",@"",@"",@"",@"",@"", nil];
        
        
        arrRows = [[NSMutableArray alloc]initWithObjects:@"Type",@"Sort",@"Price Range", nil];
       
        if ([[companyConfigDict valueForKey:@"additionalfilters"]length]>0){
            _selectedStock=[[NSMutableArray alloc]initWithObjects:@"All",@"Select",selectprice,[companyConfigDict valueForKey:@"additionalfilters"],@"",@"",@"",@"",@"",@"", nil];
            arrRows = [[NSMutableArray alloc]initWithObjects:@"Type",@"Sort",@"Price Range",[companyConfigDict valueForKey:@"additionalfilters"], nil];
        }
        
        
            
        
        [tblCatalogueFilter reloadData];
        return;
    }
    
    [arrRows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dict1=[[NSMutableDictionary alloc]initWithDictionary:obj];
        [dict1 setValue:[NSNumber numberWithInteger:0] forKey:@"state"];
        [arrRows replaceObjectAtIndex:idx withObject:dict1];
    }];
    
    if (selectedOption==3) {
        _selectedCategory=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else if (selectedOption==4) {
        _selectedSubCat=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else   if (selectedOption==0) {
        _selectedPromotionalCodes=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else if(selectedOption==1){
        _selectedFilters=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }
    
    [tblCatalogueFilter reloadData];
    

    
}

- (IBAction)valueChanged:(UISegmentedControl *)sender {
    
    if ([sender tag]!=4) {
        [self dismissKeyboard:nil];
       
        if(!_pickerView.hidden){
            [_pickerView setHidden:YES];
            [_pickerToolbar setHidden:YES];}
    }
    
    
    NSInteger seloption=0;
    
    if (selectedOption==0) {
        _selectedPromotionalCodes=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else if(selectedOption==1){
        _selectedFilters=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else if(selectedOption==2){
        
        if (selectIndex>=0 && [txtfield.text length]>0) {
            [_selectedStock replaceObjectAtIndex:selectIndex withObject:txtfield.text];
        }
        [txtfield resignFirstResponder];
    }else if(selectedOption==3){
        _selectedCategory=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }else if(selectedOption==4){
        _selectedSubCat=[NSArray arrayWithArray:(NSMutableArray*) arrRows] ;
    }
    
    
    if([[[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] lowercaseString] hasPrefix:@"group"]){
        seloption=0;
        if ([_selectedPromotionalCodes count]==0 || [_selectedCategory count]>0) {
            [self loadDataWithSelectedOption:seloption];;
        }else{
            [arrRows removeAllObjects];
            arrRows=[NSMutableArray arrayWithArray:_selectedPromotionalCodes] ;
        }
        
        
    }else if([[[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] lowercaseString] hasPrefix:@"filter"]){
        seloption=1;
       // if ([_selectedFilters count]==0) {
            [self loadDataWithSelectedOption:seloption];
        //}else{
//            [arrRows removeAllObjects];
//            arrRows=[NSMutableArray arrayWithArray:_selectedFilters] ;
//        }
        
    }else if([[[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] lowercaseString] hasPrefix:@"stocks"]){
        seloption=2;
        [self loadDataWithSelectedOption:seloption];
        
    }else if([[[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] lowercaseString] hasPrefix:@"category"]){
        seloption=3;
        //if ([_selectedCategory count]==0) {
        [self loadDataWithSelectedOption:seloption];
        //        }else{
        //            [arrRows removeAllObjects];
        //            arrRows=[NSMutableArray arrayWithArray:_selectedCategory] ;
        //       }
    }else if([[[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] lowercaseString] hasPrefix:@"sub-cat"]){
        seloption=4;
        // if ([_selectedSubCat count]==0 || [_selectedCategory count]>0) {
        [self loadDataWithSelectedOption:seloption];
        // }else{
        //    [arrRows removeAllObjects];
        //    arrRows=[NSMutableArray arrayWithArray:_selectedSubCat] ;
        //}
    }
    
    
    selectedOption=seloption;
    [self.tblCatalogueFilter reloadData];
}

//Stock Filter
-(UILabel *)createlabel :(CGRect)frame{
    UILabel *lbl=[[UILabel alloc]initWithFrame:frame];
    lbl.textColor=[UIColor blackColor];
    lbl.font=[UIFont systemFontOfSize:15.0];
    return lbl;
}

-(UITextField *)text_Field :(CGRect)frame{
    UITextField *txtField=[[UITextField alloc]initWithFrame:frame];
    txtField.textColor=[UIColor blackColor];
    txtField.font=[UIFont systemFontOfSize:15.0];
    return txtField;
}

//Picker Data
- (void)open_picker:(id)sender{
    
    if (txtfield.becomeFirstResponder) {
      
     [[self view] endEditing:TRUE];
    if (selectIndex>=0 && [txtfield.text length]>0) {
        [_selectedStock replaceObjectAtIndex:selectIndex withObject:txtfield.text];
    }
    }
    
    // UIButton *button = (UIButton *)sender;
    if ([sender tag]==1001) {
        
        colrFiltrArr=@[@"All",@"Physical",@"Free",@"Available"];
    }else if([sender tag]==1002){
        colrFiltrArr = @[@"Ascending",@"Descending"];
    }else if([sender tag]==1003){
        colrFiltrArr = [[priceConfigDict objectForKey:@"pricetablabels"] valueForKey:@"field"] ;//@[@"Price1",@"Price2",@"RRP"];
    }
    
    mainIndex=[sender tag]-1001;
    
    
    if ([colrFiltrArr count]>0) {
        [_pickerView setHidden:NO];
        [_pickerToolbar setHidden:NO];
        
        ///UIView *contentView = button.superview;
        pickerCell =(UITableViewCell* )sender;
        /*if([sender tag]==1002)
           pickerLabel=@"Sort";
        else*/
            pickerLabel=[colrFiltrArr objectAtIndex:0];
           
       // pickerCell.textLabel.text=[colrFiltrArr objectAtIndex:0];
        
        [_pickerView reloadAllComponents];
        NSInteger selindex=0;
        
        if([sender tag]==1002 && ![pickerCell.textLabel.text isEqualToString:@"Sort"]){
            selindex=[colrFiltrArr indexOfObject:pickerCell.textLabel.text];
            pickerCell.textLabel.text=[colrFiltrArr objectAtIndex:selindex];
            pickerLabel=[colrFiltrArr objectAtIndex:selindex];
            
            [_pickerView selectRow:selindex inComponent:0 animated:YES];
            
        }else  if ([sender tag]!=1002 &&![pickerCell.textLabel.text isEqualToString:@"Select"]){
            selindex=[colrFiltrArr indexOfObject:pickerCell.textLabel.text];
            pickerCell.textLabel.text=[colrFiltrArr objectAtIndex:selindex];
            pickerLabel=[colrFiltrArr objectAtIndex:selindex];
            [_pickerView selectRow:selindex inComponent:0 animated:YES];
        }
    }
}

#pragma mark -
#pragma mark Text Filed

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    
    if(!_pickerView.hidden){
    [_pickerView setHidden:YES];
    [_pickerToolbar setHidden:YES];
       
    if (mainIndex>=0)
        [_selectedStock replaceObjectAtIndex:mainIndex withObject:pickerCell.textLabel.text];
    
    }
    
    selectIndex=textField.tag-2000;
    txtfield=(UITextField* )textField;
    
    CGPoint origin = textField.frame.origin;
    CGPoint point = [textField.superview convertPoint:origin toView:self.tblCatalogueFilter];
    editIndexPath = [self.tblCatalogueFilter indexPathForRowAtPoint:point];
    
    
        if (selectTextField) {
            [textField performSelector:@selector(selectAll:) withObject:textField afterDelay:0.25];
            selectTextField=NO;
        }
    
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
    
    
    
    NSString *tstring;

    if ([textField tag]==2006) {
        tstring = [NSString stringWithFormat:@"%@",textField.text];
        
        if([tstring rangeOfString:@"."].location!=NSNotFound)
        {
        }
        else{
            if([textField.text length]>0){
                double txt1 = [textField.text doubleValue];
                
                txt1 = txt1/100;
                textField.text = [NSString stringWithFormat:@"%.2f",txt1];
                txtfield.text = [NSString stringWithFormat:@"%.2f",txt1];
            }
        }
        selectTextField=YES;
        
        UITextField *txtTo=(UITextField *)[self.view viewWithTag:2007];
        
        if(txtTo.text.length == 0 && textField.text.length !=0)
        {
            txtTo.text = textField.text;
            selectTextField=YES;
            
           
            if (selectIndex>=0 && [txtfield.text length]>0)
                [_selectedStock replaceObjectAtIndex:selectIndex withObject:txtfield.text];
            
            txtfield=nil;
            
            [txtTo becomeFirstResponder];
           
        }
        
    }else if([textField tag]==2007){
        
        
        tstring = [NSString stringWithFormat:@"%@",textField.text];
        if([tstring rangeOfString:@"."].location!=NSNotFound)
        {
        }
        else{
            if([textField.text length]>0){
                double txt2 = [textField.text doubleValue];
                txt2 = txt2/100;
                textField.text = [NSString stringWithFormat:@"%.2f",txt2];
                txtfield.text = [NSString stringWithFormat:@"%.2f",txt2];
            }
        }
        
        UITextField *txtFrom=(UITextField *)[self.view viewWithTag:2006];
        if(txtFrom.text.length == 0 && textField.text.length !=0)
        {
            txtFrom.text = textField.text;
            selectTextField=YES;
            
            if (selectIndex>=0 && [txtfield.text length]>0)
                [_selectedStock replaceObjectAtIndex:selectIndex withObject:txtfield.text];
            txtfield=nil;
            
            [txtFrom becomeFirstResponder];
            
        }
        
    }

    
    
    if (selectIndex>=0 && [txtfield.text length]>0) {
        [_selectedStock replaceObjectAtIndex:selectIndex withObject:txtfield.text];
    }
    
    txtfield=nil;
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
   
    NSString *tstring;
    if ([textField tag]==2006) {
        tstring = [NSString stringWithFormat:@"%@",textField.text];
        
        if([tstring rangeOfString:@"."].location!=NSNotFound)
        {
        }
        else{
            if([textField.text length]>0){
                double txt1 = [textField.text doubleValue];
                
                txt1 = txt1/100;
                textField.text = [NSString stringWithFormat:@"%.2f",txt1];
                txtfield.text = [NSString stringWithFormat:@"%.2f",txt1];
            }
        }
        selectTextField=YES;
    
    UITextField *txtTo=(UITextField *)[self.view viewWithTag:2007];
        
        if(txtTo.text.length == 0 && textField.text.length !=0)
        {
            txtTo.text = textField.text;
            
            //self.SelectToPrice = txtTo.text;
            selectTextField=YES;
            
            if (selectIndex>=0 && [txtfield.text length]>0)
                [_selectedStock replaceObjectAtIndex:selectIndex withObject:txtfield.text];
            
            txtfield=nil;

            [txtTo becomeFirstResponder];
        }

    }else if([textField tag]==2007){
        
        
        tstring = [NSString stringWithFormat:@"%@",textField.text];
        if([tstring rangeOfString:@"."].location!=NSNotFound)
        {
        }
        else{
            if([textField.text length]>0){
                double txt2 = [textField.text doubleValue];
                txt2 = txt2/100;
                textField.text = [NSString stringWithFormat:@"%.2f",txt2];
                txtfield.text = [NSString stringWithFormat:@"%.2f",txt2];
            }
        }
    }
    
    
    [textField resignFirstResponder];
    return YES;
}









#pragma mark -
#pragma mark picker view methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    pickerLabel=[colrFiltrArr objectAtIndex:row];
    //pickerCell.textLabel.text=[colrFiltrArr objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [colrFiltrArr count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [colrFiltrArr objectAtIndex:row];
}


- (IBAction)pickerDoneClick:(id)sender {
   
    [_pickerView setHidden:YES];
    [_pickerToolbar setHidden:YES];
    pickerCell.textLabel.text =pickerLabel;
    [_selectedStock replaceObjectAtIndex:mainIndex withObject:pickerCell.textLabel.text];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    self.tblCatalogueFilter.contentInset = contentInsets;
    self.tblCatalogueFilter.scrollIndicatorInsets = contentInsets;
    [self.tblCatalogueFilter scrollToRowAtIndexPath:editIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tblCatalogueFilter.contentInset = UIEdgeInsetsZero;
    self.tblCatalogueFilter.scrollIndicatorInsets = UIEdgeInsetsZero;
}


- (IBAction)dismissKeyboard:(id)sender {
    [[self view] endEditing:TRUE];
   // [_btnOverlay setHidden:YES];
}

@end
