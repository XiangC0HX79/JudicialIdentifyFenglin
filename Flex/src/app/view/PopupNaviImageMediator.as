package app.view
{
	import app.ApplicationFacade;
	import app.model.AttachProxy;
	import app.model.vo.AttachImageVO;
	import app.view.components.PopupNaviImage;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupNaviImageMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupNaviImageMediator";
		
		public function PopupNaviImageMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupNaviImage.addEventListener(PopupNaviImage.DOWNLOAD,onDownload);
			
			popupNaviImage.addEventListener(PopupNaviImage.PREIMAGE,onPreImage);
			popupNaviImage.addEventListener(PopupNaviImage.NEXTIMAGE,onNextImage);
			
			popupNaviImage.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
		}
		
		protected function get popupNaviImage():PopupNaviImage
		{
			return viewComponent as PopupNaviImage;
		}
				
		private function onCreation(event:FlexEvent):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
			
			initScales();
		}
		
		private function onDownload(event:Event):void
		{
			var attachImage:AttachImageVO = popupNaviImage.listSource[popupNaviImage.listIndex];				
			var fileName:String = attachImage.bitmapName;
			
			var fileRef:FileReference = new FileReference;
			
			fileRef.addEventListener(Event.SELECT,onFileSelect);				
			fileRef.addEventListener(Event.COMPLETE,onDownloadFile);			
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			
			fileRef.save(attachImage.bitmapArray,fileName);
			
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在下载《 "+ fileName + "》...");				
			}
			
			function onDownloadFile(event:Event):void 
			{							
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"《 "+ fileName + "》下载成功。");	
			}	
			
			function onIOError(event:IOErrorEvent):void
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
			}	
		}
		
		private function onPreImage(event:Event):void
		{
			popupNaviImage.listIndex--;
			
			var attachImage:AttachImageVO = popupNaviImage.listSource[popupNaviImage.listIndex];
			popupNaviImage.source =  attachImage.bitmapData;
			
			initScales();
		}
		
		private function onNextImage(event:Event):void
		{			
			popupNaviImage.listIndex++;
			
			var attachImage:AttachImageVO = popupNaviImage.listSource[popupNaviImage.listIndex];
			popupNaviImage.source =  attachImage.bitmapData;
			
			initScales();
		}
		
		private function initScales():void
		{
			if(popupNaviImage.source == null)
				return;
							
			if(popupNaviImage.listIndex == 0)
				popupNaviImage.btnPreImage.enabled = false;
			else
				popupNaviImage.btnPreImage.enabled = true;
			
			if(popupNaviImage.listIndex == popupNaviImage.listSource.length - 1)
				popupNaviImage.btnNextImage.enabled = false;	
			else
			{
				popupNaviImage.btnNextImage.enabled = (popupNaviImage.listSource[popupNaviImage.listIndex + 1] != null);		
			}	
			
			var contentScale:Number = Math.min((popupNaviImage.group.height)/popupNaviImage.source.height
				,popupNaviImage.group.width/popupNaviImage.source.width);
			var maxScale:Number = Math.max(2,contentScale);
			var minScale:Number = Math.min(1,contentScale);
				
			for(var i:Number = 0;i < popupNaviImage.scales.length;i++)
			{
				popupNaviImage.scales[i] = minScale + i * (maxScale - minScale) / (popupNaviImage.scales.length - 1);
			}
			
			var contentScaleIndex:Number = 0;
			var trueScaleIndex:Number = 0;
			var minContent:Number = 2;
			var minTrue:Number = 2;
			for(i = 0;i < popupNaviImage.scales.length;i++)
			{
				var tempContent:Number = Math.abs(popupNaviImage.scales[i] - contentScale);
				var tempTrue:Number = Math.abs(popupNaviImage.scales[i] - 1);
				if(tempContent < minContent)
				{
					minContent = tempContent;
					contentScaleIndex = i;
				}
				if(tempTrue < minTrue)
				{
					minTrue = tempTrue;
					trueScaleIndex = i;
				}
			}
			popupNaviImage.trueScaleIndex = trueScaleIndex;
			popupNaviImage.scales[trueScaleIndex] = 1;
			
			popupNaviImage.contentScaleIndex = contentScaleIndex;
			popupNaviImage.scales[contentScaleIndex] = contentScale;
			
			popupNaviImage.setScale(contentScaleIndex);
			
			popupNaviImage.image.x = int((popupNaviImage.group.width - popupNaviImage.image.width) / 2);
			popupNaviImage.image.y = int((popupNaviImage.group.height - popupNaviImage.image.height) / 2);
		}		
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_APP_INIT,
				
				ApplicationFacade.NOTIFY_POPUP_SHOW,
				
				ApplicationFacade.NOTIFY_APP_RESIZE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{				
				case ApplicationFacade.NOTIFY_APP_INIT:
					popupNaviImage.width = facade.retrieveMediator(ApplicationMediator.NAME).getViewComponent().width * 0.8;
					popupNaviImage.height = facade.retrieveMediator(ApplicationMediator.NAME).getViewComponent().height * 0.8;
					break;
				
				case ApplicationFacade.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == popupNaviImage)
					{
						popupNaviImage.width = facade.retrieveMediator(ApplicationMediator.NAME).getViewComponent().width * 0.8;
						popupNaviImage.height = facade.retrieveMediator(ApplicationMediator.NAME).getViewComponent().height * 0.8;
						
						var eventData:Array = notification.getBody()[1];
						popupNaviImage.listSource = eventData[0];	
						popupNaviImage.listIndex = eventData[1];	
						
						var attachImage:AttachImageVO = popupNaviImage.listSource[popupNaviImage.listIndex];
						popupNaviImage.source =  attachImage.bitmapData;
						
						if(popupNaviImage.initialized)
						{
							initScales();
						}
					}
					break;
				
				case ApplicationFacade.NOTIFY_APP_RESIZE:
					var popupManagerMediator:PopupManagerMediator = facade.retrieveMediator(PopupManagerMediator.NAME) as PopupManagerMediator;
					
					if((popupNaviImage.initialized) && popupManagerMediator.contain(popupNaviImage))
					{
						popupNaviImage.width = Number(notification.getBody()[0]) * 0.8;
						popupNaviImage.height = Number(notification.getBody()[1]) * 0.8;
						
						popupNaviImage.validateNow();
						
						initScales();
					}
					break;
			}
		}
	}
}