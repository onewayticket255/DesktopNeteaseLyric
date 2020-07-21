@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) id nowPlayingApplication;
+(id)sharedInstance;
@end

%group BluetoothLaunch
    %hook _UIStatusBarBluetoothItem

    //airpods 连接进耳朵时的动画
    -(id)additionAnimationForDisplayItemWithIdentifier:(id)arg1 {
            //如果当前没media应用，就开启网易云私人FM
        if (![[%c(SBMediaController) sharedInstance] nowPlayingApplication]) { 
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"orpheuswidget://radio"] options:@{} completionHandler:nil];         
        }
        return %orig;
    }

    %end
%end


%ctor{
 	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
	bool isBluetoothLaunchEnabled=[settings objectForKey:@"isBluetoothLaunchEnabled"] ? [[settings objectForKey:@"isBluetoothLaunchEnabled"] boolValue] : 1;
    if(isBluetoothLaunchEnabled){
		%init(BluetoothLaunch);
	}
}