package app.view.components.subComponents
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import spark.components.CheckBox;
	import spark.components.supportClasses.ButtonBase;
	
	[SkinState("upAndUnSelected")]
	
	[SkinState("overAndUnSelected")]
	
	[SkinState("downAndUnSelected")]
	
	[SkinState("disabledAndUnSelected")]
	
	public class BaseCheckBox extends CheckBox
	{
		public function BaseCheckBox()
		{
			super();
		}
		
		public static const DEFAULT:Number = 0;
		public static const SELECTED:Number = 1;
		public static const UNSELECTED:Number = 2;
		private var _checked:Number = 0;
		
		[Bindable]
		[Inspectable(category="General", defaultValue="false")]
		
		public function get checked():Number
		{
			return _checked;
		}
		
		public function set checked(value:Number):void
		{
			if (value == _checked)
				return;
			
			_checked = value;            
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			invalidateSkinState();
		}
		
		//--------------------------------------------------------------------------
		//
		//  States
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */ 
		override protected function getCurrentSkinState():String
		{			
			if (_checked == BaseCheckBox.DEFAULT)
				return super.getCurrentSkinState();
			else if (_checked == BaseCheckBox.SELECTED)
				return super.getCurrentSkinState() + "AndSelected";
			else 
				return super.getCurrentSkinState() + "AndUnSelected";
		}
		
		/**
		 *  @private
		 */ 
		override protected function buttonReleased():void
		{
			//super.buttonReleased();
			
			_checked++;
			_checked %= 3;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}