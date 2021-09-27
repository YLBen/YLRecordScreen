//
//  YLRecordManager.m
//  YLRecordScreen
//
//  Created by 吕彦良 on 2021/9/26.
//

#import "YLRecordManager.h"
#import <ReplayKit/ReplayKit.h>
typedef NS_ENUM(NSUInteger, ScreenRecError) {
    paramError = 0,
    recStartError = 1,
    recEndError = 2,
    exportError = 3,
    concatError = 4,
    saveError = 5,
    timeoutError = 6
};
static YLRecordManager *recordManager = nil;
@interface YLRecordManager()
{
    RPScreenRecorder *_recorder;
    NSURL *_movieUrl;
}
@property (nonatomic, copy) void(^myBlock)(void);
@end
@implementation YLRecordManager
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recordManager = [YLRecordManager new];
    });
    return recordManager;
}

- (instancetype)init{
    if(self = [super init]){
        _recorder = [RPScreenRecorder sharedRecorder];
    }
    return self;
}

- (BOOL)isRecordingSupported{
    return _recorder.isAvailable;

}

- (BOOL)isRecording{
    return _recorder.isRecording;
}

- (void)startRecording{
    if(!_recorder)
        return;
//    开始录制
    [_recorder startRecordingWithHandler:^(NSError * _Nullable error) {
        NSLog(@"视频录制开启产生问题=%@",error);
    }];
}

- (void)stopRecording{
    if(!_recorder)
        return;
//    结束录制
    [_recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        self->_movieUrl = [previewViewController valueForKey:@"movieURL"];
    }];
}

- (void)saveVideoToAlbum:(void(^)(void))success {
    _myBlock = success;
    [self export:[_movieUrl path] complete:^(ScreenRecError error, NSString *filePath) {
//        NSLog(@"export导出的路径=%@",filePath);
        [self writeVideoToAlbum:filePath];
    }];
}
//导出视频 mp4
- (void)export:(NSString *)filePathUrl complete:(void(^)(ScreenRecError error,NSString* filePath))complete {
    if (!filePathUrl) {
        NSLog(@"filePathUrl为空");
        return;
    }
    NSDate *date = [NSDate date];
    NSString *exportPath = [NSString stringWithFormat:@"%@%d.mp4",[self getCacheDir],(int)[date timeIntervalSince1970]*1000 ];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePathUrl];
    AVAsset *fileAsset = [AVURLAsset assetWithURL:fileUrl];
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    if (!([fileAsset tracksWithMediaType:AVMediaTypeVideo].count>0 && [fileAsset tracksWithMediaType:AVMediaTypeAudio].count>0)) {
        complete(exportError,filePathUrl);
        return;
    }
    for (AVAssetTrack *track in fileAsset.tracks) {
        if ([track.mediaType isEqual:AVMediaTypeVideo]) {
            AVMutableCompositionTrack *compositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            NSError *error;
            [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, fileAsset.duration) ofTrack:track atTime:kCMTimeZero error:&error];
        }
        else if([track.mediaType isEqual:AVMediaTypeAudio]){
            AVMutableCompositionTrack *compositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            NSError *error;
            [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, fileAsset.duration) ofTrack:track atTime:kCMTimeZero error:&error];
        }
    }
    AVAssetExportSession *assetExport = [AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPreset1280x720];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:exportPath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:exportPath error:&error];
        if (error) {
            NSLog(@"移除文件出错=%@",error);
        }
    }
    
    assetExport.outputFileType = AVFileTypeMPEG4;
    assetExport.outputURL = [NSURL fileURLWithPath:exportPath];
    assetExport.shouldOptimizeForNetworkUse = false;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        if (assetExport.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"Record SaveTmpVideo Success");
            complete(nil,exportPath);
        }
        else {
            complete(exportError,filePathUrl);
        }
    }];
    
}


- (void)writeVideoToAlbum:(NSString *)exportFilePath{
    
    UISaveVideoAtPathToSavedPhotosAlbum(exportFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }
    else {
        NSLog(@"保存视频成功");
        if(_myBlock){
            _myBlock();
        }
       
    }
}

- (NSString *)getCacheDir {
    NSString *cachePath = [NSString stringWithFormat:@"%@/Library/Caches/video/",NSHomeDirectory()];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cachePath]) {
        return cachePath;
    }
    [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    return cachePath;
    
}

- (void)removeCache {
    NSString *cachePath = [NSString stringWithFormat:@"%@/Library/Caches/video/",NSHomeDirectory()];
    NSFileManager*fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cachePath]) {
    return;
    }
    [fileManager removeItemAtPath:cachePath error:NULL];
}


- (UIImage*)screenSnapshot:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
