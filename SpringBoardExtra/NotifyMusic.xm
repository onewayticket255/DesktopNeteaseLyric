#import <dlfcn.h>
#import "MediaRemote.h"
#import "BulletinBoard.h"

NSString *cachedSongName;

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                   
@end

@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
@end


@interface BBServer : NSObject
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
@end

@interface BBAction : NSObject
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin : NSObject
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *sectionID;
@property(copy, nonatomic) NSString *bulletinID;
@property(retain, nonatomic) NSString *recordID;
@property(copy, nonatomic) NSString *publisherBulletinID;
@property(retain, nonatomic) NSDate *date;
@property(assign, nonatomic) BOOL turnsOnDisplay;
@property(copy, nonatomic) id defaultAction;
@end

BBServer *bbServer;

%group BBServer
	%hook BBServer

	- (id)initWithQueue: (id)arg1{
		bbServer = %orig;
		return bbServer;
	}

	%end
%end


%group NotifyMusic
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

				if([title isEqualToString:cachedSongName]) return;
				
				cachedSongName = title;

				NSString  *message = [NSString stringWithFormat: @"%@\n%@", artist, album];
				NSString *bundleId= [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];


				BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];
				bulletin.title = title;
				bulletin.message = message;
				bulletin.sectionID = @"com.apple.Music";
				bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
				bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
				bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
				bulletin.date = [NSDate date];
				bulletin.turnsOnDisplay = YES;
				bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:bundleId callblock: nil];
				
				if(bbServer && [bbServer respondsToSelector: @selector(publishBulletin:destinations:)])
				{
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

%end

%group LowBatteryNotification

	%hook SBAlertItemsController

	- (void)activateAlertItem: (id)item{
		if([item isKindOfClass: %c(SBLowPowerAlertItem)]){
			BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];
			bulletin.title = @"Low Battery";
			bulletin.message = @"";
			bulletin.sectionID = @"com.apple.Preferences";
			bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
			bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
			bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
			bulletin.date = [NSDate date];
			bulletin.turnsOnDisplay = YES;
			bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID: bulletin.sectionID callblock: nil];

			if(bbServer && [bbServer respondsToSelector: @selector(publishBulletin:destinations:)])
			{
				dispatch_sync(__BBServerQueue, 
				^{
					[bbServer publishBulletin: bulletin destinations: 14];
				});
			}
		}
		else %orig;
	}

	%end

%end


%ctor{
 	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
	bool isNotifyMusicEnabled=[settings objectForKey:@"isNotifyMusicEnabled"] ? [[settings objectForKey:@"isNotifyMusicEnabled"] boolValue] : 1;
	bool isLowBatteryNotificationEnabled=[settings objectForKey:@"isLowBatteryNotificationEnabled"] ? [[settings objectForKey:@"isLowBatteryNotificationEnabled"] boolValue] : 1;
    
	%init(BBServer);	
	if(isNotifyMusicEnabled){
		%init(NotifyMusic);
	}
	if(isLowBatteryNotificationEnabled){		
		%init(LowBatteryNotification);
	}

}