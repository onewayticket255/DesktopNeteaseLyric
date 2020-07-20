#import "MediaRemote.h"

@interface CCUIContentModuleContentContainerView : UIView
@property (assign,nonatomic) double compactContinuousCornerRadius;
@end

@interface CCUIContentModuleContainerViewController : UIViewController
@property (nonatomic,retain) UIViewController* contentViewController;
@property (nonatomic,readonly) CCUIContentModuleContentContainerView * moduleContentView;
@property (nonatomic,copy) NSString * moduleIdentifier;
-(BOOL)isExpanded;
-(void)updateExpanded;
-(void)updateImage:(NSNotification *)notification;
@end

NSNotificationCenter *notificationCenter;
UIImageView *imageView;

/*
loadView
viewDidLoad
viewWillAppear
viewWillLayoutSubviews
viewDidLayoutSubviews
viewDidAppear
*/

%group CCArtwork
    %hook CCUIContentModuleContainerViewController

    -(void)viewWillAppear:(BOOL)appear {
        %orig;
        if ([self.moduleIdentifier isEqualToString:@"com.apple.mediaremote.controlcenter.nowplaying"]) {
            notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(updateImage:) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
            [notificationCenter postNotificationName:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
            if (imageView == nil) {
                imageView = [[UIImageView alloc] initWithFrame:self.contentViewController.view.bounds];
                imageView.layer.cornerRadius = self.moduleContentView.compactContinuousCornerRadius;
                imageView.layer.masksToBounds = YES;
                [self.contentViewController.view addSubview:imageView];
                [self.contentViewController.view sendSubviewToBack:imageView];
            }
        }
    }

    -(void)viewWillLayoutSubviews {
        %orig;
        if ([self.moduleIdentifier isEqualToString:@"com.apple.mediaremote.controlcenter.nowplaying"]) {
            [self updateExpanded];
        }
    }

    %new
    -(void)updateExpanded {
        BOOL expanded = [self isExpanded];
        if (!expanded) {
            [imageView setHidden:NO];
        } else {
            [imageView setHidden:YES];
        }
    }

    %new
    -(void)updateImage:(NSNotification *)notification {
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
        if(result) {
            NSDictionary *dict = (__bridge NSDictionary *)result;
            NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
            if (artworkData != nil) {
            UIImage *image = [UIImage imageWithData:artworkData];
            imageView.image = image;
            }
        }
    });
    }

    -(void)viewWillDisappear:(BOOL)disappear {
        %orig;
        if ([self.moduleIdentifier isEqualToString:@"com.apple.mediaremote.controlcenter.nowplaying"]) {
            [notificationCenter removeObserver:self name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
        }
    }

    %end

%end

%ctor{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
    bool isCCArtworkEnabled=[settings objectForKey:@"isCCArtworkEnabled"] ? [[settings objectForKey:@"isCCArtworkEnabled"] boolValue] : 1;
    if(isCCArtworkEnabled){
        %init(CCArtwork);
    }
}

