//
//  HitTestViewController.m
//  IOSEventTest
//
//  Created by liang on 2019/3/19.
//  Copyright © 2019 liang. All rights reserved.
//

#import "HitTestButtonViewController.h"
#import "HitTestBubbleButton.h"
#import <objc/runtime.h>
@interface HitTestButtonViewController ()

@end

/**
 [多个不同元素、多个相同元素、元素的顺序，元素属性修改是否有影响]
 情况1：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，没有 gesture, touch 事件不 bubble 的情况下
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchBegan，再执行 touchesEnded。但是不会执行 action 回调（why？）
 
 情况2：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，没有 gesture, touch 事件容许 bubble 的情况下
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 action 回调（allTouchEvent，touchDown 等）、touchesBegan，再执行 action 回调（touchUpInside之类）、touchEnded
 ---- 事件也不会传播到父元素
 */
@implementation HitTestButtonViewController
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    
    HitTestBubbleButton *level_1 = [[HitTestBubbleButton alloc] initWithName:@"Level_1" bubble:self.canBubbleUp];
    level_1.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    level_1.frame = CGRectMake(10, 80, 370, 600);
    [self.view addSubview:level_1];
    [level_1 addTarget:self action:@selector(touchUpInside_1:) forControlEvents:UIControlEventTouchUpInside];

    HitTestBubbleButton *level_2_1 = [[HitTestBubbleButton alloc] initWithName:@"level_2_1_cancelsTouchesInView=NO" bubble:self.canBubbleUp];
    level_2_1.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    level_2_1.frame = CGRectMake(10, 300, 370, 100);
    [level_1 addSubview:level_2_1];
    // 测试 action 的顺序是否影响响应

    [level_2_1 addTarget:self action:@selector(touchUpBefore_2_1:) forControlEvents:UIControlEventTouchUpInside];
    [level_2_1 addTarget:self action:@selector(touchUpInsideBeforeAllTouch_2_1:) forControlEvents:UIControlEventTouchUpInside];
    [level_2_1 addTarget:self action:@selector(tapAllTouch_2_1:) forControlEvents:UIControlEventAllTouchEvents];
    [level_2_1 addTarget:self action:@selector(touchUpInsideAfterAllTouch_2_1:) forControlEvents:UIControlEventTouchUpInside];
    [level_2_1 addTarget:self action:@selector(touchDown_2_1:) forControlEvents:UIControlEventTouchDown];
    [level_2_1 addTarget:self action:@selector(touchUpAfter_2_1:) forControlEvents:UIControlEventTouchUpInside];


    HitTestBubbleButton *level_2 = [[HitTestBubbleButton alloc] initWithName:@"Level_2" bubble:self.canBubbleUp];
    level_2.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    level_2.frame = CGRectMake(10, 90, 300, 150);
    [level_1 addSubview:level_2];
    [level_2 addTarget:self action:@selector(touchUpInside_2:) forControlEvents:UIControlEventTouchUpInside];
    
    HitTestBubbleButton *level_3 = [[HitTestBubbleButton alloc] initWithName:@"Level_3" bubble:self.canBubbleUp];
    level_3.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    level_3.frame = CGRectMake(20, 120, 100, 100);
    [level_2 addSubview:level_3];

    [level_3 addTarget:self action:@selector(touchUpInside_3:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma clang diagnostic pop

#pragma mark - 万用入口第 2 种方法
//
//void dynamicMethodIMP(id self, SEL _cmd)
//{
//    // implementation ....
//    NSLog(@"Tap inner %@", NSStringFromSelector(_cmd));
//}
//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//    class_addMethod([self class],sel,(IMP)dynamicMethodIMP,"v@:");
//    return YES;
//}
@end
