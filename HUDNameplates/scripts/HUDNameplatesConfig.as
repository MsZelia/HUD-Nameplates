package
{
   import utils.Parser;
   
   public class HUDNameplatesConfig
   {
      
      private static var _config:Object;
      
      public function HUDNameplatesConfig()
      {
         super();
      }
      
      public static function get() : Object
      {
         return _config;
      }
      
      public static function init(jsonObject:*) : Object
      {
         var config:* = jsonObject;
         if(!config.players)
         {
            config.players = {};
            config.players.enabled = false;
            config.players.showSelf = false;
            config.players.showDowned = true;
            config.players.showFriends = true;
            config.players.showTeammates = true;
            config.players.showTeammatesInDopExpoRaid = true;
            config.players.minimizeEventOther = true;
            config.players.hideEventOther = false;
            config.players.hideOther = false;
            config.players.hideLevel = false;
            config.players.hideTitle = true;
            config.players.hidePublicTeams = true;
            config.players.hideInConversation = true;
         }
         else
         {
            config.players.enabled = Parser.parseBoolean(config.players.enabled,false);
            config.players.showSelf = Parser.parseBoolean(config.players.showSelf,false);
            config.players.showDowned = Parser.parseBoolean(config.players.showDowned,true);
            config.players.showFriends = Parser.parseBoolean(config.players.showFriends,true);
            config.players.showTeammates = Parser.parseBoolean(config.players.showTeammates,true);
            config.players.showTeammatesInDopExpoRaid = Parser.parseBoolean(config.players.showTeammatesInDopExpoRaid,true);
            config.players.minimizeEventOther = Parser.parseBoolean(config.players.minimizeEventOther,true);
            config.players.hideEventOther = Parser.parseBoolean(config.players.hideEventOther,false);
            config.players.hideOther = Parser.parseBoolean(config.players.hideOther,false);
            config.players.hideLevel = Parser.parseBoolean(config.players.hideLevel,false);
            config.players.hideTitle = Parser.parseBoolean(config.players.hideTitle,true);
            config.players.hidePublicTeams = Parser.parseBoolean(config.players.hidePublicTeams,true);
            config.players.hideInConversation = Parser.parseBoolean(config.players.hideInConversation,true);
         }
         if(!config.pets)
         {
            config.pets = {};
            config.pets.enabled = false;
            config.pets.showOnlyIfWounded = false;
            config.pets.showOnlyBelowHP = 0;
            config.pets.showName = true;
            config.pets.showIcon = true;
            config.pets.showLevel = true;
            config.pets.showBackground = true;
         }
         else
         {
            config.pets.enabled = Parser.parseBoolean(config.pets.enabled,false);
            config.pets.showOnlyIfWounded = Parser.parseBoolean(config.pets.showOnlyIfWounded,false);
            config.pets.showOnlyBelowHP = Parser.parsePositiveNumber(config.pets.showOnlyBelowHP,0);
            config.pets.showName = Parser.parseBoolean(config.pets.showName,true);
            config.pets.showIcon = Parser.parseBoolean(config.pets.showIcon,true);
            config.pets.showLevel = Parser.parseBoolean(config.pets.showLevel,true);
            config.pets.showBackground = Parser.parseBoolean(config.pets.showBackground,true);
         }
         _config = config;
         return _config;
      }
   }
}

