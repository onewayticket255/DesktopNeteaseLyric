#define DEVICE_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define LYRIC_WIDTH  36

#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "MediaRemote.h"

static int isEnabled;
NSUserDefaults *defaults;
static CGFloat LYRIC_Y;   //xs max = 860
static NSMutableDictionary *settings;
static bool TranslateOrRoma = 1;
static bool isNeteaseOn =0;


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

    LyricWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,LYRIC_Y,DEVICE_WIDTH,LYRIC_WIDTH)];
    LyricOriginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH,LYRIC_WIDTH/2)];
    LyricTranslateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,LYRIC_WIDTH/2,DEVICE_WIDTH,LYRIC_WIDTH/2)];
  
    [LyricOriginLabel setText:@"Lyric Start"];
    [LyricOriginLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [LyricOriginLabel setTextAlignment:NSTextAlignmentCenter];
    [LyricOriginLabel setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.233]];

    [LyricTranslateLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [LyricTranslateLabel setTextAlignment:NSTextAlignmentCenter];
    [LyricTranslateLabel setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.233]];

	[LyricWindow addSubview:LyricOriginLabel];
    [LyricWindow addSubview:LyricTranslateLabel];

    //UIWindowLevelNormal = 0 UIWindowLevelStatusBar = 1000 UIWindowLevelAlert = 2000  
    [LyricWindow setWindowLevel:2000];
    [LyricWindow setHidden:0];
    [LyricWindow setUserInteractionEnabled:YES];

   
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
	[tapGesture setNumberOfTapsRequired: 1];

    UITapGestureRecognizer *doubletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DoubleTap)];
	[doubletapGesture setNumberOfTapsRequired: 2];

    [tapGesture requireGestureRecognizerToFail:doubletapGesture];

    UILongPressGestureRecognizer *holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(LongPress)];

    
	[LyricWindow addGestureRecognizer: tapGesture];
    [LyricWindow addGestureRecognizer: doubletapGesture];
    [LyricWindow addGestureRecognizer: holdGesture];
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
    [[UIApplication sharedApplication] launchApplicationWithIdentifier: @"com.netease.cloudmusic" suspended: NO];
}

- (void)setHidden:(BOOL)arg1{
    [LyricWindow setHidden:arg1];
}


- (void)updateLyric:(NSString*)origin withTranslate:(NSString*)translate{
  	LyricOriginLabel.text=origin;
    LyricTranslateLabel.text=translate;
}

- (void)updateFrame:(CGRect) arg1{
    [LyricWindow setHidden:0];
    LyricWindow.frame=arg1;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [LyricWindow setHidden:!isNeteaseOn];
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
		LyricObject =  [[Lyric alloc] init];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([[LyricObject getLyric] isEqualToString:@"Lyric Start"]) {
            [LyricObject setHidden:1];
        }
    });

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(NowPlayingApplicationDidChange:) name:(__bridge NSString *)kMRMediaRemoteNowPlayingApplicationDidChangeNotification object:nil];


	CPDistributedMessagingCenter *c=[CPDistributedMessagingCenter centerNamed:@"mlyx.neteasemusiclyric"];
	rocketbootstrap_distributedmessagingcenter_apply(c);
	[c runServerOnCurrentThread];
	[c registerForMessageName:@"LyricChange" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	
}

%new
//autohide
-(void)NowPlayingApplicationDidChange:(NSNotification *)notification {  

    NSString *appName =[notification.userInfo  objectForKey:@"kMRMediaRemoteNowPlayingApplicationDisplayNameUserInfoKey"];
    NSLog(@"mlyx noti1 %@",notification.userInfo);
    NSLog(@"mlyx noti2 %@",appName);

    isNeteaseOn=[appName isEqualToString:@"NetEase Music"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
       [LyricObject setHidden:!isNeteaseOn];
    });

}

%new
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
	NSString* lrc_origin=userInfo[@"lrc_origin"];
	NSString* lrc_translate=userInfo[@"lrc_translate"];
    NSString* lrc_roma=userInfo[@"lrc_romaji"];
    
    NSString* text=TranslateOrRoma?lrc_translate:lrc_roma;

    NSLog(@"mlyx_debig %@",lrc_origin);

    [LyricObject updateLyric:lrc_origin withTranslate:text];

	return nil;
}
%end



static void updateLyricFrame() {
    defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *d = (NSNumber *)[defaults objectForKey:@"Y-Axis" inDomain:@"mlyx.neteaselyricsetting"];
    [LyricObject updateFrame:CGRectMake(0,[d doubleValue],DEVICE_WIDTH,LYRIC_WIDTH)];
}


%ctor{
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
    isEnabled = [settings objectForKey:@"isEnabled"] ? [[settings objectForKey:@"isEnabled"] boolValue] : 1;

    NSString* Y_Axis=[settings objectForKey:@"Y-Axis"] ? [settings objectForKey:@"Y-Axis"]: @"50";
    LYRIC_Y=[Y_Axis doubleValue];
    
    if(isEnabled){
        %init;
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateLyricFrame, CFSTR("mlyx.neteaselyricsetting/Y-AxisChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    }
}