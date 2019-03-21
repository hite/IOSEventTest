//
//  HitTestViewController.m
//  IOSEventTest
//
//  Created by liang on 2019/3/19.
//  Copyright © 2019 liang. All rights reserved.
//

#import "HitTestButtonGestureController.h"
#import "HitTestBubbleButton.h"
#import <objc/runtime.h>
@interface HitTestButtonGestureController ()

@end

/**
 [多个不同元素、多个相同元素、元素的顺序，元素属性修改是否有影响]
 
 情况1：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，而且有 gesture, touch 事件不 bubble 的情况下
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchBegan，接下来执行最后一个 gesture 手势，
    1. cancelsTouchesInView=NO 时，再执行 touchesEnded，
    2. cancelsTouchesInView=YES 时，再执行 touchesCancelled
 ---- 不会执行 action 回调
 
 情况2：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，而且有 gesture, touch 事件需要 bubble 的情况下
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后
 1. cancelsTouchesInView=NO 时，先执行 action 回调（allTouchEvent，touchDown 等）、touchesBegan，接着是执行 tap 手势响应（重点），再执行 action 回调（touchUpInside之类）、touchesEnded
 2. cancelsTouchesInView=YES 时，先执行 touchBegan，接下来执行最后一个 gesture 手势，再执行 touchesCancelled
 ---- 事件不会冒泡到父元素
 
 
 结论：
 1. 相同元素只能有一个 gesture，后来者覆盖前者
 2. 相同的 UIControl 的 target-event 可以有多个。
 3. 相同阶段的事件，执行顺序安装添加的数据。
 4. gesture 确确实实是独立于 touch event sequence 的事件
 */
@implementation HitTestButtonGestureController
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tapVCview:)];
    [self.view addGestureRecognizer:tap];
    
    HitTestBubbleButton *level_1 = [[HitTestBubbleButton alloc] initWithName:@"Level_1" bubble:self.canBubbleUp];
    level_1.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    level_1.frame = CGRectMake(10, 80, 370, 600);
    [self.view addSubview:level_1];
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(button_1:)];
        [level_1 addGestureRecognizer:tap];
    }
    [level_1 addTarget:self action:@selector(touchUpInside_1:) forControlEvents:UIControlEventTouchUpInside];
    
    HitTestBubbleButton *level_2_1 = [[HitTestBubbleButton alloc] initWithName:@"level_2_1_cancelsTouchesInView=NO" bubble:self.canBubbleUp];
    level_2_1.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    level_2_1.frame = CGRectMake(10, 300, 370, 100);
    [level_1 addSubview:level_2_1];
    // 测试 action 的顺序是否影响响应
//    {
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
//        tap.cancelsTouchesInView = NO;
//        [tap addTarget:self action:@selector(tapGestureBeforeTouchEvent_2_1:)];
//        [level_2_1 addGestureRecognizer:tap];
//    }

    [level_2_1 addTarget:self action:@selector(touchUpBefore_2_1:) forControlEvents:UIControlEventTouchUpInside];
    [level_2_1 addTarget:self action:@selector(touchUpInsideBeforeAllTouch_2_1:) forControlEvents:UIControlEventTouchUpInside];
    [level_2_1 addTarget:self action:@selector(tapAllTouch_2_1:) forControlEvents:UIControlEventAllTouchEvents];
    [level_2_1 addTarget:self action:@selector(touchUpInsideAfterAllTouch_2_1:) forControlEvents:UIControlEventTouchUpInside];
    [level_2_1 addTarget:self action:@selector(touchDown_2_1:) forControlEvents:UIControlEventTouchDown];
    [level_2_1 addTarget:self action:@selector(touchUpAfter_2_1:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *commontap = [[UITapGestureRecognizer alloc] init];
    //        tap.cancelsTouchesInView = NO;
    [commontap addTarget:self action:@selector(common_button_lv2:)];
    {
//      测试多个 gestrue 的情况
//        [level_2_1 addGestureRecognizer:commontap];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
        tap2.cancelsTouchesInView = NO;
        [tap2 addTarget:self action:@selector(button_2_1:)];
        [level_2_1 addGestureRecognizer:tap2];
    }

    HitTestBubbleButton *level_2 = [[HitTestBubbleButton alloc] initWithName:@"Level_2" bubble:self.canBubbleUp];
    level_2.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    level_2.frame = CGRectMake(10, 90, 300, 150);
    [level_1 addSubview:level_2];
    // 测试 tap 事件的复用。结论：不能复用，recognize 由后面添加的元素所用。
    [level_2 addGestureRecognizer:commontap];
//    [level_2_1 addGestureRecognizer:commontap];
    [level_2 addTarget:self action:@selector(touchUpInside_2:) forControlEvents:UIControlEventTouchUpInside];
    
    HitTestBubbleButton *level_3 = [[HitTestBubbleButton alloc] initWithName:@"Level_3" bubble:self.canBubbleUp];
    level_3.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    level_3.frame = CGRectMake(20, 120, 100, 100);
    [level_2 addSubview:level_3];
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(button_3:)];
        [level_3 addGestureRecognizer:tap];
    }
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
