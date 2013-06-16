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
	import app.view.components.PopupFirstExamine;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupFirstExamineMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupFirstExamineMediator";
		
		private var loginProxy:LoginProxy;
		private var userProxy:UserProxy;
		private var attachProxy:AttachProxy;
		private var reportProxy:ReportProxy;
		
		public function PopupFirstExamineMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupFirstExamine.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupFirstExamine.addEventListener(PopupFirstExamine.CLOSE,onClose);
			popupFirstExamine.addEventListener(PopupFirstExamine.PREVIOUS,onPrevious);
			popupFirstExamine.addEventListener(PopupFirstExamine.ACCEPT,onAccept);
			popupFirstExamine.addEventListener(PopupFirstExamine.SUBMIT,onSubmit);
			popupFirstExamine.addEventListener(PopupFirstExamine.BACK,onBack);
			
			popupFirstExamine.addEventListener(PopupFirstExamine.DOWNLOADDRAFT,onDownloadDraft);	
			popupFirstExamine.addEventListener(PopupFirstExamine.UPLOADDRAFT,onUploadDraft);
			
			popupFirstExamine.addEventListener(PopupFirstExamine.UPLOADPHOTO,onUploadPhoto);
			popupFirstExamine.addEventListener(PopupFirstExamine.DOWNLOADPHOTO,onDownloadPhoto);	
			
			popupFirstExamine.addEventListener(AppEvent.NAVIATTACH,onNaviImage);		
			
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			userProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
			attachProxy = facade.retrieveProxy(AttachProxy.NAME) as AttachProxy;
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
		}
		
		protected function get popupFirstExamine():PopupFirstExamine
		{
			return viewComponent as PopupFirstExamine;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupFirstExamine.maxHeight = popupFirstExamine.height;
			
			popupFirstExamine.gridRank.selectedIndex = (popupFirstExamine.report.firstExamineRank == -1)?9:popupFirstExamine.report.firstExamineRank;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
				
		private function onPrevious(event:Event):void
		{						
			popupFirstExamine.report.printDate = null;
			popupFirstExamine.report.firstExamineAcceptDate = null;
			popupFirstExamine.report.reportStatus = ReportStatusDict.getItem("打印").id;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 打印日期 = NULL,初审接受日期 =NULL" +
						",案件状态 = " + popupFirstExamine.report.reportStatus +
						"  WHERE ID = " + popupFirstExamine.report.id]
				]);
			
			function onSetResult(result:Number):void
			{			
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
			}
		}
		
		private function onBack(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupFirstExamine.report,true]);	
		}
				
		private function onAccept(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 初审接受日期 = #" + ApplicationFacade.NOW + "#" +
						",初审人 = " + loginProxy.loginUser.id +
						" WHERE ID = " + popupFirstExamine.report.id]
				]);
			
			function onSetResult(result:Number):void
			{			
				reportProxy.refreshReport(popupFirstExamine.report,resultHandle);
			}
			
			function resultHandle():void
			{
				popupFirstExamine.textPrintDate.text = popupFirstExamine.report.FirstExamineDate;
				
				popupFirstExamine.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{			
			if(popupFirstExamine.gridRank.selectedIndex == -1)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请选择初稿评分。");	
			}
			else if(!popupFirstExamine.attach.identifyFstExamin && !popupFirstExamine.attach.modifyFstExamin)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'鉴定意见书（初审）'和'成型照片（初审）'均未上传，是否提交复核？",closeHandle,Alert.YES | Alert.NO]);	
			}
			else if(!popupFirstExamine.attach.identifyFstExamin)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'鉴定意见书（初审）'未上传，是否提交复核？",closeHandle,Alert.YES | Alert.NO]);	
			}
			else if(!popupFirstExamine.attach.modifyFstExamin)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'成型照片（初审）'未上传，是否提交复核？",closeHandle,Alert.YES | Alert.NO]);	
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 初审日期 = #" + ApplicationFacade.NOW + "#"
							+ ",案件状态 = " + ReportStatusDict.getItem("复审").id 
							+ ",初审分数 = " + popupFirstExamine.gridRank.selectedIndex
							+ "  WHERE ID = " + popupFirstExamine.report.id]
					]);
			}
			
			function closeHandle(event:CloseEvent):void
			{
				if(event.detail == Alert.YES)
				{					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["CopyFstExamin",onCopyResult,[popupFirstExamine.report.FullNO]
						]);
				}
			}
			
			function onCopyResult(result:String):void
			{			
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 初审日期 = #" + ApplicationFacade.NOW + "#"
							+ ",案件状态 = " + ReportStatusDict.getItem("复审").id 
							+ ",初审分数 = " + popupFirstExamine.gridRank.selectedIndex
							+ "  WHERE ID = " + popupFirstExamine.report.id]
					]);
			}
						
			function onSetResult(result:Number):void
			{			
				reportProxy.refreshReport(popupFirstExamine.report,resultHandle);
			}
			
			function resultHandle():void
			{										
					sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
					
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupFirstExamine.report.FullNO + "》初审完毕。");	
			}
		}
		
		private function onDownloadDraft(event:Event):void
		{
			if(popupFirstExamine.attach.identifyFstExamin)
				attachProxy.downloadFile(popupFirstExamine.report,"鉴定意见书（初审）");
			else
				attachProxy.downloadFile(popupFirstExamine.report,"鉴定意见书（初稿）");
		}
		
		private function onUploadDraft(event:Event):void
		{
			attachProxy.uploadFile(popupFirstExamine.report,"鉴定意见书（初审）");
		}
				
		private function onDownloadPhoto(event:Event):void
		{
			if(popupFirstExamine.attach.modifyFstExamin)
				attachProxy.downloadFile(popupFirstExamine.report,"成型照片（初审）");
			else
				attachProxy.downloadFile(popupFirstExamine.report,"成型照片（初稿）");
		}
		
		private function onUploadPhoto(event:Event):void
		{
			attachProxy.uploadFile(popupFirstExamine.report,"成型照片（初审）");
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
					if(notification.getBody()[0] == popupFirstExamine)
					{
						popupFirstExamine.report = notification.getBody()[1] as ReportVO;
						
						attachProxy.refresh(popupFirstExamine.report,AttachProxy.IMAGE);
						
						if(loginProxy.checkReport(popupFirstExamine.report)
							&& (popupFirstExamine.report.ReportStatus.label == "初审"))
						{
							if (popupFirstExamine.report.FirstExamineDate == "待初审")
								popupFirstExamine.currentState = "ACCEPT";
							else
								popupFirstExamine.currentState = "EDIT";
						}
						else
						{
							popupFirstExamine.currentState = "VIEW";
						}
						
						popupFirstExamine.attach = attachProxy.attach;	
						
						if(popupFirstExamine.initialized)
						{
							popupFirstExamine.gridRank.selectedIndex = (popupFirstExamine.report.firstExamineRank == -1)?9:popupFirstExamine.report.firstExamineRank;
						}
						
						if (popupFirstExamine.report.FirstExamineDate == "待初审")
							popupFirstExamine.btnPrevious.enabled = (loginProxy.loginUser.id == popupFirstExamine.report.printer) || loginProxy.checkReport(popupFirstExamine.report);
						else if (popupFirstExamine.report.FirstExamineDate == "正在初审")
							popupFirstExamine.btnPrevious.enabled = (loginProxy.loginUser.id == popupFirstExamine.report.firstExaminer);
						else
							popupFirstExamine.btnPrevious.enabled = false;
					}
					break;
			}
		}
	}
}