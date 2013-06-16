package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.dict.SendStatusDict;
	import app.model.vo.ReportVO;
	import app.view.components.PopupSend;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSendMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSendMediator";
		
		private var reportProxy:ReportProxy;
		
		public function PopupSendMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupSend.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupSend.addEventListener(PopupSend.CLOSE,onClose);
			popupSend.addEventListener(PopupSend.ACCEPT,onAccept);
			popupSend.addEventListener(PopupSend.SUBMIT,onSubmit);
			popupSend.addEventListener(PopupSend.BACK,onBack);
			
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
		}
		
		protected function get popupSend():PopupSend
		{
			return viewComponent as PopupSend;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupSend.maxHeight = popupSend.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
				
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onBack(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupSend.report,true]);	
		}
				
		private function onAccept(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 发放接受日期 = #" + ApplicationFacade.NOW + "#" +
						" WHERE ID = " + popupSend.report.id]
				]);
			
			function onSetResult(result:Number):void
			{				
				reportProxy.refreshReport(popupSend.report,resultHandle);
			}
			
			function resultHandle():void
			{			
				popupSend.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{									
			var sql:String = "UPDATE 报告信息 SET " 
				+ "发放状态 = " + (popupSend.gridRank.selectedIndex + 1);
				
			if(popupSend.gridRank.labelDisplay.text == "已领取")
			{
				/*if(popupSend.textGetName.text == "")
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"请输入签收人。");	
					return;
				}*/
				
				if(popupSend.dateGet.selectedDate == null)
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"请选择签收日期。");	
					return;
				}
				
				sql += ",签收日期 = #" + popupSend.dateGet.text + "#";
			}
			
			if(popupSend.report.fileDate != null)
				sql += ",案件状态 = " + ReportStatusDict.getItem("完成").id;		
			
			sql += "  WHERE ID = " + popupSend.report.id;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,[sql]
				]);
			
			function onSetResult(result:Number):void
			{						
				reportProxy.refreshReport(popupSend.report,resultHandle);
			}
			
			function resultHandle():void
			{							
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupSend.report.FullNO + "》报告发放状态修改成功。");	
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_POPUP_SHOW,
				ApplicationFacade.NOTIFY_APP_INIT
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case ApplicationFacade.NOTIFY_APP_INIT:
					popupSend.listSendStatus = SendStatusDict.listDropdown;
					break;
				
				case ApplicationFacade.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == popupSend)
					{
						popupSend.report = notification.getBody()[1] as ReportVO;
						
						var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
						if(loginProxy.checkReport(popupSend.report)
							&& (popupSend.report.sendGetDate == null))
						{
							if (popupSend.report.SendDate == "待发放")
								popupSend.currentState = "ACCEPT";
							else
								popupSend.currentState = "EDIT";
						}
						else
						{
							popupSend.currentState = "VIEW";
						}
					}
					break;
			}
		}
	}
}