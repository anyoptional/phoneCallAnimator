//
//  ViewController.m
//  PhoneCallAnimator
//
//  Created by Archer on 2017/7/7.
//  Copyright © 2017年 Archer. All rights reserved.
//

#import "ViewController.h"
#import "PhoneCallController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (nonatomic, strong) UIButton *eventButton;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self buildEventButton];
}

- (void)representPhoneCall
{
    PhoneCallController *vc = [PhoneCallController new];
    vc.presentType = kPresentType_reopen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)handlePhoneCall
{
    // if exists, remove it
    UIView *iconView = [[UIApplication sharedApplication].keyWindow viewWithTag:100];
    if (iconView) {
        [iconView removeFromSuperview];
    }
    
    PhoneCallController *vc = [PhoneCallController new];
    vc.presentType = kPresentType_normal;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)buildEventButton
{
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"1.jpg"].CGImage);
    
    _eventButton = [UIButton new];
    _eventButton.frame = CGRectMake(kScreenWidth / 2 - 50, kScreenHeight - 150, 100, 100);
    _eventButton.layer.cornerRadius = 50;
    _eventButton.layer.masksToBounds = YES;
    [_eventButton setBackgroundColor:[UIColor colorWithRed:134 / 256.0 green:205 / 256.0 blue:147 / 256 alpha:1]];
    [_eventButton setTitle:@"接电话" forState:UIControlStateNormal];
    [_eventButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_eventButton addTarget:self action:@selector(handlePhoneCall) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_eventButton];
}

@end

