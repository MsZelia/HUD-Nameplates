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
      
      private static const HUDTOOLS_MENU_PLAYERS:String = MOD_NAME + "_PLAYERS";
      
      private static const HUDTOOLS_MENU_PLAYERS_ENABLED:String = MOD_NAME + "_PLAYERS_ENABLED";
      
      private static const HUDTOOLS_MENU_PLAYERS_SELF:String = MOD_NAME + "_PLAYERS_SELF";
      
      private static const HUDTOOLS_MENU_PLAYERS_DOWNED:String = MOD_NAME + "_PLAYERS_DOWNED";
      
      private static const HUDTOOLS_MENU_PLAYERS_FRIENDS:String = MOD_NAME + "_PLAYERS_FRIENDS";
      
      private static const HUDTOOLS_MENU_PLAYERS_TEAMMATES:String = MOD_NAME + "_PLAYERS_TEAMMATES";
      
      private static const HUDTOOLS_MENU_PLAYERS_EVENT_OTHER:String = MOD_NAME + "_PLAYERS_EVENT_OTHER";
      
      private static const HUDTOOLS_MENU_PLAYERS_OTHER:String = MOD_NAME + "_PLAYERS_OTHER";
      
      private static const HUDTOOLS_MENU_PLAYERS_LEVEL:String = MOD_NAME + "_PLAYERS_LEVEL";
      
      private static const HUDTOOLS_MENU_PLAYERS_TITLE:String = MOD_NAME + "_PLAYERS_TITLE";
      
      private static const HUDTOOLS_MENU_PLAYERS_PUBLIC_TEAMS:String = MOD_NAME + "_PLAYERS_PUBLIC_TEAMS";
      
      private static const HUDTOOLS_MENU_PETS:String = MOD_NAME + "_PETS";
      
      private static const HUDTOOLS_MENU_PETS_ENABLED:String = MOD_NAME + "_PETS_ENABLED";
      
      private static const HUDTOOLS_MENU_PETS_ONLY_IF_WOUNDED:String = MOD_NAME + "_PETS_ONLY_IF_WOUNDED";
      
      private static const HUDTOOLS_MENU_PETS_NAME:String = MOD_NAME + "_PETS_NAME";
      
      private static const HUDTOOLS_MENU_PETS_ICON:String = MOD_NAME + "_PETS_ICON";
      
      private static const HUDTOOLS_MENU_PETS_LEVEL:String = MOD_NAME + "_PETS_LEVEL";
      
      private static const HUDTOOLS_MENU_PETS_BACKGROUND:String = MOD_NAME + "_PETS_BACKGROUND";
      
      private static var HUDTOOLS_PLAYERS_OPTIONS:* = null;
      
      private static var HUDTOOLS_PETS_OPTIONS:* = null;
      
      private var topLevel:* = null;
      
      private var configTimer:Timer;
      
      private var lastConfig:String;
      
      private var lastConfigUpdateTime:Number = 0;
      
      private var lastRenderTime:Number = 0;
      
      private var hudTools:SharedHUDTools;
      
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
      
      private function initHUDToolsOptions() : void
      {
         if(HUDTOOLS_PLAYERS_OPTIONS == null)
         {
            HUDTOOLS_PLAYERS_OPTIONS = {};
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_ENABLED] = "enabled";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_SELF] = "showSelf";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_DOWNED] = "showDowned";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_FRIENDS] = "showFriends";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_TEAMMATES] = "showTeammates";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_EVENT_OTHER] = "hideEventOther";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_OTHER] = "hideOther";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_LEVEL] = "hideLevel";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_TITLE] = "hideTitle";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_PUBLIC_TEAMS] = "hidePublicTeams";
         }
         if(HUDTOOLS_PETS_OPTIONS == null)
         {
            HUDTOOLS_PETS_OPTIONS = {};
            HUDTOOLS_PETS_OPTIONS[HUDTOOLS_MENU_PETS_ENABLED] = "enabled";
            HUDTOOLS_PETS_OPTIONS[HUDTOOLS_MENU_PETS_ONLY_IF_WOUNDED] = "showOnlyIfWounded";
            HUDTOOLS_PETS_OPTIONS[HUDTOOLS_MENU_PETS_NAME] = "showName";
            HUDTOOLS_PETS_OPTIONS[HUDTOOLS_MENU_PETS_ICON] = "showIcon";
            HUDTOOLS_PETS_OPTIONS[HUDTOOLS_MENU_PETS_LEVEL] = "showLevel";
            HUDTOOLS_PETS_OPTIONS[HUDTOOLS_MENU_PETS_BACKGROUND] = "showBackground";
         }
      }
      
      public function onBuildMenu(parentItem:String = null) : *
      {
         var option:*;
         try
         {
            if(!config)
            {
               return;
            }
            this.initHUDToolsOptions();
            if(parentItem == MOD_NAME)
            {
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_PLAYERS,"PLAYERS",true,true,250);
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_PETS,"PETS",true,true,250);
            }
            else if(parentItem == HUDTOOLS_MENU_PLAYERS)
            {
               for(option in HUDTOOLS_PLAYERS_OPTIONS)
               {
                  this.hudTools.AddMenuItem(option,HUDTOOLS_PLAYERS_OPTIONS[option],true,true,250);
               }
            }
            else if(parentItem == HUDTOOLS_MENU_PETS)
            {
               for(option in HUDTOOLS_PETS_OPTIONS)
               {
                  this.hudTools.AddMenuItem(option,HUDTOOLS_PETS_OPTIONS[option],true,true,250);
               }
            }
            else if(HUDTOOLS_PLAYERS_OPTIONS[parentItem] != null)
            {
               this.hudTools.AddMenuItem(parentItem + "--1","true",!config.players[HUDTOOLS_PLAYERS_OPTIONS[parentItem]],false);
               this.hudTools.AddMenuItem(parentItem + "--","false",config.players[HUDTOOLS_PLAYERS_OPTIONS[parentItem]],false);
            }
            else if(HUDTOOLS_PETS_OPTIONS[parentItem] != null)
            {
               this.hudTools.AddMenuItem(parentItem + "--1","true",!config.pets[HUDTOOLS_PETS_OPTIONS[parentItem]],false);
               this.hudTools.AddMenuItem(parentItem + "--","false",config.pets[HUDTOOLS_PETS_OPTIONS[parentItem]],false);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function onSelectMenu(selectItem:String) : *
      {
         var selectedItemSuboption:Array;
         try
         {
            selectedItemSuboption = selectItem.split("--");
            if(selectedItemSuboption.length == 2)
            {
               if(HUDTOOLS_PLAYERS_OPTIONS[selectedItemSuboption[0]])
               {
                  config.players[HUDTOOLS_PLAYERS_OPTIONS[selectedItemSuboption[0]]] = Boolean(selectedItemSuboption[1]);
                  this.onTeamMarkersPostUpdate();
               }
               else if(HUDTOOLS_PETS_OPTIONS[selectedItemSuboption[0]])
               {
                  config.pets[HUDTOOLS_PETS_OPTIONS[selectedItemSuboption[0]]] = Boolean(selectedItemSuboption[1]);
                  this.onPetMarkersPostUpdate();
               }
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
      
      public function onTeamMarkersPostUpdate() : void
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
                  if(!isShown && cfg.minimizeEventOther)
                  {
                     if(marker.isEventGroup && (!marker.isTeammate || !cfg.showTeammates))
                     {
                        nameplate.inLOS = false;
                        isShown = true;
                     }
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

