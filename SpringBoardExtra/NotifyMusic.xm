#import "JBBulletinManager.h"
#import "MediaRemote.h"

NSString *cachedSongName;

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                     //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@end

@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
@end


%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNotifyMusic) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
}

%new
-(void)showNotifyMusic {

    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
        if(result) {
            NSDictionary *dict = (__bridge NSDictionary *)result;
            NSString *title = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
            NSString *artist = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
            NSString *album = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum];

            if([title isEqualToString:cachedSongName])
               return;
            
            cachedSongName = title;

            NSString  *message = [NSString stringWithFormat: @"%@\n%@", title, artist];
           
            [[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:album message:message bundleID:[[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier]];
        }

    }); 
}

%end


%ctor{
 	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
	bool isNotifyMusicEnabled=[settings objectForKey:@"isNotifyMusicEnabled"] ? [[settings objectForKey:@"isNotifyMusicEnabled"] boolValue] : 1;
    if(isNotifyMusicEnabled){
		%init;
	}
}