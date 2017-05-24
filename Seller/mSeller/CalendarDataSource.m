//
//  CalendarDataSource.m
//  mSeller
//
//  Created by Satish Kr Singh on 10/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CalendarDataSource.h"
#import "CalendarCollectionViewCell.h"

@interface CalendarDataSource()

@property(unsafe_unretained,nonatomic,readonly) NSInteger yearValue;
@end

@implementation CalendarDataSource

-(void)setYearValue:(NSInteger)yearval{
    _yearValue = yearval;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 12;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCollectionViewCell" forIndexPath:indexPath];
    [cell setValueForMonth:indexPath.item+1 Year:_yearValue];
    cell.delegate = collectionView.delegate;
    return cell;
}

@end
