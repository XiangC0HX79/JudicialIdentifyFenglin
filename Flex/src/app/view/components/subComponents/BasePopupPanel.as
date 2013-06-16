package app.view.components.subComponents
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.SkinnableContainer;
	
	[SkinState("open")]
	[SkinState("minimized")]
	[SkinState("closed")]
	
	[Style(name="borderColor",type="uint",inherit="no")]	
	[Style(name="skinAlpha",type="double",inherit="no")]	
	[Style(name="skinColor",type="uint",inherit="no")]
	
	public class BasePopupPanel extends SkinnableContainer
	{		
		[SkinPart(required = "false")]
		public var panelFrame:Group;
		
		[SkinPart(required = "false")]
		public var header:Group;
		
		[SkinPart(required = "false")]
		public var headerToolGroup:Group;
		
		[SkinPart(required = "false")]
		public var closeButton:Image;
		
		[SkinPart(required = "false")]
		public var minimizeButton:Image;
		
		[SkinPart(required = "false")]
		public var resizeButton:Image;
		
		[SkinPart(required = "false")]
		public var icon:Image;
		
		[Bindable]
		public var enableCloseButton:Boolean = true;
		
		[Bindable]
		public var enableMinimizeButton:Boolean = true;
		
		[Bindable]
		public var enableIcon:Boolean = true;
		
		[Bindable]
		public var enableDraging:Boolean = true;
		
		[Bindable]
		public var panelTitle:String = "";
				
		[Bindable]
		private var _draggable:Boolean = true;
		
		public static const SUBPANEL_OPENED:String = "open";
		
		public static const SUBPANEL_MINIMIZED:String = "minimized";
		
		public static const SUBPANEL_CLOSED:String = "closed";
		
		public function BasePopupPanel()
		{
			super();
			
			//this.width = 300;
			//this.height = 300;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		private function creationCompleteHandler(event:FlexEvent):void
		{
		}
				
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == icon)
			{
				icon.addEventListener(MouseEvent.CLICK, icon_clickHandler);
			}
			if (instance == panelFrame)
			{
				panelFrame.addEventListener(MouseEvent.MOUSE_DOWN, mouse_downHandler);
				panelFrame.addEventListener(MouseEvent.MOUSE_UP, mouse_upHandler);
				
				/*panelFrame.stage.addEventListener(MouseEvent.MOUSE_UP, mouse_upHandler);
				panelFrame.stage.addEventListener(Event.MOUSE_LEAVE, stageout_Handler);*/
			}
			if (instance == header)
			{
				header.addEventListener(MouseEvent.MOUSE_DOWN, mouse_downHandler);
				header.addEventListener(MouseEvent.MOUSE_UP, mouse_upHandler);
			}
			if (instance == closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK, close_clickHandler);
			}
			if (instance == minimizeButton)
			{
				minimizeButton.addEventListener(MouseEvent.CLICK, minimize_clickHandler);
			}
			if (instance == resizeButton)
			{
				/*resizeButton.addEventListener(MouseEvent.MOUSE_OVER, resize_overHandler);
				resizeButton.addEventListener(MouseEvent.MOUSE_OUT, resize_outHandler);
				resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, resize_downHandler);*/
			}
		}
		
		public function mouse_downHandler(event:MouseEvent):void
		{
			if (_draggable && enableDraging)
			{
				header.addEventListener(MouseEvent.MOUSE_MOVE, mouse_moveHandler);
				panelFrame.addEventListener(MouseEvent.MOUSE_MOVE, mouse_moveHandler);
			}
		}
		
		private var panelMoveStarted:Boolean = false;
		
		private function mouse_moveHandler(event:MouseEvent):void
		{
			if (!panelMoveStarted)
			{
				panelMoveStarted = true;
				
				/*if (_widgetState != WIDGET_MINIMIZED)
				{
					this.alpha = 0.7;
				}*/
				var panel:UIComponent = this as UIComponent;
				
				if (!DragManager.isDragging)
				{
					panel.startDrag();
				}
			}
		}
		
		private function mouse_upHandler(event:MouseEvent):void
		{
			header.removeEventListener(MouseEvent.MOUSE_MOVE, mouse_moveHandler);
			panelFrame.removeEventListener(MouseEvent.MOUSE_MOVE, mouse_moveHandler);
			
			var panel:UIComponent = this as UIComponent;
			
			panel.stopDrag();
			
			var appHeight:Number = FlexGlobals.topLevelApplication.height;
			var appWidth:Number = FlexGlobals.topLevelApplication.width;
			
			if (panel.y < 0)
			{
				panel.y = 0;
			} 
			if (panel.y > (appHeight - 40))
			{
				panel.y = appHeight - 40;
			}
			if (panel.x < 0)
			{
				panel.x = 20;
			}
			
			if (panel.x > (appWidth - 40))
			{
				panel.x = appWidth - 40;
			}
			
			// clear constraints since x and y have been set
			panel.left = panel.right = panel.top = panel.bottom = undefined;
			
			panelMoveStarted = false;
		}
		
		private function stageout_Handler(event:Event):void
		{
			if (panelMoveStarted)
			{
				mouse_upHandler(null);
			}
		}
		
		protected function icon_clickHandler(event:MouseEvent):void
		{
			this.panelFrame.toolTip = "";
			this.icon.toolTip = "";
		} 
		
		protected function close_clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new Event(SUBPANEL_CLOSED,true));
		}
		
		protected function minimize_clickHandler(event:MouseEvent):void
		{
			/*if (_baseWidget)
			{
				_baseWidget.setState(WIDGET_MINIMIZED);
			}
			*/
			this.panelFrame.toolTip = this.panelTitle;
			this.icon.toolTip = this.panelTitle;
		}
		
		private var _panelIcon:String = "assets/image/i_widget.png";
		[Bindable]
		public function get panelIcon():String
		{
			return _panelIcon;
		}
		
		public function set panelIcon(value:String):void
		{
			_panelIcon = value;
		}
	}
}