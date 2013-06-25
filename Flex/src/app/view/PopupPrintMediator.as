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
	import app.view.components.PopupPrint;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.formatters.DateTimeFormatter;
	
	public class PopupPrintMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupPrintMediator";
		
		private var loginProxy:LoginProxy;
		private var userProxy:UserProxy;
		private var attachProxy:AttachProxy;
		
		public function PopupPrintMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupPrint.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupPrint.addEventListener(PopupPrint.CLOSE,onClose);
			popupPrint.addEventListener(PopupPrint.ACCEPT,onAccept);
			popupPrint.addEventListener(PopupPrint.SUBMIT,onSubmit);
			popupPrint.addEventListener(PopupPrint.BACK,onBack);
			
			popupPrint.addEventListener(PopupPrint.UPLOADDRAFT,onUploadDraft);
			popupPrint.addEventListener(PopupPrint.DOWNLOADDRAFT,onDownloadDraft);	
			popupPrint.addEventListener(PopupPrint.UPLOADPHOTO,onUploadPhoto);
			popupPrint.addEventListener(PopupPrint.DOWNLOADPHOTO,onDownloadPhoto);	
			
			popupPrint.addEventListener(AppEvent.UPLOADATTACH,onUploadAttach);
			popupPrint.addEventListener(AppEvent.DELETEATTACH,onDeleteAttach);
			popupPrint.addEventListener(AppEvent.NAVIATTACH,onNaviImage);
			
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			userProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
			attachProxy = facade.retrieveProxy(AttachProxy.NAME) as AttachProxy;
		}
		
		protected function get popupPrint():PopupPrint
		{
			return viewComponent as PopupPrint;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupPrint.maxHeight = popupPrint.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onBack(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupPrint.report,true]);	
		}
		
		private function onAccept(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 打印接受日期 = #" + ApplicationFacade.NOW + "# WHERE ID = " + popupPrint.report.id]
				]);
			
			function onSetResult(result:Number):void
			{			
				popupPrint.report.printAcceptDate = ApplicationFacade.getNow();
				
				popupPrint.textPrintDate.text = popupPrint.report.PrintDate;
				
				popupPrint.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{
			if(!popupPrint.attach.identifyDraft && !popupPrint.attach.modifyImage)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'鉴定意见书（初稿）'和'成型照片（初稿）'均未上传，是否提交初审？",closeHandle,Alert.YES | Alert.NO]);	
			}		
			else if(!popupPrint.attach.identifyDraft)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["鉴定意见书（初稿）未上传，是否提交初审？",closeHandle,Alert.YES | Alert.NO]);				
			}
			else if(!popupPrint.attach.modifyImage)
			{				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["成型照片未上传，是否提交初审？",closeHandle,Alert.YES | Alert.NO]);	
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 打印日期 = #" + ApplicationFacade.NOW + "#" +
							",案件状态 = " + ReportStatusDict.getItem("初审").id +
							"  WHERE ID = " + popupPrint.report.id]
					]);
			}
			
			function closeHandle(event:CloseEvent):void
			{
				if(event.detail == Alert.YES)
				{					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["SetTable",onSetResult
							,["UPDATE 报告信息 SET 打印日期 = #" + ApplicationFacade.NOW + "#" +
								",案件状态 = " + ReportStatusDict.getItem("初审").id +
								"  WHERE ID = " + popupPrint.report.id]
						]);
				}
			}
			
			function onSetResult(result:Number):void
			{							
				attachProxy.save(popupPrint.report);	
				
				popupPrint.report.printDate = ApplicationFacade.getNow();
				
				popupPrint.report.reportStatus = ReportStatusDict.getItem("初审").id;
				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupPrint.report.FullNO + "》打印完毕。");	
			}
		}
		
		private function onUploadDraft(event:Event):void
		{
			attachProxy.uploadFile(popupPrint.report,"鉴定意见书（初稿）");
		}
		
		private function onDownloadDraft(event:Event):void
		{
			attachProxy.downloadFile(popupPrint.report,"鉴定意见书（初稿）");
		}
				
		private function onUploadPhoto(event:Event):void
		{
			attachProxy.uploadFile(popupPrint.report,"成型照片（初稿）");
		}
		
		private function onDownloadPhoto(event:Event):void
		{
			attachProxy.downloadFile(popupPrint.report,"成型照片（初稿）");
		}
		
		private function onUploadAttach(event:AppEvent):void
		{
			attachProxy.uploadImage();
		}
		
		private function onDeleteAttach(event:AppEvent):void
		{
			attachProxy.deleteImage(event.data);
		}
		
		private function onNaviImage(event:AppEvent):void
		{						
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
					if(notification.getBody()[0] == popupPrint)
					{
						popupPrint.report = notification.getBody()[1] as ReportVO;
						
						attachProxy.refresh(popupPrint.report,AttachProxy.IMAGE);
						
						if(loginProxy.checkReport(popupPrint.report)
							&& (popupPrint.report.ReportStatus.label == "打印"))
						{
							if (popupPrint.report.PrintDate == "待打印")
								popupPrint.currentState = "ACCEPT";
							else
								popupPrint.currentState = "EDIT";
						}
						else
						{
							popupPrint.currentState = "VIEW";
						}
						
						popupPrint.attach = attachProxy.attach;	
					}
					break;
			}
		}
	}
}