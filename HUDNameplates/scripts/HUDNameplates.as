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
      
      public static const MOD_VERSION:String = "1.3.2";
      
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
      
      private static const HUDTOOLS_MENU_PLAYERS_TEAMMATES_DER:String = MOD_NAME + "_PLAYERS_TEAMMATES_DER";
      
      private static const HUDTOOLS_MENU_PLAYERS_MINIMIZE_EVENT_OTHER:String = MOD_NAME + "_PLAYERS_MINIMIZE_EVENT_OTHER";
      
      private static const HUDTOOLS_MENU_PLAYERS_EVENT_OTHER:String = MOD_NAME + "_PLAYERS_EVENT_OTHER";
      
      private static const HUDTOOLS_MENU_PLAYERS_OTHER:String = MOD_NAME + "_PLAYERS_OTHER";
      
      private static const HUDTOOLS_MENU_PLAYERS_LEVEL:String = MOD_NAME + "_PLAYERS_LEVEL";
      
      private static const HUDTOOLS_MENU_PLAYERS_TITLE:String = MOD_NAME + "_PLAYERS_TITLE";
      
      private static const HUDTOOLS_MENU_PLAYERS_PUBLIC_TEAMS:String = MOD_NAME + "_PLAYERS_PUBLIC_TEAMS";
      
      private static const HUDTOOLS_MENU_PLAYERS_CONVERSATION:String = MOD_NAME + "_PLAYERS_CONVERSATION";
      
      private static const HUDTOOLS_MENU_PETS:String = MOD_NAME + "_PETS";
      
      private static const HUDTOOLS_MENU_PETS_ENABLED:String = MOD_NAME + "_PETS_ENABLED";
      
      private static const HUDTOOLS_MENU_PETS_ONLY_IF_WOUNDED:String = MOD_NAME + "_PETS_ONLY_IF_WOUNDED";
      
      private static const HUDTOOLS_MENU_PETS_NAME:String = MOD_NAME + "_PETS_NAME";
      
      private static const HUDTOOLS_MENU_PETS_ICON:String = MOD_NAME + "_PETS_ICON";
      
      private static const HUDTOOLS_MENU_PETS_LEVEL:String = MOD_NAME + "_PETS_LEVEL";
      
      private static const HUDTOOLS_MENU_PETS_BACKGROUND:String = MOD_NAME + "_PETS_BACKGROUND";
      
      private static const HUDTOOLS_MENU_TEAM:String = MOD_NAME + "_TEAM";
      
      private static const HUDTOOLS_MENU_TEAM_ENABLED:String = MOD_NAME + "_TEAM_ENABLED";
      
      private static const HUDTOOLS_MENU_TEAM_TITLE:String = MOD_NAME + "_TEAM_TITLE";
      
      private static const HUDTOOLS_MENU_TEAM_LEVEL:String = MOD_NAME + "_TEAM_LEVEL";
      
      private static const HUDTOOLS_MENU_TEAM_PERK:String = MOD_NAME + "_TEAM_PERK";
      
      private static const HUDTOOLS_MENU_TEAM_CONVERSATION:String = MOD_NAME + "_TEAM_CONVERSATION";
      
      private static const HUDTOOLS_MENU_TEAM_DOP:String = MOD_NAME + "_TEAM_DOP";
      
      private static const HUDTOOLS_MENU_TEAM_EXPO:String = MOD_NAME + "_TEAM_EXPO";
      
      private static const HUDTOOLS_MENU_TEAM_RAID:String = MOD_NAME + "_TEAM_RAID";
      
      private static const STRING_PLAYER_NAME:String = "{playerName}";
      
      private static var HUDTOOLS_PLAYERS_OPTIONS:* = null;
      
      private static var HUDTOOLS_PETS_OPTIONS:* = null;
      
      private static var HUDTOOLS_TEAM_OPTIONS:* = null;
      
      private static var TEAM_COLORS:Array = [16711680,65280,255,16776960,16711935,65535,16777215,16777215,16777215,16777215,16777215];
      
      private static const PUBLIC_TEAMS_TYPES:Object = {
         "0":"private",
         "1":"hunting",
         "2":"roleplay",
         "3":"events",
         "4":"exploration",
         "5":"building",
         "6":"casual",
         "7":"specialEvent",
         "8":"extraTeam",
         "9":"trading",
         "10":"workshopRaid",
         "11":"invalid",
         "12":"dailyOps",
         "13":"expeditions",
         "14":"raids"
      };
      
      private var topLevel:* = null;
      
      private var configTimer:Timer;
      
      private var lastConfig:String;
      
      private var lastConfigUpdateTime:Number = 0;
      
      private var lastRenderTime:Number = 0;
      
      private var hudTools:SharedHUDTools;
      
      private var TeamMarkers:*;
      
      private var PetMarkers:*;
      
      private var QuestTrackerProvider:*;
      
      private var PartyMenuList:*;
      
      private var CharacterNameData:*;
      
      private var Friends:* = {};
      
      private var PublicTeams:* = {};
      
      private var PublicTeamMembers:* = {};
      
      private var TeamMembers:* = {};
      
      private var ClonedNames:Array = [];
      
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
               BSUIDataManager.Subscribe("PublicTeamsData",this.onPublicTeamsDataUpdate);
               this.TeamMarkers = BSUIDataManager.GetDataFromClient("TeamMarkers");
               this.TeamMarkers.addEventListener(Event.CHANGE,this.onTeamMarkersPostUpdate,false,int.MIN_VALUE);
               this.PetMarkers = BSUIDataManager.GetDataFromClient("PetMarkers");
               this.PetMarkers.addEventListener(Event.CHANGE,this.onPetMarkersPostUpdate,false,int.MIN_VALUE);
               this.PartyMenuList = BSUIDataManager.GetDataFromClient("PartyMenuList");
               this.PartyMenuList.addEventListener(Event.CHANGE,this.onPartyMenuListPreUpdate,false,int.MAX_VALUE);
               this.QuestTrackerProvider = BSUIDataManager.GetDataFromClient("QuestTrackerProvider");
               this.CharacterNameData = BSUIDataManager.GetDataFromClient("CharacterNameData");
               this.initTimers();
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
         this.PartyMenuList.removeEventListener(Event.CHANGE,this.onPartyMenuListPreUpdate);
         if(this.configTimer)
         {
            this.configTimer.removeEventListener(TimerEvent.TIMER,this.loadConfig);
         }
         if(this.hudtools)
         {
            this.hudtools.Shutdown();
         }
      }
      
      public function initTimers() : void
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
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_TEAMMATES_DER] = "showTeammatesInDopExpoRaid";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_MINIMIZE_EVENT_OTHER] = "minimizeEventOther";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_EVENT_OTHER] = "hideEventOther";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_OTHER] = "hideOther";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_LEVEL] = "hideLevel";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_TITLE] = "hideTitle";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_PUBLIC_TEAMS] = "hidePublicTeams";
            HUDTOOLS_PLAYERS_OPTIONS[HUDTOOLS_MENU_PLAYERS_CONVERSATION] = "hideInConversation";
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
         if(HUDTOOLS_TEAM_OPTIONS == null)
         {
            HUDTOOLS_TEAM_OPTIONS = {};
            HUDTOOLS_TEAM_OPTIONS[HUDTOOLS_MENU_TEAM_ENABLED] = "enabled";
            HUDTOOLS_TEAM_OPTIONS[HUDTOOLS_MENU_TEAM_TITLE] = "hideTitle";
            HUDTOOLS_TEAM_OPTIONS[HUDTOOLS_MENU_TEAM_LEVEL] = "hideLevel";
            HUDTOOLS_TEAM_OPTIONS[HUDTOOLS_MENU_TEAM_PERK] = "hideSharedPerk";
            HUDTOOLS_TEAM_OPTIONS[HUDTOOLS_MENU_TEAM_CONVERSATION] = "hideInConversation";
            HUDTOOLS_TEAM_OPTIONS[HUDTOOLS_MENU_TEAM_DOP] = "hideInDailyOp";
            HUDTOOLS_TEAM_OPTIONS[HUDTOOLS_MENU_TEAM_EXPO] = "hideInExpedition";
            HUDTOOLS_TEAM_OPTIONS[HUDTOOLS_MENU_TEAM_RAID] = "hideInRaid";
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
               this.hudTools.AddMenuItem(HUDTOOLS_MENU_TEAM,"TEAM PANEL",true,true,250);
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
            else if(parentItem == HUDTOOLS_MENU_TEAM)
            {
               for(option in HUDTOOLS_TEAM_OPTIONS)
               {
                  this.hudTools.AddMenuItem(option,HUDTOOLS_TEAM_OPTIONS[option],true,true,250);
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
            else if(HUDTOOLS_TEAM_OPTIONS[parentItem] != null)
            {
               this.hudTools.AddMenuItem(parentItem + "--1","true",!config.teamPanel[HUDTOOLS_TEAM_OPTIONS[parentItem]],false);
               this.hudTools.AddMenuItem(parentItem + "--","false",config.teamPanel[HUDTOOLS_TEAM_OPTIONS[parentItem]],false);
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
               else if(HUDTOOLS_TEAM_OPTIONS[selectedItemSuboption[0]])
               {
                  config.teamPanel[HUDTOOLS_TEAM_OPTIONS[selectedItemSuboption[0]]] = Boolean(selectedItemSuboption[1]);
                  this.onPartyMenuListPreUpdate();
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
                     onPartyMenuListPreUpdate();
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
      
      public function get CharacterName() : String
      {
         return CharacterNameData.data.characterName;
      }
      
      public function get IsInDailyOps() : Boolean
      {
         if(this.QuestTrackerProvider && this.QuestTrackerProvider.data && this.QuestTrackerProvider.data.quests)
         {
            for each(var quest in this.QuestTrackerProvider.data.quests)
            {
               if(quest.questId == 5928916 || quest.questId == 6228119)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get IsInExpedition() : Boolean
      {
         if(this.QuestTrackerProvider && this.QuestTrackerProvider.data && this.QuestTrackerProvider.data.quests)
         {
            for each(var quest in this.QuestTrackerProvider.data.quests)
            {
               if(quest.questId == 6452460 || quest.questId == 6587008 || quest.questId == 7021340 || quest.questId == 7055933 || quest.questId == 7191227)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get IsInRaid() : Boolean
      {
         if(this.PartyMenuList && this.PartyMenuList.data && this.PartyMenuList.data.members)
         {
            for each(var member in this.PartyMenuList.data.members)
            {
               if(member.isLocalPlayer)
               {
                  return Boolean(member.isInRaid) && Boolean(member.isVisible) && Boolean(member.isOnServer);
               }
            }
         }
         return false;
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
      
      public function trimTitle(name:String) : String
      {
         return name.split("<")[0];
      }
      
      public function onPublicTeamsDataUpdate(event:*) : void
      {
         var team:uint;
         var member:*;
         var str:String;
         try
         {
            if(event && event.data && event.data.publicTeams)
            {
               this.PublicTeams = {};
               this.PublicTeamMembers = {};
               for(team in event.data.publicTeams)
               {
                  this.PublicTeams[team] = PUBLIC_TEAMS_TYPES[event.data.publicTeams[team].teamType];
                  for each(member in event.data.publicTeams[team].members)
                  {
                     this.PublicTeamMembers[member.playerName] = team;
                  }
               }
            }
         }
         catch(e:*)
         {
            ShowHUDMessage("onPublicTeamsDataUpdate error: " + e);
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
         var isInDopExpoRaid:Boolean;
         var clone_tf:TextField;
         var namegroup:*;
         var displayName:String;
         var playerName:String;
         var useCustomColors:Boolean;
         var useCustomFormats:Boolean;
         var useCustomTF:Boolean;
         var log:String;
         var isTeammateHidden:Boolean;
         try
         {
            t1 = getTimer();
            log = "";
            isInDopExpoRaid = this.IsInDailyOps || this.IsInExpedition || this.IsInRaid;
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
            useCustomColors = Boolean(cfg.customColors.enabled);
            useCustomFormats = Boolean(cfg.customFormats.enabled);
            useCustomTF = useCustomColors || useCustomFormats;
            isShown = false;
            i = 0;
            while(i < ClonedNames.length)
            {
               ClonedNames[i].text = "";
               i++;
            }
            i = 0;
            for(i in teamNameplates)
            {
               nameplate = teamNameplates[i];
               namegroup = nameplate.NamePlateNameGroup_mc;
               if(useCustomTF && !(namegroup.getChildAt(namegroup.numChildren - 1) is TextField))
               {
                  ClonedNames.push(cloneTextField(namegroup.Name_tf));
               }
               markers = this.TeamMarkers.data.Markers.filter(function(m:*):Boolean
               {
                  return m.entityID == nameplate.entityID;
               });
               if(markers.length)
               {
                  marker = markers[0];
                  displayName = marker.displayName;
                  playerName = trimTitle(displayName);
                  log += playerName + ":";
                  isShown = false;
                  isTeammateHidden = false;
                  if(cfg.isNW && marker.isHostile)
                  {
                     log += "isNW,";
                     nameplate.isNuclearWinterMode = true;
                     nameplate.inLOS = true;
                     isShown = true;
                  }
                  if(cfg.hideLevel)
                  {
                     nameplate.level = 0;
                  }
                  if(cfg.hideTitle)
                  {
                     displayName = playerName;
                     nameplate.displayName = displayName;
                  }
                  if(cfg.hideInConversation)
                  {
                     nameplate.isInConversation = false;
                  }
                  if(marker.isLocalPlayer && cfg.showSelf)
                  {
                     nameplate.isLocalPlayer = false;
                     isShown = true;
                     if(cfg.debug)
                     {
                        nameplate.displayName = displayName + "|" + lastRenderTime + "ms";
                     }
                  }
                  if(cfg.showDowned && marker.deadState == 1)
                  {
                     nameplate.isEventGroup = true;
                     nameplate.inLOS = true;
                     isShown = true;
                  }
                  if(cfg.showFriends && this.Friends[playerName])
                  {
                     log += "showFriends,";
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
                     if(!isInDopExpoRaid || !cfg.showTeammatesInDopExpoRaid)
                     {
                        log += "showTeammates,";
                        isTeammateHidden = true;
                        nameplate.isTeammate = false;
                        nameplate.playerState = marker.isEventGroup ? "eventgroupmate" : (marker.isPvPFlagged ? "potentialHostile" : "nonhostile");
                     }
                  }
                  if(!isShown && cfg.minimizeEventOther)
                  {
                     if(marker.isEventGroup && (!marker.isTeammate || !cfg.showTeammates))
                     {
                        log += "minimizeEventOther,";
                        nameplate.inLOS = false;
                        isShown = true;
                     }
                  }
                  if(!isShown && cfg.hideEventOther)
                  {
                     if(marker.isEventGroup && (!marker.isTeammate || !cfg.showTeammates))
                     {
                        log += "hideEventOther,";
                        nameplate.inLOS = false;
                        nameplate.isEventGroup = false;
                        nameplate.playerState = marker.isPvPFlagged ? "potentialHostile" : "nonhostile";
                        isShown = true;
                     }
                  }
                  if(!isShown && cfg.showAll)
                  {
                     log += "showAll,";
                     nameplate.inLOS = true;
                     isShown = true;
                  }
                  if(!isShown && cfg.hideOther)
                  {
                     if(!marker.isTeammate || isTeammateHidden)
                     {
                        log += "hideOther || ";
                        nameplate.inLOS = false;
                     }
                  }
                  if(useCustomTF)
                  {
                     clone_tf = namegroup.getChildAt(namegroup.numChildren - 1);
                     clone_tf.x = namegroup.Name_tf.x;
                     namegroup.Name_tf.visible = false;
                     if(useCustomFormats)
                     {
                        displayName = getCustomFormat(playerName,marker).replace(STRING_PLAYER_NAME,marker.isLocalPlayer && cfg.customFormats.showCharName ? this.CharacterName : playerName);
                        clone_tf.text = displayName;
                        if(!useCustomColors)
                        {
                           clone_tf.textColor = namegroup.Name_tf.textColor;
                        }
                     }
                     if(useCustomColors)
                     {
                        if(!useCustomFormats)
                        {
                           clone_tf.text = playerName;
                        }
                        clone_tf.textColor = getCustomColor(playerName,marker.isHostile);
                     }
                  }
                  else
                  {
                     namegroup.Name_tf.visible = true;
                  }
               }
               else
               {
                  ShowHUDMessage("Error: Marker not found!");
               }
            }
            this.lastRenderTime = getTimer() - t1;
            if(cfg.debug)
            {
               ShowHUDMessage(this.lastRenderTime + "ms || " + log);
            }
         }
         catch(e:*)
         {
            ShowHUDMessage("onTeamMarkersPostUpdate error: " + e);
         }
      }
      
      public function getCustomFormat(playerName:String, marker:Object) : String
      {
         var cfg:*;
         var formats:*;
         var format:String;
         var teamType:*;
         try
         {
            cfg = this.config.players.customFormats;
            format = STRING_PLAYER_NAME;
            formats = cfg.formats;
            if(marker.isHostile)
            {
               format = format.replace(STRING_PLAYER_NAME,formats["hostile"]);
            }
            if(this.Friends[playerName])
            {
               format = format.replace(STRING_PLAYER_NAME,formats["friend"]);
            }
            if(marker.isLocalPlayer)
            {
               format = format.replace(STRING_PLAYER_NAME,formats["self"]);
            }
            if(marker.isTeammate && !marker.isLocalPlayer)
            {
               format = format.replace(STRING_PLAYER_NAME,formats["teammate"]);
            }
            if(cfg.useTeamTypeFormats && (!marker.isTeammate || cfg.useTeamTypeFormatsForOwnTeam))
            {
               teamType = PUBLIC_TEAMS_TYPES[marker.teamType];
               if(teamType != null && cfg.teamTypeFormats[teamType] != null)
               {
                  format = format.replace(STRING_PLAYER_NAME,cfg.teamTypeFormats[teamType]);
               }
            }
            return format;
         }
         catch(e:*)
         {
            ShowHUDMessage("getCustomFormat error: " + e);
         }
         return playerName;
      }
      
      public function getCustomColor(playerName:String, isHostile:Boolean) : uint
      {
         var cfg:*;
         var teamColor:*;
         try
         {
            cfg = this.config.players.customColors;
            if(cfg.useTeamColor && this.TeamMembers[playerName])
            {
               return cfg.teamColor;
            }
            if(cfg.useHostileColor && isHostile)
            {
               return cfg.hostileColor;
            }
            if(cfg.usePublicTeamTypeColors && this.PublicTeamMembers[playerName] != null)
            {
               teamColor = cfg.publicTeamTypeColors[this.PublicTeams[this.PublicTeamMembers[playerName]]];
               if(teamColor != null)
               {
                  return teamColor;
               }
               return cfg.defaultColor;
            }
            return cfg.defaultColor;
         }
         catch(e:*)
         {
            ShowHUDMessage("getCustomColor error: " + e);
         }
         return cfg.defaultColor;
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
      
      public function onPartyMenuListPreUpdate() : void
      {
         var cfg:*;
         var member:*;
         try
         {
            this.TeamMembers = {};
            if(this.PartyMenuList.data && this.PartyMenuList.data.members)
            {
               for each(member in this.PartyMenuList.data.members)
               {
                  if(member && member.isOnServer)
                  {
                     this.TeamMembers[trimTitle(member.name)] = true;
                  }
               }
            }
            if(!config)
            {
               return;
            }
            cfg = config.teamPanel;
            if(!cfg.enabled)
            {
               return;
            }
            if(this.PartyMenuList.data && this.PartyMenuList.data.members)
            {
               for each(member in this.PartyMenuList.data.members)
               {
                  if(member && member.isOnServer)
                  {
                     if(cfg.hideTitle)
                     {
                        member.name = trimTitle(member.name);
                     }
                     if(cfg.hideLevel)
                     {
                        member.level = 0;
                     }
                     if(cfg.hideSharedPerk)
                     {
                        member.showSharedIcon = false;
                     }
                     if(cfg.hideInConversation)
                     {
                        member.isInConversation = false;
                     }
                     if(cfg.hideInDailyOp)
                     {
                        member.isInDailyOp = false;
                     }
                     if(cfg.hideInExpedition)
                     {
                        member.isInExpedition = false;
                     }
                     if(cfg.hideInRaid)
                     {
                        member.isInRaid = false;
                     }
                  }
               }
            }
         }
         catch(e:*)
         {
            ShowHUDMessage("onPartyMenuListPreUpdate error: " + e);
         }
      }
      
      private function cloneTextField(textField:TextField) : TextField
      {
         var item:XML;
         var clone:TextField = new TextField();
         var description:XML = describeType(textField);
         for each(item in description.accessor)
         {
            if(item.@access != "readonly")
            {
               try
               {
                  clone[item.@name] = textField[item.@name];
               }
               catch(error:Error)
               {
               }
            }
         }
         clone.defaultTextFormat = textField.getTextFormat();
         clone.setTextFormat(textField.getTextFormat());
         clone.filters = textField.filters;
         if(textField.parent)
         {
            textField.parent.addChild(clone);
         }
         return clone;
      }
   }
}

