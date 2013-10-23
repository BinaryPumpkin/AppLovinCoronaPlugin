//
//  PluginApplovin.mm
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PluginApplovin.h"

#include "CoronaRuntime.h"

#import "ALSdk.h"
#import "ALInterstitialAd.h"

#import "MyAdListener.h"

#import <UIKit/UIKit.h>

// ----------------------------------------------------------------------------

class PluginApplovin
{
	public:
		typedef PluginApplovin Self;

	public:
		static const char kName[];
		static const char kEvent[];

	protected:
		PluginApplovin();

	public:
		bool Initialize( CoronaLuaRef listener );

	public:
		CoronaLuaRef GetListener() const { return fListener; }

	public:
		static int Open( lua_State *L );

	protected:
		static int Finalizer( lua_State *L );

	public:
		static Self *ToLibrary( lua_State *L );

	public:
		static int init( lua_State *L );
		static int show( lua_State *L );
    
	private:
		CoronaLuaRef fListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char PluginApplovin::kName[] = "plugin.applovin";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginApplovin::kEvent[] = "PluginApplovinEvent";

PluginApplovin::PluginApplovin()
:	fListener( NULL )
{
}

bool
PluginApplovin::Initialize( CoronaLuaRef listener )
{
	// Can only initialize listener once
	bool result = ( NULL == fListener );

	if ( result )
	{
		fListener = listener;
	}

	return result;
}

int
PluginApplovin::Open( lua_State *L )
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );

	// Functions in library
	const luaL_Reg kVTable[] =
	{
		{ "init", init },
		{ "show", show },

		{ NULL, NULL }
	};

	// Set library as upvalue for each library function
	Self *library = new Self;
	CoronaLuaPushUserdata( L, library, kMetatableName );

	luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack

	return 1;
}

int
PluginApplovin::Finalizer( lua_State *L )
{
	Self *library = (Self *)CoronaLuaToUserdata( L, 1 );
	CoronaLuaDeleteRef( L, library->GetListener() );
	delete library;
	return 0;
}

PluginApplovin *
PluginApplovin::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

// [Lua] library.init( listener )
int
PluginApplovin::init( lua_State *L )
{
	int listenerIndex = 1;

	if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
	{
		Self *library = ToLibrary( L );

		CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
		library->Initialize( listener );
        
        NSLog(@"[ALSdk initializeSdk]");
        [ALSdk initializeSdk];
        
        MyAdListener* adListener = [MyAdListener alloc];
        [adListener setLuaState:L];
        [adListener setLuaRef:listener];
        [ALInterstitialAd shared].adDisplayDelegate = adListener;
	}

	return 0;
}

// [Lua] library.show( word )
int
PluginApplovin::show( lua_State *L )
{
    NSLog(@"[ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]]");
    [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];

	return 0;
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_applovin( lua_State *L )
{
	return PluginApplovin::Open( L );
}
