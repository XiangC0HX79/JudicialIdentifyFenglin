package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.ReportVO;
	import app.view.components.PopupBackReson;
	import app.view.components.PopupCancelReson;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.formatters.DateTimeFormatter;
	
	public class PopupCancelResonMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupCancelResonMediator";
		
		public function PopupCancelResonMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupCancelReson.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupCancelReson.addEventListener(PopupBackReson.CLOSE,onClose);
			popupCancelReson.addEventListener(PopupBackReson.SUBMIT,onSubmit);
		}
		
		protected function get popupCancelReson():PopupCancelReson
		{
			return viewComponent as PopupCancelReson;
		}
		
		private function initReson():void
		{			
			popupCancelReson.textPrintDate.text = popupCancelReson.report.CancelDate;
			popupCancelReson.textReson.text = popupCancelReson.report.cancelReson;
			
			if(popupCancelReson.report.cancelReson == "")
			{
				popupCancelReson.comboReson.selectedIndex = 0;
				
				popupCancelReson.textReson.text = popupCancelReson.comboReson.dataProvider[0];
				popupCancelReson.textReson.enabled = false;
			}
			else
			{
				var index:Number = -1;
				for(var i:Number = 0;i<popupCancelReson.comboReson.dataProvider.length - 1;i++)
				{
					if(popupCancelReson.comboReson.dataProvider[i] == popupCancelReson.report.cancelReson)
					{
						index = i;
						break;
					}
				}
				
				if(i != -1)
				{
					popupCancelReson.comboReson.selectedIndex = i;		
					popupCancelReson.textReson.enabled = false;
				}
				else
				{
					popupCancelReson.comboReson.selectedIndex = popupCancelReson.comboReson.dataProvider.length - 1;
					popupCancelReson.textReson.enabled = true;
				}
			}
		}
		
		private function onCreation(event:FlexEvent):void
		{								
			popupCancelReson.maxHeight = popupCancelReson.height;
			
			initReson();
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}			
				
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
				
		private function onSubmit(event:Event):void
		{						
			if(popupCancelReson.textReson.text == "")
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"请输入退案原因。");
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 案件状态 = " + ReportStatusDict.getItem("案件取消").id
							+ ",退案日期 = #"+ ApplicationFacade.NOW
							+"#,退案原因 = '" + popupCancelReson.textReson.text + "'"
							+ " WHERE ID = " + popupCancelReson.report.id]
					]);
			}
			
			function onSetResult(result:Number):void
			{		
				sendNotification(ApplicationFacade.NOTIFY_REPORT_REFRESH);
				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件取消成功。");
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
					if(notification.getBody()[0] == popupCancelReson)
					{
						popupCancelReson.report = notification.getBody()[1] as ReportVO;
						
						if(popupCancelReson.report.ReportStatus.label == "案件取消")
						{
							popupCancelReson.currentState = "VIEW";
						}
						else
						{
							popupCancelReson.currentState = "EDIT";
							
							popupCancelReson.report.cancelDate = ApplicationFacade.getNow();
						}						
						
						if(popupCancelReson.initialized)
						{
							initReson();
						}
					}
					break;
			}
		}
	}
}