package app.model
{
	import app.ApplicationFacade;
	import app.model.dict.GroupDict;
	import app.model.vo.UserVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class UserProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "UserProxy";
		
		public function UserProxy()
		{
			super(NAME, new ArrayCollection);	
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function get listAccepterA():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			for each(var user:UserVO in list)
			{
				if(user.accepterA)
				{
					user.selected = false;
					arr.addItem(user);
				}
			}
			
			return arr;
		}
		
		public function get listAccepterB():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			for each(var user:UserVO in list)
			{
				if(user.accepterB)
				{
					user.selected = false;
					arr.addItem(user);
				}
			}
			
			return arr;
		}
		
		public function get listAccepterC():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			for each(var user:UserVO in list)
			{
				if(user.accepterC)
				{
					user.selected = false;
					arr.addItem(user);
				}
			}
			
			return arr;
		}
		
		public function get listSigner():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			for each(var user:UserVO in list)
			{
				if(user.signer)
				{
					user.selected = false;
					arr.addItem(user);
				}
			}
			
			return arr;
		}
		
		public function get listConsulter():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			for each(var user:UserVO in list)
			{
				if(user.consulter)
				{
					user.selected = false;
					arr.addItem(user);
				}
			}
			
			return arr;
		}
		
		public function getUser(o:Object):UserVO
		{
			for each(var user:UserVO in list)
			{
				if(user.id == Number(o) || user.name == String(o))
					return user;
			}
			
			return null;
		}
		
		public function refresh():void
		{
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onResult
					,["SELECT * FROM 用户信息 WHERE 是否使用"]
				]);
			
			function onResult(result:ArrayCollection):void
			{
				list.removeAll();
				
				for each(var item:Object in result)
				{
					var user:UserVO = new UserVO(item);
					list.addItem(user);
				}
			}
		}
	}
}