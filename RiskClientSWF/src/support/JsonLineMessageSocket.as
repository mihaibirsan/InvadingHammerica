package support
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class JsonLineMessageSocket extends Socket
	{
		public function JsonLineMessageSocket()
		{
			addEventListener(Event.CLOSE, socketCloseHandler);
			addEventListener(Event.CONNECT, socketConnectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, socketIoErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketSecurityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketSocketDataHandler);
			objectEncoding = ObjectEncoding.AMF3;
			defaultConnect();
		}
		
		private var retrySocketConnectTimer:Timer = null;
		public function defaultConnect():void
		{
			if (connected) return;
			connect('192.168.56.101', 8123);
		}
		public function retrySocketConnect():void
		{
			if (retrySocketConnectTimer != null) return;
			retrySocketConnectTimer = new Timer(2000, 1);
			retrySocketConnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function (event:TimerEvent):void {
				retrySocketConnectTimer.stop();
				retrySocketConnectTimer = null;
				defaultConnect();
			});
			retrySocketConnectTimer.start();
		}
		
		protected function socketCloseHandler(event:Event):void
		{
			trace('closeHandler', event);
			retrySocketConnect();
		}
		
		protected function socketConnectHandler(event:Event):void
		{
			trace('connectHandler', event);
			send({ 'hello': {} });
		}
		
		protected function socketIoErrorHandler(event:IOErrorEvent):void
		{
			trace('ioErrorHandler', event);
			if (connected == false) retrySocketConnect();
		}
		
		protected function socketSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			trace('securityErrorHandler', event);
			if (connected == false) retrySocketConnect();
		}
		
		public function sendReply(reply:JsonLineReplyEvent):void
		{
			var message:Object = {};
			message[reply.command] = reply.params;
			send(message);
		}
		
		public function send(message:Object):void
		{
			writeUTFBytes(JSON.encode(message) + "\n");
			flush();
		}
		
		protected var messageBuffer:String = '';
		protected function socketSocketDataHandler(event:ProgressEvent):void
		{
			// trace('socketDataHandler', event);
			
			// Consume socket and buffer it
			messageBuffer += readUTFBytes(bytesAvailable);
			
			// All messages are expected to be one JSON object per line.
			var fullMessages:Array = messageBuffer.split(/[\n\r]+/);
			while (fullMessages.length) {
				try
				{
					var message:String = fullMessages.shift();
					if (message.match(/\A\s*\Z/)) continue;
					var json:Object = JSON.decode(message);
					trace(message);
					dispatchEvent(new JsonLineMessageEvent(JsonLineMessageEvent.MESSAGE, json));
				}
				catch (e:Error)
				{
					fullMessages.unshift(message);
					trace(e, message);
					break;
				}
			}
			messageBuffer = fullMessages.join("\n");
		}
	}
}
