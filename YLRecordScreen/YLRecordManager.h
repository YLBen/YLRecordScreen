//
//  YLRecordManager.h
//  YLRecordScreen
//
//  Created by 吕彦良 on 2021/9/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface YLRecordManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isRecordingSupported;
- (BOOL)isRecording;
- (void)startRecording;
- (void)stopRecording;
- (void)removeCache;
- (void)saveVideoToAlbum:(void(^)(void))success;

- (UIImage*)screenSnapshot:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
