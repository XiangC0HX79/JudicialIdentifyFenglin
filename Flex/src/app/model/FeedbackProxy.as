package app.model
{
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.vo.FeedbackAttachVO;
	import app.model.vo.FeedbackVO;
	import app.model.vo.ReportVO;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class FeedbackProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "FeedbackProxy";
		
		public function FeedbackProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
	/*	public function get feedback():FeedbackVO
		{
			return data as FeedbackVO;
		}*/
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function refresh(report:ReportVO,handleFunction:Function):void
		{
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,[
						"SELECT * FROM 跟踪反馈 WHERE 报告ID = " + report.id
					]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				list.removeAll();
								
				for each(var item:Object in result)
				{
					var feedback:FeedbackVO = new FeedbackVO(item);
					feedback.report = report;
					list.addItem(feedback);
				}
				
				handleFunction();
			}
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
			
			sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
		}	
		
		public function uploadAttach(feedback:FeedbackVO):void
		{						
			var attach:FeedbackAttachVO = new FeedbackAttachVO;
			
			var fileRef:FileReference = new FileReference;
			fileRef.addEventListener(Event.SELECT,onFileSelect);	
			fileRef.addEventListener(Event.COMPLETE,onFileLoad); 
			
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			fileRef.browse([]);
			
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在上传附件...");
				
				fileRef.load(); 
			}
			
			function onFileLoad(e:Event):void   
			{   				
				attach.fileName = fileRef.name;
				attach.byteArray = fileRef.data;
				
				feedback.listAttach.addItemAt(attach,feedback.listAttach.length - 1);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
			}
		}
		
		private function upload(no:Number,reportNo:String,fileName:String,requestData:Object):void
		{
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在上传文件...");
			
			var url:String =  WebServiceCommand.WSDL + "UploadFeedback.aspx";
			url += "?no=" + no;
			url += "&reportNo=" + reportNo;
			url += "&fileName=" + fileName;	
			
			var request:URLRequest = new URLRequest(encodeURI(url));	
			request.method = URLRequestMethod.POST;
			request.contentType = "application/octet-stream";		
			request.data = requestData;	
			
			var urlLoader:URLLoader = new URLLoader();	
			urlLoader.addEventListener(Event.COMPLETE, onUpload);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			urlLoader.load(request);
			
			function onUpload(event:Event):void
			{	
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
			}
		}
		
		public function save(feedback:FeedbackVO):void
		{
			for each(var attach:FeedbackAttachVO in feedback.listAttach)
			{
				if(attach != null)			
				{				
					upload(feedback.no,feedback.report.FullNO,attach.fileName,attach.byteArray);
				}
			}			
		}
		
		public function downloadAttach(feedback:FeedbackVO,feedbackAttach:FeedbackAttachVO):void
		{
			var url:String =  WebServiceCommand.WSDL + "DownloadFeedback.aspx";
			url += "?no=" + feedback.no;
			url += "&reportNo=" + feedback.report.FullNO;
			url += "&fileName=" + feedbackAttach.fileName;	
			
			var downloadURL:URLRequest = new URLRequest(encodeURI(url));
			
			var fileRef:FileReference = new FileReference;
			fileRef.addEventListener(Event.SELECT,onFileSelect);				
			fileRef.addEventListener(Event.COMPLETE,onDownloadFile);
			
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			fileRef.download(downloadURL,feedbackAttach.fileName);	
			
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在下载《 "+ feedbackAttach.fileName + "》...");				
			}
			
			function onDownloadFile(event:Event):void 
			{							
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"《 "+ feedbackAttach.fileName + "》下载成功。");	
			}	
		}
	}
}