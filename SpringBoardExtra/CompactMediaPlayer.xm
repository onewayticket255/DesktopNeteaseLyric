@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * displayName; 
@end

@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
@end

@interface MediaControlsHeaderView : UIView 
@property (nonatomic,retain) UIView* routingButton; 
-(id)routeLabel; 
//@property (nonatomic,retain) MPRouteLabel* routeLabel;  
@end

@interface MPRouteLabel : UIView 
@end

@interface MRPlatterViewController : UIViewController
@property (nonatomic,retain) MediaControlsHeaderView * nowPlayingHeaderView; 
@property (nonatomic,retain) UIView* parentContainerView;                                         
@property (nonatomic,retain) UIView* volumeContainerView;  

@end

@interface CSAdjunctItemView: UIView
@end


    
//iPhoneX music widget height 107
%hook CSMediaControlsViewController
- (CGRect)_suggestedFrameForMediaControls
{
    CGRect frame = %orig;
    frame.size.height = 107;
    return frame;
}
%end

//去除无用信息
%hook MRPlatterViewController
- (void)viewWillLayoutSubviews{
    %orig;
    if([[self parentViewController] isKindOfClass: %c(CSMediaControlsViewController)]){       
            [[[self nowPlayingHeaderView] routingButton] removeFromSuperview];
            [[self parentContainerView] removeFromSuperview];
            [[self volumeContainerView] removeFromSuperview];

            [[[[self nowPlayingHeaderView] routeLabel] titleLabel] setText:[[[%c(SBMediaController) sharedInstance] nowPlayingApplication] displayName]];
    }
}
%end



%hook CSAdjunctItemView
// CSAdjunctItemView  LC Music Widget
// CSAdjunctItemView.subviews[0] PLPlatterView
// PLPlatterView.subviews[0] MTMaterialView
- (void)didMoveToWindow{
    %orig;
    if([self subviews] && [[self subviews] count] > 0 && [[self subviews][0] subviews] && [[[self subviews][0] subviews] count] > 0){
    //MTMaterialView alpha
    [[[self subviews][0] subviews][0] setAlpha: 0];
    }
}

%end



%ctor{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
    bool isCompactMediaPlayerEnabled=[settings objectForKey:@"isCompactMediaPlayerEnabled"] ? [[settings objectForKey:@"isCompactMediaPlayerEnabled"] boolValue] : 1;
    if(isCompactMediaPlayerEnabled){
        %init;
    }
}




