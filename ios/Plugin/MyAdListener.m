//
//  MyAdListener.m
//
// Copyright (c) 2013 Binary Pumpkin Ltd
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all copies or substantial
//   portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
