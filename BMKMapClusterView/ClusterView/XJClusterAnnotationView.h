//
//  XJClusterAnnotationView.h
//  taohuadao
//
//  Created by taohuadao on 2016/12/7.
//  Copyright © 2016年 诗颖. All rights reserved.
//

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
@class XJClusterAnnotationView,XJCluster;
@protocol XJClusterAnnotationViewDelegate <NSObject>

- (void)didAddreesWithClusterAnnotationView:(XJCluster *)cluster clusterAnnotationView:(XJClusterAnnotationView *)clusterAnnotationView;

@end

@interface XJClusterAnnotationView : BMKPinAnnotationView
@property (nonatomic, copy)NSString *title;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) XJCluster *cluster;

@property (nonatomic, weak)id <XJClusterAnnotationViewDelegate>delegate;

@end
