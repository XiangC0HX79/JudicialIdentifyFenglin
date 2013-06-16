package app.controller
{	
	import app.ApplicationFacade;
	import app.model.dict.AcceptAddressDict;
	import app.model.dict.GroupDict;
	import app.model.dict.ReportStatusDict;
	import app.model.dict.RightDict;
	import app.model.dict.RoleDict;
	import app.model.dict.SendStatusDict;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class LocalConfigCommand extends SimpleCommand implements ICommand
	{
		private static const INITCOUNT:Number = 3;
		
		private static var init:Number = 0;
		
		override public function execute(note:INotification):void
		{						
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"系统初始化：加载本地配置...");
				
			var request:URLRequest = new URLRequest("config.xml");
			var load:URLLoader = new URLLoader(request);
			load.addEventListener(Event.COMPLETE,onLocaleConfigResult);
			load.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
		}
				
		private function onIOError(event:IOErrorEvent):void
		{
			sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,event.text);
		}
		
		private function appInit():void
		{
			if(++init == INITCOUNT)
			{														
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE,"程序初始化完成！");
				
				sendNotification(ApplicationFacade.NOTIFY_APP_INIT);
			}
		}
		
		private function onLocaleConfigResult(event:Event):void
		{				
			try
			{
				var xml:XML = new XML(event.currentTarget.data);
			}
			catch(e:Object)
			{
				trace(e);
			}
			
			if(xml == null)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"配置文件损坏，请检查config.xml文件正确性！");
				
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"程序初始化：本地配置加载失败！");	
			}
			else
			{				
				WebServiceCommand.WSDL = xml.WebServiceUrl;
				
				//服务器时间同步
				sendNotification(ApplicationFacade.NOTIFY_TIME_SYN);
								
				//加载参数表
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW);
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onSysParamResult
						,["SELECT * FROM 参数表"]
						,false]);
				
				//加载角色表
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW);
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onRoleResult
						,["SELECT * FROM 角色表"]
						,false]);
				
				//加载权限表
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW);
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onRightResult
						,["SELECT * FROM 权限表"]
						,false]);
			}
		}
				
		private function onSysParamResult(result:ArrayCollection):void
		{						
			for each(var item:Object in result)
			{
				if(item.组名 == "类型组别")
				{
					var group:GroupDict = new GroupDict(item.参数ID,item.参数值);
					GroupDict.dict[group.id] = group;
				}
				else if(item.组名 == "案件状态")
				{
					var reportStatus:ReportStatusDict = new ReportStatusDict(item.参数ID,item.参数值);
					ReportStatusDict.dict[reportStatus.id] = reportStatus;
				}
				else if(item.组名 == "发放状态")
				{
					var sendStatus:SendStatusDict = new SendStatusDict(item.参数ID,item.参数值);
					SendStatusDict.dict[sendStatus.id] = sendStatus;
				}
				else if(item.组名 == "受理地点")
				{
					var acceptAddressDict:AcceptAddressDict = new AcceptAddressDict(item.参数ID,item.参数值);
					AcceptAddressDict.dict[acceptAddressDict.id] = acceptAddressDict;
				}
			}
			
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE,"程序初始化：系统参数表加载完成！");	
			
			appInit();
		}
		
		private function onRoleResult(result:ArrayCollection):void
		{						
			for each(var item:Object in result)
			{
				var role:RoleDict = new RoleDict(item.ID,item.角色);
				RoleDict.dict[role.id] = role;
			}
			
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE,"程序初始化：角色表加载完成！");	
			
			appInit();
		}
		
		private function onRightResult(result:ArrayCollection):void
		{						
			for each(var item:Object in result)
			{
				var role:RightDict = new RightDict(item.ID,item.权限);
				RightDict.dict[role.id] = role;
			}
			
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE,"程序初始化：权限表加载完成！");	
			
			appInit();
		}
	}
}