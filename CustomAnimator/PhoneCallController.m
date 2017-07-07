//
//  PhoneCallController.m
//  PhoneCallAnimator
//
//  Created by Archer on 2017/7/7.
//  Copyright © 2017年 Archer. All rights reserved.
//

#import "PhoneCallController.h"
#import "PresentAnimator.h"
#import "DismissAnimator.h"
#import "UIView+Additions.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define WIDTH 200

@interface PhoneCallController () <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) CAShapeLayer *waveLayer1;
@property (nonatomic, strong) CAShapeLayer *waveLayer2;
@property (nonatomic, strong) CAShapeLayer *waveLayer3;
@end

@implementation PhoneCallController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self conformsTransitoningProtocol];
    
    [self buildUI];
    [self buildWaveLayers];
}

- (void)conformsTransitoningProtocol
{
    // 遵循转场代理（modal方式）
    // push方式在UINavgationControllerDelegate
    // tabbar点击在UITabBarControllerDelegate
    self.transitioningDelegate = self;
}

- (void)dealloc
{
    NSLog(@"-------> PhoneCallController dealloc");
}

- (void)hangUpPhoneCall
{
    self.dismissType = kDismissType_normal;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)packUpPhoneCall
{
    self.dismissType = kDismissType_packup;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startWaveAnimation
{
    CABasicAnimation *animation1 = [CABasicAnimation animation];
    animation1.duration = 1.0;
    animation1.repeatCount = MAXFLOAT;
    animation1.keyPath = @"transform";
    animation1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(WIDTH, 0, 0)];
    
    [_waveLayer1 addAnimation:animation1 forKey:nil];
    [_waveLayer2 addAnimation:animation1 forKey:nil];
    [_waveLayer3 addAnimation:animation1 forKey:nil];
}

- (void)stopWaveAnimation
{
    [_waveLayer1 removeAllAnimations];
    [_waveLayer2 removeAllAnimations];
    [_waveLayer3 removeAllAnimations];
    
    [_waveLayer1 removeFromSuperlayer];
    [_waveLayer2 removeFromSuperlayer];
    [_waveLayer3 removeFromSuperlayer];
}

- (void)buildUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"2.jpg"].CGImage);
    
    _iconButton = [UIButton new];
    [_iconButton setBackgroundImage:[UIImage imageNamed:@"zero.jpeg"] forState:UIControlStateNormal];
    _iconButton.frame = CGRectMake(kScreenWidth / 2 - 50, 150, 100, 100);
    _iconButton.layer.cornerRadius = 50;
    _iconButton.layer.masksToBounds = YES;
    [self.view addSubview:_iconButton];
    
    _hangUpButton = [UIButton new];
    _hangUpButton.frame = CGRectMake(80, kScreenHeight * 3 / 4, 60, 60);
    _hangUpButton.backgroundColor = [UIColor redColor];
    [_hangUpButton setTitle:@"挂断" forState:UIControlStateNormal];
    [_hangUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _hangUpButton.layer.cornerRadius = 30;
    _hangUpButton.layer.masksToBounds = YES;
    [_hangUpButton addTarget:self action:@selector(hangUpPhoneCall) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_hangUpButton];
    
    _packUpButton = [UIButton new];
    _packUpButton.frame = CGRectMake(kScreenWidth - 140, kScreenHeight * 3 / 4, 60, 60);
    _packUpButton.backgroundColor = [UIColor greenColor];
    [_packUpButton setTitle:@"收起" forState:UIControlStateNormal];
    [_packUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _packUpButton.layer.cornerRadius = 30;
    _packUpButton.layer.masksToBounds = YES;
    [_packUpButton addTarget:self action:@selector(packUpPhoneCall) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_packUpButton];
}

- (void)buildWaveLayers
{
    _waveLayer1 = [CAShapeLayer layer];
    _waveLayer1.fillColor = [UIColor clearColor].CGColor;
    _waveLayer1.strokeColor = [UIColor cyanColor].CGColor;
    _waveLayer1.lineCap = kCALineCapRound;
    
    _waveLayer2 = [CAShapeLayer layer];
    _waveLayer2.fillColor = [UIColor clearColor].CGColor;
    _waveLayer2.strokeColor = [UIColor cyanColor].CGColor;
    _waveLayer2.lineCap = kCALineCapRound;
    
    _waveLayer3 = [CAShapeLayer layer];
    _waveLayer3.fillColor = [UIColor clearColor].CGColor;
    _waveLayer3.strokeColor = [UIColor cyanColor].CGColor;
    _waveLayer3.lineCap = kCALineCapRound;
    

    CGFloat width = WIDTH;
    CGFloat width1 = 30;
    CGFloat width2 = 60;
    CGFloat centerY = _packUpButton.top - 100;
    
    UIBezierPath *shapePath = [[UIBezierPath alloc] init];
    [shapePath moveToPoint:CGPointMake(-width, centerY)];
    
    UIBezierPath *shapePath1 = [[UIBezierPath alloc] init];
    [shapePath1 moveToPoint:CGPointMake(-width - width1, centerY)];
    
    UIBezierPath *shapePath2 = [[UIBezierPath alloc] init];
    [shapePath2 moveToPoint:CGPointMake(-width - width2, centerY)];
    
    
    CGFloat  x = 0;
    for (int i =0 ; i < 6; i++) {
        [shapePath addQuadCurveToPoint:CGPointMake(x - WIDTH / 2.0, centerY) controlPoint:CGPointMake(x - WIDTH + WIDTH/4.0, centerY - 8)];
        [shapePath addQuadCurveToPoint:CGPointMake(x, centerY) controlPoint:CGPointMake(x - WIDTH/4.0, centerY + 8)];
        
        [shapePath1 addQuadCurveToPoint:CGPointMake(x - width1 - WIDTH / 2.0, centerY) controlPoint:CGPointMake(x - width1 - WIDTH + WIDTH/4.0, centerY - 14)];
        [shapePath1 addQuadCurveToPoint:CGPointMake(x - width1, centerY) controlPoint:CGPointMake(x - width1 - WIDTH/4.0, centerY + 14)];
        
        [shapePath2 addQuadCurveToPoint:CGPointMake(x - width2 - WIDTH / 2.0, centerY) controlPoint:CGPointMake(x - width2 - WIDTH + WIDTH/4.0, centerY - 20)];
        [shapePath2 addQuadCurveToPoint:CGPointMake(x - width2, centerY) controlPoint:CGPointMake(x - width2 - WIDTH/4.0, centerY + 20)];
        
        x += width;
    }
    
    _waveLayer1.path = shapePath.CGPath;
    _waveLayer2.path = shapePath1.CGPath;
    _waveLayer3.path = shapePath2.CGPath;
    
    [self.view.layer addSublayer:_waveLayer1];
    [self.view.layer addSublayer:_waveLayer2];
    [self.view.layer addSublayer:_waveLayer3];
}

#pragma mark  -- UIViewControllerTransitioningDelegate

// 自定义present弹出控制器时的动画需要提供的遵守UIViewControllerAnimatedTransitioning对象
// 返回nil，使用系统默认样式
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [PresentAnimator new];
}

// 自定义dismiss移除控制器时的动画需要提供的遵守UIViewControllerAnimatedTransitioning对象
// 返回nil，使用系统默认样式
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissAnimator new];
}

@end

