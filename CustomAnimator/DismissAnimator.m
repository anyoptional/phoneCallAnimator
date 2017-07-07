//
//  DismissAnimator.m
//  PhoneCallAnimator
//
//  Created by Archer on 2017/7/7.
//  Copyright © 2017年 Archer. All rights reserved.
//

#import "DismissAnimator.h"
#import "PhoneCallController.h"
#import "ViewController.h"
#import "UIView+Additions.h"
#import "IconView.h"

@interface DismissAnimator () <CAAnimationDelegate>
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) PhoneCallController *fromVC;
@property (nonatomic, weak) ViewController *toVC;
@end

@implementation DismissAnimator

- (void)dealloc
{
    NSLog(@"-------> DismissAnimator dealloc");
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    _fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (_fromVC.dismissType == kPresentType_normal) {
        return 1.25f;
    }
    return 2.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    _transitionContext = transitionContext;
    
    _fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    _toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *container = [transitionContext containerView];
    [container addSubview:_toVC.view];
    [container addSubview:_fromVC.view];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:_toVC];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // 添加转场动画 normal态
    if (_fromVC.dismissType == kDismissType_normal) {
        // 改变背景
        CABasicAnimation *contentAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
        contentAnimation.fromValue = _fromVC.view.layer.contents;
        contentAnimation.toValue = _toVC.view.layer.contents;
        contentAnimation.duration = duration / 3;
        contentAnimation.removedOnCompletion = NO;
        contentAnimation.fillMode = kCAFillModeForwards;
        contentAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [_fromVC.view.layer addAnimation:contentAnimation forKey:@"contentAnimation"];
        
        // 移除 头像
        UIButton *iconButton = _fromVC.iconButton;
        [self groupAnimationFor:iconButton.layer
                      fromValue:@(iconButton.centerY)
                        toValue:@(-iconButton.height / 2)
                       duration:duration
              animationIdentify:@"iconAnimation"];
        
        // 移除 挂断电话
        UIButton *hangUpButton = _fromVC.hangUpButton;
        [self groupAnimationFor:hangUpButton.layer
                      fromValue:@(hangUpButton.centerY)
                        toValue:@(finalFrame.size.height + hangUpButton.height / 2)
                       duration:duration
              animationIdentify:@"hangAnimation"];
        
        // 移除 挂起电话
        UIButton *packUpButton = _fromVC.packUpButton;
        [self groupAnimationFor:packUpButton.layer
                      fromValue:@(packUpButton.centerY)
                        toValue:@(finalFrame.size.height + packUpButton.height / 2)
                       duration:duration
              animationIdentify:@"packAnimation"];
        
        // 关闭水波动画
        [_fromVC stopWaveAnimation];
    }else{ // packup态
        // 在fromVC的iconButton位置添加一个相同的控件
        IconView *iconButton = [IconView new];
        [iconButton setBackgroundImage:_fromVC.iconButton.currentBackgroundImage forState:UIControlStateNormal];
        iconButton.frame = _fromVC.iconButton.frame;
        iconButton.layer.cornerRadius = 50;
        iconButton.layer.masksToBounds = YES;
        iconButton.tag = 100; // reopen时要移除，用来retrieve
        [iconButton addTarget:_toVC action:@selector(representPhoneCall) forControlEvents:UIControlEventTouchUpInside];
        [[UIApplication sharedApplication].keyWindow addSubview:iconButton];
        
        
        // 以icon的中心为原点，半径600像素，画一个圆
        // 这个圆就足够大了，能包住整个屏幕
        CGPoint center = iconButton.center;
        CGMutablePathRef iconBtnPath = CGPathCreateMutable();
        CGPathAddArc(iconBtnPath, NULL, center.x, center.y, 600, 0, M_2_PI, true);
        // 缩放的最终路径
        // 是以iconButton的边界组成的圆
        // 添加一个mask用来做缩放动画
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        CGMutablePathRef iconFinalPath = CGPathCreateMutable();
        CGPathAddArc(iconFinalPath, NULL, center.x, center.y, iconButton.height / 2, 0, M_2_PI, true);
        maskLayer.path = iconFinalPath;
        _fromVC.view.layer.mask = maskLayer;
        
        // 从大圆缩放到小圆
        CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskLayerAnimation.delegate = self;
        // CFBridgingRelease()省掉手动释放CGPathRef
        maskLayerAnimation.fromValue = CFBridgingRelease(iconBtnPath);
        maskLayerAnimation.toValue = CFBridgingRelease(iconFinalPath);
        maskLayerAnimation.duration = duration / 2;
        maskLayerAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        maskLayerAnimation.removedOnCompletion = NO;
        maskLayerAnimation.fillMode = kCAFillModeForwards;
        [maskLayer addAnimation:maskLayerAnimation forKey:@"maskLayerAnimation"];
        
        // 将icon从上方移动到下方
        CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        moveAnimation.delegate = self;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, iconButton.centerX, iconButton.centerY);
        // 2/3 3/4等是随意取的
        CGPoint cp1 = CGPointMake(_fromVC.view.width, iconButton.centerY);
        CGPoint cp2 = CGPointMake(_fromVC.view.width * 2/3, _fromVC.view.height * 3/4);
        CGPoint ep = CGPointMake(_fromVC.view.width * 5/6, _fromVC.view.height * 4/5);
        CGPathAddCurveToPoint(path, NULL, cp1.x, cp1.y, cp2.x, cp2.y, ep.x, ep.y);
        moveAnimation.path = path;
        moveAnimation.duration = duration / 2;
        moveAnimation.removedOnCompletion = NO;
        // time用来将两个动画串联起来
        CFTimeInterval time = [maskLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        moveAnimation.beginTime = time + maskLayerAnimation.duration;
        moveAnimation.fillMode = kCAFillModeForwards;
        moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [iconButton.layer addAnimation:moveAnimation forKey:@"moveAnimation"];
        // 释放路径
        CFRelease(path);
    }
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    // 结束后的位置
    IconView *iconButton = [[UIApplication sharedApplication].keyWindow viewWithTag:100];
    if (iconButton) {
        CGPoint origin = CGPointMake(_fromVC.view.width * 5/6 - iconButton.width / 2, _fromVC.view.height * 4/5 - iconButton.height / 2);
        CGSize size = CGSizeMake(iconButton.width, iconButton.height);
        iconButton.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // dismiss normal
    if ([anim isEqual:[_fromVC.packUpButton.layer animationForKey:@"packAnimation"]]) {
        [_transitionContext completeTransition:YES];
    }else{ // packup
        IconView *iconButton = [[UIApplication sharedApplication].keyWindow viewWithTag:100];
        if ([anim isEqual:[iconButton.layer.mask animationForKey:@"maskLayerAnimation"]]) {
            iconButton.hidden = YES;
        }else{
            iconButton.hidden = NO;
            [_transitionContext completeTransition:YES];
        }
    }
}

- (void)groupAnimationFor:(CALayer *)layer
                fromValue:(id)fromValue
                  toValue:(id)toValue
                 duration:(NSTimeInterval)duration
        animationIdentify:(NSString *)identify
{
    CABasicAnimation *positionAniamtion = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionAniamtion.fromValue = fromValue;
    positionAniamtion.toValue = toValue;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1);
    opacityAnimation.toValue = @(0.2);
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.delegate = self;
    groupAnimation.animations = @[positionAniamtion, opacityAnimation];
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.duration = duration;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.timingFunction  = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [layer addAnimation:groupAnimation forKey:identify];
}

@end
