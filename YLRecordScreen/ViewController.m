//
//  ViewController.m
//  YLRecordScreen
//
//  Created by 吕彦良 on 2021/9/26.
//

#import "ViewController.h"
#import "UIView+YLLoading.h"
#import "YLRecordManager.h"
@interface ViewController ()
{
    bool _isRecord;
}
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
}

- (IBAction)recordScreen:(UIButton *)sender {
    
    if (!_isRecord) {
        [[YLRecordManager sharedInstance] startRecording];        
        _isRecord = !_isRecord;
        [_recordBtn setTitle:@"录制中.." forState:UIControlStateNormal];
    }else{
        [[YLRecordManager sharedInstance] stopRecording];
        [_recordBtn setTitle:@"视频录制" forState:UIControlStateNormal];
        _isRecord = !_isRecord;
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否保持到相册" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        __weak __typeof__(self) weakSelf = self;
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(self) strongSelf = weakSelf;
            [strongSelf.view av_postLoading];
//            strongSelf.activityIndicatorView.hidden = NO;
            [[YLRecordManager sharedInstance] saveVideoToAlbum:^{
                __strong __typeof(self) strongSelf = weakSelf;
                [strongSelf.view av_hideLoading];
                [strongSelf.view av_postMessage:@"保持成功"];
//                strongSelf.activityIndicatorView.hidden = YES;
//                [strongSelf.activityIndicator stopAnimating];
            }];
           }];
           UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

           }];
        [alertController addAction:sureAction];           // A
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
}
#pragma mark - life cycle

#pragma mark - public methods

#pragma mark - private methods

#pragma mark - getter && setter

#pragma mark - lazy loading





@end
