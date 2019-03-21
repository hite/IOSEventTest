//
//  HitTestButton.m
//  IOSEventTest
//
//  Created by liang on 2019/3/19.
//  Copyright © 2019 liang. All rights reserved.
//

#import "HitTestBubbleButton.h"

@implementation HitTestBubbleButton

- (instancetype)initWithName:(NSString *)name bubble:(BOOL)canBubble
{
    if (self = [super init]) {
        [self setTitle:name forState:UIControlStateNormal];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.canBubbleUp = canBubble;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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

- (void)touchUpInside_nil_target:(id)sender
{
    NSLog(@"测试 target = nil 的情况");
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

#pragma target-action mechanism

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL succ = [super beginTrackingWithTouch:touch withEvent:event];
    NSLog(@"In %@, Method = %s", self, __func__);
    return succ;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL succ = [super continueTrackingWithTouch:touch withEvent:event];
    NSLog(@"In %@, Method = %s", self, __func__);
    return succ;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    NSLog(@"In %@, Method = %s", self, __func__);
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
    NSLog(@"In %@, Method = %s", self, __func__);
}
#pragma override

- (NSString *)description
{
    return [NSString stringWithFormat:@"[View = %@ , %@]", self.titleLabel.text, self.canBubbleUp?@"Bubble":@"Cann`t bubble"];
}

@end
