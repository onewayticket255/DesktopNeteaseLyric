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


BBServer *bbServer;

%group BBServer
	%hook BBServer

	- (id)initWithQueue: (id)arg1{
		bbServer = %orig;
		return bbServer;
	}

	%end

	%hook BBBulletin
	- (BBSectionIcon*)sectionIcon {
		id r = %orig;
		BBSectionIcon *icon = [BBSectionIcon new];
		if ([self.publisherBulletinID isEqualToString:@"mlyx-netease"]){
			[icon addVariant:[BBSectionIconVariant variantWithFormat:0 imageName: @"icon-netease" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/NeteaseLyricSetting.bundle"]]];
		    return icon;
		}else if([self.publisherBulletinID isEqualToString:@"mlyx-qqmusic"]){
			[icon addVariant:[BBSectionIconVariant variantWithFormat:0 imageName: @"icon-qqmusic" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/NeteaseLyricSetting.bundle"]]];
		    return icon;
		}else if([self.publisherBulletinID isEqualToString:@"mlyx-spotify"]){
			[icon addVariant:[BBSectionIconVariant variantWithFormat:0 imageName: @"icon-spotify" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/NeteaseLyricSetting.bundle"]]];
		    return icon;
		}else{
			return r;
		}		
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


				BBBulletin *bulletin = [%c(BBBulletin) new];
   
				bulletin.title = title;
				bulletin.message = message;
				//sectionID 必须是apple原生应用 通知才会显示，不懂为什么
				bulletin.sectionID = @"com.apple.Music";
				bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
				bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
				bulletin.date = [NSDate date];
				bulletin.turnsOnDisplay = YES;
				bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:bundleId callblock: nil];
				

				if ([bundleId isEqualToString:@"com.netease.cloudmusic"]){
					bulletin.publisherBulletinID = @"mlyx-netease";
					bulletin.header = @"Netease Music";
				}

				if([bundleId isEqualToString:@"com.tencent.QQMusic"]){
					bulletin.publisherBulletinID = @"mlyx-qqmusic";
					bulletin.header = @"QQ Music";
				}
				
				if([bundleId isEqualToString:@"com.spotify.client"]){
					bulletin.publisherBulletinID = @"mlyx-spotify";
					bulletin.header = @"Spotify";
				}

				


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