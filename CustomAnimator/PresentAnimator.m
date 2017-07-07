//
//  PresentAnimator.m
//  PhoneCallAnimator
//
//  Created by Archer on 2017/7/7.
//  Copyright © 2017年 Archer. All rights reserved.
//

#import "PresentAnimator.h"
#import "PhoneCallController.h"
#import "ViewController.h"
#import "UIView+Additions.h"
#import "IconView.h"

@interface PresentAnimator () <CAAnimationDelegate>
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) ViewController *fromVC;
@property (nonatomic, weak) PhoneCallController *toVC;
@end

@implementation PresentAnimator

- (void)dealloc
{
    NSLog(@"-------> PresentAnimator dealloc");
}

// 返回动画的持续时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    _toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (_toVC.presentType == kPresentType_normal) {
        return 1.25f; // 接电话 1.25s
    }
    return 2.0f; // 恢复 2s
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // 保存一下ctx留待使用
    _transitionContext = transitionContext;
    
    // 获取fromVC 和 toVC
    // fromVC表示当前正在显示的VC toVC表示将要显示的VC
    _fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    _toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    // 获取容器
    UIView *container = [transitionContext containerView];
    
    // 动画时长和最终大小
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGRect finalFrame = [transitionContext finalFrameForViewController:_toVC];
    
    // 添加转场动画 normal态
    if (_toVC.presentType == kPresentType_normal) {
        // 将fromVC.view 和 toVC.view加在容器上以显示和做动画
        // 顺序很重要
        [container addSubview:_fromVC.view];
        [container addSubview:_toVC.view];
        
        // 改变背景
        CABasicAnimation *contentAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
        contentAnimation.fromValue = _fromVC.view.layer.contents;
        contentAnimation.toValue = _toVC.view.layer.contents;
        contentAnimation.duration = duration / 3;
        contentAnimation.removedOnCompletion = NO;
        contentAnimation.fillMode = kCAFillModeForwards;
        contentAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [_toVC.view.layer addAnimation:contentAnimation forKey:@"contentAnimation"];
        
        // 移入 头像
        UIButton *iconButton = _toVC.iconButton;
        [self positionAnimationFor:iconButton.layer
                         fromValue:@(-iconButton.height / 2)
                           toValue:@(iconButton.centerY)
                          duration:duration
                 animationIdentify:@"iconAnimation"];
        
        // 移入 挂断电话
        UIButton *hangUpButton = _toVC.hangUpButton;
        [self positionAnimationFor:hangUpButton.layer
                         fromValue:@(finalFrame.size.height + hangUpButton.height / 2)
                           toValue:@(hangUpButton.centerY)
                          duration:duration
                 animationIdentify:@"hangAnimation"];
        
        // 移入 挂起电话
        UIButton *packUpButton = _toVC.packUpButton;
        [self positionAnimationFor:packUpButton.layer
                         fromValue:@(finalFrame.size.height + packUpButton.height / 2)
                           toValue:@(packUpButton.centerY)
                          duration:duration
                 animationIdentify:@"packAnimation"];
        
    }else{ // reopen态
        // 将fromVC.view 和 toVC.view加在容器上以显示和做动画
        [container addSubview:_toVC.view];
        [container addSubview:_fromVC.view];
        
        // 将icon从下方移动到上方
        IconView *iconButton = [[UIApplication sharedApplication].keyWindow viewWithTag:100];
        CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        moveAnimation.delegate = self;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, iconButton.centerX, iconButton.centerY);
        // 2/3 3/4等是随意取的
        CGPoint cp1 = CGPointMake(_toVC.view.width * 2/3, _toVC.view.height * 3/4);
        CGPoint cp2 = CGPointMake(_toVC.view.width, _toVC.iconButton.centerY);
        CGPoint ep = CGPointMake(_toVC.iconButton.centerX, _toVC.iconButton.centerY);
        CGPathAddCurveToPoint(path, NULL, cp1.x, cp1.y, cp2.x, cp2.y, ep.x, ep.y);
        moveAnimation.path = path;
        moveAnimation.duration = duration / 2;
        moveAnimation.removedOnCompletion = NO;
        moveAnimation.fillMode = kCAFillModeForwards;
        moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [iconButton.layer addAnimation:moveAnimation forKey:@"moveAnimation"];
        // 释放路径
        CFRelease(path);
        iconButton.frame = _toVC.iconButton.frame;

        
        // 以iconButton的边界组成的圆
        CGPoint center = iconButton.center;
        CGMutablePathRef iconBtnPath = CGPathCreateMutable();
        CGPathAddArc(iconBtnPath, NULL, center.x, center.y, iconButton.height / 2, 0, M_2_PI, true);
        // 缩放的最终路径
        // 以icon的中心为原点，半径600像素，画一个圆
        // 这个圆就足够大了，能包住整个屏幕
        // 添加一个mask用来做缩放动画
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        CGMutablePathRef iconFinalPath = CGPathCreateMutable();
        CGPathAddArc(iconFinalPath, NULL, center.x, center.y, 600, 0, M_2_PI, true);
        maskLayer.path = iconFinalPath;
        _toVC.view.layer.mask = maskLayer;
        
        // 从小圆放大到大圆
        CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskLayerAnimation.delegate = self;
        // CFBridgingRelease()省掉手动释放CGPathRef
        maskLayerAnimation.fromValue = CFBridgingRelease(iconBtnPath);
        maskLayerAnimation.toValue = CFBridgingRelease(iconFinalPath);
        maskLayerAnimation.duration = duration / 2;
        CFTimeInterval time = [iconButton.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        maskLayerAnimation.beginTime = time + moveAnimation.duration;
        maskLayerAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseIn];
        maskLayerAnimation.removedOnCompletion = NO;
        maskLayerAnimation.fillMode = kCAFillModeForwards;
        [maskLayer addAnimation:maskLayerAnimation forKey:@"maskLayerAnimation"];
    }
    
    // 开启水波动画
    [_toVC startWaveAnimation];
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    _fromVC.view.layer.mask = nil;
    
    // 结束后的位置
    IconView *iconButton = [[UIApplication sharedApplication].keyWindow viewWithTag:100];
    if (iconButton) {
        [iconButton removeFromSuperview];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    IconView *iconButton = [[UIApplication sharedApplication].keyWindow viewWithTag:100];

    // 接电话转场结束 normal态
    if ([anim isEqual:[_toVC.packUpButton.layer animationForKey:@"packAnimation"]]) {
        // 报告系统转场结束
        [_transitionContext completeTransition:YES];
    }else if ([anim isEqual:[iconButton.layer animationForKey:@"moveAnimation"]]){
        [[_transitionContext containerView] insertSubview:_fromVC.view belowSubview:_toVC.view];
    }
    else if ([anim isEqual:[_toVC.view.layer.mask animationForKey:@"maskLayerAnimation"]]){
        [_transitionContext completeTransition:YES];
    }
}

- (void)positionAnimationFor:(CALayer *)layer
                   fromValue:(id)fromValue
                     toValue:(id)toValue
                    duration:(NSTimeInterval)duration
           animationIdentify:(NSString *)identify
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.delegate = self;
    animation.duration = duration;
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction  = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [layer addAnimation:animation forKey:identify];
}

@end
