package risk.ui
{
	import fl.controls.Button;
	import fl.controls.TextInput;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class BidUI extends Sprite
	{
		public var goldField:TextInput;
		public var bidButton:Button;
		
		public function BidUI()
		{
			super();
			
			goldField.addEventListener(Event.CHANGE, function (event:Event):void {
				event.stopPropagation();
			});
			
			bidButton.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				dispatchEvent(new Event(Event.SELECT));
			});
		}
		
		public function get value():int
		{
			return parseInt(goldField.text, 10);
		}
		public function set value(value:int):void
		{
			goldField.text = value.toString(10);
		}
	}
}
