//
//  MyAdListener.h
//  Plugin
//
//  Created by Bruce McNeish on 30/08/2013.
//
//

#import <Foundation/Foundation.h>

#import "ALAdDisplayDelegate.h"
#import "ALAdLoadDelegate.h"

#include "CoronaLua.h"

@interface MyAdListener : NSObject< ALAdDisplayDelegate, ALAdLoadDelegate > {
    lua_State*      L;
    CoronaLuaRef    luaRef;
}

-(void) setLuaState: (lua_State*) newState;
-(void) setLuaRef: (CoronaLuaRef) newRef;
-(void) sendEvent: (NSString*) eventName;

-(lua_State*) L;
-(CoronaLuaRef) luaRef;
@end