package risk.ui
{
	import flash.display.Sprite;
	
	public class PlayerUIBase extends Sprite
	{
		public function PlayerUIBase()
		{
			super();
		}
		
		protected var _playerName:String;
		public function get playerName():String
		{
			return _playerName;
		}
		public function set playerName(value:String):void
		{
			_playerName = value;
			redraw();
		}
		
		protected var _playerColor:String;
		public function get playerColor():String
		{
			return _playerColor;
		}
		public function set playerColor(value:String):void
		{
			_playerColor = value;
		}
		
		protected var _gold:int;
		public function get gold():int
		{
			return _gold;
		}
		public function set gold(value:int):void
		{
			_gold = value;
			redraw();
		}
		
		protected var _ghosts:int;
		public function get ghosts():int
		{
			return _ghosts;
		}
		public function set ghosts(value:int):void
		{
			_ghosts = value;
			redraw();
		}
		
		protected var _currentPlayer:Boolean;
		public function get currentPlayer():Boolean
		{
			return _currentPlayer;
		}
		public function set currentPlayer(value:Boolean):void
		{
			_currentPlayer = value;
			redraw();
		}
		
		public function redraw():void
		{
		}
	}
}
