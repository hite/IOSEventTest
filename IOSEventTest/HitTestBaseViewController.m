//
//  HitTestBaseViewController.m
//  IOSEventTest
//
//  Created by liang on 2019/3/20.
//  Copyright © 2019 liang. All rights reserved.
//

#import "HitTestBaseViewController.h"
#import <objc/runtime.h>

@interface HitTestBaseViewController ()

@end

@implementation HitTestBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 万用入口
#pragma mark - 万用入口第1 种方法
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [self.class instanceMethodSignatureForSelector:@selector(fakeActionTapSel:)];
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Tap %@", NSStringFromSelector(anInvocation.selector));
    NSString *debugInfo = @"[Debug]";
    [anInvocation setArgument:&debugInfo atIndex:2];
    [anInvocation setSelector:@selector(fakeActionTapSel:)];
    
    [anInvocation invokeWithTarget:self];
}

- (void)fakeActionTapSel:(NSString *)args
{
//    NSLog(@"Tap fakeActionTapSel = %@", args);
}


#pragma mark - 万用入口第 2 种方法

//void dynamicMethodIMPBase(id self, SEL _cmd)
//{
//    // implementation ....
//    NSLog(@"Tap %@", NSStringFromSelector(_cmd));
//}
//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//    class_addMethod([self class],sel,(IMP)dynamicMethodIMPBase,"v@:");
//    return YES;
//}
@end
