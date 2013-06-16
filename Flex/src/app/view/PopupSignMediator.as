package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.ReportVO;
	import app.model.vo.UserVO;
	import app.view.components.PopupSign;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupSignMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSignMediator";
		
		private var loginProxy:LoginProxy;
		private var reportProxy:ReportProxy;
		
		public function PopupSignMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupSign.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupSign.addEventListener(PopupSign.PREVIOUS,onPrevious);
			popupSign.addEventListener(PopupSign.CLOSE,onClose);
			popupSign.addEventListener(PopupSign.ACCEPT,onAccept);
			popupSign.addEventListener(PopupSign.SUBMIT,onSubmit);
			popupSign.addEventListener(PopupSign.BACK,onBack);
						
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
		}
		
		protected function get popupSign():PopupSign
		{
			return viewComponent as PopupSign;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupSign.maxHeight = popupSign.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
				
		private function onPrevious(event:Event):void
		{						
			popupSign.report.bindingDate = null;
			popupSign.report.reportStatus = ReportStatusDict.getItem("装订").id;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 装订日期 = NULL,签字接受日期 =NULL" +
						",案件状态 = " + popupSign.report.reportStatus +
						"  WHERE ID = " + popupSign.report.id]
				]);
			
			function onSetResult(result:Number):void
			{			
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
			}
		}
		
		private function onBack(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupSign.report,true]);	
		}
				
		private function onAccept(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 签字接受日期 = #" + ApplicationFacade.NOW + "#" +
						" WHERE ID = " + popupSign.report.id]
				]);
			
			function onSetResult(result:Number):void
			{			
				reportProxy.refreshReport(popupSign.report,resultHandle);
			}
			
			function resultHandle():void
			{
				popupSign.textPrintDate.text = popupSign.report.SignDate;
				
				popupSign.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{					
			var sign:String = "";
			for each(var signer:UserVO in popupSign.listSigner)
			{
				if(signer.selected)
				{
					sign += signer.name + "/";
				}
			}
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET " 
						+ "签字日期 = #" + ApplicationFacade.NOW + "#" 
						+ ",案件状态 = " + ReportStatusDict.getItem("发放及归档").id
						+ ",签字人 = '" + sign 
						+ "',其他签字人 = '" + popupSign.textOtherConsult.text 
						+ "'  WHERE ID = " + popupSign.report.id]
				]);
			
			function onSetResult(result:Number):void
			{				
				reportProxy.refreshReport(popupSign.report,resultHandle);
			}
			
			function resultHandle():void
			{				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupSign.report.FullNO + "》鉴定完毕。");	
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
					if(notification.getBody()[0] == popupSign)
					{
						popupSign.report = notification.getBody()[1] as ReportVO;
						
						if(loginProxy.checkReport(popupSign.report)
							&& (popupSign.report.ReportStatus.label == "签字"))
						{
							if (popupSign.report.SignDate == "待签字")
								popupSign.currentState = "ACCEPT";
							else
								popupSign.currentState = "EDIT";
						}
						else
						{
							popupSign.currentState = "VIEW";
						}
																
						var user:UserProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
						popupSign.listSigner = user.listSigner;
						
						for each(var signer:UserVO in popupSign.listSigner)
						{
							if(popupSign.report.signer.indexOf(signer.name + "/") >= 0)
							{
								signer.selected = true;
							}
						}
					}
					break;
			}
		}
	}
}