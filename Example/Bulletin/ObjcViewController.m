//
//  ObjcViewController.m
//  Bulletin_Example
//
//  Created by Mitch Treece on 8/12/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#import "ObjcViewController.h"
#import "Bulletin_Example-Swift.h"
@import Bulletin;

@interface ObjcViewController ()
@property (nonatomic) UILabel *tapLabel;
@end

@implementation ObjcViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Objective-C";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tapLabel = [[UILabel alloc] init];
    self.tapLabel.text = @"Tap to Present Bulletin";
    self.tapLabel.textColor = [UIColor lightGrayColor];
    self.tapLabel.textAlignment = NSTextAlignmentCenter;
    self.tapLabel.numberOfLines = 0;
    self.tapLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tapLabel];
    
    NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[label]-8-|" options:0 metrics:0 views:@{@"label": self.tapLabel}];
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[label]-|" options:0 metrics:0 views:@{@"label": self.tapLabel}];
    [self.view addConstraints:hConstraints];
    [self.view addConstraints:vConstraints];
    
    [self presentBulletinWithDelay:0.5f];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentBulletin)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)presentBulletinWithDelay:(NSTimeInterval)delay {
    
    NotificationView *view = [[NotificationView alloc] init];
    view.iconImageView.image = [UIImage imageNamed:@"app_icon"];
    view.iconTitleLabel.text = @"BULLETIN";
    view.timeLabel.text = @"now";
    view.titleLabel.text = @"Objective-C";
    view.messageLabel.text = @"Hey look! Bulletin works with objc too! That's cool, but you really should just start using Swift 🙄.";
    
    BulletinView *bulletin = [BulletinView notification];
    [bulletin setPosition:kBulletinViewPositionBottom];
    [bulletin setBackgroundEffect:kBulletinViewBackgroundEffectDarkenMedium];
    [bulletin embedContent:view];
    
    if ([UIDevice currentDevice].isPhoneX) {
        [bulletin setCornerRadius:18];
        [bulletin setEdgeInsets:UIEdgeInsetsMake(0, 14, [UIScreen mainScreen].displayFeatureInsets.bottom + 4, 14)];
    }
    
    [bulletin presentAfter:delay];
    
}

- (void)presentBulletin {
    
    [self presentBulletinWithDelay:0];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
