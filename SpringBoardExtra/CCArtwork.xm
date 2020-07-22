#import "MediaRemote.h"
@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) id nowPlayingApplication;
+(id)sharedInstance;
@end

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
             [notificationCenter addObserver:self selector:@selector(NowPlayingApplicationDidChange:) name:(__bridge NSString *)kMRMediaRemoteNowPlayingApplicationDidChangeNotification object:nil];
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

    %new
   //autohide
    -(void)NowPlayingApplicationDidChange:(NSNotification *)notification {  

        NSString *appName =[notification.userInfo  objectForKey:@"kMRMediaRemoteNowPlayingApplicationDisplayNameUserInfoKey"];
        // NSLog(@"mlyx noti1 %@",notification.userInfo);
        // NSLog(@"mlyx noti2 %@",appName);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [imageView setHidden:!appName];
        });
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

