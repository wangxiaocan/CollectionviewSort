//
//  MineCollectionViewCell.m
//  CollectionviewSort
//
//  Created by wangwenke on 16/4/12.
//  Copyright © 2016年 wangwenke. All rights reserved.
//

#import "MineCollectionViewCell.h"

@implementation MineCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _cellImage = [[UIImageView alloc]initWithFrame:CGRectMake(5.0, 5.0, frame.size.width - 10.0, frame.size.height - 10.0)];
        [self.contentView addSubview:_cellImage];
    }
    return self;
}

@end
