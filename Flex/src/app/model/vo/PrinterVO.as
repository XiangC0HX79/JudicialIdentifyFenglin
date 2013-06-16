package app.model.vo
{
	[Bindable]
	public class PrinterVO extends UserVO
	{
		public var printCount:Number = 0;
		
		public function PrinterVO(item:Object=null)
		{
			super(item);
			
			this.printCount = item.打印数量;
		}
	}
}