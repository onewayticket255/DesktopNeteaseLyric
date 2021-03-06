#import <UIKit/UIKit.h>
#import "MediaRemote.h"
#import "BulletinBoard.h"

@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isUILocked;
@end

NSString *cachedSongName;

struct SBIconImageInfo {
    CGSize size;
    CGFloat scale;
    CGFloat continuousCornerRadius;
};

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;   
@property (nonatomic,readonly) NSString * displayName;                                                                                
@end

@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
@end

@interface SBApplicationIcon : NSObject
-(id)initWithApplication:(SBApplication*)arg1 ;
-(id)unmaskedIconImageWithInfo:(struct SBIconImageInfo)arg1;
@end

@interface SBApplicationController : NSObject
+(id)sharedInstance;
-(id)applicationWithBundleIdentifier:(id)arg1;
@end


BBServer *bbServer;


%hook BBServer

- (id)initWithQueue: (id)arg1{
	bbServer = %orig;
	return bbServer;
}

%end





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
			NSString *bundleId= [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];
			
			
			if(!title||[title isEqualToString:cachedSongName]) return;
			
			cachedSongName = title;
			
			NSString  *message;

			if(artist&&!album){
				message = artist;
			}

			if(artist&&album){
				message = [NSString stringWithFormat: @"%@\n%@", artist, album];
			}
			
			BBBulletin *bulletin = [%c(BBBulletin) new];

			bulletin.header = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] displayName];
			bulletin.title = title;
			bulletin.message = message;
			//sectionID 必须是apple原生应用 通知才会显示，不懂为什么
			bulletin.sectionID = @"com.apple.Preferences";
			bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
			bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
			bulletin.date = [NSDate date];
			bulletin.turnsOnDisplay = YES;
			bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:bundleId callblock: nil];
			


			BBSectionIcon *icon = [BBSectionIcon new];
			SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleId];
			SBApplicationIcon *appIcon = [[%c(SBApplicationIcon) alloc] initWithApplication: app];

			struct SBIconImageInfo iconInfo;

			iconInfo.size = CGSizeMake(128, 128);
			iconInfo.scale = 2.0;
			iconInfo.continuousCornerRadius = 0;

			UIImage *tmpIcon = [appIcon unmaskedIconImageWithInfo:iconInfo];
			[icon addVariant:[BBSectionIconVariant variantWithFormat:0 imageData:UIImagePNGRepresentation(tmpIcon)]];
		
			bulletin.icon=icon;
			
			if(bbServer&&![[%c(SBLockScreenManager) sharedInstance] isUILocked]){
				dispatch_sync(__BBServerQueue, 
				^{  
					//4: lockscreen
					//8: banner
					//16: All
					[bbServer publishBulletin: bulletin destinations: 8];
				});
			}

	

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