package risk.ui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Territory extends Sprite
	{
		public var armiesField:TextField;
		
		public function Territory()
		{
			super();
			
			mouseChildren = false;
			buttonMode = useHandCursor = true;
			
			var textFormat:TextFormat = new TextFormat('Myriad Pro Bold', 16, 0xFFFFFF, true);
			
			addChild(armiesField = new TextField());
			armiesField.autoSize = TextFieldAutoSize.CENTER;
			armiesField.x = width/2;
			armiesField.y = height/2;
			armiesField.defaultTextFormat = textFormat;
			
			addEventListener(MouseEvent.MOUSE_OVER, function (event:MouseEvent):void {
				mouseOver = true;
			});
			addEventListener(MouseEvent.MOUSE_OUT, function (event:MouseEvent):void {
				mouseOver = false;
			});
		}
		
		protected var _addArmies:int;
		public function get addArmies():int
		{
			return _addArmies;
		}
		public function set addArmies(value:int):void
		{
			_addArmies = value;
			redraw();
		}
		
		protected var _existingArmies:int;
		public function get existingArmies():int
		{
			return _existingArmies;
		}
		public function set existingArmies(value:int):void
		{
			_existingArmies = value;
			redraw();
		}
		
		public var ownerPlayerId:Number;
		
		public function get armiesColor():Number
		{
			return armiesField.textColor;
		}
		public function set armiesColor(value:Number):void
		{
			armiesField.textColor = value;
		}
		
		private var _mouseOver:Boolean;
		public function get mouseOver():Boolean
		{
			return _mouseOver;
		}
		public function set mouseOver(value:Boolean):void
		{
			_mouseOver = value;
			if (value) parent.addChild(this); // Move to the top of the Z queue
			redraw();
		}
		
		public function redraw():void
		{
			var f:Array = [];
			if (_mouseOver) {
				f.push(new GlowFilter(0xFFFFFF, 1, 2, 2, 4, 2, true));
			}
			filters = f;
			
			armiesField.text = '';
			if (existingArmies > 0) {
				armiesField.appendText(existingArmies.toString(10));
			}
			if (addArmies > 0) {
				armiesField.appendText('+' + addArmies.toString(10));
			}
		}
	}
}
