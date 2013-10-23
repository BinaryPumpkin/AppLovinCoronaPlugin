//
//  Applovin.h
//
//  Copyright (c) 2012-2013 Binary Pumpkin Lts
//

#ifndef _PluginApplovin_H__
#define _PluginApplovin_H__

#include "CoronaLua.h"
#include "CoronaMacros.h"

// This corresponds to the name of the library, e.g. [Lua] require "plugin.applovin"
// where the '.' is replaced with '_'
CORONA_EXPORT int luaopen_plugin_applovin( lua_State *L );

#endif // _PluginApplovin_H__