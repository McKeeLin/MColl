//
//  captureView.m
//  MColl
//
//

#import "captureView.h"
#import "dataHelper.h"
#import "PreviewVC.h"
#import "collectionVC.h"
#import "captureVC.h"


@interface captureView ()
{
    AVCaptureDevice *_camera;
    AVCaptureSession *_session;
    AVCaptureStillImageOutput *_imageOutput;
    AVCaptureVideoPreviewLayer *_previewLayer;
}

@end

@implementation captureView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame frontCamera:(BOOL)frontCamera
{
    self = [super initWithFrame:frame];
    if( self ){
        NSArray *devieces = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for( AVCaptureDevice *deviece in devieces ){
            if( deviece.position == AVCaptureDevicePositionFront && frontCamera ){
                _camera = deviece;
                break;
            }
            if( deviece.position == AVCaptureDevicePositionBack && !frontCamera ){
                _camera = deviece;
                break;
            }
        }
        
        if( _camera ){
            _imageOutput = [[AVCaptureStillImageOutput alloc] init];
            _session = [[AVCaptureSession alloc] init];
            _session.sessionPreset = AVCaptureSessionPresetHigh;
            [_session addInput:[[AVCaptureDeviceInput alloc] initWithDevice:_camera error:nil]];
            [_session addOutput:_imageOutput];
            
            _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
            _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [self.layer addSublayer:_previewLayer];

        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    BOOL running = _session.isRunning;
    if( running ){
        [_session stopRunning];
    }
    
    NSMutableDictionary *outputSettings = [[NSMutableDictionary alloc] initWithCapacity:0];
    [outputSettings setObject:[NSNumber numberWithFloat:self.frame.size.width] forKey:(id)kCVPixelBufferWidthKey];
    [outputSettings setObject:[NSNumber numberWithFloat:self.frame.size.height] forKey:(id)kCVPixelBufferHeightKey];
    [outputSettings setObject:AVVideoCodecJPEG forKey:AVVideoCodecKey];
    _imageOutput.outputSettings = outputSettings;
    _previewLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    AVCaptureConnection *conn = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if( conn ){
        if( conn.supportsVideoOrientation ){
            conn.videoOrientation = (NSInteger)[UIApplication sharedApplication].statusBarOrientation;
        }
    }
    
    if( running ){
        [_session startRunning];
    }
}

- (void)start
{
    if( !_session.isRunning )
    {
        [_session startRunning];
    }
}

- (void)stop
{
    if( _session.isRunning ){
        [_session stopRunning];
    }
}

- (void)caputre
{
    AVCaptureConnection *conn = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if( conn ){
        if( conn.supportsVideoOrientation ){
            conn.videoOrientation = (NSInteger)[UIApplication sharedApplication].statusBarOrientation;
        }
        [_imageOutput captureStillImageAsynchronouslyFromConnection:conn completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){
            if( imageDataSampleBuffer ){
                _imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                [self stop];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    PreviewVC *vc = [[PreviewVC alloc] init];
                    vc.imageData = _imageData;
                    vc.group = _group;
                    vc.capView = self;
                    [_capVC presentViewController:vc animated:YES completion:nil];
                });
            }
        }];
    }
}

@end
