//
//  PhoneCallController.h
//  PhoneCallAnimator
//
//  Created by Archer on 2017/7/7.
//  Copyright © 2017年 Archer. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, PresentType) {
    kPresentType_normal,
    kPresentType_reopen
};

typedef NS_ENUM(NSUInteger, DismissType) {
    kDismissType_normal,
    kDismissType_packup
};

@interface PhoneCallController : UIViewController
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UIButton *hangUpButton;
@property (nonatomic, strong) UIButton *packUpButton;

@property (nonatomic, assign) PresentType presentType;
@property (nonatomic, assign) DismissType dismissType;

- (void)startWaveAnimation;
- (void)stopWaveAnimation;
@end
