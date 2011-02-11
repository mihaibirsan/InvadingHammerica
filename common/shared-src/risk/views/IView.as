package risk.views
{
	public interface IView
	{
		function handleMessage(command:String, params:Object):void;
		function hide():void;
		function show():void;
	}
}
