package app.view
{
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	
	import app.ApplicationFacade;
	import app.model.AppConfigProxy;
	import app.model.RadioGroupProxy;
	import app.model.RadioImageProxy;
	import app.model.RadioProxy;
	import app.model.RadioStatusProxy;
	import app.model.RadioTypeProxy;
	import app.model.vo.AppConfigVO;
	import app.model.vo.DigitalComCO;
	import app.model.vo.RadioTypeVO;
	import app.model.vo.RadioVO;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SocketMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SocketMediator";
		
		public static var WSDL:String = "";
		
		private var SocketIP:String = "127.0.0.1";
		private var SocketPort:Number = 12306;
				
		public function SocketMediator()
		{
			super(NAME, new Socket);
			
			socket.addEventListener(Event.CONNECT,onConnect);	
			
			socket.addEventListener(Event.CLOSE,onClose);		
			socket.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandle);			
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSocketOnSecurityError);	
		}
		
		protected function get socket():Socket
		{
			return viewComponent as Socket;
		}
				
		public function connect():void
		{
			socket.connect(SocketIP,SocketPort);
						
			Security.loadPolicyFile("xmlsocket://" + SocketIP + ":" + SocketPort);
		}
				
		private function onClose(event:Event):void 
		{  			
			handleConnectError();
		} 
		
		private function ioErrorHandle(event:IOErrorEvent):void
		{  
			handleConnectError();
		}  
		
		private function onSocketOnSecurityError(event:SecurityErrorEvent):void 
		{  
			handleConnectError();			
		}  
				
		private function closeHandle(event:CloseEvent):void
		{			
			flash.net.navigateToURL(new URLRequest("javascript:location.reload();"),"_self");
		}
		
		private function handleConnectError():void
		{
			if((countError == 0) || (countError > 5))
				sendNotification(ApplicationFacade.NOTIFY_ALERT_ERROR,"Socket服务器连接失败，请检查网络！");
			else
				reConnect();
		}		
				
		private function reConnect():void
		{
			sendNotification(ApplicationFacade.NOTIFY_LOADINGBAR_SHOW,"Socket服务器断开连接，正在重连...");
			
			countError++;
			
			var appConfig:AppConfigVO = facade.retrieveProxy(AppConfigProxy.NAME).getData() as AppConfigVO;
			
			socket.connect(appConfig.SocketIP,appConfig.SocketPort);
		}
		
		private function onConnect( event:Event ):void 
		{  								
			if(countError == 0)
			{
				sendNotification(ApplicationFacade.NOTIFY_INIT_APP,null,InitAppMediator.SOCKETSERVER);
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_LOADINGBAR_HIDE);
			}
			
			countError = 1;			
		}  
		
		//接受数据		
		private var bytesArray:ByteArray = new ByteArray;
		private function onGetData(event:ProgressEvent):void 
		{  			
			var target:Socket = event.target as Socket;
						
			while(target.bytesAvailable)			
			{			
				target.readBytes(bytesArray,bytesArray.length);
				
				//如出现Error: Error #2030: 遇到文件尾错误，请用：str=socket.readUTFBytes(socket.bytesAvailable);				
			}
			
			decodeDataGet(bytesArray);
			
			bytesArray= new ByteArray;
		}  
		
		private function decodeDataGet(data:ByteArray):void
		{			
			var recves:String = data.readUTFBytes(data.length);
			var colRecv:Array = recves.split('@');
			
			for each(var recv:String in colRecv)
			{
				if(recv == "")
					continue;
				
				var dataType:String = recv.substr(0,3);
				
				var dataReceive:String = recv.substr(3);
							
				if(dataType == "GPS")
				{							
					var arrItem:Array = dataReceive.split('|');
					
					var stId:Number = Number(arrItem[0]);
					if(stId < 10000)
						stId = stId - 4000;
					
					var radioProxy:RadioProxy = facade.retrieveProxy(RadioProxy.NAME) as RadioProxy;
					
					var radio:RadioVO = radioProxy.dict[stId.toString()];
									
					if(radio)
					{						
						if(arrItem[1])
						{				
							if(arrItem.length < 10)
								trace(dataReceive);
							
							var dt:Date =  new Date(Date.parse(arrItem[6].replace(/-/g,'/')));
							
							if(dt.time > radio.LastDateTime.time)
							{
								radio.LastDateTime = dt;	
							
								radio.mapPoint.update(Number(arrItem[1]),Number(arrItem[2]));
								
								radio.refresh();
								
								sendNotification(ApplicationFacade.NOTIFY_SOCKET_RADIOGEOMETRY,radio);
								
								/*radio.taskID = Number(arrItem[7]);
								radio.taskName = arrItem[8];
								radio.taskType = arrItem[9];*/
							}
							else
							{
								//trace(radio.IDCard);								
							}
						}
						else
						{			
							if(arrItem[4] == 1)
							{
								radio.STStatus = arrItem[4];
								radio.STGroup = arrItem[5];							
							}
							else if(arrItem[4] == 2)
							{
								radio.STStatus = arrItem[4];
								radio.STGroup = "0";							
							}
							else if((arrItem[4] == 3) || (arrItem[4] == 4))
							{
								radio.STStatus = 1;
								radio.STGroupStatus = arrItem[4];
								radio.STGroup = arrItem[5];		
							}
							else
							{
								radio.STStatus = arrItem[4];
								radio.STGroup = "0";							
							}
													
							radio.refresh();
							
							var radioGroupProxy:RadioGroupProxy = facade.retrieveProxy(RadioGroupProxy.NAME) as RadioGroupProxy;
							radioGroupProxy.AddRadio(radio);
							//radioGroupProxy.col.refresh();
							
							var radioImageProxy:RadioImageProxy = facade.retrieveProxy(RadioImageProxy.NAME) as RadioImageProxy;
							var bitmap:BitmapData = radioImageProxy.getImage(radio.type,radio.status);
							
							if(bitmap != radio.bitmap)
							{
								radio.bitmap = bitmap;		
								
								sendNotification(ApplicationFacade.NOTIFY_SOCKET_RADIOSYMBOL,radio);
							}
						}
					} 
				}
				else
				{				
					trace(recv);
				}
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_INIT_LOGIN_COMPLETE,
				ApplicationFacade.NOTIFY_SOCKET_SEND
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{							
				case ApplicationFacade.NOTIFY_INIT_LOGIN_COMPLETE:					
					socket.addEventListener(ProgressEvent.SOCKET_DATA,onGetData);  					
					break;
				
				case ApplicationFacade.NOTIFY_SOCKET_SEND:		
					sendMessage(notification.getBody());
					break;
			}
		}
		
		private function sendMessage(msg:*):void
		{
			try
			{
				if((socket.connected) && (msg is String))
				{
					/*var len:int = String(msg).length;
						
					socket.writeByte(len & 0xFF);
					socket.writeByte(len >> 8 & 0xFF);
					socket.writeByte(len >> 16 & 0xFF);
					socket.writeByte(len >> 24 & 0xFF);*/
					
					socket.writeUTFBytes(msg);
					
					socket.flush();
				}
			}
			catch(e:Error)
			{
				trace("SendMessage Error");
			}		
		}
	}
}