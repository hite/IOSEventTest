//
//  HitTestViewController.m
//  IOSEventTest
//
//  Created by liang on 2019/3/19.
//  Copyright © 2019 liang. All rights reserved.
//

#import "HitTestTouchGestureController.h"
#import "HitTestBubbleView.h"

@interface HitTestTouchGestureController ()

@end

/**
 情况1：普通的 UIResponder 元素， 所有元素都有 touch 事件也有 gesture, touch 事件不 bubble 的情况下
 
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchBegan ，然后调用 gesture，然后根据 cancelsTouchesInView 的值，决定是 touchCancelled 还是 touchend。
 ---- 无论 cancel 或者 end，此时事件都不会向父元素传播。
 
 
 情况2：普通的 UIResponder 元素， 所有元素都有 touch 事件也有 gesture, touch 事件容许 bubble 的情况下
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchBegan，然后调用 gesture
    1. cancelsTouchesInView = NO， 执行 touchend。同时，执行父类的 touchBegan 和 touchEnd, 但是不会执行父类的 gesture
    1. cancelsTouchesInView = YES，默认值。执行 touchCancelled。同时，执行父类的 touchBegan 和 touchEnd, 但是不会执行父类的 gesture
 结论：容许 bubble 的情况下都可以传播到父元素，cancelsTouchesInView 只影响 touch 结束的事件。
 */
@implementation HitTestTouchGestureController

#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tapVCView:)];
    [self.view addGestureRecognizer:tap];
    
    HitTestBubbleView *level_1 = [[HitTestBubbleView alloc] initWithName:@"Level_1" bubble:self.canBubbleUp];
    level_1.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    level_1.frame = CGRectMake(10, 80, 370, 600);
    [self.view addSubview:level_1];
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(view_1:)];
        [level_1 addGestureRecognizer:tap];
    }
    
    HitTestBubbleView *level_1_1 = [[HitTestBubbleView alloc] initWithName:@"Level_2_1-cancelsTouchesInView=NO" bubble:self.canBubbleUp];
    level_1_1.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    level_1_1.frame = CGRectMake(10, 300, 370, 100);
    [level_1 addSubview:level_1_1];
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.cancelsTouchesInView = NO;
        [tap addTarget:self action:@selector(view_2_1:)];
        [level_1_1 addGestureRecognizer:tap];
    }
    
    HitTestBubbleView *level_2 = [[HitTestBubbleView alloc] initWithName:@"Level_2" bubble:self.canBubbleUp];
    level_2.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    level_2.frame = CGRectMake(10, 90, 300, 150);
    [level_1 addSubview:level_2];
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(view_2:)];
        [level_2 addGestureRecognizer:tap];
    }
    
    HitTestBubbleView *level_3 = [[HitTestBubbleView alloc] initWithName:@"Level_3" bubble:self.canBubbleUp];
    level_3.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    level_3.frame = CGRectMake(20, 120, 100, 100);
    [level_2 addSubview:level_3];
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(view_3:)];
        [level_3 addGestureRecognizer:tap];
    }
}
#pragma clang diagnostic pop

@end
