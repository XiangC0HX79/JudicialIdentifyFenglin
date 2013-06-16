package app.model.vo
{
	[Bindable]
	public class EntrustUnitVO
	{
		public static const ALL:EntrustUnitVO = new EntrustUnitVO({ID:-1,类别:4,单位名称:'所有单位'});
		
		
		public var id:Number;
		public var type:Number;
		public var label:String = "";
		
		public function EntrustUnitVO(item:Object)
		{
			this.id = item.ID;
			this.type = item.类别;
			this.label = item.单位名称;
		}
	}
}