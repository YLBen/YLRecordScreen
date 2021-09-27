//
//  UIView+YLLoading.h
//  iOSExperience
//
//  Created by Ben Lv on 2018/5/27.
//  Copyright © 2018年 avatar. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIView (YLLoading)

/// 无标题缓冲视图
- (void)av_postLoading;
- (void)av_postLoadingWithTitle:(NSString *)title;
- (void)av_postLoadingWithTitle:(NSString *)title detail:(NSString *)detail;
- (void)av_postLoadingWithTitle:(NSString *)title contentColor:(UIColor *)contentColor;

/** 自动隐藏message 默认时间为2秒 */
- (void)av_postMessage:(NSString *)message;
- (void)av_postMessage:(NSString *)message duration:(NSTimeInterval)duration;
- (void)av_postMessageWithTitle:(NSString *)title detail:(NSString *)detail contentColor:(UIColor *)contentColor backgroundColor:(UIColor *)backgroundColor duration:(NSTimeInterval)duration;

///隐藏loading视图
- (void)av_hideLoading;
- (void)av_hideLoadingWithAfterDelay:(CGFloat)afterDelay;

@end
