package app.view
{
	import app.ApplicationFacade;
	import app.model.UserProxy;
	import app.model.dict.GroupDict;
	import app.model.dict.RoleDict;
	import app.model.vo.UserVO;
	import app.view.components.NaviManageUser;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviManageUserMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviManageUserMediator";
				
		private var userProxy:UserProxy;
		
		public function NaviManageUserMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			naviManageUser.addEventListener(NaviManageUser.LISTUSERCHANGE,onListUserChange);
			
			naviManageUser.addEventListener(NaviManageUser.CLOSE,onClose);
			naviManageUser.addEventListener(NaviManageUser.NEWUSER,onNewUser);
			naviManageUser.addEventListener(NaviManageUser.UPDATEUSER,onUpdateUser);
			naviManageUser.addEventListener(NaviManageUser.DELETEUSER,onDeleteUser);
			
			userProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
			
			naviManageUser.listUser = userProxy.list;
		}
		
		protected function get naviManageUser():NaviManageUser
		{
			return viewComponent as NaviManageUser;
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
				
		private function onListUserChange(event:Event):void
		{
			var user:UserVO = naviManageUser.gridUser.selectedItem as UserVO;
			
			if(user != null)
			{				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onGroupResult
						,["SELECT * FROM 类型用户表 WHERE 用户ID = " + user.id]
					]);
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onRoleResult
						,["SELECT * FROM 用户角色表 WHERE 用户ID = " + user.id]
					]);
			}
			
			function onGroupResult(result:ArrayCollection):void
			{
				for each(var group:GroupDict in naviManageUser.listGroup)
				{
					group.selected = false;
				}
				
				for each(var item:Object in result)
				{
					group = GroupDict.dict[item.类型ID] as GroupDict;
					if(group != null)
					{
						group.selected = true;
					}
				}
			}
			
			function onRoleResult(result:ArrayCollection):void
			{
				for each(var role:RoleDict in naviManageUser.listRole)
				{
					role.selected = false;
				}
				
				for each(var item:Object in result)
				{
					role = RoleDict.dict[item.角色ID] as RoleDict;
					if(role != null)
					{
						role.selected = true;
					}
				}
			}
		}
		
		private function onNewUser(event:Event):void
		{		
			if(naviManageUser.textName.text == "")
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"姓名不能为空。");					
			}
			else if(naviManageUser.textUserName.text == "")
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"用户名不能为空。");					
			}
			else
			{
				for each(var item:UserVO in naviManageUser.listUser)
				{
					if(naviManageUser.textName.text == item.name)
					{
						sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"相同姓名已存在,请重新输入姓名。");
						return;
					}
					
					if(naviManageUser.textUserName.text == item.username)
					{
						sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"相同用户名已存在,请重新输入用户名。");
						return;
					}
				}
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onInsertResult
						,["INSERT INTO 用户信息 (姓名,性别,用户名,密码,联系方式,受理人A,受理人B,受理人C,签字人,会诊人) VALUES ('" + 
							naviManageUser.textName.text + "','" + 
							naviManageUser.comboSex.labelDisplay.text + "','" + 
							naviManageUser.textUserName.text + "','" + 
							naviManageUser.textPassWord.text + "','" + 
							naviManageUser.textPhone.text + "'," +
							naviManageUser.checkAccpterA.selected + "," +
							naviManageUser.checkAccpterB.selected + "," +
							naviManageUser.checkAccpterC.selected + "," +
							naviManageUser.checkSigner.selected + "," +
							naviManageUser.checkDiagnosiser.selected + 
								")"]
					]);				
			}
			
			function onInsertResult(result:Number):void
			{		
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onGetResult
						,["SELECT * FROM 用户信息 WHERE 姓名 = '" + naviManageUser.textName.text + "'"]
					]);
			}
			
			function onGetResult(result:ArrayCollection):void
			{
				if(result.length == 0)
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"添加用户失败。");						
				}
				else
				{
					var user:UserVO = new UserVO(result[0]);
					naviManageUser.listUser.addItem(user);	
					naviManageUser.gridUser.selectedItem = user;
					
					var sql:String = "DELETE FROM 类型用户表 WHERE 用户ID = " + user.id;
					for each(var group:GroupDict in naviManageUser.listGroup)
					{
						if(group.selected)
							sql += ";INSERT INTO 类型用户表 (类型ID,用户ID) VALUES (" + group.id + "," + user.id + ")";
					}
					
					sql += ";DELETE FROM 用户角色表 WHERE 用户ID = " + user.id;
					for each(var role:RoleDict in naviManageUser.listRole)
					{
						if(role.selected)
							sql += ";INSERT INTO 用户角色表 (用户ID,角色ID) VALUES (" + user.id + "," + role.id + ")";
					}
					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["ExcuteNoQuery",onResult
							,[sql]
						]);					
				}
			}
			
			function onResult(result:Number):void
			{							
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"添加用户成功。");
			}
		}
		
		private function onUpdateUser(event:Event):void
		{			
			var user:UserVO = naviManageUser.gridUser.selectedItem as UserVO;
			
			if(user == null)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请先选择用户。");				
			}
			else if(naviManageUser.textName.text == "")
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"姓名不能为空。");					
			}
			else if(naviManageUser.textUserName.text == "")
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"用户名不能为空。");					
			}
			else
			{
				for each(var item:UserVO in naviManageUser.listUser)
				{
					if(item.id != user.id)
					{
						if(naviManageUser.textName.text == item.name)
						{
							sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"相同姓名已存在,请重新输入姓名。");
							return;
						}
						
						if(naviManageUser.textUserName.text == item.username)
						{
							sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"相同用户名已存在,请重新输入用户名。");
							return;
						}
					}
				}
				
				var sql:String = "UPDATE 用户信息 SET 姓名 = '" + naviManageUser.textName.text + 
					"',性别 = '" + naviManageUser.comboSex.labelDisplay.text + 
					"',用户名 = '" + naviManageUser.textUserName.text + 
					"',密码 = '" + naviManageUser.textPassWord.text + 
					"',联系方式='" + naviManageUser.textPhone.text + 
					"',受理人A=" + naviManageUser.checkAccpterA.selected + 
					",受理人B=" + naviManageUser.checkAccpterB.selected + 
					",受理人C=" + naviManageUser.checkAccpterC.selected + 
					",签字人=" + naviManageUser.checkSigner.selected + 
					",会诊人=" + naviManageUser.checkDiagnosiser.selected + 
					" WHERE ID =" + user.id;
				
				sql += ";DELETE FROM 类型用户表 WHERE 用户ID = " + user.id;				
				for each(var group:GroupDict in naviManageUser.listGroup)
				{
					if(group.selected)
						sql += ";INSERT INTO 类型用户表 (类型ID,用户ID) VALUES (" + group.id + "," + user.id + ")";
				}
				
				sql += ";DELETE FROM 用户角色表 WHERE 用户ID = " + user.id;	
				for each(var role:RoleDict in naviManageUser.listRole)
				{
					if(role.selected)
						sql += ";INSERT INTO 用户角色表 (用户ID,角色ID) VALUES (" + user.id + "," + role.id + ")";
				}
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["ExcuteNoQuery",onResult
						,[sql]
					]);
				
				function onResult(result:Number):void
				{		
					user.name = naviManageUser.textName.text;				
					user.username = naviManageUser.textUserName.text;
					user.password = naviManageUser.textPassWord.text;				
					user.sex = naviManageUser.comboSex.labelDisplay.text;
					user.phone = naviManageUser.textPhone.text;
					
					user.accepterA = naviManageUser.checkAccpterA.selected;
					user.accepterB = naviManageUser.checkAccpterB.selected;
					user.accepterC = naviManageUser.checkAccpterC.selected;
					user.signer = naviManageUser.checkSigner.selected;
					user.consulter = naviManageUser.checkDiagnosiser.selected;
					
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"更新用户信息成功。");
				}
			}			
		}
		
		private function onDeleteUser(event:Event):void
		{			
			var user:UserVO = naviManageUser.gridUser.selectedItem as UserVO;
			
			if(user == null)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请先选择用户。");				
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,["确认删除用户'" + user.name + "'？",closeHandle,Alert.YES|Alert.NO]);	
			}
			
			function closeHandle(closeEvent:CloseEvent):void
			{
				if(closeEvent.detail == Alert.YES)
				{					
					var sql:String = "UPDATE 用户信息 SET 是否使用 = False WHERE ID = " + user.id;
					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["SetTable",onResult
							,[sql]
						]);					
				}
			}
			
			function onResult(result:Number):void
			{							
				userProxy.list.removeItemAt(userProxy.list.getItemIndex(user));
								
				for each(var group:GroupDict in GroupDict.list)
				{
					group.selected = false;
				}
				
				for each(var role:RoleDict in RoleDict.list)
				{
					role.selected = false;
				}
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"删除用户成功。");
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
						//userProxy.refresh();
						
						for each(var group:GroupDict in GroupDict.list)
						{
							group.selected = false;
						}
						naviManageUser.listGroup = GroupDict.list;
						
						for each(var role:RoleDict in RoleDict.list)
						{
							role.selected = false;
						}
						naviManageUser.listRole = RoleDict.list;
						
						if(naviManageUser.initialized)
						{							
							naviManageUser.gridUser.selectedItem = null;
						}							
					}
					break;
			}
		}
	}
}