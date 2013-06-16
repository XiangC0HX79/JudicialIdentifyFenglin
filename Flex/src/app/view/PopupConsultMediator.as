package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.model.AttachProxy;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.AttachImageVO;
	import app.model.vo.ReportVO;
	import app.model.vo.UserVO;
	import app.view.components.PopupConsult;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupConsultMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupConsultMediator";
		
		private var loginProxy:LoginProxy;
		private var reportProxy:ReportProxy;
		private var attachProxy:AttachProxy;
		
		public function PopupConsultMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupConsult.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupConsult.addEventListener(PopupConsult.CLOSE,onClose);
			popupConsult.addEventListener(PopupConsult.ACCEPT,onAccept);
			popupConsult.addEventListener(PopupConsult.SUBMIT,onSubmit);
			popupConsult.addEventListener(PopupConsult.BACK,onBack);
			
			popupConsult.addEventListener(PopupConsult.UPLOAD,onUpload);
			popupConsult.addEventListener(PopupConsult.DOWNLOAD,onDownload);
			
			popupConsult.addEventListener(AppEvent.UPLOADATTACH,onUploadAttach);
			popupConsult.addEventListener(AppEvent.DELETEATTACH,onDeleteAttach);
			popupConsult.addEventListener(AppEvent.NAVIATTACH,onNaviImage);
			
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
			attachProxy = facade.retrieveProxy(AttachProxy.NAME) as AttachProxy;
		}
		
		protected function get popupConsult():PopupConsult
		{
			return viewComponent as PopupConsult;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupConsult.maxHeight = popupConsult.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
				
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onBack(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupConsult.report,true]);	
		}
		
		private function onAccept(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 会诊接受日期 = #" + ApplicationFacade.NOW + "#" +
						" WHERE ID = " + popupConsult.report.id]
				]);
			
			function onSetResult(result:Number):void
			{			
				popupConsult.report.consultDate = ApplicationFacade.getNow();
				
				popupConsult.textPrintDate.text = popupConsult.report.ConsultDate;
					
				popupConsult.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{			
			if(!popupConsult.attach.consultResult)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请先上传《会诊结果》。");				
				return;
			}
			
			var consult:String = "";
			for each(var consulter:UserVO in popupConsult.listConsulter)
			{
				if(consulter.selected)
				{
					consult += consulter.name + "/";
				}
			}
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 会诊日期 = #" + ApplicationFacade.NOW + "#"
						+ ",案件状态 = " + ReportStatusDict.getItem("受理").id 
						+ ",会诊人 = '" + consult 
						+ "',其他会诊人 = '" + popupConsult.textOtherConsult.text 
						+ "'  WHERE ID = " + popupConsult.report.id]
				]);
			
			function onSetResult(result:Number):void
			{									
				reportProxy.refreshReport(popupConsult.report,resultHandle);
			}
			
			function resultHandle():void
			{												
				attachProxy.saveConsultImage(popupConsult.report);
				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupConsult.report.FullNO + "》会诊完毕。");	
			}
		}
		
		private function onUpload(event:Event):void
		{
			attachProxy.uploadFile(popupConsult.report,"会诊结果");
		}
		
		private function onDownload(event:Event):void
		{
			attachProxy.downloadFile(popupConsult.report,"会诊结果");
		}
		
		private function onUploadAttach(event:AppEvent):void
		{
			attachProxy.uploadConsultImage();
		}
		
		private function onDeleteAttach(event:AppEvent):void
		{
			attachProxy.deleteConsultImage(event.data);
		}
		
		private function onNaviImage(event:AppEvent):void
		{			
			//var attachImage:AttachImageVO = event.data as AttachImageVO;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupNaviImageMediator.NAME).getViewComponent(),event.data]);	
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
					if(notification.getBody()[0] == popupConsult)
					{						
						popupConsult.report = notification.getBody()[1] as ReportVO;
						
						attachProxy.refresh(popupConsult.report,AttachProxy.CONSULTIMAGE);
															
						if(loginProxy.checkReport(popupConsult.report)
							&& (popupConsult.report.ReportStatus.label == "会诊"))
						{
							if (popupConsult.report.ConsultDate == "待会诊")
								popupConsult.currentState = "ACCEPT";
							else
								popupConsult.currentState = "EDIT";
						}
						else
						{
							popupConsult.currentState = "VIEW";
						}
												
						popupConsult.attach = attachProxy.attach;						
						
						var user:UserProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
						popupConsult.listConsulter = user.listConsulter;
						
						for each(var consulter:UserVO in popupConsult.listConsulter)
						{
							if(popupConsult.report.consulter.indexOf(consulter.name + "/") >= 0)
							{
								consulter.selected = true;
							}
						}
					}
			}
		}
	}
}