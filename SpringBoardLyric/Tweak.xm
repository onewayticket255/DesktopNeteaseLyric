#define DEVICE_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define DEVICE_HEIGHT  [[UIScreen mainScreen] bounds].size.height
#define LYRIC_WIDTH  34 //iPhone X,iPhone XS safe-area-inset-bottom

#import <UIKit/UIKit.h>
#import "MediaRemote.h"
#import <MRYIPCCenter.h>

/*
Model         pt         safe-area-inset-top safe-area-inset-bottom
iPhone X      375*812    44                  34
iPhone XS Max 414*896    44                  34
*/

static int isLyricEnabled;
static int isLockScreenEnabled ;
static CGFloat LYRIC_Y;  
static NSMutableDictionary *settings;
static bool TranslateOrRoma = 1;
static bool isMusicOn =0;

NSUserDefaults *defaults;
MRYIPCCenter* center;

@interface UIWindow ()
-(void)_setSecure:(BOOL)arg1 ;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                   
@end

@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
-(BOOL)isPlaying;
@end

@interface UIApplication ()
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface NSUserDefaults ()
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

@interface Lyric: NSObject
{
    UIWindow *LyricWindow;
    UILabel *LyricOriginLabel;
    UILabel *LyricTranslateLabel;
}
- (id)init;
- (void)SingleTap:(id)arg1;
- (void)DoubleTap;
- (void)LongPress;
- (void)updateLyric:(NSString*)origin withTranslate:(NSString*)translate;
- (void)updateFrame:(CGRect)arg1;
- (void)setHidden:(BOOL)arg1;
- (NSString*)getLyric;
@end

@implementation Lyric
- (id)init{
   self = [super init];
   if(self){
    
    LYRIC_Y= settings[@"Y-Axis"] ? [settings[@"Y-Axis"] doubleValue]:DEVICE_HEIGHT-LYRIC_WIDTH;

    LyricWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,LYRIC_Y,DEVICE_WIDTH,LYRIC_WIDTH)];
    LyricOriginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH,LYRIC_WIDTH/2)];
    LyricTranslateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,LYRIC_WIDTH/2,DEVICE_WIDTH,LYRIC_WIDTH/2)];
  
    LyricOriginLabel.text = @"Lyric Start";
    LyricOriginLabel.adjustsFontSizeToFitWidth = 1;
    LyricOriginLabel.font = [UIFont boldSystemFontOfSize:14];
    LyricOriginLabel.textAlignment = NSTextAlignmentCenter;
    LyricOriginLabel.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.233];

    LyricTranslateLabel.font = [UIFont boldSystemFontOfSize:14];
    LyricTranslateLabel.adjustsFontSizeToFitWidth = 1;
    LyricTranslateLabel.textAlignment = NSTextAlignmentCenter;
    LyricTranslateLabel.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.233];

    [LyricWindow addSubview:LyricOriginLabel];
    [LyricWindow addSubview:LyricTranslateLabel];

    //UIWindowLevelNormal = 0 UIWindowLevelStatusBar = 1000 UIWindowLevelAlert = 2000  
    LyricWindow.windowLevel = 2000;
    LyricWindow.hidden = 0;
    LyricWindow.userInteractionEnabled = 1;

   
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    [tapGesture setNumberOfTapsRequired: 1];

    UITapGestureRecognizer *doubletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DoubleTap)];
    [doubletapGesture setNumberOfTapsRequired: 2];

    [tapGesture requireGestureRecognizerToFail:doubletapGesture];

    UILongPressGestureRecognizer *holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(LongPress)];

    
    [LyricWindow addGestureRecognizer: tapGesture];
    [LyricWindow addGestureRecognizer: doubletapGesture];
    [LyricWindow addGestureRecognizer: holdGesture];

    //show in lockscreen
    [LyricWindow _setSecure:1];
   }
   return self;
}


- (void)SingleTap:(id)gestureRecognizer {    
    CGPoint loc=[gestureRecognizer locationInView:LyricOriginLabel];
    if((double)loc.x<DEVICE_WIDTH*1/3){
        MRMediaRemoteSendCommand(kMRPreviousTrack, 0);
    }else if((double)loc.x<DEVICE_WIDTH*2/3){
        MRMediaRemoteSendCommand(kMRTogglePlayPause, 0);
    }else{
        MRMediaRemoteSendCommand(kMRNextTrack, 0);
    }      	
}

- (void)DoubleTap{    
    TranslateOrRoma=!TranslateOrRoma;
}

- (void)LongPress{    
    NSString *nowPlayingID = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];
    if(nowPlayingID){
        [[UIApplication sharedApplication] launchApplicationWithIdentifier:nowPlayingID suspended: NO];
    }else{
        //默认开启网易云
        [[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.netease.cloudmusic" suspended: NO];
    }
    
}

- (void)setHidden:(BOOL)arg1{
    LyricWindow.hidden = arg1;
}


- (void)updateLyric:(NSString*)origin withTranslate:(NSString*)translate{
    LyricOriginLabel.text=origin;
    LyricTranslateLabel.text=translate;
}

- (void)updateFrame:(CGRect) arg1{
    LyricWindow.hidden = 0;
    LyricWindow.frame = arg1;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        LyricWindow.hidden = !isMusicOn;
    });
}

- (NSString*)getLyric{
    return LyricOriginLabel.text;
}


@end

static Lyric* LyricObject;

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig; 

    if(!LyricObject){
        LyricObject =  [Lyric new];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([[LyricObject getLyric] isEqualToString:@"Lyric Start"]) {
            [LyricObject setHidden:1];
        }
    });

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(NowPlayingApplicationDidChange:) name:(__bridge NSString *)kMRMediaRemoteNowPlayingApplicationDidChangeNotification object:nil];


    center = [MRYIPCCenter centerNamed:@"mlyx.neteasemusiclyric"];
    [center addTarget:self action:@selector(_updateLyric:)];
}

%new
- (void)_updateLyric:(NSDictionary *)args{
    NSString* lrc_origin=args[@"lrc_origin"];
    NSString* lrc_translate=args[@"lrc_translate"];
    NSString* lrc_romaji=args[@"lrc_romaji"];
  
    NSString* text=TranslateOrRoma?lrc_translate:lrc_romaji;

    dispatch_async(dispatch_get_main_queue(), ^{   
        [LyricObject updateLyric:lrc_origin withTranslate:text];
    }); 
}

%new
//autohide
-(void)NowPlayingApplicationDidChange:(NSNotification *)notification {  

    NSString *appName =notification.userInfo[@"kMRMediaRemoteNowPlayingApplicationDisplayNameUserInfoKey"];
    NSLog(@"mlyx NowPlayingApplicationDidChangeInfo %@",notification.userInfo);
    NSLog(@"mlyx NowPlayingApplicationDidChangeAppName %@",appName);

    isMusicOn=[appName isEqualToString:@"NetEase Music"]||[appName isEqualToString:@"QQMusic"]||[appName isEqualToString:@"Spotify"];
    
    dispatch_async(dispatch_get_main_queue(), ^{   
       [LyricObject setHidden:!isMusicOn];
    });

}


%end


static void updateLyricFrame() {
    defaults = [NSUserDefaults standardUserDefaults];
    [LyricObject updateFrame:CGRectMake(0,[(NSNumber *)[defaults objectForKey:@"Y-Axis" inDomain:@"mlyx.neteaselyricsetting"] doubleValue],DEVICE_WIDTH,LYRIC_WIDTH)];
}




@interface SBLockScreenManager
+(instancetype)sharedInstance;
-(void)_wakeScreenForTapToWake;
@end

%hook SBLockHardwareButtonActions
-(void)performSinglePressAction{

    %orig;
    
    if(isLockScreenEnabled && isMusicOn && [[%c(SBMediaController) sharedInstance] isPlaying]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[%c(SBLockScreenManager) sharedInstance] _wakeScreenForTapToWake];
        });
    }
    
}
%end

%hook SBDashBoardIdleTimerProvider

- (BOOL)isIdleTimerEnabled {
  return isLockScreenEnabled && isMusicOn && [[%c(SBMediaController) sharedInstance] isPlaying]?0:%orig;
}

%end

%ctor{
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
    isLyricEnabled = settings[@"isLyricEnabled"] ? [settings[@"isLyricEnabled"] boolValue] : 1;    
    isLockScreenEnabled = settings[@"isLockScreenEnabled"] ? [settings[@"isLockScreenEnabled"] boolValue] : 0; 

    if(isLyricEnabled){
        %init;
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateLyricFrame, CFSTR("mlyx.neteaselyricsetting/Y-AxisChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    }
}