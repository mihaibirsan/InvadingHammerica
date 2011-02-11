package risk.views
{
	import fl.controls.Button;
	import fl.controls.ColorPicker;
	import fl.controls.DataGrid;
	import fl.controls.Label;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import risk.data.PersonalData;
	import risk.ui.PersonalDataUI;
	
	import support.JsonLineReplyEvent;
	
	public class LobbyView extends Sprite implements IView
	{
		// Personal details
		public var personal:PersonalDataUI;
		
		// Lobby interaction
		public var createRoomButton:Button;
		public var roomList:DataGrid;
		
		public var roomListDP:DataProvider;
		
		public function LobbyView()
		{
			super();
			
			roomListDP = new DataProvider();
			
			roomList.columns = [ 'id', 'name', 'playerNames' ];
			roomList.dataProvider = roomListDP;
			
			roomList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, function (event:ListEvent):void {
				// Send join room message
				dispatchEvent(new JsonLineReplyEvent('room-join', {
					id: event.item.id // TODO: Make sure this is the right room ID
				}));
			});
			createRoomButton.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
				// Send create room message
				dispatchEvent(new JsonLineReplyEvent('room-create', {
				}));
				dispatchEvent(new JsonLineReplyEvent('room-set', {
					newName: 'Battlefield' + (Math.floor(Math.random()*900)+100)
				}));
			});
			
			hide();
		}
		
		public function handleMessage(command:String, params:Object):void
		{
			// Update UI to reflect command
			if (command == 'lobby-announce') {
				roomListDP.removeAll();
				roomListDP.concat(params.rooms);
			}
		}
		
		public function hide():void
		{
			visible = false;
		}
		
		public function show():void
		{
			visible = true;
			personal.nameField.text = PersonalData.personalData.name;
			personal.colorField.selectedColor = parseInt(PersonalData.personalData.color, 16);
		}
	}
}
