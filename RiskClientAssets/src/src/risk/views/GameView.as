package risk.views
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import risk.data.PersonalData;
	import risk.ui.BidUI;
	import risk.ui.PlayerUIBase;
	import risk.ui.Territory;
	
	import support.JsonLineReplyEvent;
	
	public class GameView extends Sprite implements IView
	{
		public var territories:Sprite;
		public var territoryNames:Sprite;
		
		public var otherPlayerUI:Array;
		public var otherPlayerUI1:PlayerUIBase;
		public var otherPlayerUI2:PlayerUIBase;
		public var otherPlayerUI3:PlayerUIBase;
		public var playerUI:PlayerUIBase;
		
		public var obstructor:MovieClip;
		public var bidUI:BidUI;
		
		public function GameView()
		{
			super();
			
			otherPlayerUI = [ otherPlayerUI1, otherPlayerUI2, otherPlayerUI3 ];
			
			removeChild(obstructor);
			
			removeChild(bidUI);
			bidUI.addEventListener(Event.SELECT, function (event:Event):void {
				bidComplete();
			});
			
			// Initialize territories and clicking policies
			territories.mouseEnabled = 
				territories.mouseChildren = false;
			territoryNames.mouseEnabled = 
				territoryNames.mouseChildren = false;
			
			// TODO: 'game-bid' { goldAmmount: }
			// TODO: 'game-placeArmies' { placementArray: }
			// TODO: 'game-battle' { attackingTerritory: , defendingTerritory: }
			// TODO: 'game-chooseDieCount' { count: }
			// TODO: 'game-spendGhosts' { count: }
			// TODO: 'game-chooseArmyMoveCount' { count: }
			// TODO: 'game-fortify' { sourceTerritory: , targetTerritory: }
			
			hide();
		}
		
		public function handleMessage(command:String, params:Object):void
		{
			if (command == 'game-announce')
			{
				// TODO: Handle params.phase
				// TODO: Handle params.territories, updating each territory with the occupant army
				// Update players cards
				var j:int = 0;
				for (var i:int = 0; i < params.players.length; i++) {
					if (params.players[i].id == PersonalData.personalData.id) {
						playerUI.playerName = params.players[i].name;
						playerUI.playerColor = params.players[i].color;
						playerUI.gold = params.players[i].gold;
						playerUI.ghosts = params.players[i].ghosts;
						// TODO: Current player
					} else {
						otherPlayerUI[j].playerName = params.players[i].name;
						otherPlayerUI[j].playerColor = params.players[i].color;
						otherPlayerUI[j].gold = params.players[i].gold;
						otherPlayerUI[j].ghosts = params.players[i].ghosts;
						// TODO: Current player
						j++;
					}
				}
				for (; j < otherPlayerUI.length; j++) otherPlayerUI[j].visible = false;
			} 
			
			else if (command == 'game-bid')
			{
				bidSetup();
			}
			
			else if (command == 'game-placeArmies')
			{
				placeArmiesSetup(params.count);
				// TODO: Put territories UI in army placement mode
				// NOTE: Armies can be placed 1 per territory, or all three in the same territory
			}
			
			else if (command == 'game-battle')
			{
				// TODO
			}
			
			else if (command == 'game-chooseDieCount')
			{
				// TODO
			}
			
			else if (command == 'game-spendGhosts')
			{
				// TODO
			}
			
			else if (command == 'game-chooseArmyMoveCount')
			{
				// TODO
			}
			
			else if (command == 'game-fortify')
			{
				// TODO
			}
		}
		
		protected function bidSetup():void
		{
			addChild(obstructor);
			addChild(bidUI);
			bidUI.value = 0;
			stage.focus = bidUI.goldField;
		}
		protected function bidComplete():void
		{
			removeChild(obstructor);
			removeChild(bidUI);
			dispatchEvent(new JsonLineReplyEvent('game-bid', {
				goldAmmount: bidUI.value
			}));
		}
		
		protected var placeArmiesCount:int;
		protected var placeArmiesMaxCount:int;
		protected var placeArmiesBuffer:Object;
		protected function placeArmiesSetup(maxCount:int):void
		{
			placeArmiesCount = 0;
			placeArmiesMaxCount = maxCount;
			placeArmiesBuffer = {};
			
			territories.mouseEnabled = 
				territories.mouseChildren = true;
			
			addEventListener(MouseEvent.CLICK, placeArmiesClickHandler);
		}
		protected function placeArmiesClickHandler(event:MouseEvent):void
		{
			var territory:Territory = event.target as Territory;
			if (territory == null) return;
			
			if (placeArmiesCount == placeArmiesMaxCount-1 && territory.addArmies == 1) {
				territory.addArmies = placeArmiesMaxCount;
				placeArmiesCount = placeArmiesMaxCount;
				placeArmiesBuffer[territory.name] = 1;
				placeArmiesComplete();
			} else if (territory.addArmies == 0) {
				territory.addArmies = 1;
				placeArmiesCount++;
				placeArmiesBuffer[territory.name] = 1;
				if (placeArmiesCount == placeArmiesMaxCount) placeArmiesComplete();
			}
		}
		protected function placeArmiesComplete():void
		{
			removeEventListener(MouseEvent.CLICK, placeArmiesClickHandler);
			dispatchEvent(new JsonLineReplyEvent('game-placeArmies', {
				territories: placeArmiesBuffer
			}));
			
			for (var prop:String in placeArmiesBuffer) {
				territories[prop].addArmies = 0;
			}
			
			territories.mouseEnabled = 
				territories.mouseChildren = false;
			
			placeArmiesCount = 0;
			placeArmiesMaxCount = 0;
			placeArmiesBuffer = {};
		}
		
		public function hide():void
		{
			visible = false;
		}
		
		public function show():void
		{
			visible = true;
		}
	}
}
