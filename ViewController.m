//
//  ViewController.m
//  CollectionviewSort
//
//  Created by wangwenke on 16/4/12.
//  Copyright © 2016年 wangwenke. All rights reserved.
//

#import "ViewController.h"
#import "MineCollectionViewCell.h"
#import "CollectionReusableView.h"
#define DEVICE_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define DEVICE_HEIGHT  ([UIScreen mainScreen].bounds.size.height)
static NSString *collectionCell = @"mineCell";
static NSString *collectionHeader = @"mineHeader";
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *mineCollection;
@property (nonatomic, strong) NSMutableArray *imagesSectionOneArray;
@property (nonatomic, strong) NSMutableArray *imagesSectionTwoArray;
@property (nonatomic, strong) NSMutableArray *cellAttributesArray;
@property (nonatomic, assign) CGPoint lastPressPoint;

/**
 * scrollerTimer
 */
@property (nonatomic, strong) NSTimer *scrollerTimer;
@property (nonatomic, assign) CGFloat scrollerValue;
@property (nonatomic, assign) BOOL isCanSort;//是否支持排序功能

//用于判断一、二分区是否有移动动画
@property (nonatomic, assign) BOOL isSorting;
@property (nonatomic, assign) BOOL sectionOneIsSort;
@property (nonatomic, assign) BOOL sectionTwoIsSort;

@end

@implementation ViewController

- (NSMutableArray *)imagesSectionOneArray{
    if (!_imagesSectionOneArray) {
        self.imagesSectionOneArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _imagesSectionOneArray;
}

- (NSMutableArray *)imagesSectionTwoArray{
    if (!_imagesSectionTwoArray) {
        self.imagesSectionTwoArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _imagesSectionTwoArray;
}

- (NSMutableArray *)cellAttributesArray{
    if (!_cellAttributesArray) {
        self.cellAttributesArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _cellAttributesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    _lastPressPoint = CGPointZero;
    _isCanSort = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
    for (int i = 0; i < 15; i++) {
        [self.imagesSectionOneArray addObject:[NSString stringWithFormat:@"%d",i % 10 + 1]];
    }
    
    for (int i = 21; i < 30; i++) {
        [self.imagesSectionTwoArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 5.0;
    layout.minimumInteritemSpacing = 5.0;
    layout.sectionInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    _mineCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64.0, DEVICE_WIDTH, DEVICE_HEIGHT - 64.0) collectionViewLayout:layout];
    _mineCollection.backgroundColor = [UIColor lightGrayColor];
    _mineCollection.dataSource = self;
    _mineCollection.delegate = self;
    [_mineCollection registerClass:[MineCollectionViewCell class] forCellWithReuseIdentifier:collectionCell];
    [_mineCollection registerClass:[CollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeader];
    [self.view addSubview:_mineCollection];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return self.imagesSectionOneArray.count;
    }
    return self.imagesSectionTwoArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((DEVICE_WIDTH - 25.0) / 4.0, (DEVICE_WIDTH - 25.0) / 4.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(DEVICE_WIDTH, 44.0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCell forIndexPath:indexPath];
    cell.hidden = NO;
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.section == 0) {
        cell.cellImage.image = [UIImage imageNamed:self.imagesSectionOneArray[indexPath.row]];
        if (_sectionOneIsSort && indexPath.row + 1 == self.imagesSectionOneArray.count) {
            cell.hidden = YES;
        }
    }else{
        cell.cellImage.image = [UIImage imageNamed:self.imagesSectionTwoArray[indexPath.row]];
        if (_sectionTwoIsSort && indexPath.row + 1 == self.imagesSectionTwoArray.count) {
            cell.hidden = YES;
        }
    }
    
    for (UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [cell removeGestureRecognizer:gesture];
        }
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [cell addGestureRecognizer:longPress];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionHeader forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor whiteColor];
        if (indexPath.section == 0) {
            reusableView.title.text = [NSString stringWithFormat:@"section one"];

        }else{
            reusableView.title.text = [NSString stringWithFormat:@"section two"];
        }
        return reusableView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_isCanSort) {
        [self startMoveClickedCellAtIndexpath:indexPath];
        return;
    }
}


//长按拖动排序
- (void)longPressGesture:(UILongPressGestureRecognizer *)sender{
    if (!_isCanSort) {
        return;
    }
    MineCollectionViewCell *cell = (MineCollectionViewCell *)sender.view;
    [_mineCollection bringSubviewToFront:cell];
    NSIndexPath *cellIndexPath = [_mineCollection indexPathForCell:cell];
    [_mineCollection bringSubviewToFront:cell];
    BOOL isChanged = NO;
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.lastPressPoint = [sender locationInView:_mineCollection];
    }else if (sender.state == UIGestureRecognizerStateChanged){
        [self.cellAttributesArray removeAllObjects];
        for (int i = 0;i < self.imagesSectionOneArray.count; i++) {
            [self.cellAttributesArray addObject:[_mineCollection layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
        for (int i = 0;i < self.imagesSectionTwoArray.count; i++) {
            [self.cellAttributesArray addObject:[_mineCollection layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:1]]];
        }

        [self scrollerCollectionView:[sender locationInView:self.view]];
        cell.center = [sender locationInView:_mineCollection];
        
        for (UICollectionViewLayoutAttributes *attributes in self.cellAttributesArray) {
            if (CGRectContainsPoint(attributes.frame, cell.center) && cellIndexPath != attributes.indexPath) {
                isChanged = YES;
                //对数组中存放的元素重新排序
                if (cellIndexPath.section == attributes.indexPath.section) {
                    if (cellIndexPath.section == 0) {
                        NSString *imageStr = self.imagesSectionOneArray[cellIndexPath.row];
                        [self.imagesSectionOneArray removeObjectAtIndex:cellIndexPath.row];
                        [self.imagesSectionOneArray insertObject:imageStr atIndex:attributes.indexPath.row];

                    }else{
                        NSString *imageStr = self.imagesSectionTwoArray[cellIndexPath.row];
                        [self.imagesSectionTwoArray removeObjectAtIndex:cellIndexPath.row];
                        [self.imagesSectionTwoArray insertObject:imageStr atIndex:attributes.indexPath.row];
                    }
                    [self.mineCollection moveItemAtIndexPath:cellIndexPath toIndexPath:attributes.indexPath];
                }else{
                    if (cellIndexPath.section == 0) {//一区移动到二区
                        NSString *imageStr = self.imagesSectionOneArray[cellIndexPath.row];
                        [self.imagesSectionOneArray removeObjectAtIndex:cellIndexPath.row];
                        [self.imagesSectionTwoArray insertObject:imageStr atIndex:attributes.indexPath.row];

                    }else{//二区移动到一区
                        NSString *imageStr = self.imagesSectionTwoArray[cellIndexPath.row];
                        [self.imagesSectionTwoArray removeObjectAtIndex:cellIndexPath.row];
                        [self.imagesSectionOneArray insertObject:imageStr atIndex:attributes.indexPath.row];

                    }
                    [self.mineCollection moveItemAtIndexPath:cellIndexPath toIndexPath:attributes.indexPath];

                }
                
                
            }
        }
        
    }else if (sender.state == UIGestureRecognizerStateEnded) {
        if (!isChanged) {
            cell.center = [_mineCollection layoutAttributesForItemAtIndexPath:cellIndexPath].center;
        }
        NSLog(@"排序后---%d--%d",self.imagesSectionOneArray.count,self.imagesSectionTwoArray.count);
    }
    
    
}

//点击时排序
- (void)startMoveClickedCellAtIndexpath:(NSIndexPath *)indexPath{
    if (_isSorting) {
        return;
    }
    _isSorting = YES;
    MineCollectionViewCell *movedCell = (MineCollectionViewCell *)[_mineCollection cellForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *endAttributes = nil;
    NSIndexPath *endIndexPath = nil;
    if (indexPath.section == 0) {
        _sectionOneIsSort = NO;
        _sectionTwoIsSort = YES;
        [self.imagesSectionTwoArray addObject:[self.imagesSectionOneArray objectAtIndex:indexPath.row]];
        endIndexPath = [NSIndexPath indexPathForItem:_imagesSectionTwoArray.count - 1 inSection:1];
        [self.mineCollection insertItemsAtIndexPaths:@[endIndexPath]];
        [self.mineCollection reloadSections:[NSIndexSet indexSetWithIndex:1]];
    }else{
        _sectionOneIsSort = YES;
        _sectionTwoIsSort = NO;
        [self.imagesSectionOneArray addObject:[self.imagesSectionTwoArray objectAtIndex:indexPath.row]];
        endIndexPath = [NSIndexPath indexPathForItem:_imagesSectionOneArray.count - 1 inSection:0];
        [self.mineCollection insertItemsAtIndexPaths:@[endIndexPath]];
        [self.mineCollection reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    endAttributes = [_mineCollection layoutAttributesForItemAtIndexPath:endIndexPath];
    MineCollectionViewCell __weak *endCell = (MineCollectionViewCell *)[_mineCollection cellForItemAtIndexPath:endIndexPath];
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        movedCell.center = endAttributes.center;
    } completion:^(BOOL finished) {
        endCell.hidden = NO;
        movedCell.hidden = YES;
        weakSelf.sectionOneIsSort = NO;
        weakSelf.sectionTwoIsSort = NO;
        if (indexPath.section == 0) {
            [weakSelf.imagesSectionOneArray removeObjectAtIndex:indexPath.row];
            [weakSelf.mineCollection deleteItemsAtIndexPaths:@[indexPath]];
        }else{
            [weakSelf.imagesSectionTwoArray removeObjectAtIndex:indexPath.row];
            [weakSelf.mineCollection deleteItemsAtIndexPaths:@[indexPath]];

        }
        weakSelf.isSorting = NO;
    }];
}





//自动滑动collectionView
- (void)scrollerCollectionView:(CGPoint)point{
    if (point.y <= 10 + 64.0) {
        _scrollerValue = -1.0;
    }else if (point.y >= DEVICE_HEIGHT - 20.0){
        _scrollerValue = 1.0;
    }else{
        if (_scrollerTimer) {
            [_scrollerTimer invalidate];
            _scrollerTimer = nil;
        }
        return;
    }
    if (!_scrollerTimer) {
        _scrollerTimer = [NSTimer scheduledTimerWithTimeInterval:0.007 target:self selector:@selector(startScrollerCollectionView) userInfo:nil repeats:YES];
        [_scrollerTimer setFireDate:[NSDate distantPast]];
    }
    
}

- (void)startScrollerCollectionView{
    CGPoint point = self.mineCollection.contentOffset;
    if (point.y + _scrollerValue <= 0 || point.y + _scrollerValue + self.mineCollection.bounds.size.height >= self.mineCollection.contentSize.height) {
        [_scrollerTimer invalidate];
        _scrollerTimer = nil;
        return;
    }
    point = CGPointMake(point.x, point.y + _scrollerValue);
    _mineCollection.contentOffset = point;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
