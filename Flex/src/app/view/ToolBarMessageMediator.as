package app.view
{
	import app.ApplicationFacade;
	import app.view.components.ToolBarMessage;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class ToolBarMessageMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ToolBarMessageMediator";
		
		private var timer:Timer;
		
		public function ToolBarMessageMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			toolBarMessage.addEventListener(MouseEvent.CLICK,onClick);
			
			timer = new Timer(10000);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			timer.start();
		}
		
		protected function get toolBarMessage():ToolBarMessage
		{
			return viewComponent as ToolBarMessage;
		}
		
		private function onClick(event:MouseEvent):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupMessageMediator.NAME).getViewComponent()]);			
		}
		
		private var id:Number = -1;
		private function onTimer(event:TimerEvent):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["getCurMessage",onGetCurMessageResult
					,[
						id
					]
					,false
				]);
		}
		
		private function onGetCurMessageResult(result:String):void
		{		
			var arr:Array = result.split("|");
			if(arr.length == 1)
			{
				id = -1;
			}
			else
			{
				id = Number(arr[1]);
			}
			
			if(toolBarMessage.labelMessage != null)
			{
				toolBarMessage.labelMessage.text = arr[0];
				
				toolBarMessage.moveMessage.end();
				toolBarMessage.moveMessage.play();
			}
		}
	}
}