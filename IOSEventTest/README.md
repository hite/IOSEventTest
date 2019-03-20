### 关于 UIControl、 UIResponder 和 touch event 事件的相互作用效果研究

**场景1：只有 touch 事件，没有添加 tap 手势，不 bubbleup 时。**
 ---- 元素通过 hittest 测试，找到第一响应者后，事件不会继续向下传递。因为第一响应获取之后没有传递
 ---- 可以正确 touchEnd；
 
 场景2：只有 touch 事件，没有添加 tap 手势，容许 bubbleup 时。
 ---- 元素通过 hittest 测试，找到第一响应者后，事件还会继续向上传递事件，按照从子到父的过程，传播事件
 ---- 可以正确 touchEnd；

 **情况1：普通的 UIResponder 元素， 所有元素都有 touch 事件也有 gesture, touch 事件不 bubble 的情况下**
 
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchBegan ，然后调用 gesture，然后根据 cancelsTouchesInView 的值，决定是 touchCancelled 还是 touchend。
 ---- 无论 cancel 或者 end，此时事件都不会向父元素传播。

 
 情况2：普通的 UIResponder 元素， 所有元素都有 touch 事件也有 gesture, touch 事件容许 bubble 的情况下
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchBegan，然后调用 gesture
    1. cancelsTouchesInView = NO， 执行 touchend。同时，执行父类的 touchBegan 和 touchEnd, 但是不会执行父类的 gesture
    1. cancelsTouchesInView = YES，默认值。执行 touchCancelled。同时，执行父类的 touchBegan 和 touchEnd, 但是不会执行父类的 gesture
 结论：容许 bubble 的情况下都可以传播到父元素，cancelsTouchesInView 只影响 touch 结束的事件。

**多个不同元素、多个相同元素、元素的顺序，元素属性修改是否有影响**
 情况1：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，没有 gesture, touch 事件不 bubble 的情况下
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 touchBegan，再执行 touchesEnded。但是不会执行 action 回调（why？）
 
 情况2：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，没有 gesture, touch 事件容许 bubble 的情况下
 ---- UIApplication 接收到时间，通过 hittest 找到第一响应者之后，先执行 action 回调（allTouchEvent，touchDown 等）、touchesBegan，再执行 action 回调（touchUpInside之类）、touchEnded
 ---- 事件也不会传播到父元素

**情况1：普通的 UIControl 元素， 所有元素都有 touch 事件，有 action 回调，而且有 gesture, touch 事件不 bubble 的情况下**
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
 5. UIControl 的 target-event 只是对 touch event sequence 的采样事件，不会干扰手势也不会干扰 event 本身。
 6. touchesBegan 等调用父类的作用不仅仅是向父元素传播，也在于完成本次 event sequence 的事件。

 ## 参考链接
 1. [iOS事件处理，看我就够了~](https://segmentfault.com/a/1190000013265845) ,本文没有考虑 cancelsTouchesInView 的影响
 2. [iOS 触摸事件响应链](https://cloud.tencent.com/developer/article/1117024)