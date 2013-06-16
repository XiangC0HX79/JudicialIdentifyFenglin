package app.view
{
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.ReportVO;
	import app.view.components.PopupFile;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupFileMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupFileMediator";
		
		private var loginProxy:LoginProxy;
		private var reportProxy:ReportProxy;
		
		public function PopupFileMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupFile.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupFile.addEventListener(PopupFile.ACCEPT,onAccept);
			popupFile.addEventListener(PopupFile.SUBMIT,onSubmit);
			popupFile.addEventListener(PopupFile.BACK,onBack);
			
			popupFile.addEventListener(PopupFile.DOWNLOAD,onDownload);
			popupFile.addEventListener(PopupFile.CLOSE,onClose);
			
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
		}
		
		protected function get popupFile():PopupFile
		{
			return viewComponent as PopupFile;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupFile.maxHeight = popupFile.height;
			
			init();
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function init():void
		{
			popupFile.btnDownload.enabled = (popupFile.report.fileDate != null);
		}
		
		private function onDownload(event:Event):void
		{			
			var defaultName:String = popupFile.report.FullNO + " " + popupFile.report.checkedPeople + ".zip";
				
			var url:String =  WebServiceCommand.WSDL + "DownloadFile.aspx";
			url += "?year=" + popupFile.report.year 
				+ "&type=" + popupFile.report.type 
				+ "&reprortNo=" + popupFile.report.no 
				+ "&group=" + popupFile.report.Group.id;
			
			var downloadURL:URLRequest = new URLRequest(encodeURI(url));
			//var downloadURL:URLRequest = new URLRequest(url);
			
			var fileRef:FileReference = new FileReference;
			fileRef.addEventListener(Event.SELECT,onFileSelect);				
			fileRef.addEventListener(Event.COMPLETE,onDownloadFile);
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			fileRef.download(downloadURL,defaultName);
						
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在下载《 "+ defaultName + "》...");				
			}
			
			function onDownloadFile(event:Event):void 
			{							
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"《 "+ defaultName + "》下载成功。");	
			}	
			
			function onIOError(event:IOErrorEvent):void
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
			}	
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onBack(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),popupFile.report,true]);	
		}
				
		private function onAccept(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["UPDATE 报告信息 SET 归档接受日期 = #" + ApplicationFacade.NOW + "#" +
						",归档人 = " + loginProxy.loginUser.id +
						" WHERE ID = " + popupFile.report.id]
				]);
			
			function onSetResult(result:Number):void
			{				
				reportProxy.refreshReport(popupFile.report,resultHandle);
			}
			
			function resultHandle():void
			{			
				popupFile.currentState = "EDIT";
			}
		}
		
		private function onSubmit(event:Event):void
		{									
			var sql:String = "UPDATE 报告信息 SET " 
				+ "归档日期  = #" + ApplicationFacade.NOW + "#" 
				+ ",反馈意见  = '" + popupFile.textReson.text + "'";
			
			if(popupFile.report.sendGetDate != null)
				sql += ",案件状态 = " + ReportStatusDict.getItem("完成").id;	
			
			sql += "  WHERE ID = " + popupFile.report.id;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,[sql]
				]);
			
			function onSetResult(result:Number):void
			{			
				reportProxy.refreshReport(popupFile.report,resultHandle);
			}
			
			function resultHandle():void
			{					
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupFile.report.FullNO + "》归档完毕。");
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
					if(notification.getBody()[0] == popupFile)
					{
						popupFile.report = notification.getBody()[1] as ReportVO;
												
						if(loginProxy.checkReport(popupFile.report)
							&& (popupFile.report.fileDate == null))
						{
							if (popupFile.report.FileDate == "待归档")
								popupFile.currentState = "ACCEPT";
							else if(popupFile.report.filer == loginProxy.loginUser.id)
								popupFile.currentState = "EDIT";
							else
								popupFile.currentState = "VIEW";
						}
						else
						{
							popupFile.currentState = "VIEW";
						}
						
						if(popupFile.initialized)
							init();
					}
					break;
			}
		}
	}
}