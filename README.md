#关于 UIResponder 链和 target-action 事件的相互影响的机理和应用
https://github.com/hite/IOSEventTest

**这是一个供探索、验证、对比测试而精心设计的demo。**
用来研究 UIControl，普通的 View 在 使用 target-action, addTapGestureRecognizer 方式时，不同情况下如何相互作用。
试图解答以下问题；
1. 第一响应者如何确认？（包括 `alpha，hidden，clipToBound` 属性的影响，都不是本次试验的重点）
2. target-action 和 tapGesture 混用时，如何表现，加入变量 `cancelsTouchesInView` 时，是否有不同？
3. target-action 或者 tapGesture 是否各自都有多个？
   - 包括相同类型 event state 和 gesture Type 是否有多个？
   - 包括不同类型 event state 和 gesture Type 是否有多个？
4. 相同和不同类型 target-action 或者 tapGesture 的添加顺序和执行顺序是否有关系？

### 设计可测试变量
1. touch 事件是否冒泡（bubble up）
2. 是否有是普通 UIResponder 还是 UIControl
3. 是否添加了 TapGesture 事件。
这些大测试变量是通过选不同测试入口的方式来进行的。同时，每一个大测试变量里还有一些小测试变量，写在代码内部，个别需要去掉注释或者调整代码顺序来自行验证。如,
1. 多个相同元素
2. 多个不同元素
3. 元素之前的顺序
4. cancelsTouchesInView 变量(不考虑，delaysTouchesBegan，默认为 NO;delaysTouchesEnded，默认为 YES)

*如果没有条件运行源码自己观察，下面是我自己的观察和总结，可能有谬误，欢迎指正*
-------TLTR;--------
######1. HitTestTouchViewController, 测试普通的 UILabel 元素在是否事件冒泡到父元素的表现
场景1：只有 touch 事件，没有添加 tap 手势，不 bubble 时。
1. 元素通过 hittest 测试，找到第一响应者后，事件不会继续向下传递。因为第一响应获取之后没有传递
1. 可以正确 touchesEnded；
 
场景2：只有 touch 事件，没有添加 tap 手势，容许 bubble 时。
1. 元素通过 hittest 测试，找到第一响应者后，事件还会继续向上传递事件，按照从子到父的过程，传播事件
1. 可以正确 touchesEnded；

######2. HitTestTouchGestureController，测试普通的 UILabel 元素在响应 touch 事件的同时，还被添加的 tapGesture 的表现

情况1：普通的 UIResponder 元素， 所有元素都有 touch 事件也有 gesture, touch 事件不 bubble 的情况下
1. UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchesBegan ，然后调用 gesture，然后根据 cancelsTouchesInView 的值，决定是 touchCancelled 还是 touchesEnded。
1. 无论 cancel 或者 end，此时事件都不会向父元素传播。
 
情况2：普通的 UIResponder 元素， 所有元素都有 touch 事件也有 gesture, touch 事件容许 bubble 的情况下
1. UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchesBegan，然后调用 gesture
    1. cancelsTouchesInView = NO， 执行 touchesEnded。同时，执行父类的 touchesBegan 和 touchesEnded, 但是不会执行父类的 gesture
    1. cancelsTouchesInView = YES，默认值。执行 touchCancelled。同时，执行父类的 touchesBegan 和 touchesCancelled, 但是不会执行父元素的 gesture
 结论：容许 bubble 的情况下都可以传播到父元素（这是显而易见的，也是这个实验设计的缺陷，在 touchesEnded 里去调用 super 的 touchesEnded 是不是真的符合实际情况？），cancelsTouchesInView 只影响 touch 结束的事件。
 *但父元素的 TapGesture 不会响应* 

######3. HitTestButtonViewController，测试 UIButton 有 addTarget，无 gesture 手势时，是否 bubble up 对 target-action 的影响

*多个不同元素、多个相同元素、元素的顺序，元素属性修改是否有影响*
情况1：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，没有 gesture, touch 事件不 bubble 的情况下
1. UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchesBegan，再执行 touchesEnded。但是不会执行 action 回调（why？）
2. 猜测原因：super 的 `touchesEnded:withEvent:` 会调用触发 `UIControlEventTouchUpInside`，因为我们没有调用 super 所以没有触发。
有调用栈为参考，
![调用栈](http://upload-images.jianshu.io/upload_images/277783-9e9adfb77088c5ef?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)，
可见，触发 action-target 都是由 UIControl 父类实现的。
 
情况2：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，没有 gesture, touch 事件容许 bubble 的情况下
1. UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 action 回调（allTouchEvent，touchDown 等）、touchesBegan，再执行 action 回调（touchUpInside之类）、touchesEndeded
1. touch 事件不会传播到父元素，即使是没有 action 回调， button 上的事件也不会向父元素传播。

######4. HitTestButtonGestureController，测试 UIButton 有 addTarget，同时也有 gesture 手势时，是否 bubble up 对 target-action 和 gesture 的影响

情况1：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，而且有 gesture, touch 事件不 bubble 的情况下
1. UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchesBegan，接下来执行最后一个 gesture 手势，
    1. cancelsTouchesInView=NO 时，再执行 touchesEnded，
    2. cancelsTouchesInView=YES 时，再执行 touchesCancelled
1. 不会执行 action 回调，因为没有调用 `touchesEnded` super 方法。 
>If a gesture recognizer recognizes its gesture, it unbinds the remaining touches of that gesture from their view (so the window won’t deliver them). The window cancels the previously delivered touches with a (touchesCancelled(_:with:)) message. If a gesture recognizer doesn’t recognize its gesture, the view receives all touches in the multi-touch sequence.
 
情况2：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，而且有 gesture, touch 事件需要 bubble 的情况下
1. UIApplication 接收到时间，通过 hittest 找到第一响应者之后
   - cancelsTouchesInView=NO 时，先执行 action 回调（allTouchEvent，touchDown 等）、touchesBegan，接着是执行 tap 手势响应（重点），再执行 action 回调（touchUpInside之类）、touchesEnded
   - cancelsTouchesInView=YES 时，先执行 touchesBegan，接下来执行最后一个 gesture 手势，再执行 touchesCancelled
1. touch 事件不会传播到父元素， gesture 更不会传播到父元素

### 结论：
1. 一个元素只能有一个 某某类型的 gesture，后来者覆盖前者；但是可以有多个不同类型的 gesture。
2. 相同的 UIControl 的 target-event 可以有多个，不弄是否有相同 event state 类型。
3. 相同阶段的事件，执行顺序按照添加的顺序。
3. UIControl 内部的事件不会传播到父元素，gesture 也一样。
4. gesture 确确实实是独立于 touch event sequence 的事件，但是会干扰 event, Gesture 会先接管 touch event 的流程，然传递给 target-action 处理。
4. Tap 事件和 view 是一一绑定的关系，多个 view 绑定相同 tap，最后一个有效。
5. UIControl 的 target-event 只是对 touch event sequence 的采样后触发的逻辑，不会干扰手势也不会干扰 event 本身。注意 touch 的采样不会采样父元素的 touch event sequence。
6. 在 UIResponder 的事件链路里 touchesBegan 等调用父类的作用不仅仅是向父类传播事件，也在于完成本次 event sequence 事件，到结束或取消。
6. `cancelTrackingWithEvent` 是由 `touchesCancelled:withEvent:` 调用的。
7. `When adding an action method to a control, you specify both the action method and an object that defines that method to the addTarget:action:forControlEvents: method. If you specify nil for the target object, the control searches the responder chain for an object that defines the specified action method.` 他的含义在于如果 level_2 元素上的某个类型的 action 对应的 target = nil，则回去找 level_1 的 类型，查询 respondsToSelector 是否为 YES。    
而不是理解为：level_2 不响应 event，然后让 level_1 来处理，这样理解是错误的。当然大部分情况下 target = nil ，还不如将这控件设置为 disabled（不考虑样式上的区别）。

### 原理
通过简单的调用栈比较发现 当 `[UIWindow sendEvent:]` 之后
1. Touch 事件由，[UIWindow _sendTouchesForEvent] 分发
2. TapGesture 事件由，[UIGestureEvnvironment _updateForEvent:window:] 里的 `_wasDeliveredToGestureRecognizers` 分发
可见两者是两套系统。下面是来自苹果的文档里的一段，描述二者的关系。

>A window delivers touch events to a gesture recognizer before it delivers them to the hit-tested view attached to the gesture recognizer. Generally, if a gesture recognizer analyzes the stream of touches in a multi-touch sequence and doesn’t recognize its gesture, the view receives the full complement of touches. If a gesture recognizer recognizes its gesture, the remaining touches for the view are cancelled. 
[见文](https://developer.apple.com/documentation/uikit/uigesturerecognizer)

### 实际应用距举例
#### 1.模仿 AOP 拦截
在所有可用响应的事件的元素，执行自身逻辑之前拦截，做功能逻辑的鉴权。
典型的场景：
**界面有“导出图片”，“转为 gif”，“上传到服务”三个按钮，这三个功能都需要用户购买 vip 服务。**
1. 传统的思路是在这三个方法的事件里，都添加前置判断逻辑，来判断是否是 vip ，不是则弹出购买 vip 的逻辑。这样的代码需要和真实的逻辑混在一起，即使是一个 `if isVip()  return `这样的逻辑也是职责不清。
2. 使用 TapGesture 独占的特性，我们在所有的按钮上都添加 cancelsTouchesInView = YES 的手势事件，单独处理 vip 判断逻辑。这样就做到了职责分离，即使后期，vip 服务和具体功能没有关联，也不需要改动“导出图片”等按钮的真实逻辑
#### 2.[想象中的需求] App 内点击劫持
如果在 wechat 之类的第三方 App 上想做些事情，可以考虑使用 TapGesture 独占的特性来实现点击劫持。
#### 3.无干扰的事件监听
我们知道 target-action 可以添加多个，因为它观察者的身份不会对旧的逻辑产生影响（当然同时我们也知道一个事实：对于 tapGesture 事件无能为力）
所以我们可以为所有 button 都添加一个自己的 action，用来监听用户对这个 button 的点击情况
1. 当 button 没有添加业务事件时，代码逻辑里应该将这个 button disable（否则用户会丢失点击事件），这样我们的监听也不会触发
2. 当 button 有业务事件时，点击后业务逻辑和监听逻辑都会执行
well done。目前这种方式，被我使用在 apm SDK，`SauronEye` 里。用来代替传统的去 hook button 的 `addTarget` 方法的方式，更优雅


## 参考链接
1. [iOS事件处理，看我就够了~](https://segmentfault.com/a/1190000013265845) ,本文没有考虑 cancelsTouchesInView 的影响
2. [iOS 触摸事件响应链](https://cloud.tencent.com/developer/article/1117024)
3. [Documentation of UIGestureRecognizer](https://developer.apple.com/documentation/uikit/uigesturerecognizer)
4. [Documentation UIKit Views and Controls UIControl](https://developer.apple.com/documentation/uikit/uicontrol)
