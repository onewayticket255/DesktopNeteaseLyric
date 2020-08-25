%hook SBFullscreenZoomView
- (void)addSubview:(UIView *)arg1{
    UIView *view=[UIView new];
    view.backgroundColor=UIColor.blackColor;
    view.frame=arg1.frame;
    %orig(view);
}
%end


%ctor{
 	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
	bool isDarkLaunchScreenEnabled=[settings objectForKey:@"isDarkLaunchScreenEnabled"] ? [[settings objectForKey:@"isDarkLaunchScreenEnabled"] boolValue] : 1;
    if(isDarkLaunchScreenEnabled){
		%init;
	}
}