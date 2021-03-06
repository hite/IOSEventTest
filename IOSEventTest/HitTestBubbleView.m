//
//  HitTestViewLink.m
//  IOSEventTest
//
//  Created by liang on 2019/3/19.
//  Copyright © 2019 liang. All rights reserved.
//

#import "HitTestBubbleView.h"


@implementation HitTestBubbleView

- (instancetype)initWithName:(NSString *)name bubble:(BOOL)canBubble;
{
    if (self = [super init]) {
        self.canBubbleUp = canBubble;
        self.text = name;
        self.userInteractionEnabled = YES;
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

#pragma mark - hittest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *v = [super hitTest:point withEvent:event];
    NSLog(@"The view %@ finds target = %@", self, [v description]);
    return v;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL ins = [super pointInside:point withEvent:event];
    NSLog(@"The point %@ is %@ in of %@", NSStringFromCGPoint(point), (ins?@"":@" NOT "), self);
    return ins;
}

#pragma mark - touch event
//以下系列方法，调用 super 的方法和 NSLog 的顺序会影响后续 target-action 事件的顺序ß
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.canBubbleUp) {
        [super touchesBegan:touches withEvent:event];
    }
    NSLog(@"In %@, Method = %s", self, __func__);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.canBubbleUp) {
        [super touchesMoved:touches withEvent:event];
    }
    NSLog(@"In %@, Method = %s", self, __func__);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.canBubbleUp) {
        [super touchesEnded:touches withEvent:event];
    }
    NSLog(@"In %@, Method = %s", self, __func__);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.canBubbleUp) {
        [super touchesCancelled:touches withEvent:event];
    }
    NSLog(@"In %@, Method = %s", self, __func__);
}

- (void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches
{
    if (self.canBubbleUp) {
        [super touchesEstimatedPropertiesUpdated:touches];
    }
    NSLog(@"In %@, Method = %s", self, __func__);
}

#pragma override

- (NSString *)description
{
    return [NSString stringWithFormat:@"[View = %@ , %@]", self.text, self.canBubbleUp?@"Bubble":@"Cann`t bubble"];
}


@end
