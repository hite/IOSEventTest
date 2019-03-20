//
//  HitTestViewController.m
//  IOSEventTest
//
//  Created by liang on 2019/3/19.
//  Copyright © 2019 liang. All rights reserved.
//

#import "HitTestTouchViewController.h"
#import "HitTestBubbleView.h"

@interface HitTestTouchViewController ()

@end

/**
 
 场景1：只有 touch 事件，没有添加 tap 手势，不 bubbleup 时。
 ---- 元素通过 hittest 测试，找到第一响应者后，事件不会继续向下传递。因为第一响应获取之后没有传递
 ---- 可以正确 touchEnd；
 
 场景2：只有 touch 事件，没有添加 tap 手势，容许 bubbleup 时。
 ---- 元素通过 hittest 测试，找到第一响应者后，事件还会继续向上传递事件，按照从子到父的过程，传播事件
 ---- 可以正确 touchEnd；
 */

@implementation HitTestTouchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];

    HitTestBubbleView *level_1 = [[HitTestBubbleView alloc] initWithName:@"Level_1" bubble:self.canBubbleUp];
    level_1.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    level_1.frame = CGRectMake(10, 80, 370, 600);
    [self.view addSubview:level_1];

    
    HitTestBubbleView *level_2_1 = [[HitTestBubbleView alloc] initWithName:@"Level_2_1" bubble:self.canBubbleUp];
    level_2_1.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    level_2_1.frame = CGRectMake(10, 300, 370, 100);
    [level_1 addSubview:level_2_1];

    HitTestBubbleView *level_2 = [[HitTestBubbleView alloc] initWithName:@"Level_2" bubble:self.canBubbleUp];
    level_2.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    level_2.frame = CGRectMake(10, 90, 300, 150);
    [level_1 addSubview:level_2];

    
    HitTestBubbleView *level_3 = [[HitTestBubbleView alloc] initWithName:@"Level_3" bubble:self.canBubbleUp];
    level_3.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    level_3.frame = CGRectMake(20, 120, 100, 100);
    [level_2 addSubview:level_3];

}

@end
