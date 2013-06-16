package app.view
{
	import app.ApplicationFacade;
	import app.model.dict.RightDict;
	import app.model.dict.RoleDict;
	import app.view.components.NaviManageRole;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviManageRoleMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviManageRoleMediator";
		
		public function NaviManageRoleMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			naviManageRole.addEventListener(NaviManageRole.CLOSE,onClose);
			naviManageRole.addEventListener(NaviManageRole.LISTROLECHANGE,onListRoleChange);			
			naviManageRole.addEventListener(NaviManageRole.NEWROLE,onNewRole);
			naviManageRole.addEventListener(NaviManageRole.UPDATEROLE,onUpdateRole);
			naviManageRole.addEventListener(NaviManageRole.DELETEROLE,onDeleteRole);
		}
		
		protected function get naviManageRole():NaviManageRole
		{
			return viewComponent as NaviManageRole;
		}
				
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onListRoleChange(event:Event):void
		{
			var role:RoleDict = naviManageRole.gridRole.selectedItem as RoleDict;
			
			if(role != null)
			{								
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onResult
						,["SELECT 权限ID FROM 角色权限表 WHERE 角色ID = " + role.id]
					]);
			}
			
			function onResult(result:ArrayCollection):void
			{
				for each(var right:RightDict in naviManageRole.listRight)
				{
					right.selected = false;
				}
				
				for each(var item:Object in result)
				{
					right = RightDict.dict[item.权限ID] as RightDict;
					if(right != null)
					{
						right.selected = true;
					}
				}
			}
		}
		
		private function onNewRole(event:Event):void
		{
			if(naviManageRole.textRole.text == "")
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"角色名不能为空。");					
			}
			else
			{
				for each(var item:RoleDict in naviManageRole.listRole)
				{
					if(naviManageRole.textRole.text == item.label)
					{
						sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"相同角色名已存在,请重新输入角色名。");
						return;
					}
				}
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onInsertResult
						,["INSERT INTO 角色表 (角色) VALUES ('" + naviManageRole.textRole.text + "')"]
					]);				
			}
			
			function onInsertResult(result:Number):void
			{
				if(Number(result) == 0)
				{						
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"添加角色失败。");
				}
				else
				{					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["GetTable",onMaxIDResult
							,["SELECT * FROM 角色表 WHERE 角色 = '" + naviManageRole.textRole.text + "'"]
						]);
				}
			}
			
			function onMaxIDResult(result:ArrayCollection):void
			{
				if(result.length == 0)
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"添加角色失败。");						
				}
				else
				{
					var role:RoleDict = new RoleDict(result[0].ID,result[0].角色);
					RoleDict.dict[role.id] = role;							
					
					naviManageRole.listRole = RoleDict.list;
					naviManageRole.gridRole.selectedItem = role;
					
					var sql:String = "DELETE FROM 角色权限表 WHERE 角色ID = " + role.id;
					for each(var right:RightDict in naviManageRole.listRight)
					{
						if(right.selected)
							sql += ";INSERT INTO 角色权限表 (角色ID,权限ID) VALUES (" + role.id + "," + right.id + ")";
					}
					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["ExcuteNoQuery",onResult
							,[sql]
						]);					
				}
			}
			
			function onResult(result:Number):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"添加角色成功。");
			}
		}
		
		private function onUpdateRole(event:Event):void
		{
			var role:RoleDict = naviManageRole.gridRole.selectedItem as RoleDict;
			
			if(role == null)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请先选择角色。");				
			}
			else if(naviManageRole.textRole.text == "")
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"角色名不能为空。");					
			}
			else
			{
				for each(var item:RoleDict in naviManageRole.listRole)
				{
					if(item.id != role.id)
					{
						if(naviManageRole.textRole.text == item.label)
						{
							sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"相同角色名已存在,请重新输入角色名。");
							return;
						}
					}
				}
				
				var sql:String = "UPDATE 角色表 SET 角色 = '" + naviManageRole.textRole.text + "' WHERE ID =" + role.id;
				
				sql += ";DELETE FROM 角色权限表 WHERE 角色ID = " + role.id;				
				for each(var right:RightDict in RightDict.list)
				{
					if(right.selected)
						sql += ";INSERT INTO 角色权限表 (角色ID,权限ID) VALUES (" + role.id + "," + right.id + ")";
				}
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["ExcuteNoQuery",onResult
						,[sql]
					]);
				
				function onResult(result:Number):void
				{
					if(Number(result) == 0)
					{						
						sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"更新角色信息失败。");
					}
					else
					{																	
						sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"更新角色信息成功。");
					}
				}
			}			
		}
		
		private function onDeleteRole(event:Event):void
		{
			var role:RoleDict = naviManageRole.gridRole.selectedItem as RoleDict;
			
			if(role == null)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请先选择角色。");				
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,["确认删除角色'" + role.label + "'？",closeHandle,Alert.YES|Alert.NO]);	
			}
			
			function closeHandle(closeEvent:CloseEvent):void
			{
				if(closeEvent.detail == Alert.YES)
				{					
					var sql:String = "DELETE FROM 角色表 WHERE ID = " + role.id;
					sql += ";DELETE FROM 角色权限表 WHERE 角色ID = " + role.id;	
					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["ExcuteNoQuery",onResult
							,[sql]
						]);
				}
			}
			
			function onResult(result:Number):void
			{
				if(Number(result) == 0)
				{						
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"删除角色失败。");
				}
				else
				{											
					delete RoleDict.dict[role.id];
					
					naviManageRole.listRole = RoleDict.list;
					
					naviManageRole.gridRole.selectedItem = null;
					
					for each(var right:RightDict in RightDict.list)
					{
						right.selected = false;
					}
					
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"删除角色成功。");
				}
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
					if(notification.getBody()[0] == facade.retrieveMediator(PopupSysManagerMediator.NAME).getViewComponent())
					{
						for each(var role:RoleDict in RoleDict.list)
						{
							role.selected = false;
						}
						naviManageRole.listRole = RoleDict.list;
						
						for each(var right:RightDict in RightDict.list)
						{
							right.selected = false;
						}
						naviManageRole.listRight = RightDict.list;
						
						if(naviManageRole.initialized)
						{
							naviManageRole.gridRole.selectedItem = null;
						}						
					}
					break;
			}
		}
	}
}