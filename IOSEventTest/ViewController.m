//
//  ViewController.m
//  IOSEventTest
//
//  Created by liang on 2019/1/18.
//  Copyright © 2019 liang. All rights reserved.
//

#import "ViewController.h"
#import "HitTestBaseViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIView *outer;
@property (weak, nonatomic) IBOutlet UIView *inner;

@end


//打印宏展开后的函数
#define __toString(x) #x
#define __toString_0(x) #x
#define LOG_MACRO2(x) NSLog(@"%s=\n%s", #x, __toString(x))

/////////////////////
/**
 * Returns the first argument given. At least one argument must be provided.
 *
 * This is useful when implementing a variadic macro, where you may have only
 * one variadic argument, but no way to retrieve it (for example, because \c ...
 * always needs to match at least one argument).
 *
 * @code
 
 #define varmacro(...) \
 metamacro_head(__VA_ARGS__)
 
 * @endcode
 */

#define metamacro_concat_(A, B) A ## B

#define metamacro_concat(A, B) \
metamacro_concat_(A, B)

#define metamacro_at(N, ...) \
metamacro_concat(metamacro_at, N)(__VA_ARGS__)

/**
 * Identical to #metamacro_foreach_cxt, except that no CONTEXT argument is
 * given. Only the index and current argument will thus be passed to MACRO.
 */
#define metamacro_foreach(MACRO, SEP, ...) \
metamacro_foreach_cxt(metamacro_foreach_iter, SEP, MACRO, __VA_ARGS__)

/**
 * For each consecutive variadic argument (up to twenty), MACRO is passed the
 * zero-based index of the current argument, CONTEXT, and then the argument
 * itself. The results of adjoining invocations of MACRO are then separated by
 * SEP.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define metamacro_foreach_cxt(MACRO, SEP, CONTEXT, ...) \
metamacro_concat(metamacro_foreach_cxt, metamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

#define strongify(...) \
try {} @finally {} \
metamacro_foreach(rac_strongify_,, __VA_ARGS__) \

// 注释开始
#define metamacro_head_(FIRST, ...) FIRST
#define metamacro_head(...) \
metamacro_head_(__VA_ARGS__, 0)
#define metamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) metamacro_head(__VA_ARGS__)
/**
 * Returns the number of arguments (up to twenty) provided to the macro. At
 * least one argument must be provided.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define metamacro_argcount(...) \
metamacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
//结束.总结:可变参数是除了声明外的其它参数。利用位置，将已有的数据挤出去，这样就可以获取到参数个数了。

#define metamacro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define metamacro_foreach_iter(INDEX, MACRO, ARG) MACRO(INDEX, ARG)

#define rac_strongify_(INDEX, VAR) \
__strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_);

@interface ViewController() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController{
    NSArray<NSDictionary *> *_allControllers;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    LOG_MACRO2(@strongify(self));
    
//    LOG_MACRO2(metamacro_argcount(a,b,c,d));
//    上面的例子研究了如何展开 metamacro_argcount 是如何展开的
    self->_allControllers = @[
        @{ @"title" : @"Touch ",
           @"cls" : @"HitTestTouchViewController",
           @"bubbleUp" : @0 },
        @{ @"title" : @"Touch, Bubble up ",
           @"cls" : @"HitTestTouchViewController",
           @"bubbleUp" : @1 },
        @{ @"title" : @"gesture, Touch ",
           @"cls" : @"HitTestTouchGestureController",
           @"bubbleUp" : @0 },
        @{ @"title" : @"gesture, Touch Bubble up ",
           @"cls" : @"HitTestTouchGestureController",
           @"bubbleUp" : @1 },
        @{ @"title" : @"button, Touch ",
           @"cls" : @"HitTestButtonViewController",
           @"bubbleUp" : @0 },
        @{ @"title" : @"button, Touch  Bubble up ",
           @"cls" : @"HitTestButtonViewController",
           @"bubbleUp" : @1 },
        @{ @"title" : @"button, gestrue, Touch ",
           @"cls" : @"HitTestButtonGestureController",
           @"bubbleUp" : @0 },
        @{ @"title" : @"button, gestrue, Touch  Bubble up ",
           @"cls" : @"HitTestButtonGestureController",
           @"bubbleUp" : @1 }
    ];

    UITableView *tableView = [UITableView new];
    [self.view addSubview:tableView];
    tableView.frame = self.view.bounds;
    tableView.delegate = self;
    tableView.dataSource = self;
    
}

#pragma

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self->_allControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kIdentifier = @"kIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
    }
    NSDictionary *item = [self->_allControllers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item objectForKey:@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *item = [self->_allControllers objectAtIndex:indexPath.row];
    Class cls = NSClassFromString([item objectForKey:@"cls"]);
    HitTestBaseViewController *vc = [cls new];
    [vc setTitle:[item objectForKey:@"title"]];
    vc.canBubbleUp = [[item objectForKey:@"bubbleUp"] boolValue];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
