#include <Preferences/PSListController.h>
#include <Preferences/PSSpecifier.h>
#include <substrate.h>
#import "prefs.h"

NSString *const PLFilterKey = @"pl_filter";

@implementation NSDictionary (libprefs)

+ (NSDictionary *)dictionaryWithFile:(NSString *)path {
  if (@available(iOS 11, *)) return [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
  return [NSDictionary dictionaryWithContentsOfFile:path];
}

@end

@implementation PSSpecifier (libprefs)

+ (BOOL)environmentPassesPreferenceLoaderFilter:(NSDictionary *)filter {
	if (!filter || filter.count == 0) return YES;
	NSArray *versions = [filter objectForKey:@"CoreFoundationVersion"];
	if (versions.count == 1) return (kCFCoreFoundationVersionNumber >= [versions[0] floatValue]);
	else if (versions.count == 2) return (kCFCoreFoundationVersionNumber >= [versions[0] floatValue] && kCFCoreFoundationVersionNumber < [versions[1] floatValue]);
	return YES;
}

- (NSBundle *)preferenceLoaderBundle {
  return [self propertyForKey:@"pl_bundle"];
}

@end

extern "C" NSArray *SpecifiersFromPlist(NSDictionary *plist, PSSpecifier *previousSpecifier, id target, NSString *plistName, NSBundle *bundle, NSString *title, NSString *specifierID, PSListController *callerList, NSMutableArray **bundleControllers);

@implementation PSListController (libprefs)

- (NSArray *)specifiersFromEntry:(NSDictionary *)entry sourcePreferenceLoaderBundlePath:(NSString *)sourceBundlePath title:(NSString *)title {
	NSDictionary *specifierPlist = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:entry, nil], @"items", nil];
  NSBundle *bundle;
  NSMutableArray *potentialPaths = [NSMutableArray new];
  if ([entry objectForKey:@"bundlePath"]) [potentialPaths addObject:entry[@"bundlePath"]];
  if ([entry objectForKey:@"bundle"]) {
    [potentialPaths addObject:[NSString stringWithFormat:@"/Library/PreferenceBundles/%@.bundle", entry[@"bundle"]]];
    [potentialPaths addObject:[NSString stringWithFormat:@"/System/Library/PreferenceBundles/%@.bundle", entry[@"bundle"]]];
	}
  if ([entry objectForKey:@"bundle"]) for (NSString *path in potentialPaths) if ((bundle = [NSBundle bundleWithPath:path])) break;
	NSMutableArray *bundleControllers = [MSHookIvar<NSArray *>(self, "_bundleControllers") mutableCopy];
	NSArray *specs = SpecifiersFromPlist(specifierPlist, nil,  self, title, bundle, NULL, NULL, self, &bundleControllers);
	if (specs.count == 0) return nil;
  for (PSSpecifier *specifier in specs) if (!specifier.name) {
    specifier.name = title;
    specifier.identifier = title;
  }
	return specs;
}

@end

%ctor {
  dlopen("/usr/lib/libprefs.dylib", RTLD_LAZY);
}