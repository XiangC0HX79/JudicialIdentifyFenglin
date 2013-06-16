package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.view.components.NaviManageData;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviManageDataMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviManageDataMediator";
		
		public function NaviManageDataMediator(viewComponent:Object = null)
		{
			super(NAME, viewComponent);
			
			naviManageData.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			naviManageData.addEventListener(NaviManageData.RESET,onBackUp);
			//naviManageData.addEventListener(NaviManageData.FEEDBACK,onFeedback);
			
			naviManageData.addEventListener(NaviManageData.CLOSE,onClose);
		}
		
		protected function get naviManageData():NaviManageData
		{
			return viewComponent as NaviManageData;
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
				
		private function onCreation(event:FlexEvent):void
		{								
			init();
		}			
		
		private function init():void
		{
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,["SELECT * FROM 参数表 WHERE 组名 = '初始编号'"]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{		
				for each(var item:Object in result)
				{
					switch(item.参数ID)
					{
						case 0:
							naviManageData.numCan.value = Number(item.参数值);
							break;
						case 1:
							naviManageData.numSan.value = Number(item.参数值);
							break;
						case 2:
							naviManageData.numShang.value = Number(item.参数值);
							break;
						case 3:
							naviManageData.numJing.value = Number(item.参数值);
							break;
					}
				}
			}
		}
		
		private function onFeedback(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SendMail",onResult,[]]);
			
			function onResult(result:String):void
			{		
				var arr:Array = result.split("|");
				if(arr[0] != "000")
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,arr[1]);		
				else
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"开发反馈信息提交成功。");		
			}
		}
		
		private function onBackUp(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["重置编号后新受理案件的将从初始编号和当前编号取大值开始编号，比如设置的初始编号为'100',而当前编号为'50'，那么新受理案件编号为'100',如果设置的初始编号为'40'，而当前编号为'50',那么新受理案件编号为'51'。是否重置编号？",closeHandle,Alert.YES | Alert.NO]);
			
			function closeHandle(event:CloseEvent):void
			{
				if(event.detail == Alert.YES)
				{			
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["ReSetNo",onResult,[naviManageData.numCan.value,naviManageData.numSan.value,naviManageData.numShang.value,naviManageData.numJing.value]]);
				}
			}
			
			function onResult(result:String):void
			{
				//sendNotification(ApplicationFacade.NOTIFY_REPORT_REFRESH);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"重置编号成功！");			
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
					if((notification.getBody()[0] == facade.retrieveMediator(PopupSysManagerMediator.NAME).getViewComponent())
						&& naviManageData.initialized)
					{												
						init();		
					}
					break;
			}
		}
	}
}