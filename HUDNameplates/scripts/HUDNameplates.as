package
{
   import Shared.*;
   import Shared.AS3.*;
   import Shared.AS3.Data.*;
   import Shared.AS3.Events.*;
   import com.adobe.serialization.json.*;
   import fl.motion.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import scaleform.gfx.*;
   import utils.*;
   
   public class HUDNameplates extends MovieClip
   {
      
      public static const MOD_NAME:String = "HUDNameplates";
      
      public static const MOD_VERSION:String = "1.0.0";
      
      public static const FULL_MOD_NAME:String = MOD_NAME + " " + MOD_VERSION;
      
      public static const CONFIG_FILE:String = "../HUDNameplates.json";
      
      public static const CONFIG_RELOAD_TIME:uint = 5800;
      
      private static const TITLE_HUDMENU:String = "HUDMenu";
      
      private static const HUDTOOLS_MENU_TEST:String = MOD_NAME + "_TEST";
      
      private var topLevel:* = null;
      
      private var configTimer:Timer;
      
      private var lastConfig:String;
      
      private var lastConfigUpdateTime:Number = 0;
      
      private var lastRenderTime:Number = 0;
      
      private var hudTools:SharedHUDTools;
      
      private var HUDModeData:*;
      
      private var TeamMarkers:*;
      
      private var PetMarkers:*;
      
      private var Friends:* = {};
      
      public function HUDNameplates()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler,false,0,true);
      }
      
      public static function toString(data:Object) : String
      {
         return new JSONEncoder(data).getString();
      }
      
      public static function ShowHUDMessage(message:String) : void
      {
         GlobalFunc.ShowHUDMessage("[" + FULL_MOD_NAME + "] " + message);
      }
      
      public function addedToStageHandler(event:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler,false,0,true);
         this.topLevel = stage.getChildAt(0);
         if(Boolean(this.topLevel))
         {
            if(getQualifiedClassName(this.topLevel) == TITLE_HUDMENU)
            {
               this.hudTools = new SharedHUDTools(MOD_NAME);
               this.hudTools.RegisterMenu(this.onBuildMenu,this.onSelectMenu);
               BSUIDataManager.Subscribe("FriendsListDataCold",this.onFriendsListDataUpdate);
               this.TeamMarkers = BSUIDataManager.GetDataFromClient("TeamMarkers");
               this.TeamMarkers.addEventListener(Event.CHANGE,this.onTeamMarkersPostUpdate,false,int.MIN_VALUE);
               this.PetMarkers = BSUIDataManager.GetDataFromClient("PetMarkers");
               this.PetMarkers.addEventListener(Event.CHANGE,this.onPetMarkersPostUpdate,false,int.MIN_VALUE);
               this.initConfigTimer();
            }
            else
            {
               ShowHUDMessage("Error: mod must be loaded by HUDMenu!");
            }
         }
         else
         {
            ShowHUDMessage("Not added to stage: " + getQualifiedClassName(this.topLevel));
         }
      }
      
      public function removedFromStageHandler(event:Event) : *
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         this.TeamMarkers.removeEventListener(Event.CHANGE,this.onTeamMarkersPostUpdate);
         this.PetMarkers.removeEventListener(Event.CHANGE,this.onPetMarkersPostUpdate);
         if(this.configTimer)
         {
            this.configTimer.removeEventListener(TimerEvent.TIMER,this.loadConfig);
         }
         if(this.hudtools)
         {
            this.hudtools.Shutdown();
         }
      }
      
      public function initConfigTimer() : void
      {
         this.configTimer = new Timer(CONFIG_RELOAD_TIME);
         this.configTimer.addEventListener(TimerEvent.TIMER,this.loadConfig,false,0,true);
         this.configTimer.start();
      }
      
      public function onBuildMenu(parentItem:String = null) : *
      {
         try
         {
            if(parentItem == MOD_NAME)
            {
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_TEST,"test",false,false,250);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function onSelectMenu(selectItem:String) : *
      {
         try
         {
            if(selectItem == HUDTOOLS_MENU_TEST)
            {
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function loadConfig() : void
      {
         var loaderComplete:Function;
         var ioErrorHandler:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            loaderComplete = function(event:Event):void
            {
               var jsonData:Object;
               var line:uint;
               try
               {
                  if(lastConfig != loader.data)
                  {
                     jsonData = new JSONDecoder(loader.data,false).getValue();
                     HUDNameplatesConfig.init(jsonData);
                     onTeamMarkersPostUpdate();
                     onPetMarkersPostUpdate();
                     lastConfigUpdateTime = getTimer();
                     lastConfig = loader.data;
                  }
               }
               catch(e:JSONParseError)
               {
                  line = e.text.substr(0,e.location).match(/\n/g).length + 1;
                  ShowHUDMessage("Error parsing config: " + e.message + " in line " + line);
               }
               catch(e:Error)
               {
                  ShowHUDMessage("Error initializing config: " + e);
               }
            };
            ioErrorHandler = function(e:IOErrorEvent):void
            {
               ShowHUDMessage("Error loading config: " + e.text);
            };
            url = new URLRequest(CONFIG_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete,false,0,true);
            loader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler,false,0,true);
         }
         catch(e:Error)
         {
            ShowHUDMessage("Error loading config: " + e);
         }
      }
      
      public function get isReloadable() : Boolean
      {
         return true;
      }
      
      public function get config() : Object
      {
         return HUDNameplatesConfig.get();
      }
      
      public function get TeamNameplates() : *
      {
         return this.topLevel.TeammateMarkerBase ? this.topLevel.TeammateMarkerBase.TeamNameplates : null;
      }
      
      public function get PetNameplates() : *
      {
         return this.topLevel.PetMarkerBase ? this.topLevel.PetMarkerBase.PetNameplates : null;
      }
      
      public function onFriendsListDataUpdate(event:*) : void
      {
         var i:int;
         try
         {
            if(event && event.data && event.data.players)
            {
               i = 0;
               while(i < event.data.players.length)
               {
                  this.Friends[event.data.players[i].name] = event.data.players[i].isFriend;
                  i++;
               }
            }
         }
         catch(e:*)
         {
         }
      }
      
      public function onTeamMarkersPostUpdate(event:*) : void
      {
         var isShown:Boolean;
         var i:int;
         var cfg:*;
         var marker:*;
         var nameplate:*;
         var teamNameplates:*;
         var markers:*;
         var t1:*;
         try
         {
            t1 = getTimer();
            teamNameplates = this.TeamNameplates;
            if(!config || !teamNameplates)
            {
               return;
            }
            cfg = config.players;
            if(!cfg.enabled)
            {
               return;
            }
            isShown = false;
            for each(nameplate in teamNameplates)
            {
               markers = this.TeamMarkers.data.Markers.filter(function(m:*):Boolean
               {
                  return m.entityID == nameplate.entityID;
               });
               if(markers.length)
               {
                  marker = markers[0];
                  isShown = false;
                  if(cfg.hideLevel)
                  {
                     nameplate.level = 0;
                  }
                  if(cfg.hideTitle)
                  {
                     nameplate.displayName = marker.displayName.split("<")[0];
                  }
                  if(marker.isLocalPlayer && cfg.showSelf)
                  {
                     nameplate.isLocalPlayer = false;
                     isShown = true;
                  }
                  if(cfg.showDowned && marker.deadState == 1)
                  {
                     nameplate.isEventGroup = true;
                     nameplate.inLOS = true;
                     isShown = true;
                  }
                  if(cfg.showFriends && this.Friends[marker.displayName.split("<")[0]])
                  {
                     nameplate.inLOS = true;
                     nameplate.isTeammate = true;
                     nameplate.playerState = "teammate";
                     isShown = true;
                  }
                  if(marker.isPublicTeamLeader && cfg.hidePublicTeams)
                  {
                     nameplate.isPublicTeamLeader = false;
                  }
                  if(!isShown && marker.isTeammate && !cfg.showTeammates)
                  {
                     nameplate.isTeammate = false;
                     nameplate.playerState = marker.isEventGroup ? "eventgroupmate" : (marker.isPvPFlagged ? "potentialHostile" : "nonhostile");
                  }
                  if(!isShown && cfg.hideEventOther)
                  {
                     if(marker.isEventGroup && (!marker.isTeammate || !cfg.showTeammates))
                     {
                        nameplate.inLOS = false;
                        nameplate.isEventGroup = false;
                        nameplate.playerState = marker.isPvPFlagged ? "potentialHostile" : "nonhostile";
                        isShown = true;
                     }
                  }
                  if(!isShown && cfg.showAll)
                  {
                     nameplate.inLOS = true;
                     isShown = true;
                  }
                  if(!isShown && cfg.hideOther)
                  {
                     if(!marker.isTeammate)
                     {
                        nameplate.inLOS = false;
                     }
                  }
               }
               else
               {
                  ShowHUDMessage("Error: Marker not found!");
               }
            }
            this.lastRenderTime = getTimer() - t1;
         }
         catch(e:*)
         {
            ShowHUDMessage("onTeamMarkersPostUpdate error: " + e);
         }
      }
      
      public function onPetMarkersPostUpdate() : void
      {
         var petNameplates:*;
         var nameplate:*;
         var cfg:*;
         try
         {
            petNameplates = this.PetNameplates;
            if(!config || !petNameplates)
            {
               return;
            }
            cfg = config.pets;
            if(!cfg.enabled)
            {
               return;
            }
            for each(nameplate in petNameplates)
            {
               if(cfg.showOnlyIfWounded && !nameplate.Wounded_mc.visible)
               {
                  nameplate.visible = false;
               }
               else if(cfg.showOnlyBelowHP > 0 && nameplate.PetNamePlateNameGroup_mc.PetHealthBar_mc && 100 * nameplate.PetNamePlateNameGroup_mc.PetHealthBar_mc.HP.Percent > cfg.showOnlyBelowHP)
               {
                  nameplate.visible = false;
               }
               else
               {
                  nameplate.PetNamePlateNameGroup_mc.Name_tf.visible = cfg.showName;
                  nameplate.PetNamePlateNameGroup_mc.PetIconSmall_mc.visible = cfg.showIcon;
                  nameplate.PetNamePlateNameGroup_mc.Level_mc.visible = cfg.showLevel;
                  nameplate.PetNamePlateNameGroup_mc.PTNameplate_mc.PTNameplateBG_mc.visible = cfg.showBackground;
               }
            }
         }
         catch(e:*)
         {
            ShowHUDMessage("onPetMarkersPostUpdate error: " + e);
         }
      }
   }
}

