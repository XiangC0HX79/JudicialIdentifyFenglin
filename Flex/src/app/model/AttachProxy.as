package app.model
{
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.vo.AttachImageVO;
	import app.model.vo.AttachVO;
	import app.model.vo.ReportVO;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.graphics.codec.JPEGEncoder;
	import mx.messaging.AbstractConsumer;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class AttachProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "AttachProxy";
		
		public static const NONE:String = "none";
		public static const IMAGE:String = "image";
		public static const CONSULTIMAGE:String = "consultimage";
		
		public function AttachProxy()
		{
			super(NAME, new AttachVO);
		}
		
		public function get attach():AttachVO
		{
			return data as AttachVO;
		}
		
		public function refresh(report:ReportVO,type:String = NONE,jurisdiction:Boolean = false):void
		{	
			attach.listImage.removeAll();	
			attach.listConsultImage.removeAll();
			attach.consultResult = false;
			attach.identifyDraft = false;
			attach.identifyFstExamin = false;
			attach.identifySndExamin = false;
			attach.identifyFinal = false;
			attach.modifyImage = false;
			attach.modifyFstExamin = false;
			attach.modifySndExamin = false;
			attach.modifyFinal = false;
			
			if(report.id > 0)
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetAttachInfo",onGetAttachInfoResult
						,[report.FullNO]
					]);
			}				
			else
			{
				attach.listImage.addItem(null);
			}
			
			function onGetAttachInfoResult(result:ArrayCollection):void
			{								
				for each(var item:Object in result)
				{
					var fileName:String = item.FileName.substr(0,item.FileName.indexOf('.'));
					var fileType:String = item.FileName.substr(item.FileName.indexOf('.'),item.FileName.length);
					
					if(fileName == "鉴定意见书（初稿）")
					{
						attach.identifyDraft = true;
					}
					else if(fileName == "鉴定意见书（初审）")
					{
						attach.identifyFstExamin = true;
					}
					else if(fileName == "鉴定意见书（复审）")
					{
						attach.identifySndExamin = true;
					}
					else if(fileName == "鉴定意见书")
					{
						attach.identifyFinal = true;
					}
					else if(fileName == "成型照片（初稿）")
					{
						attach.modifyImage = true;
					}
					else if(fileName == "成型照片（初审）")
					{
						attach.modifyFstExamin = true;
					}
					else if(fileName == "成型照片（复审）")
					{
						attach.modifySndExamin = true;
					}
					else if(fileName == "成型照片")
					{
						attach.modifyFinal = true;
					}
					else if(fileName == "会诊结果")
					{
						attach.consultResult = true;
					}
					else if(fileName.indexOf("初步照片") ==0)
					{
						var attachImage:AttachImageVO = new AttachImageVO;	
						attachImage.bitmapName = item.FileName;		
						
						attach.listImage.addItem(attachImage);						
					}
					else if(fileName.indexOf("会诊照片") ==0)
					{
						attachImage = new AttachImageVO;		
						attachImage.bitmapName = item.FileName;		
						
						attach.listConsultImage.addItem(attachImage);				
					}
				}
				
				if(jurisdiction)
					attach.listImage.addItem(null);
				
				if(report.ReportStatus.label == "会诊")
					attach.listConsultImage.addItem(null);
				
				if(type == IMAGE)
					downloadImageList(report.FullNO,attach.listImage);				
				else if(type == CONSULTIMAGE)
					downloadImageList(report.FullNO,attach.listConsultImage);
			}
		}
				
		private function onIOError(event:IOErrorEvent):void
		{
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
			
			sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
		}	
		
		private function upload(reportNo:String,fileName:String,requestData:ByteArray):void
		{
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在上传文件...");
						
			var pageLength:Number = 1024 * 1024;
			var pageNumber:Number = Math.ceil(requestData.length / pageLength);
						
			var pageIndex:Number = 0;
			
			var url:String =  WebServiceCommand.WSDL + "Upload.aspx";
			url += "?reportNo=" + reportNo;
			url += "&fileName=" + fileName;	
			url += "&pageIndex=" + pageIndex;	
			
			var data:ByteArray = new ByteArray;				
			if(pageIndex < pageNumber - 1)
				data.writeBytes(requestData,pageIndex * pageLength,pageLength);
			else
				data.writeBytes(requestData,pageIndex * pageLength,requestData.length - (pageNumber - 1) * pageLength);
			
			var request:URLRequest = new URLRequest(encodeURI(url));	
			request.method = URLRequestMethod.POST;
			request.contentType = "application/octet-stream";		
			request.data = data;	
			
			var urlLoader:URLLoader = new URLLoader();	
			urlLoader.addEventListener(Event.COMPLETE, onUpload);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			urlLoader.load(request);
									
			function onUpload(event:Event):void
			{	
				pageIndex ++;
				
				if(pageIndex == pageNumber)
					sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				else
				{
					var url:String =  WebServiceCommand.WSDL + "Upload.aspx";
					url += "?reportNo=" + reportNo;
					url += "&fileName=" + fileName;	
					url += "&pageIndex=" + pageIndex;	
					
					var data:ByteArray = new ByteArray;				
					if(pageIndex < pageNumber - 1)
						data.writeBytes(requestData,pageIndex * pageLength,pageLength);
					else
						data.writeBytes(requestData,pageIndex * pageLength,requestData.length - (pageNumber - 1) * pageLength);
					
					var request:URLRequest = new URLRequest(encodeURI(url));	
					request.method = URLRequestMethod.POST;
					request.contentType = "application/octet-stream";		
					request.data = data;
					
					urlLoader.load(request);
				}
			}
		}
				
		private function downloadImageList(reportNo:String,listImage:ArrayCollection):void
		{			
			var imageIndex:Number = 0;
			
			if(listImage.length == 0)
				return;
			
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在下载照片...");
									
			downloadImage();
			
			function downloadImage():void
			{
				var attachImage:AttachImageVO = listImage[imageIndex] as AttachImageVO;
				if(attachImage != null)
				{
					var url:String =  WebServiceCommand.WSDL + "DownloadThumbnail.aspx";
					url += "?reportNo=" + reportNo;
					url += "&fileName=" + attachImage.bitmapName;
					url += "&w=100";
					url += "&h=100";
										
					var downloadURL:URLRequest = new URLRequest(encodeURI(url));	
					downloadURL.method = URLRequestMethod.POST;
										
					var urlLoader:URLLoader = new URLLoader;
					urlLoader.addEventListener(Event.COMPLETE,completeHandler);
					urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);					
					urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					urlLoader.load(downloadURL);
				}
				else
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				}
			}
									
			function completeHandler(event:Event):void   
			{   								
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCompleteHandler);   
				loader.loadBytes(event.currentTarget.data);
				
				var attachImage:AttachImageVO = listImage[imageIndex] as AttachImageVO;
				attachImage.bitmapArray = event.currentTarget.data;
			}
			
			function loaderCompleteHandler(event:Event):void
			{							
				var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
				var bitmap:Bitmap = Bitmap(loaderInfo.content);  
				
				var attachImage:AttachImageVO = listImage[imageIndex] as AttachImageVO;			
				attachImage.bitmapData = bitmap.bitmapData;
								
				var scale:Number = (bitmap.width / bitmap.height);
				var scale_width:Number = (scale > 1)?100:(scale * 100);
				var scale_height:Number = (scale > 1)?(100 / scale):100;				
				attachImage.facBitmapData = new BitmapData (scale_width, scale_height);
				
				var scale_W:Number = scale_width / bitmap.width;
				var matrix:Matrix = new Matrix(scale_W,0,0,scale_W,0,0);
				attachImage.facBitmapData.draw(bitmap.bitmapData,matrix);	
				
				var jpegEncoder:JPEGEncoder = new JPEGEncoder;
				attachImage.facBitmapArray = jpegEncoder.encode(attachImage.facBitmapData);
				
				imageIndex ++;				
				if(imageIndex < listImage.length)
				{								
					downloadImage();
				}
				else
				{			
					sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
				}				 
			}   
		}
		
		public function downloadFile(report:ReportVO,fileName:String):void
		{			
			var url:String =  WebServiceCommand.WSDL + "Download.aspx";
			url += "?reportNo=" + report.FullNO;
			url += "&fileName=" + fileName + ".doc";	
			
			var downloadURL:URLRequest = new URLRequest(encodeURI(url));
						
			var fileRef:FileReference = new FileReference;
			fileRef.addEventListener(Event.SELECT,onFileSelect);				
			fileRef.addEventListener(Event.COMPLETE,onDownloadFile);
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			var index:Number = fileName.indexOf("（");
			var defaultName:String = (index == -1)?fileName:fileName.substr(0,index);
			fileRef.download(downloadURL,report.FullNO + " " + report.checkedPeople + " " + defaultName + ".doc");	
			
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在下载《 "+ defaultName + "》...");				
			}
			
			function onDownloadFile(event:Event):void 
			{							
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"《 "+ defaultName + "》下载成功。");	
			}	
		}
				
		public function uploadImage():void
		{						
			var imageTypes:FileFilter = new FileFilter("图片 (*.jpg,*.bmp,*.png)", "*.jpg;*.jpeg;*.bmp;*.png");
			
			var fileRefList:FileReferenceList = new FileReferenceList();
			fileRefList.addEventListener(Event.SELECT,onFileSelect);							
			fileRefList.browse([imageTypes]);
			
			var fileIndex:Number = 0;
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在上传初步照片...");
				
				for each(var fileRef:FileReference in fileRefList.fileList)
				{
					fileRef.addEventListener(Event.COMPLETE,onFileLoad); 
					fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);		
				}
				
				fileRefList.fileList[0].load(); 
			}
			
			function onFileLoad(event:Event):void   
			{   		
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCompleteHandler);   
				loader.loadBytes(event.currentTarget.data);
			}
						
			function loaderCompleteHandler(event:Event):void
			{			
				var fileRef:FileReference = fileRefList.fileList[fileIndex] as FileReference;
				
				var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
				var bitmap:Bitmap = Bitmap(loaderInfo.content);  
				
				var attachImage:AttachImageVO = new AttachImageVO;	
				attachImage.bitmapName = fileRef.name;								
				attachImage.bitmapData = bitmap.bitmapData;
				attachImage.bitmapArray = fileRef.data;
				
				var scale:Number = (bitmap.width / bitmap.height);
				var scale_width:Number = (scale > 1)?100:(scale * 100);
				var scale_height:Number = (scale > 1)?(100 / scale):100;				
				attachImage.facBitmapData = new BitmapData (scale_width, scale_height);
				
				var scale_W:Number = scale_width / bitmap.width;
				var matrix:Matrix = new Matrix(scale_W,0,0,scale_W,0,0);
				attachImage.facBitmapData.draw(bitmap.bitmapData,matrix);	
				
				var jpegEncoder:JPEGEncoder = new JPEGEncoder;
				attachImage.facBitmapArray = jpegEncoder.encode(attachImage.facBitmapData);
				
				attach.listImage.addItemAt(attachImage,attach.listImage.length - 1);
				
				fileIndex ++;
				if(fileIndex < fileRefList.fileList.length)
				{			
					fileRefList.fileList[fileIndex].load();
				}
				else
				{				
					sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);						
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"照片上传成功。");
				}				 
			}
		}
				
		public function deleteImage(attachImage:AttachImageVO):void
		{
			attach.listImage.removeItemAt(attach.listImage.getItemIndex(attachImage));
		}
		
		public function save(report:ReportVO):void
		{
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["UploadImage",onSetResult
					,[
						report.FullNO
					]
				]);	
			
			function onSetResult(result:String):void
			{						
				for(var i:Number = 0;i<attach.listImage.length;i++)
				{
					var attachImage:AttachImageVO = attach.listImage[i] as AttachImageVO;
					if(attachImage != null)			
					{										
						upload(report.FullNO,"初步照片" + (i + 1) + attachImage.bitmapType,attachImage.bitmapArray);
					}
				}
			}
		}
		
		public function uploadFile(report:ReportVO,fileName:String):void
		{
			var fileRef:FileReference = new FileReference;
			fileRef.addEventListener(Event.SELECT,onFileSelect);	
			fileRef.addEventListener(Event.COMPLETE,onFileLoad); 
			
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			var imageTypes:FileFilter = new FileFilter("Word文档 (*.doc)", "*.doc");
			fileRef.browse([imageTypes]);
			
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在上传《 "+ fileName + "》...");
				
				var request:URLRequest = new URLRequest(WebServiceCommand.WSDL + "WordService.aspx");
				fileRef.load(); 
			}
			
			function onFileLoad(event:Event):void   
			{   		
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);
				
				var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
				
				upload(report.FullNO,fileName + ".doc",event.currentTarget.data);
				
				if(fileName == "鉴定意见书（初稿）")
				{
					attach.identifyDraft = true;
				}
				else if(fileName == "鉴定意见书（初审）")
				{
					attach.identifyFstExamin = true;
				}
				else if(fileName == "鉴定意见书（复审）")
				{
					attach.identifySndExamin = true;
				}
				else if(fileName == "鉴定意见书")
				{
					attach.identifyFinal = true;
				}
				else if(fileName == "成型照片（初稿）")
				{
					attach.modifyImage = true;
				}
				else if(fileName == "成型照片（初审）")
				{
					attach.modifyFstExamin = true;
				}
				else if(fileName == "成型照片（复审）")
				{
					attach.modifySndExamin = true;
				}
				else if(fileName == "成型照片")
				{
					attach.modifyFinal = true;
				}
				else if(fileName == "会诊结果")
				{
					attach.consultResult = true;
				}
			}
		}
		
		public function uploadConsultImage():void
		{						
			var fileIndex:Number = 0;
			
			var imageTypes:FileFilter = new FileFilter("图片 (*.jpg,*.bmp,*.png)", "*.jpg;*.jpeg;*.bmp;*.png");
			
			var fileRefList:FileReferenceList = new FileReferenceList();
			fileRefList.addEventListener(Event.SELECT,onFileSelect);							
			fileRefList.browse([imageTypes]);
			
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在上传会诊照片...");
				
				for each(var fileRef:FileReference in fileRefList.fileList)
				{
					fileRef.addEventListener(Event.COMPLETE,onFileLoad); 		
				}
				
				fileRefList.fileList[0].load(); 
			}
			
			function onFileLoad(event:Event):void   
			{   					
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCompleteHandler);   
				loader.loadBytes(event.currentTarget.data);
			}
			
			function loaderCompleteHandler(event:Event):void
			{			
				var fileRef:FileReference = fileRefList.fileList[fileIndex] as FileReference;
				
				var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
				var bitmap:Bitmap = Bitmap(loaderInfo.content);  
				
				var attachImage:AttachImageVO = new AttachImageVO;		
				attachImage.bitmapName = fileRef.name;								
				attachImage.bitmapData = bitmap.bitmapData;
				attachImage.bitmapArray = fileRef.data;
				
				var scale:Number = (bitmap.width / bitmap.height);
				var scale_width:Number = (scale > 1)?100:(scale * 100);
				var scale_height:Number = (scale > 1)?(100 / scale):100;				
				attachImage.facBitmapData = new BitmapData (scale_width, scale_height);
				
				var scale_W:Number = scale_width / bitmap.width;
				var matrix:Matrix = new Matrix(scale_W,0,0,scale_W,0,0);
				attachImage.facBitmapData.draw(bitmap.bitmapData,matrix);	
				
				var jpegEncoder:JPEGEncoder = new JPEGEncoder;
				attachImage.facBitmapArray = jpegEncoder.encode(attachImage.facBitmapData);
				
				attach.listConsultImage.addItemAt(attachImage,attach.listConsultImage.length - 1);
				
				fileIndex++;
				if(fileIndex < fileRefList.fileList.length)
				{			
					fileRefList.fileList[fileIndex].load();
				}
				else
				{				
					sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);						
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"照片上传成功。");
				}				 
			}   			
		}
		
		public function deleteConsultImage(attachImage:AttachImageVO):void
		{
			attach.listConsultImage.removeItemAt(attach.listConsultImage.getItemIndex(attachImage));
		}
		
		public function saveConsultImage(report:ReportVO):void
		{
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["UploadConsultImage",onSetResult
					,[
						report.FullNO
					]
				]);	
			
			function onSetResult(result:String):void
			{								
				for(var i:Number = 0;i<attach.listConsultImage.length;i++)
				{
					var attachImage:AttachImageVO = attach.listConsultImage[i] as AttachImageVO;
					if(attachImage != null)			
					{										
						upload(report.FullNO,"会诊照片" + (i + 1) + attachImage.bitmapType,attachImage.bitmapArray);
					}
				}
			}
		}
	}
}