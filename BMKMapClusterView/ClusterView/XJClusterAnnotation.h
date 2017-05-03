//
//  THDClusterAnnotation.h
//  taohuadao
//
//  Created by taohuadao on 2016/12/7.
//  Copyright © 2016年 诗颖. All rights reserved.
//

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
@class XJCluster;
@interface XJClusterAnnotation : BMKPointAnnotation
///所包含annotation个数
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) XJCluster *cluster;
@end
