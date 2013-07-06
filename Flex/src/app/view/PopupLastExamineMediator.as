package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.model.AttachProxy;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.ReportVO;
	import app.view.components.PopupLastExamine;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupLastExamineMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupLastExamineMediator";
		
		private var loginProxy:LoginProxy;
		private var attachProxy:AttachProxy;
		private var reportProxy:ReportProxy;
		
		public function PopupLastExamineMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupLastExamine.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupLastExamine.addEventListener(PopupLastExamine.PREVIOUS,onPrevious);
			popupLastExamine.addEventListener(PopupLastExamine.CLOSE,onClose);
			popupLastExamine.addEventListener(PopupLastExamine.ACCEPT,onAccept);
			popupLastExamine.addEventListener(PopupLastExamine.SUBMIT,onSubmit);
			popupLastExamine.addEventListener(PopupLastExamine.BACK,onBack);
			
			popupLastExamine.addEventListener(PopupLastExamine.DOWNLOADDRAFT,onDownloadDraft);	
			popupLastExamine.addEventListener(PopupLastExamine.UPLOADDRAFT,onUploadDraft);
			
			popupLastExamine.addEventListener(PopupLastExamine.UPLOADPHOTO,onUploadPhoto);
			popupLastExamine.addEventListener(PopupLastExamine.DOWNLOADPHOTO,onDownloadPhoto);	
			
			popupLastExamine.addEventListener(AppEvent.NAVIATTACH,onNaviImage);	
			
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			attachProxy = facade.retrieveProxy(AttachProxy.NAME) as AttachProxy;
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
		}
		
		protected function get popupLastExamine():PopupLastExamine
		{
			return viewComponent as PopupLastExamine;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupLastExamine.maxHeight = popupLastExamine.height;
			
			popupLastExamine.gridRank.selectedIndex = (popupLastExamine.report.lastExamineRank == -1)?9:popupLastExamine.report.lastExamineRank;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function onPrevious(event:Event):void
		{						
			popupLastExamine.report.firstExamineDate = null;
			popupLastExamine.report.lastExamineAcceptDate = null
			popupLastExamine.report.firstExamineRank = -1;;
			popupLastExamine.report.reportStatus = ReportStatusDict.getItem("初审").id;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 初审日期 = NULL,复审接受日期 = NULL,初审分数=-1" +
						",案件状态 = " + popupLastExamine.report.reportStatus +
						"  WHERE ID = " + popupLastExamine.report.id]
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
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupLastExamine.report,true]);	
		}
				
		private function onAccept(event:Event):void
		{						
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET " +
						"复审接受日期 = #" + ApplicationFacade.NOW +
						"#,复审人 = " + loginProxy.loginUser.id +
						" WHERE ID = " + popupLastExamine.report.id]
				]);
			
			function onSetResult(result:Number):void
			{				
				reportProxy.refreshReport(popupLastExamine.report,resultHandle);
			}
			
			function resultHandle():void
			{
				popupLastExamine.textPrintDate.text = popupLastExamine.report.LastExamineDate;
				
				popupLastExamine.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{			
			if(popupLastExamine.gridRank.selectedIndex == -1)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请选择受理人C评分。");	
			}
			else if(!popupLastExamine.attach.identifySndExamin && !popupLastExamine.attach.modifySndExamin)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'鉴定意见书（复审）'和'成型照片（复审）'均未上传，是否提交修订？",closeHandle,Alert.YES | Alert.NO]);	
			}
			else if(!popupLastExamine.attach.identifySndExamin)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'鉴定意见书（复审）'未上传，是否提交修订？",closeHandle,Alert.YES | Alert.NO]);	
			}
			else if(!popupLastExamine.attach.modifySndExamin)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'成型照片（复审）'未上传，是否提交修订？",closeHandle,Alert.YES | Alert.NO]);	
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 复审日期 = #" + ApplicationFacade.NOW + "#"
							+ ",案件状态 = " + ReportStatusDict.getItem("修订").id
							+ ",复审分数 = " + popupLastExamine.gridRank.selectedIndex
							+ "  WHERE ID = " + popupLastExamine.report.id]
					]);
			}
			
			function closeHandle(event:CloseEvent):void
			{
				if(event.detail == Alert.YES)
				{					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["CopySndExamin",onCopyResult,[popupLastExamine.report.FullNO]
						]);
				}
			}
			
			function onCopyResult(result:String):void
			{			
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 复审日期 = #" + ApplicationFacade.NOW + "#"
							+ ",案件状态 = " + ReportStatusDict.getItem("修订").id
							+ ",复审分数 = " + popupLastExamine.gridRank.selectedIndex
							+ "  WHERE ID = " + popupLastExamine.report.id]
					]);
			}
			
			function onSetResult(result:Number):void
			{								
				reportProxy.refreshReport(popupLastExamine.report,resultHandle);
			}
			
			function resultHandle():void
			{										
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
								
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupLastExamine.report.FullNO + "》复核完毕。");	
			}
		}
		
		private function onDownloadDraft(event:Event):void
		{
			if(popupLastExamine.attach.identifySndExamin)
				attachProxy.downloadFile(popupLastExamine.report,"鉴定意见书（复审）");
			else
				attachProxy.downloadFile(popupLastExamine.report,"鉴定意见书（初审）");
		}
		
		private function onUploadDraft(event:Event):void
		{
			attachProxy.uploadFile(popupLastExamine.report,"鉴定意见书（复审）");
		}
		
		private function onDownloadPhoto(event:Event):void
		{
			if(popupLastExamine.attach.modifySndExamin)
				attachProxy.downloadFile(popupLastExamine.report,"成型照片（复审）");
			else
				attachProxy.downloadFile(popupLastExamine.report,"成型照片（初审）");
		}
		
		private function onUploadPhoto(event:Event):void
		{
			attachProxy.uploadFile(popupLastExamine.report,"成型照片（复审）");
		}
				
		private function onNaviImage(event:AppEvent):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupNaviImageMediator.NAME).getViewComponent(),popupLastExamine.report,popupLastExamine.attach.listImage,event.data]);	
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
					if(notification.getBody()[0] == popupLastExamine)
					{
						popupLastExamine.report = notification.getBody()[1] as ReportVO;
						
						attachProxy.refresh(popupLastExamine.report,AttachProxy.IMAGE);
						
						if(loginProxy.checkReport(popupLastExamine.report)
							&& (popupLastExamine.report.ReportStatus.label == "复审"))
						{
							if (popupLastExamine.report.LastExamineDate == "待复核")
								popupLastExamine.currentState = "ACCEPT";
							else
								popupLastExamine.currentState = "EDIT";
						}
						else
						{
							popupLastExamine.currentState = "VIEW";
						}
												
						popupLastExamine.attach = attachProxy.attach;
						
						if(popupLastExamine.initialized)
						{
							popupLastExamine.gridRank.selectedIndex = (popupLastExamine.report.lastExamineRank == -1)?9:popupLastExamine.report.lastExamineRank;
						}
						
						if (popupLastExamine.report.LastExamineDate == "待复核")
							popupLastExamine.btnPrevious.enabled = (loginProxy.loginUser.id == popupLastExamine.report.firstExaminer) || loginProxy.checkReport(popupLastExamine.report);
						else if (popupLastExamine.report.LastExamineDate == "正在复核")
							popupLastExamine.btnPrevious.enabled = (loginProxy.loginUser.id == popupLastExamine.report.lastExaminer);
						else
							popupLastExamine.btnPrevious.enabled = false;
					}
					break;
			}
		}
	}
}