package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import risk.data.PersonalData;
	import risk.views.GameView;
	import risk.views.IView;
	import risk.views.LobbyView;
	import risk.views.RoomView;
	
	import support.JsonLineMessageEvent;
	import support.JsonLineMessageSocket;
	import support.JsonLineReplyEvent;
	
	[SWF(width='640', height='640', backgroundColor='#FFFFFF', frameRate='24')]
	
	public class RiskClientSWF extends Sprite
	{
		static public function randomColor():String
		{
			var color:String = '';
			for (var i:int = 0; i < 3; i++) {
				var k:String = Math.floor(Math.random()*16).toString(16);
				color += k + k;
			}
			return color;
		}
		
		protected var jsonSocket:JsonLineMessageSocket;
		
		public var lobbyView:LobbyView;
		public var roomView:RoomView;
		public var gameView:GameView;
		
		public function RiskClientSWF()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			PersonalData.personalData = {
				id: null,
				name: 'Commander' + (Math.floor(Math.random()*9000)+1000),
				color: randomColor()
			};
			
			addChild(lobbyView = new LobbyView());
			addChild(roomView = new RoomView());
			addChild(gameView = new GameView());
			
			jsonSocket = new JsonLineMessageSocket();
			jsonSocket.addEventListener(Event.CONNECT, function (event:Event):void {
				view = lobbyView;
				jsonSocket.send({ 'personal-set': { 
					newName: PersonalData.personalData.name,
					newColor: PersonalData.personalData.color
				}});
			});
			jsonSocket.addEventListener(JsonLineMessageEvent.MESSAGE, jsonMessageEventHandler);
			addEventListener(JsonLineReplyEvent.REPLY, jsonReplyEventHandler);
			
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
			stageResizeHandler();
		}
		
		private var _view:IView = null;
		public function get view():IView
		{
			return _view;
		}
		public function set view(value:IView):void
		{
			if (_view == value) return;
			if (_view) {
				_view.hide();
			}
			_view = value;
			if (_view) {
				_view.show();
			}
		}
		
		protected function jsonMessageEventHandler(event:JsonLineMessageEvent):void
		{
			var message:Object = event.data;
			for (var command:String in message) {
				if (command == 'hello') 
				{
					// Authentication
					PersonalData.personalData.id = message[command].id;
				}
				
				else if (command.match(/^lobby-/))
				{
					view = lobbyView;
					view.handleMessage(command, message[command]);
				}
				
				else if (command.match(/^room-/))
				{
					view = roomView;
					view.handleMessage(command, message[command]);
				}
				
				else if (command.match(/^game-/))
				{
					view = gameView;
					view.handleMessage(command, message[command]);
				}
				
				else if (command.match(/^message-/))
				{
					// TODO: Message popup
				}
				
				else trace('Unknown command', command);
			}
		}
		
		protected function jsonReplyEventHandler(event:JsonLineReplyEvent):void
		{
			jsonSocket.sendReply(event);
		}
		
		protected function stageResizeHandler(event:Event = null):void
		{
		}
	}
}
