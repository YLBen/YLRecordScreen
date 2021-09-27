//
//  UIView+YLLoading.m
//  iOSExperience
//
//  Created by Ben Lv on 2018/5/27.
//  Copyright © 2018年 avatar. All rights reserved.
//

#import "UIView+YLLoading.h"
#import "MBProgressHUD.h"
//#import <MBProgressHUD/MBProgressHUD.h>
#import <objc/runtime.h>

static const CGFloat KTipNormalOverTime = 2;

@interface UIView (AVLoadingView) <MBProgressHUDDelegate>

@property (nonatomic,strong) MBProgressHUD * progressHud;

@end

@implementation UIView (AVLoadingView)

- (MBProgressHUD *)progressHud {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setProgressHud:(MBProgressHUD *)progressHud {
    return objc_setAssociatedObject(self, @selector(progressHud), progressHud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIView (YLLoading)

#pragma mark - postLoading.

- (void)av_postLoading
{
    [self av_postLoadingWithTitle:nil];
}

- (void)av_postLoadingWithTitle:(NSString *)title {
    [self av_postLoadingWithTitle:title detail:nil];
}

- (void)av_postLoadingWithTitle:(NSString *)title contentColor:(UIColor *)contentColor {
    [self av_postLoadingWithTitle:title detail:nil];
    self.progressHud.contentColor = contentColor;
}

- (void)av_postLoadingWithTitle:(NSString *)title detail:(NSString *)detail {
    [self av_checkCreateHudLoading];
    
    if (title.length) {
        self.progressHud.label.text = title;
    }
    if (detail.length) {
        self.progressHud.detailsLabel.text = detail;
    }
}


#pragma mark - postMessage

- (void)av_postMessage:(NSString *)message {
    [self av_postMessage:message duration:KTipNormalOverTime];
}

- (void)av_postMessage:(NSString *)message duration:(NSTimeInterval)duration{
    [self av_checkCreateHudLoading];
    [self av_setTitle:message];
    // Set the text mode to show only text.
    self.progressHud.mode = MBProgressHUDModeText;
    // Move to bottm center.
    //    self.progressHud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    
    [self av_hideLoadingWithAfterDelay:duration];
}

- (void)av_postMessageWithTitle:(NSString *)title detail:(NSString *)detail contentColor:(UIColor *)contentColor backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration {
    [self av_checkCreateHudLoading];
    self.progressHud.mode = MBProgressHUDModeText;
    
    if (title.length) {
        self.progressHud.label.text = title;
    }
    if (detail.length) {
        self.progressHud.detailsLabel.text = detail;
    }
    if (contentColor) {
        self.progressHud.contentColor = contentColor;
    }
    if (backgroundColor) {
        self.progressHud.label.superview.backgroundColor = backgroundColor;
    }
    [self av_hideLoadingWithAfterDelay:duration];
}

- (void)av_hideLoading {
    if (self.progressHud) {
        [self.progressHud hideAnimated:YES];
        [self.progressHud removeFromSuperview];
        self.progressHud.delegate = nil;
        self.progressHud = nil;
    }
}

- (void)av_hideLoadingWithAfterDelay:(CGFloat)afterDelay {
    if (self.progressHud) {
        [self.progressHud hideAnimated:YES afterDelay:afterDelay];
    }
}

#pragma mark - private method

- (void)av_checkCreateHudLoading
{
    if (!self.progressHud) {
        self.progressHud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        self.progressHud.bezelView.color = [UIColor clearColor];
        self.progressHud.contentColor = [UIColor blackColor];
        self.progressHud.delegate = self;
    }
}

- (void)av_setTitle:(NSString *)title {
    if (title.length) {
        self.progressHud.label.text = title;
    }
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    if (self.progressHud) {
        [self.progressHud removeFromSuperview];
        self.progressHud.delegate = nil;
        self.progressHud = nil;
    }
}


@end
