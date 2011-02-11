package risk.ui
{
	import flash.filters.GlowFilter;
	import flash.text.TextField;

	public class PlayerUI extends PlayerUIBase
	{
		public var playerNameField:TextField;
		public var goldField:TextField;
		public var ghostsField:TextField;
		
		public function PlayerUI()
		{
			super();
		}
		
		override public function redraw():void
		{
			playerNameField.text = playerName;
			goldField.text = gold.toString();
			ghostsField.text = ghosts.toString();
			
			var f:Array = [];
			f.push(new GlowFilter(parseInt(playerColor, 16), 1, 4, 4, 6, 2, true));
			if (currentPlayer) {
				f.push(new  GlowFilter(0x000000, .5, 4, 4, 6, 2));
			}
			
			filters = f;
		}
	}
}
