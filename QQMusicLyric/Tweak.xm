#import <Foundation/Foundation.h>
#import <MRYIPCCenter.h>

MRYIPCCenter* center = [MRYIPCCenter centerNamed:@"mlyx.neteasemusiclyric"];

static NSString* lastLyric;

@interface SongInfo
- (NSString*)song_Name;
@end

@interface KSLyric
@property(retain, nonatomic) NSMutableArray *sentencesArray;
@end

@interface AudioPlayManager
@property(retain, nonatomic) SongInfo *currentSong; 
- (double)curTime;
@end

@interface KSSentence 
@property(retain, nonatomic) NSString *text;
@property(nonatomic) long long startTime;
@end

@interface LocalLyricObject
@property(retain, nonatomic) NSMutableArray *lyricArray; 
@property(retain, nonatomic) NSMutableArray *translateLyricArray; 
@property(retain, nonatomic) NSMutableArray *yinyiLyricArray; 
@property(retain, nonatomic) SongInfo *song;
@property(retain, nonatomic) KSLyric *translateLyric; 
@property(retain, nonatomic) KSLyric *yinyiLyric; 
@property(retain, nonatomic) KSLyric *originLyric; 
@end

@interface MyLyric:NSObject
@property(nonatomic) NSString* text;
@property long long startTime;
@end

@implementation MyLyric
@end


double curTime;
double lstTime=0;
NSMutableDictionary* allLyrics=[NSMutableDictionary dictionaryWithCapacity:1024];

%hook LyricManager
-(LocalLyricObject*)getLyricObjectFromLocal:(SongInfo* )arg1 lyricFrom:(unsigned long long)arg2 {

    if(%orig.originLyric.sentencesArray.count > 0){
      NSMutableArray* tempMyLyrics_origin = [NSMutableArray arrayWithCapacity:1024];
      NSMutableArray* tempMyLyrics_translate = [NSMutableArray arrayWithCapacity:1024];
      NSMutableArray* tempMyLyrics_roma = [NSMutableArray arrayWithCapacity:1024];
    
      for (KSSentence* sentence in %orig.originLyric.sentencesArray) {
                MyLyric* myLyric = [MyLyric alloc];
                myLyric.text = [sentence text];
                myLyric.startTime = [sentence startTime];
                [tempMyLyrics_origin addObject:myLyric];
      }

      for (KSSentence* sentence in %orig.translateLyric.sentencesArray) {
                MyLyric* myLyric = [MyLyric alloc];
                myLyric.text = [sentence text];
                myLyric.startTime = [sentence startTime];
                [tempMyLyrics_translate addObject:myLyric];         
      }

      for (KSSentence* sentence in %orig.yinyiLyric.sentencesArray) {
                MyLyric* myLyric = [MyLyric alloc];
                myLyric.text = [sentence text];
                myLyric.startTime = [sentence startTime];
                [tempMyLyrics_roma addObject:myLyric];
      }

      NSMutableDictionary* theLyric=[NSMutableDictionary dictionaryWithCapacity:3];

      theLyric[@"origin"]=tempMyLyrics_origin;
      theLyric[@"translate"]=tempMyLyrics_translate;
      theLyric[@"roma"]=tempMyLyrics_roma;

      NSLog(@"mlyx_qqmusic_song name %@",[%orig.song song_Name]);
      NSLog(@"mlyx_qqmusic_tempMyLyrics_origin %@",tempMyLyrics_origin);
      NSLog(@"mlyx_qqmusic_tempMyLyrics_translate %@",tempMyLyrics_translate);
      NSLog(@"mlyx_qqmusic_tempMyLyrics_roma %@",tempMyLyrics_roma);

      allLyrics[[%orig.song song_Name]]=theLyric;
    }
  
  return %orig;
}
%end



%hook AudioPlayManager

- (void)updateProgress:(id)arg1 {
  %orig;
  

  //updateProgress调用太频繁，控制下频率
  curTime=[self curTime]*1000;
  double diff = curTime - lstTime;
  if (diff < 600 && diff > -1)
      return;
  lstTime = curTime;
    
 
  NSMutableDictionary* theLyric= allLyrics[self.currentSong.song_Name];

  NSArray* originLyricArray = theLyric[@"origin"];
  NSArray* translateLyricArray = theLyric[@"translate"];
  NSArray* romaLyricArray = theLyric[@"roma"];

  int currentOriginLyricIndex=0;
  int currentTranslateLyricIndex=0;
  int currentRomaLyricIndex=0;


  for(int i=0;i<originLyricArray.count;i++){
    MyLyric* tmpLyric=originLyricArray[i];

    if ([tmpLyric startTime] > curTime) {
        //NSLog(@"mlyx origin_time %lld",[tmpLyric startTime]);
        break;
    }
    currentOriginLyricIndex=i;
  }

  for(int i=0;i<romaLyricArray.count;i++){
    MyLyric* tmpLyric=romaLyricArray[i];

    if ([tmpLyric startTime] > curTime) {
        //NSLog(@"mlyx roma_time %lld",[tmpLyric startTime]);
        break;
    }
    currentRomaLyricIndex=i;
  }


  // 这种方式获取currentTranslateLyricIndex有问题
  // 一个歌词对应的origin startTime==roma startTime!==translate startTime
  // for(int i=0;i<translateLyricArray.count;i++){
  //   MyLyric* tmpLyric=translateLyricArray[i];

  //   if ([tmpLyric startTime] > curTime){ 
  //       NSLog(@"mlyx translate_time %lld",[tmpLyric startTime]);
  //       break;
  //   }
  //   currentTranslateLyricIndex=i;
  // }

  //Workaround
  //大部分情况准确,少数歌曲不准确
  currentTranslateLyricIndex=currentOriginLyricIndex-(originLyricArray.count-translateLyricArray.count);
  
  //防越界
  if(currentTranslateLyricIndex<0){ 
    currentTranslateLyricIndex=0;
  }

  
  NSLog(@"mlyx_qqmusic count %lu %lu %lu",originLyricArray.count,translateLyricArray.count,romaLyricArray.count);
  
  
  MyLyric *lyricO=originLyricArray[currentOriginLyricIndex];
  NSString *lrc_origin = lyricO.text;

  if([lastLyric isEqualToString:lrc_origin]) return;
	
	lastLyric=lrc_origin;

  MyLyric *lyricT;
  MyLyric *lyricR;
 
  NSString *lrc_translate=@" ";
  NSString *lrc_romaji=@" ";

  
  if(!lrc_origin){
	  lrc_origin=@" ";
  }

  if(translateLyricArray.count>0){
      lyricT=translateLyricArray[currentTranslateLyricIndex];
      lrc_translate =lyricT.text;
  }

  if(romaLyricArray.count>0){
      lyricR=romaLyricArray[currentRomaLyricIndex];
      lrc_romaji=lyricR.text;
  }
        
   
  NSLog(@"mlyx_qqmusic Progress_time %f",curTime);
  NSLog(@"mlyx_qqmusic Currentlyric_index %d",currentOriginLyricIndex);
  NSLog(@"mlyx_qqmusic Translatelyric_index %d",currentTranslateLyricIndex);
  NSLog(@"mlyx_qqmusic Romalyric_index %d",currentRomaLyricIndex);
  NSLog(@"mlyx_qqmusic lyric_origin %@",lrc_origin);
  NSLog(@"mlyx_qqmusic lyric_trans %@",lrc_translate);
  NSLog(@"mlyx_qqmusic lyric_roma %@",lrc_romaji);

  NSDictionary *info = @{@"lrc_origin" : lrc_origin, @"lrc_translate" : lrc_translate, @"lrc_romaji" : lrc_romaji};

	[center callExternalMethod:@selector(_updateLyric:) withArguments:info];
}
%end


//debug
// if(%orig.lyricArray){

  // //lyricOne=%orig.lyricArray
  // NSLog(@"mlyx_qqmusic_name %@",[%orig.song song_Name]);
  // NSLog(@"mlyx_qqmusic_arr %@",%orig.lyricArray[0]);
  // NSLog(@"mlyx_qqmusic_arr %@",%orig.lyricArray[1]);
  // NSLog(@"mlyx_qqmusic_arr %@",%orig.lyricArray[2]);
  // NSLog(@"mlyx_qqmusic_arr %@",%orig.lyricArray[3]);
  // }
  
  // KSSentence* s0= %orig.originLyric.sentencesArray[0];
  // KSSentence* s1= %orig.originLyric.sentencesArray[1];
  // KSSentence* s2= %orig.originLyric.sentencesArray[2];
  // KSSentence* s3= %orig.originLyric.sentencesArray[3];
  // KSSentence* s4= %orig.originLyric.sentencesArray[4];
  // KSSentence* s5= %orig.originLyric.sentencesArray[5];

  // KSSentence* t0= %orig.translateLyric.sentencesArray[0];
  // KSSentence* t1= %orig.translateLyric.sentencesArray[1];
  // KSSentence* t2= %orig.translateLyric.sentencesArray[2];
  // KSSentence* t3= %orig.translateLyric.sentencesArray[3];
  // KSSentence* t4= %orig.translateLyric.sentencesArray[4];
  // KSSentence* t5= %orig.translateLyric.sentencesArray[5];

  // NSLog(@"mlyx_qqmusic s0 %@ - %lld",s0.text,s0.startTime);
  // NSLog(@"mlyx_qqmusic s1 %@ - %lld",s1.text,s1.startTime);
  // NSLog(@"mlyx_qqmusic s2 %@ - %lld",s2.text,s2.startTime);
  // NSLog(@"mlyx_qqmusic s3 %@ - %lld",s3.text,s3.startTime);
  // NSLog(@"mlyx_qqmusic s4 %@ - %lld",s4.text,s4.startTime);
  // NSLog(@"mlyx_qqmusic s5 %@ - %lld",s5.text,s5.startTime);
  
  // NSLog(@"mlyx_qqmusic t0 %@ - %lld",t0.text,t0.startTime);
  // NSLog(@"mlyx_qqmusic t1 %@ - %lld",t1.text,t1.startTime);
  // NSLog(@"mlyx_qqmusic t2 %@ - %lld",t2.text,t2.startTime);
  // NSLog(@"mlyx_qqmusic t3 %@ - %lld",t3.text,t3.startTime);
  // NSLog(@"mlyx_qqmusic t4 %@ - %lld",t4.text,t4.startTime);
  // NSLog(@"mlyx_qqmusic t5 %@ - %lld",t5.text,t5.startTime);