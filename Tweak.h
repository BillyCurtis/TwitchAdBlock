#import <AmazonIVSPlayer/IVSPlayer.h>
#import <Twitch/FollowingViewController.h>
#import <Twitch/HeadlinerFollowingAdManager.h>
#import <Twitch/LiveHLSURLProvider.h>
#import <TwitchCoreUI/TWDefaultThemeManager.h>
#import <TwitchKit/TKGraphQL.h>

static NSMutableDictionary<NSString *, TWHLSProvider *> *providers;