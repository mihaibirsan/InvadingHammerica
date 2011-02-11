package com.gskinner.motion
{
	public class GTweenFrom extends GTween
	{
		public function GTweenFrom(target:Object=null, duration:Number=10, properties:Object=null, tweenProperties:Object=null)
		{
			var newProperties:Object = {};
			for (var prop:String in properties) {
				newProperties[prop] = target[prop];
				target[prop] = properties[prop];
			}
			super(target, duration, newProperties, tweenProperties);
		}
		
	}
}