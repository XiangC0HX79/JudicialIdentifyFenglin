package app.model.vo
{
	import app.model.dict.GroupDict;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class UserVO
	{
		public var id:Number;
		public var name:String = "";
		public function get label():String{return name;}
		
		public var username:String = "";
		public var password:String = "";
				
		public var sex:String = "";
		public var phone:String = "";
		
		public var accepterA:Boolean = false;
		public var accepterB:Boolean = false;
		public var accepterC:Boolean = false;		
		public var signer:Boolean = false;
		public var consulter:Boolean = false;
		
		public var selected:Boolean = false;
		
		public function UserVO(item:Object = null)
		{
			if(item != null)
			{
				this.id = item.ID;
				this.name = item.姓名;
				
				this.username = item.用户名;
				this.password = item.密码;
				
				this.sex = item.性别;
				this.phone = item.联系方式;
				
				this.accepterA = item.受理人A;
				this.accepterB = item.受理人B;
				this.accepterC = item.受理人C;
				
				this.signer = item.签字人;
				this.consulter = item.会诊人;
			}
		}
	}
}