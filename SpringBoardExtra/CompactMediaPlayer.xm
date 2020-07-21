@interface MediaControlsHeaderView : UIView 
@property (nonatomic,retain) UIView* routingButton;  
@end

@interface MRPlatterViewController : UIViewController
@property (nonatomic,retain) MediaControlsHeaderView * nowPlayingHeaderView; 
@property (nonatomic,retain) UIView* parentContainerView;                                         
@property (nonatomic,retain) UIView* volumeContainerView;  

@end

@interface CSAdjunctItemView: UIView
@end

%group CompactMediaPlayer
    
    //IphoneX music widget height 107
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
        }
    }
    %end

    %hook CSAdjunctItemView
    // CSAdjunctItemView  LC Music Widget
    // CSAdjunctItemView.subviews[0] PLPlatterView
    // PLPlatterView.subviews[0] MTMaterialView
    - (void)layoutSubviews{
        %orig;
        if([self subviews] && [[self subviews] count] > 0 && [[self subviews][0] subviews] && [[[self subviews][0] subviews] count] > 0){
        //MTMaterialView alpha
        [[[self subviews][0] subviews][0] setAlpha: 0];
        }
    }

    %end
%end


%ctor{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
    bool isCompactMediaPlayerEnabled=[settings objectForKey:@"isCompactMediaPlayerEnabled"] ? [[settings objectForKey:@"isCompactMediaPlayerEnabled"] boolValue] : 1;
    if(isCompactMediaPlayerEnabled){
        %init(CompactMediaPlayer);
    }
}




