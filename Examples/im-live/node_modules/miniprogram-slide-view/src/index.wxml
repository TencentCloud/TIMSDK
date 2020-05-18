<!--slide-view/slide-view.wxml-->
<movable-area class="container" style="width: {{width}}rpx; height: {{height}}rpx;">
  <movable-view direction="horizontal" class="movable-view" out-of-bounds="{{out}}" damping="20" x="{{x}}" style="width: {{width + slideWidth}}rpx; height: {{height}}rpx;" inertia bindtouchend="onTouchEnd" bindtouchstart="onTouchStart" bindchange="onChange">
    <view class="left" >
      <slot name= "left"></slot>
    </view>
    <view class= "right">
      <slot name="right"></slot>
    </view>
  </movable-view>
</movable-area>
