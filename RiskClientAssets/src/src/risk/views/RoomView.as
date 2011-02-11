package risk.views
{
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.List;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import risk.data.PersonalData;
	import risk.ui.PersonalDataUI;
	
	import support.JsonLineReplyEvent;
	
	public class RoomView extends Sprite implements IView
	{
		// Personal details
		public var personal:PersonalDataUI;
		
		// Room details
		public var roomTitle:TextField;
		public var leaveRoomButton:Button;
		public var readyButton:Button;
		public var beginBattleButton:Button;
		public var nameLabel:Label;
		public var roomNameField:TextInput;
		public var playerList:List;
		
		public var playerListDP:DataProvider;
		
		public function RoomView()
		{
			super();

			playerListDP = new DataProvider();
			
			playerList.labelFunction = function (item:Object):String {
				return item.name + ' ' + (item.ready ? '✓' : '');
			}
			playerList.iconFunction = function (item:Object):Shape {
				var shape:Shape = new Shape();
				with (shape.graphics) {
					beginFill(parseInt(item.color, 16));
					drawRect(0, 0, 16, 16);
					endFill();
				}
				return shape;
			}
			playerList.selectable = false;
			playerList.dataProvider = playerListDP;
			
			leaveRoomButton.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				// Send leave room message
				dispatchEvent(new JsonLineReplyEvent('room-leave', {
				}));
			});
			readyButton.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				// Send ready message
				dispatchEvent(new JsonLineReplyEvent('room-ready', {
					status: !readyButton.selected
				}));
			});
			beginBattleButton.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				// Send begin battle message
				dispatchEvent(new JsonLineReplyEvent('room-begin', {
				}));
			});
			
			roomNameField.addEventListener(Event.CHANGE, function (event:Event):void {
				// Send update room name message
				dispatchEvent(new JsonLineReplyEvent('room-set', {
					newName: roomNameField.text
				}));
			});
			
			hide();
		}
		
		public function handleMessage(command:String, params:Object):void
		{
			// Update UI to reflect command
			if (command == 'room-announce') {
				roomTitle.text = params.name;
				roomNameField.text = params.name;
				playerListDP.removeAll();
				playerListDP.concat(params.players);
				playerList.dataProvider = playerListDP;
				beginBattleButton.visible = params.allReady;
			}
		}
		
		public function hide():void
		{
			visible = false;
		}
		
		public function show():void
		{
			visible = true;
			readyButton.selected = false;
			personal.nameField.text = PersonalData.personalData.name;
			personal.colorField.selectedColor = parseInt(PersonalData.personalData.color, 16);
		}
	}
}
