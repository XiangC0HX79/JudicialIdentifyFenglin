package app.model
{
	import app.ApplicationFacade;
	import app.model.dict.GroupDict;
	import app.model.dict.RightDict;
	import app.model.dict.RoleDict;
	import app.model.vo.LoginVO;
	import app.model.vo.ReportVO;
	import app.model.vo.UserVO;
	import app.view.AppAlertMediator;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class LoginProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "LoginProxy";
		
		public function LoginProxy()
		{
			super(NAME, null);
		}
		
		public function get loginUser():LoginVO
		{
			return data as LoginVO;
		}
		
		public function login(userName:String,passWord:String):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onUserResult
					,["SELECT * FROM 用户信息 WHERE (姓名 = '" + userName + "' OR 用户名 = '" + userName + "') AND 密码 = '" + passWord + "' AND 是否使用"]
				]);
						
			function onUserResult(result:ArrayCollection):void
			{
				if(result.length == 0)
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"用户或密码不正确，请重新输入用户名或密码。");
				}
				else
				{
					setData(new LoginVO(result[0]));
					
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["GetTable",onGroupResult
							,["SELECT 类型ID FROM 类型用户表 WHERE 用户ID = " + loginUser.id]
						]);
				}
			}
			
			function onGroupResult(result:ArrayCollection):void
			{
				for each(var item:Object in result)
				{
					var group:GroupDict = GroupDict.dict[item.类型ID] as GroupDict;
					if(group != null)
					{
						loginUser.listGroup.addItem(group);
					}
				}
								
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onRoleResult
						,["SELECT 角色ID FROM 用户角色表 WHERE 用户ID = " + loginUser.id]
					]);
			}
			
			function onRoleResult(result:ArrayCollection):void
			{
				for each(var item:Object in result)
				{
					var role:RoleDict = RoleDict.dict[item.角色ID] as RoleDict;
					if(role != null)
					{
						loginUser.listRole.addItem(role);
					}					
				}
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onRightResult
						,["SELECT 权限ID FROM 用户角色表,角色权限表 "
							+ "WHERE 用户角色表.角色ID = 角色权限表.角色ID AND 用户角色表.用户ID = " 
							+ loginUser.id
							+ " GROUP BY 权限ID"]
					]);
			}
			
			function onRightResult(result:ArrayCollection):void
			{
				for each(var item:Object in result)
				{
					var right:RightDict = RightDict.dict[item.权限ID] as RightDict;
					if(right != null)
					{
						loginUser.listRight.addItem(right);
					}					
				}
								
				sendNotification(ApplicationFacade.NOTIFY_LOGIN_SUCCESS);
			}
		}
		
		public function editPassword(oldPassword:String,newPassWord:String):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onResult
					,["UPDATE 用户信息 SET 密码 = '" + newPassWord + "' WHERE ID  = " + loginUser.id + " AND 密码 = '" + oldPassword + "'"]
					,true]);
			
			function onResult(result:Number):void
			{
				if(result == 0)
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"原始密码不正确，请重新输入原始密码。");
				}
				else
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"密码修改成功。");
				}
			}
		}
		
		public function checkReport(report:ReportVO):Boolean
		{
			switch(report.ReportStatus.label)
			{
				case "受理":
					return checkRight(report.ReportStatus.label) && (loginUser.id == report.accepter);
					break;
				
				case "会诊":		
				case "签字":
					return checkRight(report.ReportStatus.label);
					break;
								
				case "打印":	
					return (loginUser.id == report.printer);
					break;
				
				case "修订":			
					return (loginUser.id == report.printer);
					break;	
				
				case "初审":
					if(report.FirstExamineDate == "待初审")
						return checkRight(report.ReportStatus.label) && checkGroup(report.Group);
					else
						return (loginUser.id == report.firstExaminer);
					break;
				
				case "复审":
					if(report.LastExamineDate == "待复核")
						return checkRight(report.ReportStatus.label) && checkGroup(report.Group);
					else
						return (loginUser.id == report.lastExaminer);
					break;
				
				case "装订":
					if(report.BindingDate == "待装订")
						return checkRight(report.ReportStatus.label);
					else
						return (loginUser.id == report.bindinger);
					break;
					
				case "发放及归档":
					var check:Boolean;
					if(report.FileDate == "待归档")
						check = checkRight("归档");
					else
						check = (loginUser.id == report.filer);
					
					return (checkRight("发放报告") && (loginUser.id == report.accepter))
						|| check;
					break;
				
				default:
					return false;
					break;
			}
		}
		
		public function checkGroup(check:GroupDict):Boolean
		{			
			if(check.label == "待定")
				return true;
			
			for each(var group:GroupDict in this.loginUser.listGroup)
			{
				if(group == check)
					return true;
			}
			
			return false;
		}
		
		public function checkRight(idorlabel:String):Boolean
		{
			for each(var right:RightDict in this.loginUser.listRight)
			{
				if(right == RightDict.getItem(idorlabel))
				{
					return true;
				}
			}
			
			return false;
		}
	}
}