package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.MessageProxy;
	import app.model.vo.LoginVO;
	import app.view.components.PopupMessage;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.formatters.DateTimeFormatter;
	
	public class PopupMessageMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupMessageMediator";
				
		private var messageProxy:MessageProxy;
		
		public function PopupMessageMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupMessage.addEventListener(PopupMessage.SUBMIT,onSubmit);
			popupMessage.addEventListener(PopupMessage.CLOSE,onClose);
			
			messageProxy = facade.retrieveProxy(MessageProxy.NAME) as MessageProxy;
			popupMessage.list = messageProxy.list;
		}
		
		protected function get popupMessage():PopupMessage
		{
			return viewComponent as PopupMessage;
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onSubmit(event:Event):void
		{
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "HH:mm:ss";
			
			var time:String = ApplicationFacade.NOW + " " + dateF.format(new Date);
			
			var login:LoginVO = facade.retrieveProxy(LoginProxy.NAME).getData() as LoginVO;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,[
						"INSERT INTO 留言板 (时间,姓名,留言) VALUES (#" + time + "#,'" + login.name + "','" + popupMessage.textMessage.text + "')"
					]
				]);
			
			function onSetResult(result:Number):void
			{		
				if(result == 1)
				{
					messageProxy.refresh();
				}
			}
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
					if(notification.getBody()[0] == popupMessage)
					{
						messageProxy.refresh();
					}
			}
		}
	}
}