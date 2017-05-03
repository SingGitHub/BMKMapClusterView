//
//  ViewController.m
//  BMKMapClusterView
//
//  Created by 蒋诗颖 on 2017/5/3.
//  Copyright © 2017年 BaiduMap. All rights reserved.
//


#import "ViewController.h"
#import "XJClusterController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 200, 100)];
    [btn setTitle:@"百度地图" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)didBtnClick:(UIButton *)btn {
    XJClusterController *mapVC = [[XJClusterController alloc] init];
    [self.navigationController pushViewController:mapVC animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
