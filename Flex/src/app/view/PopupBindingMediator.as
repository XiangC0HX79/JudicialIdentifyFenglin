package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.LoginVO;
	import app.model.vo.ReportVO;
	import app.view.components.PopupBinding;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupBindingMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupBindingMediator";
				
		private var loginProxy:LoginProxy;
		private var reportProxy:ReportProxy;
		
		public function PopupBindingMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupBinding.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupBinding.addEventListener(PopupBinding.PREVIOUS,onPrevious);
			popupBinding.addEventListener(PopupBinding.CLOSE,onClose);
			popupBinding.addEventListener(PopupBinding.ACCEPT,onAccept);
			popupBinding.addEventListener(PopupBinding.SUBMIT,onSubmit);
			popupBinding.addEventListener(PopupBinding.BACK,onBack);
			
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy; 
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
		}
		
		protected function get popupBinding():PopupBinding
		{
			return viewComponent as PopupBinding;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupBinding.maxHeight = popupBinding.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
				
		private function onPrevious(event:Event):void
		{						
			popupBinding.report.revisionDate = null;
			popupBinding.report.reportStatus = ReportStatusDict.getItem("修订").id;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 修订日期 = NULL,装订接受日期 = NULL" +
						",案件状态 = " + popupBinding.report.reportStatus +
						"  WHERE ID = " + popupBinding.report.id]
				]);
			
			function onSetResult(result:Number):void
			{			
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
			}
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onBack(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupBinding.report,true]);	
		}
				
		private function onAccept(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 装订接受日期 = #" + ApplicationFacade.NOW + "#" +
						",装订人 = " + loginProxy.loginUser.id +
						" WHERE ID = " + popupBinding.report.id]
				]);
			
			function onSetResult(result:Number):void
			{				
				reportProxy.refreshReport(popupBinding.report,resultHandle);
			}
			
			function resultHandle():void
			{
				popupBinding.textPrintDate.text = popupBinding.report.BindingDate;
				
				popupBinding.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{						
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 装订日期 = #" + ApplicationFacade.NOW + "#" +
						",案件状态 = " + ReportStatusDict.getItem("签字").id + 
						"  WHERE ID = " + popupBinding.report.id]
				]);
			
			
			function onSetResult(result:Number):void
			{				
				reportProxy.refreshReport(popupBinding.report,resultHandle);
			}
			
			function resultHandle():void
			{				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupBinding.report.FullNO + "》装订完毕。");
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
					if(notification.getBody()[0] == popupBinding)
					{
						popupBinding.report = notification.getBody()[1] as ReportVO;
						
						if(loginProxy.checkReport(popupBinding.report)
							&& (popupBinding.report.ReportStatus.label == "装订"))
						{
							if (popupBinding.report.BindingDate == "待装订")
								popupBinding.currentState = "ACCEPT";
							else
								popupBinding.currentState = "EDIT";
						}
						else
						{
							popupBinding.currentState = "VIEW";
						}
					}
					break;
			}
		}
	}
}