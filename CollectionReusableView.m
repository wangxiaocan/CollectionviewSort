//
//  CollectionReusableView.m
//  CollectionviewSort
//
//  Created by wangwenke on 16/4/13.
//  Copyright © 2016年 wangwenke. All rights reserved.
//

#import "CollectionReusableView.h"

@implementation CollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _title = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 0, frame.size.width - 15.0, frame.size.height)];
        _title.font = [UIFont boldSystemFontOfSize:17.0];
        _title.textAlignment = NSTextAlignmentLeft;
        _title.textColor = [UIColor orangeColor];
        [self addSubview:_title];
    }
    return self;
}

@end
