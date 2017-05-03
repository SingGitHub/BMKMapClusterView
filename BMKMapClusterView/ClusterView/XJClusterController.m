//
//  XJClusterController.m
//  taohuadao
//
//  Created by taohuadao on 2016/12/5.
//  Copyright © 2016年 诗颖. All rights reserved.
//

#import "XJClusterController.h"
#import "UIView+Extension.h"
#import <CoreLocation/CLAvailability.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

#import "BMKClusterManager.h"
#import "XJClusterAnnotation.h"
#import "XJClusterAnnotationView.h"

#import "XJCluster.h"

#define animationTime 0.5
#define viewMultiple 2
#define ScreenSize [UIScreen mainScreen].bounds.size

@interface XJClusterController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKPoiSearchDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate,BMKDistrictSearchDelegate,XJClusterAnnotationViewDelegate>{
    BMKMapView* _mapView;
    BMKReverseGeoCodeOption *_reverseGeoCodeOption;
    BMKClusterManager *_clusterManager;//点聚合管理类
    NSInteger _clusterZoom;//聚合级别
    NSMutableArray *_clusterCaches;//点聚合缓存标注
}

@property (nonatomic, strong)BMKPoiSearch *poiSearch;

@property (nonatomic, strong)BMKLocationService *locService;
@property (nonatomic, strong)BMKGeoCodeSearch *geoCodeSerch;
@property (nonatomic, strong)BMKDistrictSearch *districtSearch;

@property (nonatomic, strong)NSMutableArray *mapArray;

/// 当前地图的中心点
@property (nonatomic) CLLocationCoordinate2D cCoordinate;

@end

@implementation XJClusterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    [self setupView];
    [self setupMapService];
}

#pragma mark - XJClusterAnnotationViewDelegate
- (void)didAddreesWithClusterAnnotationView:(XJCluster *)cluster clusterAnnotationView:(XJClusterAnnotationView *)clusterAnnotationView{

        if (clusterAnnotationView.size > 3) {
            [_mapView setCenterCoordinate:clusterAnnotationView.annotation.coordinate];
            [_mapView zoomIn];
        }
}




- (void)onGetDistrictResult:(BMKDistrictSearch *)searcher result:(BMKDistrictResult *)result errorCode:(BMKSearchErrorCode)error {

    BMKCoordinateRegion region ;//表示范围的结构体
    region.center = result.center;//中心点
    region.span.latitudeDelta = 0.02;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    region.span.longitudeDelta = 0.02;//纬度范围
    [_mapView setRegion:region animated:YES];
}

//更新聚合状态
- (void)updateClusters {

 
    _clusterZoom = (NSInteger)_mapView.zoomLevel;
    @synchronized(_clusterCaches) {

        
            NSMutableArray *clusters = [NSMutableArray array];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ///获取聚合后的标注
                __block NSArray *array = [_clusterManager getClusters:_clusterZoom];
        
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (BMKCluster *item in array) {
                        XJClusterAnnotation *annotation = [[XJClusterAnnotation alloc] init];
                        annotation.coordinate = item.coordinate;
                        annotation.size = item.size;
                        annotation.title = item.title;
                        annotation.cluster = item.cluster;
                        [clusters addObject:annotation];
                    }
                    [_mapView removeOverlays:_mapView.overlays];
                    [_mapView removeAnnotations:_mapView.annotations];
                    [_mapView addAnnotations:clusters];

                });
            });
        }
//    }
}

#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    XJClusterAnnotationView *clusterAnnotation = (XJClusterAnnotationView*)view.annotation;
    if ([clusterAnnotation.title isEqualToString:@"我的位置"]) {
        [self positionButtonClick];
        return;
    }
    
    NSLog(@"点击了%@小吃店面", clusterAnnotation.title);
}

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    if ([view isKindOfClass:[XJClusterAnnotationView class]]) {
        XJClusterAnnotationView *clusterAnnotation = (XJClusterAnnotationView*)view.annotation;
        if (clusterAnnotation.size > 3) {
            [mapView setCenterCoordinate:view.annotation.coordinate];
            [mapView zoomIn];
        }
    }
}

/**
 *地图初始化完毕时会调用此接口
 *@param mapView 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    [_mapView updateLocationViewWithParam:displayParam];
    
    BMKCoordinateRegion region ;//表示范围的结构体
    region.center = _mapView.centerCoordinate;//中心点
    self.cCoordinate = _mapView.centerCoordinate;//中心点
    region.span.latitudeDelta = 0.002;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    region.span.longitudeDelta = 0.002;//纬度范围
    [_mapView setRegion:region animated:YES];
    [self updateClusters];
}

/**
 *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
 *@param mapView 地图View
 *@param status 此时地图的状态
 */
- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status {
    if (_clusterZoom != 0 && _clusterZoom != (NSInteger)mapView.zoomLevel) {
        [self updateClusters];
    }
}

#pragma mark - 添加PT
- (void)addAnnoWithPT:(XJCluster *)cluster {

    BMKClusterItem *clusterItem = [[BMKClusterItem alloc] init];
    clusterItem.coor = cluster.pt;
    clusterItem.title = cluster.name;
    clusterItem.cluster = cluster;
    [_clusterManager addClusterItem:clusterItem];
}

#pragma mark BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //屏幕坐标转地图经纬度
    CLLocationCoordinate2D MapCoordinate = [_mapView convertPoint:_mapView.center toCoordinateFromView:_mapView];
    
    if (_reverseGeoCodeOption==nil) {
        //初始化反地理编码类
        _reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    }
    
    //需要逆地理编码的坐标位置
    _reverseGeoCodeOption.reverseGeoPoint =MapCoordinate;
    [_geoCodeSerch reverseGeoCode:_reverseGeoCodeOption];
    
    
    
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 1;
    option.pageCapacity = 10;
    
    option.location = mapView.centerCoordinate;
    
    option.keyword = @"小吃";
    BOOL flag = [self.poiSearch poiSearchNearBy:option];
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        NSLog(@"周边检索发送失败");
    }
 
    
}

// Override
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    //普通annotation
    NSString *AnnotationViewID = @"ClusterMark";
    XJClusterAnnotation *cluster = (XJClusterAnnotation*)annotation;
    XJClusterAnnotationView *annotationView = [[XJClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    annotationView.title = cluster.title;
    annotationView.size = cluster.size;
    annotationView.cluster = cluster.cluster;
    annotationView.delegate = self;
    annotationView.canShowCallout = NO;//在点击大头针的时候会弹出那个黑框框
    annotationView.draggable = NO;//禁止标注在地图上拖动
    annotationView.annotation = cluster;
    
    UIView *viewForImage=[[UIView alloc]init];
    UIImageView *imageview=[[UIImageView alloc]init];
    CGSize contentSize = [self contentSizeWithTitle:cluster.title];
    CGFloat XJ_OffsetX = 15.0f;
    [viewForImage setFrame:CGRectMake(0, 0, (contentSize.width + XJ_OffsetX ) *viewMultiple, (contentSize.height + XJ_OffsetX ) *viewMultiple)];
    [imageview setFrame:CGRectMake(0, 0, (contentSize.width + XJ_OffsetX ) *viewMultiple, (contentSize.height + XJ_OffsetX ) *viewMultiple)];
    annotationView.xj_size = CGSizeMake(contentSize.width, contentSize.height);

    [imageview setImage:[UIImage imageNamed:@"kong"]];
    
    imageview.layer.masksToBounds=YES;
    imageview.layer.cornerRadius = 10;
    [viewForImage addSubview:imageview];
    annotationView.image = [self getImageFromView:viewForImage];
    return annotationView;
}

- (CGSize)contentSizeWithTitle:(NSString *)title {
    CGSize maxSize = CGSizeMake(ScreenSize.width *0.5, MAXFLOAT);
    // 计算文字的高度
    return  [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size;
}

-(UIImage *)getImageFromView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"抱歉，未找到结果");
    }
    [_clusterManager clearClusterItems];
    for (BMKPoiInfo *poiInfo in poiResultList.poiInfoList) {
        XJCluster *cluster = [[XJCluster alloc] init];
        cluster.name = poiInfo.name;
        cluster.pt = poiInfo.pt;
        
        [self addAnnoWithPT:cluster];
    }
}

#pragma mark - 用户位置更新后，会调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {

    //设置地图中心为用户经纬度
    [_mapView updateLocationData:userLocation];

    [self updateClusters];

}


- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"error %@",error);
}



#pragma mark - NavBar
- (void)setupNavBar {
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - 地图配置
- (void)setupMapService {
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    _locService.desiredAccuracy =  kCLLocationAccuracyBest;
    _locService.distanceFilter = 10;//大于100米
    [_locService startUserLocationService];
    
    _geoCodeSerch = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSerch.delegate = self;
    
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    
    _clusterManager = [[BMKClusterManager alloc] init];
    
    
    //初始化检索对象
    self.districtSearch = [[BMKDistrictSearch alloc] init];
    //设置delegate，用于接收检索结果
    self.districtSearch.delegate = self;
    
    //在此处理正常结果
    _clusterCaches = [[NSMutableArray alloc] init];
    for (NSInteger i = 3; i < 22; i++) {
        [_clusterCaches addObject:[NSMutableArray array]];
    }
}

#pragma mark - setupView
- (void)setupView {

    /// 地图
    _mapView = [[BMKMapView alloc]init];
    
    [_mapView setMapType:BMKMapTypeStandard];// 地图类型 ->卫星／标准、
    _mapView.showsUserLocation = YES;
    _mapView.gesturesEnabled = YES;
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapView.frame = self.view.bounds;

    [self.view addSubview:_mapView];
    
}


- (void)dealloc {
    _mapView.delegate = nil;
    if (_mapView) {
        _mapView = nil;
    }
    _geoCodeSerch.delegate = nil;
    _locService.delegate = nil;
    _geoCodeSerch = nil;
    _reverseGeoCodeOption = nil;
    _poiSearch = nil;
    _districtSearch.delegate = nil;
}


#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4]] forBarMetrics:UIBarMetricsDefault];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    [_locService stopUserLocationService];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}
#pragma mark - 懒加载
- (BMKPoiSearch *)poiSearch {
    if (!_poiSearch) {
        _poiSearch = [[BMKPoiSearch alloc] init];
        _poiSearch.delegate = self;
    }
    return _poiSearch;
}

- (NSMutableArray *)mapArray {
    if (!_mapArray) {
        _mapArray = [NSMutableArray array];
    }
    return _mapArray;
}

- (void)positionButtonClick {

    BMKCoordinateRegion region ;//表示范围的结构体
    region.center = self.cCoordinate;//中心点
    region.span.latitudeDelta = 0.002;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    region.span.longitudeDelta = 0.002;//纬度范围
    [_mapView setRegion:region animated:YES];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
