//
// Created by Zhang Zeqing on 4/20/15.
// Copyright (c) 2015 NYSNETECH. All rights reserved.
//

@import AVFoundation;
#import <Masonry/View+MASAdditions.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ScannerViewController.h"
#import "UIColor+NTFactory.h"
#import "NTFactory.h"
#import "EventDetailViewController.h"
#import "NTHTTPSessionManager.h"
#import "EventStore.h"
#import "NTEvent.h"


@interface ScannerViewController ()
@property(nonatomic, strong) UIView *previewView;
@property(nonatomic, weak) UILabel *infoLabel;
@end

@implementation ScannerViewController {
    /* Here’s a quick rundown of the instance variables (via 'iOS 7 By Tutorials'):

     1. _captureSession – AVCaptureSession is the core media handling class in AVFoundation. It talks to the hardware to retrieve, process, and output video. A capture session wires together inputs and outputs, and controls the format and resolution of the output frames.

     2. _videoDevice – AVCaptureDevice encapsulates the physical camera on a device. Modern iPhones have both front and rear cameras, while other devices may only have a single camera.

     3. _videoInput – To add an AVCaptureDevice to a session, wrap it in an AVCaptureDeviceInput. A capture session can have multiple inputs and multiple outputs.

     4. _previewLayer – AVCaptureVideoPreviewLayer provides a mechanism for displaying the current frames flowing through a capture session; it allows you to display the camera output in your UI.
     5. _running – This holds the state of the session; either the session is running or it’s not.
     6. _metadataOutput - AVCaptureMetadataOutput provides a callback to the application when metadata is detected in a video frame. AV Foundation supports two types of metadata: machine readable codes and face detection.
     7. _backgroundQueue - Used for showing alert using a separate thread.
     */
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    BOOL _running;
    AVCaptureMetadataOutput *_metadataOutput;
}


#pragma mark - view cycle

- (void)loadView {
    [super loadView];

    self.title = @"Scanner";
    self.view.backgroundColor = [UIColor nt_backgroundColor];
    self.navigationItem.titleView = [NTFactory titleLogoView];

    _previewView = [UIView new];
    _previewView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_previewView];

    [_previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(self.view.mas_width);
        make.center.equalTo(self.view);
    }];

    _infoLabel = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor nt_foregroundColor];
        [self.view addSubview:label];
        label;
    });

    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(20, 20, 20, 20));
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCaptureSession];
    [_previewView.layer addSublayer:_previewLayer];

    // listen for going into the background and stop the session
    [[[NSNotificationCenter defaultCenter]
            rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] subscribeNext:^(id x) {
        [self startRunning];
    }];

    [[[NSNotificationCenter defaultCenter]
            rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] subscribeNext:^(id x) {
        [self stopRunning];
    }];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _previewLayer.frame = _previewView.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRunning];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - AV capture methods

- (void)setupCaptureSession {
    // 1
    if (_captureSession) return;
    // 2
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice) {
        self.infoLabel.text = @"No video camera on this device!";
        return;
    }
    // 3
    _captureSession = [[AVCaptureSession alloc] init];
    // 4
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:nil];
    // 5
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    // 6
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;


    // capture and process the metadata
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue = dispatch_queue_create("com.1337labz.featurebuild.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
}

- (void)startRunning {
    if (_running) return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
    _running = YES;
}
- (void)stopRunning {
    if (!_running) return;
    _running = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_captureSession stopRunning];
    });
}

#pragma mark - Delegate functions

- (void)   captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
          fromConnection:(AVCaptureConnection *)connection {

    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            // 3
            AVMetadataMachineReadableCodeObject *code =
                    (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:obj];
            // 4
            if ([self validCode:code]) {
                *stop = YES;
                DDLogInfo(@"code scanned: %@", code);
                [self processCode:code];
                [self stopRunning];
            }
        }
    }];
}

- (BOOL)validCode:(AVMetadataMachineReadableCodeObject *)code {
    return [code.type isEqualToString:@"org.iso.QRCode"];
}

- (void)processCode:(AVMetadataMachineReadableCodeObject *)code {
    if (!_running) {
        return;
    }
    NSString *eventID = code.stringValue;
    [SVProgressHUD show];

    @weakify(self);
    NTHTTPSessionManager *manager = [NTHTTPSessionManager sharedManager];
    [[manager getEventByEventID:eventID] subscribeNext:^(NTEvent *event) {
        @strongify(self);
        [SVProgressHUD dismiss];
        EventDetailViewController *eventDetailViewController = [EventDetailViewController controllerWithEvent:event];
        [self.navigationController pushViewController:eventDetailViewController animated:YES];
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Error"];
    }];
}

@end