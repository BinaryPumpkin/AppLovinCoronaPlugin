//
//  LuaLoader.java
//
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

// This corresponds to the name of the Lua library,
// e.g. [Lua] require "plugin.library"
package plugin.applovin;

import android.content.Context;

import com.ansca.corona.CoronaActivity;
import com.ansca.corona.CoronaEnvironment;
import com.ansca.corona.CoronaLua;
import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaRuntimeListener;
import com.applovin.adview.AppLovinAdView;
import com.applovin.sdk.AppLovinAd;
import com.applovin.sdk.AppLovinAdClickListener;
import com.applovin.sdk.AppLovinAdDisplayListener;
import com.applovin.sdk.AppLovinAdLoadListener;
import com.applovin.sdk.AppLovinAdSize;
import com.applovin.sdk.AppLovinSdk;
import com.naef.jnlua.JavaFunction;
import com.naef.jnlua.LuaState;
import com.naef.jnlua.NamedJavaFunction;

/**
 * Implements the Lua interface for a Corona plugin.
 * <p>
 * Only one instance of this class will be created by Corona for the lifetime of the application.
 * This instance will be re-used for every new Corona activity that gets created.
 */
public class LuaLoader implements JavaFunction, CoronaRuntimeListener {
	private static final String 		EVENT_NAME 			= "appLovinEvent";
	private int 						fListener			= CoronaLua.REFNIL;
	private AppLovinSdk    				sdk					= null;
    private AppLovinAdView				interstitialView	= null;
    private AppLovinAdLoadListener 		loadCallback		= null;
    private AppLovinAdClickListener 	clickCallback		= null;
    private AppLovinAdDisplayListener	displayCallback		= null;
    private AppLovinAd					cachedAd			= null;
    private LuaState					luaState			= null;
    private Boolean						closeMsgSent		= false;

	public LuaLoader() {
		// Set up this plugin to listen for Corona runtime events to be received by methods
		// onLoaded(), onStarted(), onSuspended(), onResumed(), and onExiting().
		CoronaEnvironment.addRuntimeListener(this);
	}

	@Override public void onLoaded(CoronaRuntime runtime){}
	@Override public void onStarted(CoronaRuntime runtime){}
	@Override public void onSuspended(CoronaRuntime runtime){}
	@Override public void onResumed(CoronaRuntime runtime){}
	@Override public void onExiting(CoronaRuntime runtime) {
		// Remove the Lua listener reference.
		CoronaLua.deleteRef( runtime.getLuaState(), fListener );
		fListener = CoronaLua.REFNIL;
	}

	@Override public int invoke(LuaState L) {
		// Register this plugin into Lua with the following functions.
		NamedJavaFunction[] luaFunctions = new NamedJavaFunction[] {
			new InitWrapper(),
			new ShowWrapper(),
		};
		String libName = L.toString( 1 );
		L.register(libName, luaFunctions);

		// Returning 1 indicates that the Lua require() function will return the above Lua library.
		return 1;
	}
    
	private class InitWrapper implements NamedJavaFunction {
		@Override public String getName() 			{ return "init";  }
		@Override public int 	invoke(LuaState L) 	{ return init(L); }
	}

	private class ShowWrapper implements NamedJavaFunction {
		@Override public String getName() 			{ return "show";  }
		@Override public int 	invoke(LuaState L)  { return show(L); }
	}	
	
	private void sendMessage( String msg )
	{
		CoronaLua.newEvent( luaState, EVENT_NAME );
		luaState.pushString(msg);
		luaState.setField(-2, "phase" );
	    
		// Dispatch event to library's listener
		try {
			CoronaLua.dispatchEvent( luaState, fListener, 0 );
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * The following Lua function has been called:  library.init(listenerFunc)
	 */
	public int init(LuaState L) {
		luaState = L;
		
		int listenerIndex = 1;

		if ( CoronaLua.isListener( L, listenerIndex, EVENT_NAME ) ) {
			fListener = CoronaLua.newRef( L, listenerIndex );
			
			CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
			activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					// Fetch a reference to the Corona activity.
					// Note: Will be null if the end-user has just backed out of the activity.
					CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
					if (activity == null) {
						return;
					}

					// BM: Init AppLovin here...
					Context context = com.ansca.corona.CoronaEnvironment.getApplicationContext();
					AppLovinSdk.initializeSdk(context);
			        sdk = AppLovinSdk.getInstance(context);

			        // Manually create an AdView. This is intentionally size BANNER.
					interstitialView = new AppLovinAdView( AppLovinAdSize.BANNER, activity );
					interstitialView.setAutoDestroy(true);
					
			        // Define a custom load listener to save an ad upon load rather than displaying it immediately
			        loadCallback = new AppLovinAdLoadListener() {
			            @Override
			            public void adReceived(AppLovinAd ad)
			            {
			                sendMessage("loaded");
			                cachedAd = ad;		
			            }
			            @Override
			            public void failedToReceiveAd(int errorCode)
			            {
			                sendMessage("notAvailable");
			            }
			        };
			        sdk.getAdService().loadNextAd( AppLovinAdSize.INTERSTITIAL, loadCallback);
			        
			        clickCallback = new AppLovinAdClickListener() {
			        	@Override 
			        	public void adClicked(AppLovinAd ad)
			        	{
			                sendMessage("clicked");
			                closeMsgSent = true;
			            }
			        };
			        interstitialView.setAdClickListener(clickCallback);
			        
			        displayCallback = new AppLovinAdDisplayListener() {
						@Override
						public void adDisplayed(AppLovinAd arg0) {
							sendMessage("displayed");
						}

						@Override
						public void adHidden(AppLovinAd arg0) {
							if ( closeMsgSent == false ) {
								sendMessage("closed");
								closeMsgSent = true;
							}
							
					        sdk.getAdService().loadNextAd( AppLovinAdSize.INTERSTITIAL, loadCallback);
						}
			        };
			        interstitialView.setAdDisplayListener(displayCallback);
				}
			} );
	    }

		return 0;
	}

	/**
	 * The following Lua function has been called:  library.show()
	 */
	public int show(LuaState L) {
		CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
		activity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// Fetch a reference to the Corona activity.
				// Note: Will be null if the end-user has just backed out of the activity.
				CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
				if (activity != null && cachedAd != null )
				{
					closeMsgSent = false;
		    		interstitialView.renderAd(cachedAd);
				}
			}
		});

		return 0;
	}
}