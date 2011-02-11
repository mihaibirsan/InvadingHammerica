package support
{
	import flash.events.Event;
	
	public class JsonLineReplyEvent extends Event
	{
		static public const REPLY:String = 'jsonLineReplyEvent';
		
		public var command:String;
		public var params:Object;
		
		public function JsonLineReplyEvent(command:String, params:Object)
		{
			super(REPLY, true, true);
			this.command = command;
			this.params = params;
		}
	}
}
