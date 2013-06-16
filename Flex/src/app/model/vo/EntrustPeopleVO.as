package app.model.vo
{
	[Bindable]
	public class EntrustPeopleVO
	{
		public static const ALL:EntrustPeopleVO = new EntrustPeopleVO({ID:-1,姓名:'所有联系人'});
		
		public var id:Number = 0;
		public var label:String = "";
		public var phone:String = "";
		public var unitID:Number = 0;
		
		public function EntrustPeopleVO(item:Object)
		{
			this.id = item.ID;
			this.label = item.姓名;
			this.phone = item.联系方式;
			this.unitID = item.单位ID;
		}
	}
}