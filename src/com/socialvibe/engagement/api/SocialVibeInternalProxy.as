package com.socialvibe.engagement.api
{
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;
	
	/**
	 * The SocialVibeInternalProxy class exposes all necessary functionality for an engagement to communicate with
	 * SocialVibe's servers, interact with the surrounding engagement container, tracking user interactions,
	 * and access utility functions such as sharing on Facebook and popping up external pages.  The proxy
	 * acts as an intermediary between the engagement and the engagement API. *** FOR INTERNAL USE ONLY ***
	 * 
	 */
	dynamic public class SocialVibeInternalProxy extends Proxy
	{
		private var _unconnectedMode:Boolean = true;
		
		private var EngagemantAPI:Class;
		private var EngagemantAPI_instance:*;
		
		private var FILE_NAME_SPACE:String = "com.socialvibe.engagement.EngagementAPI";
		
		/**
		 * Creates a new SocialVibeInternalProxy instance.
		 * 
		 */
		public function SocialVibeInternalProxy()
		{
			connect();
		}
		
		private function connect():void
		{
			var domain:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			
			try {
				EngagemantAPI = (ApplicationDomain.currentDomain.getDefinition(FILE_NAME_SPACE) as Class);
				
				EngagemantAPI_instance = EngagemantAPI['getInstance']();
				
				if (EngagemantAPI_instance)
				{
					EngagemantAPI_instance.startEngage();
					_unconnectedMode = false;
					
					trace ("SocialVibeInternalProxy::API Connected");
				}
			}
			catch (e:Error)
			{
				_unconnectedMode = true;
				
				// retry to connect to API //
				setTimeout(connect, 500);
			}
		}
		
		/**
		 * Indicates whether the proxy is connected to SocialVibe's engagement API.  A value of 'true' means the proxy is not connected.
		 * This is case when running locally outside of the SocialVibe engagement container.
		 *
		 **/
		public function get unconnectedMode():Boolean
		{
			return _unconnectedMode;
		}
		
		
		/**
		 * Signals the completion event for the engagement.  The completion event tells our 
		 * system to grant the user the appropriate user benefit (i.e. Farm Cash on FarmVille).
		 * 
		 * This is a required API call.
		 * 
		 * @param onComplete the callback function that gets called when the user benefit is credited.
		 * 
		 **/
		public function engage(onComplete:Function = null):void
		{
			if (_unconnectedMode)
			{
				trace ("SocialVibeInternalProxy::engage()");
				if (onComplete != null)
				{
					setTimeout(onComplete, 1000);
				}
			}
			else
			{
				EngagemantAPI_instance.engage(onComplete);
			}
		}
		
		/**
		 * Signals the end of the engagement.  This function unloads the engagement creative from
		 * the container and displays to the user a "Congrats &amp; Share" screen.  This function must 
		 * be called after the call to engage().
		 * 
		 * This is a required API call.
		 * 
		 **/
		public function endEngage():void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::endEngage() - Congrats & Share screen should show now.");
			else
				EngagemantAPI_instance.endEngage();
		}
		
		/**
		 * Saves comment data made by the user.  Upon completion of the engagement (i.e. when engage() is called), this comment data
		 * is saved to our system.
		 * 
		 * @param comment a user inputed string of any length.
		 *
		 **/
		public function saveCommentData(comment:String):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::saveCommentData(" + comment + ")");
			else
				EngagemantAPI_instance.saveCommentData(comment);
		}
		
		/**
		 * Saves vote data made by the user.  Upon completion of the engagement (i.e. when engage() is called), this vote data
		 * is saved to our system.
		 * 
		 * @param category a number representing the index of the question the user is answering (typically '1' for the first question, '2' for the second question).
		 * @param label a string representation of the answer choice (typically the actual answer choice text).
		 * @param vote a numerical representation of the answer choice.  This number must be unique across all answer choices and all question categories.  For example, 
		 * for a 2-question poll with 4 answer options for each question, the vote value for the first answer on the first question is typically '1' and the first 
		 * answer on the second question is typically '5'.
		 *
		 **/
		public function saveVoteData(category:Number, label:String, vote:Number):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::saveVoteData(" + category + ", " + label + ", " + vote + ")");
			else
				EngagemantAPI_instance.saveVoteData(category, label, vote);
		}
		
		/**
		 * Retrieves the last 5 comments made by users who have completed this engagement.  Note: there is a 15 minute cache delay on the data.
		 * The structure of the comment data returned is an array of objects with a 'body' and 'ago' fields, like so:
		 * {body:"COMMENT_TEXT", ago:"31 minutes ago"}
		 * 
		 * @return an Array of comment data Objects. 
		 **/
		public function getRecentComments():Array
		{
			if (_unconnectedMode)
			{
				trace ("SocialVibeInternalProxy::getRecentComments()");
				
				// returns placeholder comments //
				return [{body:"last comment text", ago:"31 minutes ago"}, {body:"2nd to last comment text", ago:"36 minutes ago"}, {body:"3rd comment text", ago:"56 minutes ago"}, {body:"4th comment text", ago:"1 hour ago"}, {body:"5th comment text", ago:"2 hours ago"}];
			}
			
			return EngagemantAPI_instance.getRecentComments();
		}
		
		/**
		 * Retrieves all vote data of users who have completed this engagement.  Note: there is a 15 minute cache delay on the data.
		 * The structure of the vote data returned is an array of Objects with a 'category', 'vote', 'label', and 'vote_count' fields, like so:
		 * {category:"1", label:"FIRST ANSWER CHOICE FROM THE FIRST QUESTION", vote:"1", vote_count:"25023"}
		 * 
		 * @return an Array of vote data Objects. 
		 **/
		public function getVoteSummary():Array
		{
			if (_unconnectedMode)
			{
				trace ("SocialVibeInternalProxy::getRecentComments()");
				
				// returns placeholder values for a single question poll with 4 answer choices //
				return [
					{category:"1", label:"First answer choice from first question", vote:"1", vote_count:"25023"}, 
					{category:"1", label:"Second answer choice from first question", vote:"2", vote_count:"18652"}, 
					{category:"1", label:"Third answer choice from first question", vote:"3", vote_count:"15684"}, 
					{category:"1", label:"Fourth answer choice from first question", vote:"4", vote_count:"1568"}
				];
			}
			
			return EngagemantAPI_instance.getVoteSummary();
		}
		
		
		/* =================================
			CONTAINER API
		================================= */
		
		/**
		 *  Indicates the width of the engagement, in pixels.
		 *
		 **/
		public function get engagement_width():Number
		{
			if (_unconnectedMode)
				return 750;
			else
				return EngagemantAPI_instance.engagement_width;
		}
		
		/**
		 *  Indicates the height of the engagement, in pixels.
		 *
		 **/
		public function get engagement_height():Number
		{
			if (_unconnectedMode)
				return 500;
			else
				return EngagemantAPI_instance.engagement_height;
		}
		
		/**
		 *  Closes the entire engagement container.  This function is uncommonly used.
		 *
		 **/
		public function closeEngagement():void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::closeEngagement()");
			else
				EngagemantAPI_instance.closeEngagement();
		}
		
		
		/* =================================
			SOCIAL API
		================================= */
		
		/**
		 * Pops up the Facebook share feed dialog.  The Facebook share interaction is also tracked when 
		 * this is called.
		 *
		 **/
		public function shareToFacebook():void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::shareToFacebook()");
			else
				EngagemantAPI_instance.shareToFacebook();
		}
		
		/**
		 * Pops up the Twitter share dialog.  The Twitter share interaction is also tracked when 
		 * this is called.
		 *
		 **/
		public function shareToTwitter():void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::shareToTwitter()");
			else
				EngagemantAPI_instance.shareToTwitter();
		}
		
		/**
		 * Removes the Facebook/Twitter share options on the "Congrats &amp; Share" screen when the engagement ends.
		 *
		 **/
		public function disableSharing():void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::disableSharing()");
			else
				EngagemantAPI_instance.disableSharing();
		}
		
		
		/* =================================
			EXTERNAL API
		================================= */
		
		/**
		 * Pops up an external browser window from the engagement.  This function should be used for
		 * popping up Facebook pages.  The Facebook popup interaction is also tracked when this is called.
		 *
		 * @param url the full URL path of the Facebook page.  If none is specified, uses the CLICK_TAG.
		 * @param width the width of the popup window, in pixels.  Default: 1024 pixels.
		 * @param height the height of the popup window, in pixels.  Default: 800 pixels.
		 * 
		 **/
		public function popupFBPage(url:String = null, width:Number = 1024, height:Number = 800):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::popupFBPage(" + url + ", " + width + ", " + height + ")");
			else
				EngagemantAPI_instance.popupFBPage(url, width, height);
		}
		
		/**
		 * Pops up an external browser window from the engagement.  This function should be used for
		 * normal websites.  The website popup interaction is also tracked when this is called.
		 *
		 * @param url the full URL path of the website.  If none is specified, uses the CLICK_TAG.
		 * @param width the width of the popup window, in pixels.  Default: 1024 pixels.
		 * @param height the height of the popup window, in pixels.  Default: 800 pixels.
		 * 
		 **/
		public function popupWebsite(url:String = null, width:Number = 1024, height:Number = 800):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::popupWebsite(" + url + ", " + width + ", " + height + ")");
			else
				EngagemantAPI_instance.popupWebsite(url, width, height);
		}
		
		/**
		 * Pops up an external browser window from the engagement.  This function should be used for
		 * terms, rules, or promo websites.  The Terms/Rules/Promo popup interaction is also tracked when this is called.
		 *
		 * @param url the full URL path of the terms, rules, or promo website.  If none is specified, uses the CLICK_TAG.
		 * @param width the width of the popup window, in pixels.  Default: 1024 pixels.
		 * @param height the height of the popup window, in pixels.  Default: 800 pixels.
		 * 
		 **/
		public function popupTermsPage(url:String = null, width:Number = 1024, height:Number = 800):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::popupTermsPage(" + url + ", " + width + ", " + height + ")");
			else
				EngagemantAPI_instance.popupTermsPage(url, width, height);
		}
		
		
		/* =================================
			TRACKING API
		================================= */
		
		/**
		 * Loads a given tracking image pixel URL.
		 * 
		 * @param pixel_url the full URL path to an image pixel.
		 * @param add_timestamp a flag indicating whether or not to add a cache-busting timestamp to the end of the URL.  The default is false.
		 *
		 **/
		public function loadExternalTracking(pixel_url:String, add_timestamp:Boolean = false):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::loadExternalTracking(" + pixel_url + ", " + add_timestamp + ")");
			else
				EngagemantAPI_instance.loadExternalTracking(pixel_url, add_timestamp);
		}
		
		/**
		 * Tracks the user interaction of navigating to the next step or frame in the engagement.
		 * 
		 * @param value a label that is used in reports to identify the kind of next navigation (i.e. 'step 1').
		 *
		 **/
		public function trackNavigationNext(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackNavigationNext(" + value + ")");
			else
				EngagemantAPI_instance.trackNavigationNext(value);
		}
		
		/**
		 * Tracks the user interaction of navigating to a specific step or frame in the engagement.  Use this to track
		 * user interactions for going to previous steps or jumping ahead multiple steps.
		 * 
		 * @param value a label that is used in reports to identify the kind of 'goto' navigation (i.e. 'back to step 1').
		 *
		 **/
		public function trackNavigationGoto(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackNavigationGoto(" + value + ")");
			else
				EngagemantAPI_instance.trackNavigationGoto(value);
		}
		
		/**
		 * Tracks the user interaction of skipping a step or frame in the engagement.  A typical example is skipping a
		 * step in the engagement that asks the user to share on Facebook.
		 * 
		 * @param value a label that is used in reports to identify the kind of skip navigation (i.e. 'FB share on step 2').
		 * @param isShare a flag to signal if this skip interaction is for skipping webcam functionality.
		 * @param isWebcam a flag to signal if this skip interaction is for skipping share functionality.
		 *
		 **/
		public function trackNavigationSkip(value:Object = null, isShare:Boolean = false, isWebcam:Boolean = false):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackNavigationSkip(" + value + ", " + isShare + ", " + isWebcam + ")");
			else
				EngagemantAPI_instance.trackNavigationSkip(value, isShare, isWebcam);
		}
		
		/**
		 * Tracks the user interaction bringing up a dialog within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the kind of dialog (i.e. 'more info dialog').
		 * @param isWebcam a flag to signal if this dialog is for using the webcam.
		 *
		 **/
		public function trackNavigationDialog(value:Object = null, isWebcam:Boolean = false):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackNavigationDialog(" + value + ", " + isWebcam + ")");
			else
				EngagemantAPI_instance.trackNavigationDialog(value, isWebcam);
		}
		
		/**
		 * Tracks the starting of a video asset.
		 * 
		 * @param value a label that is used in reports to identify the video asset (i.e. 'video 1').
		 *
		 **/
		public function trackVideoStarted(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackVideoStarted(" + value + ")");
			else
				EngagemantAPI_instance.trackVideoStarted(value);
		}
		
		/**
		 * Tracks the completion of a video asset.
		 * 
		 * @param value a label that is used in reports to identify the video asset (i.e. 'video 1').
		 *
		 **/
		public function trackVideoCompleted(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackVideoCompleted(" + value + ")");
			else
				EngagemantAPI_instance.trackVideoCompleted(value);
		}
		
		/**
		 * Tracks the user interaction of starting a game within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the game (i.e. 'word search game').
		 *
		 **/
		public function trackGameStart(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackGameStart(" + value + ")");
			else
				EngagemantAPI_instance.trackGameStart(value);
		}
		
		/**
		 * Tracks the user interaction of completing a game within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the game (i.e. 'word search game').
		 *
		 **/
		public function trackGameEnd(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackGameEnd(" + value + ")");
			else
				EngagemantAPI_instance.trackGameEnd(value);
		}
		
		/**
		 * Tracks the user interaction of uploading a file within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the uploaded file (i.e. the url of the uploaded file).
		 * @param isPhoto a flag that signals whether this upload is for a photo.
		 * @param isVideo a flag that signals whether this upload is for a video.
		 *
		 **/
		public function trackUpload(value:Object = null, isPhoto:Boolean = false, isVideo:Boolean = false):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackUpload(" + value + ", " + isPhoto + ", " + isVideo + ")");
			else
				EngagemantAPI_instance.trackUpload(value, isPhoto, isVideo);
		}
		
		/**
		 * Tracks the user interaction of playing a sound file within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the sound file (i.e. 'sound clip 1').
		 *
		 **/
		public function trackSoundPlayed(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackSoundPlayed(" + value + ")");
			else
				EngagemantAPI_instance.trackSoundPlayed(value);
		}
		
		/**
		 * Tracks the user interaction of popping up an external website within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the popup (i.e. the URL of the popup).
		 *
		 **/
		public function trackExternalPopup(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackExternalPopup(" + value + ")");
			else
				EngagemantAPI_instance.trackExternalPopup(value);
		}
		
		/**
		 * Tracks the user interaction of popping up a Facebook page within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the popup (i.e. the URL of the Facebook page).
		 *
		 **/
		public function trackExternalFBPopup(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackExternalFBPopup(" + value + ")");
			else
				EngagemantAPI_instance.trackExternalFBPopup(value);
		}
		
		/**
		 * Tracks the user interaction of downloading a file from within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the download (i.e. the URL of the downloaded file).
		 *
		 **/
		public function trackDownload(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackDownload(" + value + ")");
			else
				EngagemantAPI_instance.trackDownload(value);
		}
		
		/**
		 * Tracks the user interaction of starting a print job from within the engagement.
		 * 
		 * @param value a label that is used in reports to identify the print job (i.e. 'print menu').
		 *
		 **/
		public function trackPrint(value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackPrint(" + value + ")");
			else
				EngagemantAPI_instance.trackPrint(value);
		}
		
		/**
		 * Tracks an aggregate form of user interactions.  A use-case for this is when sometime might generate many integrations, like a game,
		 * and you just want to track how many times a user interacts within the game.
		 * 
		 * @param name a label that is used in reports to identify the type of aggregate interaction (i.e. 'game jumps').
		 * @param interaction_count the total count of user interactions for this aggregate interaction.
		 *
		 **/
		public function trackAggregateInteraction(name:String, interaction_count:Number):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackAggregateInteraction(" + name + ", " + interaction_count + ")");
			else
				EngagemantAPI_instance.trackAggregateInteraction(name, interaction_count);
		}
		
		/**
		 * A catch-all tracking function for all other types of user interactions.  Use this when you want to track something that
		 * is not covered by the other specific tracking functions.
		 * 
		 * @param name a label that is used in reports to identify this user interaction (i.e. 'google maps').
		 * @param value another label that is used in reports to further identify this 'other' interaction (i.e. 'search').
		 *
		 **/
		public function trackOtherInteraction(name:String, value:Object = null):void
		{
			if (_unconnectedMode)
				trace ("SocialVibeInternalProxy::trackOtherInteraction(" + name + ", " + value + ")");
			else
				EngagemantAPI_instance.trackOtherInteraction(name, value);
		}
		
		
		/**
		 * Proxys all other method calls to the API.
		 * 
		 * @param methodName The name of the method being invoked.
		 * @param ... args arguments to pass to the called method.
		 *
		 **/
		override flash_proxy function callProperty(methodName:*, ... args):*
		{
			try {

				if (_unconnectedMode)
					trace ("SocialVibeInternalProxy::" + methodName + "(" + args.join(', ') + ")");
				else
					EngagemantAPI_instance[methodName].apply(EngagemantAPI_instance, args);

			} catch (e:Error) {
				trace ("SocialVibeInternalProxy::" + e);
			}
		}
	}
}