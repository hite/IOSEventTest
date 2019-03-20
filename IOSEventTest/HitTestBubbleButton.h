//
//  HitTestButton.h
//  IOSEventTest
//
//  Created by liang on 2019/3/19.
//  Copyright © 2019 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HitTestBubbleButton : UIButton
- (instancetype)initWithName:(NSString *)name bubble:(BOOL)canBubble;
/**
 是否容许,touch 事件传递到父元素
 */
@property (nonatomic, assign) BOOL canBubbleUp;
@end

NS_ASSUME_NONNULL_END
