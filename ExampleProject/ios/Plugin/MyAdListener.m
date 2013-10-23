//
//  MyAdListener.m
//  Plugin
//
//  Created by Bruce McNeish on 30/08/2013.
//
//

#import "MyAdListener.h"
#import "PluginApplovin.h"
#import "ALAdService.h"

@implementation MyAdListener

-(void) setLuaState: (lua_State*) newState
{
    L = newState;
}
-(void) setLuaRef: (CoronaLuaRef) newRef
{
    luaRef = newRef;
}
-(void) sendEvent: (NSString*) eventName;
{
    NSLog(@"Sending Event: %@", eventName);
    
	// Create event and add message to it
	CoronaLuaNewEvent( L, "PluginApplovinevent" );
	lua_pushstring( L, [eventName UTF8String] );
	lua_setfield( L, -2, "phase" );
    
	// Dispatch event to library's listener
	CoronaLuaDispatchEvent( L, luaRef, 0 );
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    NSLog(@"## Ad dismissed: %@", [ad.size label]);
    [self sendEvent:@"closed"];
}

-(void)ad:(ALAd *) ad wasDisplayedIn: (UIView *)view
{
    NSLog(@"## Ad displayed: %@", [ad.size label]);
    [self sendEvent:@"displayed"];
}

-(void)ad:(ALAd *) ad wasClickedIn: (UIView *)view
{
    NSLog(@"## Ad clicked: %@", [ad.size label]);
    [self sendEvent:@"clicked"];
}

-(void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    NSLog(@"## Ad loaded: %@", [ad.size label]);
    [self sendEvent:@"loaded"];
}

-(void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    if(code == 202)
        NSLog(@"NO FILL - AppLovin server reports no ad available");
    if(code >= 500)
        NSLog(@"AppLovin reports server error.");
    if(code < 0)
        NSLog(@"AppLovin SDK reports internal error.");

    [self sendEvent:@"notAvailable"];
}

@end
