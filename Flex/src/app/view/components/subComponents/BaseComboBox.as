package app.view.components.subComponents
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import spark.components.ComboBox;
	import spark.events.TextOperationEvent;
	
	[Event(name="textchange",type ="flash.events.Event")]   
	[Event(name="enter",type ="flash.events.Event")]   
	
	public class BaseComboBox extends ComboBox
	{
		public static const TEXTCHANGE:String = "textchange";
		public static const ENTER:String = "enter";
		
		public function BaseComboBox()
		{
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (partName == "textInput")
			{
				instance.addEventListener(TextOperationEvent.CHANGE , handleTextChange);
				instance.addEventListener(FlexEvent.ENTER , handleEnter);
			}
		}
		
		private function handleTextChange(event:TextOperationEvent):void
		{
			dispatchEvent(new Event(TEXTCHANGE));
		}
		
		private function handleEnter(event:FlexEvent):void
		{
			dispatchEvent(new Event(ENTER));
		}
	}
}