//
//  XJClusterAnnotationView.m
//  taohuadao
//
//  Created by taohuadao on 2016/12/7.
//  Copyright © 2016年 诗颖. All rights reserved.
//

#import "XJClusterAnnotationView.h"
#import "XJCluster.h"
#define ScreenSize [UIScreen mainScreen].bounds.size

@interface XJClusterAnnotationView()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *pharmacyLabel;
@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation XJClusterAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        //CGSize imageSize = [self contentSize];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 60, 60)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:87/255.0 blue:138/255.0 alpha:0.9];
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick)];
        // 2. 将点击事件添加到label上
        [_titleLabel addGestureRecognizer:labelTapGestureRecognizer];
        _titleLabel.userInteractionEnabled = YES; // 可以理解为设置label可被点击
        [self addSubview:_titleLabel];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.alpha = 0.9;
        [self addSubview:_imageView];
        
        _pharmacyLabel = [[UILabel alloc] init];
        _pharmacyLabel.textColor = [UIColor whiteColor];
        _pharmacyLabel.font = [UIFont systemFontOfSize:14];
        _pharmacyLabel.textAlignment = NSTextAlignmentCenter;
        _pharmacyLabel.numberOfLines = 0;
        [_imageView addSubview:_pharmacyLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize imageSize = [self contentSize];
    _imageView.frame = CGRectMake(0, 0, imageSize.width + 15,imageSize.height + 15 );
    _pharmacyLabel.frame = CGRectMake(5, 5, imageSize.width ,imageSize.height);
}

- (CGSize)contentSize {
    CGSize maxSize = CGSizeMake(ScreenSize.width *0.5, MAXFLOAT);
    // 计算文字的高度
    return  [_title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
}

- (void)labelClick {
    if ([self.delegate respondsToSelector:@selector(didAddreesWithClusterAnnotationView:clusterAnnotationView:)]) {
        [self.delegate didAddreesWithClusterAnnotationView:_cluster clusterAnnotationView:self];
    }
}

- (void)setSize:(NSInteger)size {
    _size = size;
    if (size > 3) {
        _titleLabel.hidden = NO;
        _imageView.hidden = YES;
        _pharmacyLabel.hidden = YES;
        _titleLabel.layer.cornerRadius = 30.0f;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.text = [NSString stringWithFormat:@"小吃:\n%ld家", size];
    } else {
        _titleLabel.hidden = YES;
        _imageView.hidden = NO;
        _pharmacyLabel.hidden = NO;
        _pharmacyLabel.text = _title;
        _imageView.image = [UIImage imageNamed:@"mapPopViewBGICon"];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setCluster:(XJCluster *)cluster {
    _cluster = cluster;
}

@end
