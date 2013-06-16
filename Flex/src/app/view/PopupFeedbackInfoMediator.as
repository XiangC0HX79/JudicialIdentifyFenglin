package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.model.FeedbackProxy;
	import app.model.vo.FeedbackVO;
	import app.model.vo.ReportVO;
	import app.view.components.PopupFeedbackInfo;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupFeedbackInfoMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupFeedbackInfoMediator";
				
		private var feedbackProxy:FeedbackProxy;
		
		public function PopupFeedbackInfoMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupFeedbackInfo.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupFeedbackInfo.addEventListener(PopupFeedbackInfo.CLOSE,onClose);
			
			popupFeedbackInfo.addEventListener(AppEvent.DOWNLOADATTACH,onDownloadAttach);
			
			feedbackProxy = facade.retrieveProxy(FeedbackProxy.NAME) as FeedbackProxy;
			
			popupFeedbackInfo.listFeedback = feedbackProxy.list;
		}
		
		protected function get popupFeedbackInfo():PopupFeedbackInfo
		{
			return viewComponent as PopupFeedbackInfo;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupFeedbackInfo.maxHeight = popupFeedbackInfo.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onDownloadAttach(event:AppEvent):void
		{
			var feedback:FeedbackVO = 	popupFeedbackInfo.comboNo.selectedItem as FeedbackVO;
			if(feedback != null)
				feedbackProxy.downloadAttach(feedback,event.data);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_POPUP_SHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{				
				case ApplicationFacade.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == popupFeedbackInfo)
					{				
						var report:ReportVO = notification.getBody()[1] as ReportVO;
						feedbackProxy.refresh(report,handleFunction);
					}
			}
			
			function handleFunction():void
			{
				if(feedbackProxy.list.length == 0)
					popupFeedbackInfo.selectFeedback = null;		
				else					
					popupFeedbackInfo.selectFeedback = feedbackProxy.list[0];		
			}
		}
	}
}