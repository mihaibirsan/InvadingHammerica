package risk.ui
{
	import fl.controls.ColorPicker;
	import fl.controls.Label;
	import fl.controls.TextInput;
	import fl.events.ColorPickerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import risk.data.PersonalData;
	
	import support.JsonLineReplyEvent;
	
	public class PersonalDataUI extends Sprite
	{
		public var nameLabel:Label;
		public var nameField:TextInput;
		public var colorLabel:Label;
		public var colorField:ColorPicker;
		
		public function PersonalDataUI()
		{
			super();
			
			nameField.addEventListener(Event.CHANGE, function (event:Event):void {
				// Send update name message
				PersonalData.personalData.name = nameField.text;
				dispatchEvent(new JsonLineReplyEvent('personal-set', {
					newName: PersonalData.personalData.name
				}));
			});
			colorField.addEventListener(ColorPickerEvent.CHANGE, function (event:Event):void {
				// Send update name message
				PersonalData.personalData.color = colorField.hexValue;
				dispatchEvent(new JsonLineReplyEvent('personal-set', {
					newColor: PersonalData.personalData.color
				}));
			});
		}
	}
}
