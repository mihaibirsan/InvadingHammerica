package support
{
	import flash.events.Event;
	
	public class JsonLineMessageEvent extends Event
	{
		public static var MESSAGE:String = 'jsonLineMessageEvent';
		
		public var data:*;
		
		public function JsonLineMessageEvent(type:String, data:*)
		{
			super(type, false, false);
			this.data = data;
		}
	}
}
