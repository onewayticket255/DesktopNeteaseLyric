#define DEVICE_WIDTH  [[UIScreen mainScreen] bounds].size.width
#import "MediaRemote.h"

@interface UIApplication ()
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface NSTask : NSObject
+ (NSTask *)launchedTaskWithExecutableURL:(NSURL *)url 
                                arguments:(NSArray<NSString *> *)arguments 
                                    error:(out NSError * _Nullable *)error 
                       terminationHandler:(void (^)(NSTask *))terminationHandler;
@end

@interface SBMainDisplaySceneLayoutStatusBarView:UIView
- (void)tap;
@end

@interface MPUNowPlayingController 
@property (nonatomic,readonly) NSDictionary * currentNowPlayingInfo;
- (id)currentNowPlayingInfo;
- (id)currentNowPlayingArtwork;
@end


@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                
@end


@interface SBMediaController 
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+ (id)sharedInstance;
- (BOOL)isPlaying;
@end



@interface BCBatteryDeviceController 
+ (id)sharedInstance;
-(NSArray *)connectedDevices;
@end

@interface SpringBoard: UIApplication
- (id)_accessibilityFrontMostApplication;
-(void)frontDisplayDidChange: (id)arg1;
@end


@interface BCBatteryDevice
-(NSString *)name;
@end

@interface Lyric: NSObject
{
    UIWindow *LyricWindow;
    UILabel *LyricLabel;
}
- (id)init;
- (void)SingleTap:(id)arg1;
- (void)LongPress;
- (void)updateLyric;
- (void)start;
- (void)end;
- (void)setHidden:(BOOL)arg1;
@end

static MPUNowPlayingController* globalMPUNowPlaying;
static Lyric* LyricObject;
static int isOn=1;
static int isEnabled;
static int isWallpaperEnabled;
static NSData* cachedArtwork;


static CGFloat LYRIC_Y;   //xs max = 860
static NSString* MusicRoute;   //@"Dominic AirPods Pro";
static NSString* currentApp; 
static NSMutableDictionary *settings;


static bool BluetoothEarphoneConnected(){
	for(BCBatteryDevice *device in [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices]){
		if([device.name isEqualToString:MusicRoute])
			return true;
	}
	return false;
}

@implementation Lyric
- (id)init{
   self = [super init];
   if(self){
    LyricWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0,LYRIC_Y,DEVICE_WIDTH ,22)];
    LyricLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH ,22)];
   
    [LyricLabel setText:@"Lyric Start"];
    [LyricLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [LyricLabel setTextAlignment:NSTextAlignmentCenter];
    [LyricLabel setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.233]];


    [LyricWindow addSubview:LyricLabel];
    [LyricWindow setWindowLevel:100000];
    [LyricWindow setHidden:NO];
    [LyricWindow setUserInteractionEnabled:YES];
   

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(SingleTap:)];
	[tapGesture setNumberOfTapsRequired: 1];

    UILongPressGestureRecognizer *holdGesture = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(LongPress)];

    
	[LyricWindow addGestureRecognizer: tapGesture];
    [LyricWindow addGestureRecognizer: holdGesture];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([LyricLabel.text isEqualToString:@"Lyric Start"]) {
            [LyricWindow setHidden:YES];
        }
    });

   }
   return self;
}


- (void)SingleTap:(id)gestureRecognizer {    
    if(gestureRecognizer) {
		CGPoint loc = [gestureRecognizer locationInView:LyricLabel];
        NSLog(@"mlyx debug,%f",loc.x);
	    if((double)loc.x<DEVICE_WIDTH*1/3){
            NSLog(@"mlyx debug, left");
            MRMediaRemoteSendCommand(kMRPreviousTrack, 0);
        }else if((double)loc.x<DEVICE_WIDTH*2/3){
            NSLog(@"mlyx debug, center");
            MRMediaRemoteSendCommand(kMRTogglePlayPause, 0);
        }else{
            NSLog(@"mlyx debug, right");
            MRMediaRemoteSendCommand(kMRNextTrack, 0);
        }      
	}
}

- (void)LongPress{    
    [[UIApplication sharedApplication] launchApplicationWithIdentifier: @"com.netease.cloudmusic" suspended: NO];
}

- (void)setHidden:(BOOL)arg1{
    [LyricWindow setHidden:arg1];
}


- (void)updateLyric{
  //fix lyric strange behaviour
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1);
	dispatch_after(delay, dispatch_get_main_queue(), ^(void){

        if(![globalMPUNowPlaying currentNowPlayingInfo]){
            [%c(MPUNowPlayingController) new];
	    }	

        NSDictionary *info = [globalMPUNowPlaying currentNowPlayingInfo];
        NSString *album = [info objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"];
        NSString *title = [info objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"];

        UIImage *image = [globalMPUNowPlaying currentNowPlayingArtwork];
        NSData *imageData = UIImagePNGRepresentation(image);
        if(isWallpaperEnabled && ![imageData isEqualToData: cachedArtwork]){
            cachedArtwork = imageData;
            [imageData writeToFile:@"var/mobile/Documents/Artwork.jpg" atomically:YES];
	        [NSTask launchedTaskWithExecutableURL:[NSURL fileURLWithPath:@"/usr/bin/wallpaper"] arguments:@[@"-n",@"/var/mobile/Documents/Artwork.jpg",@"-h"] error:nil terminationHandler:nil];        
        }
        

        bool remoteConnected = BluetoothEarphoneConnected();
        
        os_log(OS_LOG_DEFAULT, "mlyx_debug  album = %{public}@, title = %{public}@ remoteConnected =%d", album,title,remoteConnected);

        NSString *text=remoteConnected? title : album;  
        [LyricLabel setText:text];
        [LyricWindow setHidden:NO];
     
    });

}

- (void)start{
    [LyricWindow setHidden:NO];
    [LyricLabel setText:@"Lyric Start"];      
    isOn=1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{        
        if ([LyricLabel.text isEqualToString:@"Lyric Start"]) {
            [LyricWindow setHidden:YES];
        }
    });
}

- (void)end{
    [LyricLabel setText:@"Lyric End"];     
    isOn=0;
    cachedArtwork=nil;
    if(isWallpaperEnabled){
        [NSTask launchedTaskWithExecutableURL:[NSURL fileURLWithPath:@"/usr/bin/wallpaper"] arguments:@[@"-n",@"/var/mobile/Documents/Wallpaper.jpg",@"-h"] error:nil terminationHandler:nil]; 
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([LyricLabel.text isEqualToString:@"Lyric End"]) {
            [LyricWindow setHidden:YES];
        }
    });
}
@end




%hook MPUNowPlayingController
- (id)init{
    id orig = %orig;  
    if (orig) {
        globalMPUNowPlaying = orig;
    }     
    return orig;
}
%end


%hook SBMediaController
- (void)_mediaRemoteNowPlayingInfoDidChange:(id)arg1 {
    %orig;
    NSString *nowPlayingID = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];
    if(isOn && [nowPlayingID isEqualToString:@"com.netease.cloudmusic"] && ![currentApp isEqualToString:@"com.netease.cloudmusic"]){   
       [LyricObject updateLyric];
    }  
}
%end


%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;  

    if(!LyricObject){
		LyricObject =  [[Lyric alloc] init];
    }
}

- (void)frontDisplayDidChange: (id)arg1 {
	%orig;
	currentApp = [(SBApplication*)[self _accessibilityFrontMostApplication] bundleIdentifier];
    NSString *nowPlayingID = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];
    //网易云在前台时，_mediaRemoteNowPlayingInfoDidChange不会被调用。只有网易云在后台时才会被调用。所以直接隐藏。
    if(isOn && [nowPlayingID isEqualToString:@"com.netease.cloudmusic"]){
        [currentApp isEqualToString:@"com.netease.cloudmusic"]?[LyricObject setHidden:1]:[LyricObject setHidden:0];
    }	
}
%end


//statusBar in app
%hook SBMainDisplaySceneLayoutStatusBarView
- (void)_addStatusBarIfNeeded {
	%orig;
	UIView *statusBar = [self valueForKey:@"_statusBar"];
	UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    tapGesture.numberOfTapsRequired = 2;
    [statusBar addGestureRecognizer:tapGesture];
    NSLog(@"mlyx tap1");
}

%new
- (void)tap {
	NSLog(@"mlyx tap2,setting:%@",settings);
    isOn?[LyricObject end]:[LyricObject start];

}

%end 



//statusBar in homescreen
%hook SBStatusBarManager
-(void)handleStatusBarTapWithEvent:(id)UITouchEvent {
    UITouch* touch=[[UITouchEvent allTouches] anyObject];
    if(touch.tapCount==2){
    NSLog(@"mlyx tap3,setting:%@",settings);
    isOn?[LyricObject end]:[LyricObject start];
    }  
    %orig;   
}
%end 


%ctor{
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourcompany.musicpreference.plist"];

    isEnabled = [settings objectForKey:@"isEnabled"] ? [[settings objectForKey:@"isEnabled"] boolValue] : 1;
    isWallpaperEnabled = [settings objectForKey:@"isWallpaperEnabled"] ? [[settings objectForKey:@"isWallpaperEnabled"] boolValue] : 1;
    MusicRoute=[settings objectForKey:@"MusicRoute"] ? [settings objectForKey:@"MusicRoute"]: @"airpods";

    NSString* Y_Axis=[settings objectForKey:@"Y-Axis"] ? [settings objectForKey:@"Y-Axis"]: @"50";
    LYRIC_Y=[Y_Axis doubleValue];

    if(isEnabled){
        %init(_ungrouped);
    }
}