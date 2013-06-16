package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.model.AttachProxy;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.FileVO;
	import app.model.vo.ReportVO;
	import app.model.vo.UserVO;
	import app.view.components.PopupRevision;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupRevisionMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupRevisionMediator";
		
		private var userProxy:UserProxy;
		private var attachProxy:AttachProxy;
		private var reportProxy:ReportProxy;
		
		public function PopupRevisionMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupRevision.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupRevision.addEventListener(PopupRevision.PREVIOUS,onPrevious);
			popupRevision.addEventListener(PopupRevision.CLOSE,onClose);
			popupRevision.addEventListener(PopupRevision.ACCEPT,onAccept);
			popupRevision.addEventListener(PopupRevision.SUBMIT,onSubmit);
			popupRevision.addEventListener(PopupRevision.BACK,onBack);
			
			popupRevision.addEventListener(PopupRevision.DOWNLOADDRAFT,onDownloadDraft);	
			popupRevision.addEventListener(PopupRevision.UPLOADDRAFT,onUploadDraft);
			
			popupRevision.addEventListener(PopupRevision.UPLOADPHOTO,onUploadPhoto);
			popupRevision.addEventListener(PopupRevision.DOWNLOADPHOTO,onDownloadPhoto);
			
			userProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
			attachProxy = facade.retrieveProxy(AttachProxy.NAME) as AttachProxy;
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
		}
		
		protected function get popupRevision():PopupRevision
		{
			return viewComponent as PopupRevision;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupRevision.maxHeight = popupRevision.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
				
		private function onPrevious(event:Event):void
		{						
			popupRevision.report.lastExamineDate = null;
			popupRevision.report.revisionAcceptDate = null
			popupRevision.report.lastExamineRank = -1;
			popupRevision.report.reportStatus = ReportStatusDict.getItem("复审").id;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 复审日期 = NULL,修订接受日期 =NULL,复审分数=-1" +
						",案件状态 = " + popupRevision.report.reportStatus +
						"  WHERE ID = " + popupRevision.report.id]
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
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupRevision.report,true]);	
		}
		
		private function onAccept(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 修订接受日期 = #" + ApplicationFacade.NOW + "#" +
						" WHERE ID = " + popupRevision.report.id]
				]);
			
			function onSetResult(result:Number):void
			{				
				reportProxy.refreshReport(popupRevision.report,resultHandle);
			}
			
			function resultHandle():void
			{				
				popupRevision.textPrintDate.text = popupRevision.report.RevisionDate;
				popupRevision.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{			
			if(!popupRevision.attach.identifySndExamin && !popupRevision.attach.identifyFinal)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,'请先上传《鉴定意见书》！');
				return;
			}
				
			if(!popupRevision.attach.identifyFinal && !popupRevision.attach.modifyFinal)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'鉴定意见书（终稿）'和'成型照片（终稿）'均未上传，是否提交装订？",closeHandle,Alert.YES | Alert.NO]);	
			}	
			else if(!popupRevision.attach.identifyFinal)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'鉴定意见书（终稿）'未上传，是否提交装订？",closeHandle,Alert.YES | Alert.NO]);	
			}	
			else if(!popupRevision.attach.modifyFinal)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,["'成型照片（终稿）'未上传，是否提交装订？",closeHandle,Alert.YES | Alert.NO]);	
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 修订日期 = #" + ApplicationFacade.NOW + "#"
							+ ",案件状态 = " + ReportStatusDict.getItem("装订").id
							+ "  WHERE ID = " + popupRevision.report.id]
					]);
			}
			
			function closeHandle(event:CloseEvent):void
			{
				if(event.detail == Alert.YES)
				{					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["CopyFinal",onCopyResult,[popupRevision.report.FullNO]
						]);
				}
			}
			
			function onCopyResult(result:String):void
			{			
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 修订日期 = #" + ApplicationFacade.NOW + "#"
							+ ",案件状态 = " + ReportStatusDict.getItem("装订").id
							+ "  WHERE ID = " + popupRevision.report.id]
					]);
			}
			
			function onSetResult(result:Number):void
			{				
				reportProxy.refreshReport(popupRevision.report,resultHandle);
			}
			
			function resultHandle():void
			{				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupRevision.report.FullNO + "》修订完毕。");	
			}
		}
		
		private function onDownloadDraft(event:Event):void
		{
			if(popupRevision.attach.identifyFinal)
				attachProxy.downloadFile(popupRevision.report,"鉴定意见书");
			else
				attachProxy.downloadFile(popupRevision.report,"鉴定意见书（复审）");
		}
		
		private function onUploadDraft(event:Event):void
		{
			attachProxy.uploadFile(popupRevision.report,"鉴定意见书");
		}
		
		private function onDownloadPhoto(event:Event):void
		{
			if(popupRevision.attach.modifyFinal)
				attachProxy.downloadFile(popupRevision.report,"成型照片");
			else
				attachProxy.downloadFile(popupRevision.report,"成型照片（复审）");
		}
		
		private function onUploadPhoto(event:Event):void
		{
			attachProxy.uploadFile(popupRevision.report,"成型照片");
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
					if(notification.getBody()[0] == popupRevision)
					{
						popupRevision.report = notification.getBody()[1] as ReportVO;
						
						attachProxy.refresh(popupRevision.report);
						
						var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
						if(loginProxy.checkReport(popupRevision.report)
							&& (popupRevision.report.ReportStatus.label == "修订"))
						{
							if (popupRevision.report.RevisionDate == "待修订")
								popupRevision.currentState = "ACCEPT";
							else
								popupRevision.currentState = "EDIT";
						}
						else
						{
							popupRevision.currentState = "VIEW";
						}
						
						if (popupRevision.report.RevisionDate == "待修订")
							popupRevision.btnPrevious.enabled = (loginProxy.loginUser.id == popupRevision.report.printer) || (loginProxy.loginUser.id == popupRevision.report.lastExaminer);
						else if (popupRevision.report.RevisionDate == "正在修订")
							popupRevision.btnPrevious.enabled = (loginProxy.loginUser.id == popupRevision.report.printer);
						else
							popupRevision.btnPrevious.enabled = false;
						
						popupRevision.attach = attachProxy.attach;
					}
					break;			
			}
		}
	}
}