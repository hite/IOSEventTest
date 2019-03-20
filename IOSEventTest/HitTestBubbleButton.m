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
    NSLog(@"在 %@ 查到，查到的目标 target = %@", self, [v description]);
    return v;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL ins = [super pointInside:point withEvent:event];
    NSLog(@"%@ 是否在 %@ 内部 = %d", self, NSStringFromCGPoint(point), ins);
    return ins;
}

#pragma mark - touch event
#pragma mark - touch event

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
    return [NSString stringWithFormat:@"[View = %@ , %@]", self.titleLabel.text, self.canBubbleUp?@"冒泡":@"不冒泡"];
}

@end
