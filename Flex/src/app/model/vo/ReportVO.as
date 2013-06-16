package app.model.vo
{
	import app.model.dict.AcceptAddressDict;
	import app.model.dict.GroupDict;
	import app.model.dict.ReportStatusDict;
	import app.model.dict.SendStatusDict;
	
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class ReportVO
	{
		public var dateF:DateTimeFormatter;
		
		public var id:Number = -1;
		
		public var type:Number = 0;
		public function get Group():GroupDict
		{
			return GroupDict.getItem(type);
		}
		
		public var no:Number = 0;
		public var subNo:Number = 0;
		public function get ShortNO():String
		{						
			return year + " " + Group.label.charAt(0) + " " + SubNo;
		}
		public function get FullNO():String
		{						
			return "沪枫林 " + year + " " + Group.label + " " + SubNo + " 号";
		}
		public function get SubNo():String
		{						
			var no:String = String(this.no);
			var l:Number = no.length;
			for(var i:Number = 4; i>l ; i--)
				no = "0" + no;
			
			if(this.subNo != 0)
				no += "-" + this.subNo;
			
			return no;
		}
		
		public var year:String = (new Date).fullYear.toString();
		public var acceptDate:Date = new Date;
		public function get AcceptDate():String
		{			
			if(this.ReportStatus.label == "受理")
				return "正在受理";
			else
				return acceptDate == null?"":dateF.format(acceptDate);
		}
		
		public var unitEntrust:String = "";	//委托单位
		public var unitContact:String = "";	//委托单位联系方式
		public var unitPeople:String = "";	//委托单位联系人
		
		public var checkedPeople:String = "";	//受检人
		public var checkedContact:String = "";	//受检人联系方式
		
		public function get PayStatus():String
		{			
			var label:String = "Y" + this.paidAmount;
			
			if(this.ReportStatus.label == "案件取消")
			{
				var temp:Number = this.paidAmount - this.refund;
				if(temp > 0)
					label += " N-" + temp;
			}
			else
			{
				if(this.Paydebt > 0)
					label += " N" + this.Paydebt;
			}
			
			return label;
			
			/*if(this.ReportStatus.label == "案件取消")
			{
				return ((this.paidAmount - this.refund) > 0)?"待退费":"已退费";
			}
			else
			{
				return (this.Paydebt > 0)?"欠费":"已缴费";
			}*/
		}
		
		public function get Paydebt():Number
		{
			if(this.commision)
				return (this.payAmount - this.paidAmount - this.commisionAmount);
			else
				return (this.payAmount - this.paidAmount);
		}
		
		public var payAmount:Number = 0;	//应缴金额
		public var paidAmount:Number = 0;	//已缴金额
		public var refund:Number = 0;//退费金额
		
		public var billDate:Date;	//开票日期
		public var billAmount:Number = 0;	//开票金额
		public var billStatus:String = "";	//开票情况
		public var billNo:String = "";		//票号
		
		public var payType:String = "";	//缴费方式
		public var payFirstDate:Date;	//预收款日期
		public var payLastDate:Date;	//尾款日期
		
		public var commision:Boolean;	//是否返佣
		public var commisionAmount:Number = 0;	//返佣金额
				
		public var accepterAddress:Number = 0;//受理地点
		public function get AccepterAddress():AcceptAddressDict
		{
			return AcceptAddressDict.getItem(accepterAddress);
		}
		public var accepterType:String = ""; //案件类型
		public var imageCount:Number = 0;		//影像资料
		
		public var remark:String = "";		//备注
		
		public var accepter:Number;				//受理人
		public var accepterName:String = "";	//受理人姓名
		public var accepterA:Number;		//受理人A
		public var accepterAName:String = "";	//受理人A姓名
		public var accepterB:Number;		//受理人B
		public var accepterBName:String = "";	//受理人B姓名
		public var accepterC:Number;		//受理人C
		public var accepterCName:String = "";	//受理人C姓名
		
		public var finishDate:Date;	//预计报告日期
		public var finishType:Number = 0;	//预计报告类型
		public function get FinishType():String
		{
			if(finishType == 0)
				return "正常";
			else if(finishType == 1)
				return "加急";
			else
				return "延后";
		}
		
		public var distributeDate:Date;		//分配日期
		
		//会诊
		public var consultAcceptDate:Date;
		public var consulter:String;
		public var otherConsulter:String;
		public var consultDate:Date;
		public function get ConsultDate():String
		{		
			if(this.ReportStatus.label == "会诊")
			{
				if(consultAcceptDate == null)
					return "待会诊";
				else
					return "正在会诊";
			}
			else
			{
				return consultDate == null?"":dateF.format(consultDate);
			}
		}
		
		//打印
		public var printAcceptDate:Date;
		public var printer:Number;
		public var printerName:String;
		public var printDate:Date;
		public function get PrintDate():String
		{		
			if(this.ReportStatus.label == "打印")
			{
				if(printAcceptDate == null)
					return "待打印";
				else
					return "正在打印";
			}
			else
			{
				return printDate == null?"":dateF.format(printDate);
			}
		}
		
		//初审
		public var firstExamineAcceptDate:Date;
		public var firstExaminer:Number;
		public var firstExaminerName:String;
		public var firstExamineRank:Number = -1;
		public var firstExamineDate:Date;
		public function get FirstExamineDate():String
		{			
			if(this.ReportStatus.label == "初审")
			{
				if(firstExamineAcceptDate == null)
					return "待初审";
				else
					return "正在初审";
			}
			else
				return firstExamineDate == null?"":dateF.format(firstExamineDate);
		}
		
		//复核
		public var lastExamineAcceptDate:Date;
		public var lastExaminer:Number;
		public var lastExaminerName:String;
		public var lastExamineRank:Number = -1;
		public var lastExamineDate:Date;
		public function get LastExamineDate():String
		{			
			if(this.ReportStatus.label == "复审")
			{
				if(lastExamineAcceptDate == null)
					return "待复核";
				else
					return "正在复核";
			}
			else
				return lastExamineDate == null?"":dateF.format(lastExamineDate);
		}
		
		//修订
		public var revisionAcceptDate:Date;
		public var revisionDate:Date;
		public function get RevisionDate():String
		{			
			if(this.ReportStatus.label == "修订")
			{
				if(revisionAcceptDate == null)
					return "待修订";
				else
					return "正在修订";
			}
			else
				return revisionDate == null?"":dateF.format(revisionDate);
		}
		
		//装订
		public var bindingAcceptDate:Date;
		public var bindinger:Number;
		public var bindingerName:String = "";
		public var bindingDate:Date;
		public function get BindingDate():String
		{			
			if(this.ReportStatus.label == "装订")
			{
				if(bindingAcceptDate == null)
					return "待装订";
				else
					return "正在装订";
			}
			else
				return bindingDate == null?"":dateF.format(bindingDate);
		}
		
		//签字
		public var signAcceptDate:Date;
		public var signer:String;
		public var otherSigner:String;
		public var signDate:Date;
		public function get SignDate():String
		{			
			if(this.ReportStatus.label == "签字")
			{
				if(signAcceptDate == null)
					return "待签字";
				else
					return "正在签字";
			}
			else
				return signDate == null?"":dateF.format(signDate);
		}
		
		//报告
		public var sendAcceptDate:Date;
		//public var sendDate:Date;
		public function get SendDate():String
		{			
			if(this.ReportStatus.label == "发放及归档")
			{
				if(sendAcceptDate == null)
				{
					return "待发放";
				}
				else if(sendGetDate == null)
				{
					var sendS:SendStatusDict = SendStatusDict.dict[this.sendStatus];
					if(sendS != null)
					{
						return sendS.label;
					}
					else
					{
						return "未知状态";
					}
				}
				return dateF.format(sendGetDate);
			}
			else
				return sendGetDate == null?"":dateF.format(sendGetDate);
		}
		
		public var sendStatus:Number = 0;
		public var sendGetPeople:String = "";
		public var sendGetDate:Date;
				
		
		
		//归档
		public var fileAcceptDate:Date;
		public var filer:Number;
		public var filerName:String = "";
		public var fileDate:Date;
		public function get FileDate():String
		{			
			if(this.ReportStatus.label == "发放及归档")
			{
				if(fileAcceptDate == null)
					return "待归档";
				else if(fileDate == null)
					return "正在归档";
				else
					return dateF.format(fileDate);
			}
			else
				return fileDate == null?"":dateF.format(fileDate);
		}
		public var fileRemark:String = "";
		
		//重新受理
		public var backer:Number;
		public var backerName:String = "";
		public var backDate:Date;
		public function get BackDate():String
		{			
			return backDate == null?"":dateF.format(backDate);
		}
		public var backReson:String = "";
		public var backed:Boolean;
				
		//跟踪反馈
		public var feedbackNum:String;
				
		//退案
		public var cancelDate:Date;
		public function get CancelDate():String
		{			
			return cancelDate == null?"":dateF.format(cancelDate);
		}
		public var cancelReson:String = "";
		
		//报告状态
		public var reportStatus:Number;
		public function get ReportStatus():ReportStatusDict
		{
			return ReportStatusDict.getItem(reportStatus);
		}
		
		public var selected:Boolean = true;
		
		public function ReportVO(item:Object = null)
		{
			dateF = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd";
			
			if(item != null)
			{
				copy(item);
			}
			else
			{
				this.finishDate = new Date(this.acceptDate.fullYear
					,this.acceptDate.month
					,this.acceptDate.date + 14);
			}
		}
		
		public function copy(item:Object):void
		{
			this.id = item.ID;
			
			this.type = Number(item.类别);
			this.no = Number(item.编号);
			this.subNo = (item.次级编号  == undefined)?0:Number(item.次级编号);
			
			this.year = item.年度;
			this.acceptDate = item.受理日期;
			
			this.unitEntrust = (item.委托单位 == undefined)?"":item.委托单位;
			this.unitContact = item.委托单位联系方式;
			this.unitPeople = (item.委托单位联系人  == undefined)?"":item.委托单位联系人;
			
			this.checkedPeople = item.受检人;
			this.checkedContact = item.受检人联系方式;
			
			this.payAmount = item.应缴金额;
			this.payFirstDate = item.预收款日期;
			this.paidAmount = (item.已缴金额  == undefined)?0:item.已缴金额;
			this.payLastDate = item.尾款日期;			
			this.refund = (item.退费金额  == undefined)?0:item.退费金额;
			
			if((item.开票情况 == "发票") ||  (item.开票情况 == "收据"))
				this.billStatus = item.开票情况;
			else
				this.billStatus = "";
			
			this.billAmount = (item.开票金额  == undefined)?0:item.开票金额;
			this.billNo = (item.票号  == undefined)?"":item.票号;
			this.billDate = item.开票日期;
						
			if((item.缴费方式 == "现金") || (item.缴费方式 == "POS机")|| (item.缴费方式 == "转账"))
				this.payType = item.缴费方式;
			else 
				this.payType = "";
			
			this.commision = item.是否返佣;
			this.commisionAmount = (item.返佣金额  == undefined)?0:item.返佣金额;
			
			this.accepterAddress = item.受理地点;
			this.accepterType = (item.案件类型  == undefined)?"临床":item.案件类型;
			this.imageCount = item.影像资料;
			this.remark = item.备注;
			
			this.accepter = item.受理人;
			this.accepterName = item.受理人姓名;
			this.accepterA = item.受理人A;
			this.accepterAName = item.受理人A姓名;
			this.accepterB = item.受理人B;
			this.accepterBName = item.受理人B姓名;
			this.accepterC = item.受理人C;
			this.accepterCName = item.受理人C姓名;
			
			this.finishDate = (item.预计报告日期 == undefined)?(new Date):item.预计报告日期;
			this.finishType = Number(item.预计报告类型);
			
			this.distributeDate = item.分配日期;
			
			this.consultAcceptDate = item.会诊接受日期;
			this.consulter = (item.会诊人  == undefined)?"":item.会诊人;
			this.otherConsulter = item.其他会诊人;
			this.consultDate = item.会诊日期;
			
			this.printAcceptDate = item.打印接受日期;
			this.printer = item.打印人;
			this.printerName = item.打印人姓名;
			this.printDate = item.打印日期;
			
			this.firstExamineAcceptDate = item.初审接受日期;
			this.firstExaminer = item.初审人;
			this.firstExaminerName = item.初审人姓名;
			this.firstExamineRank = Number(item.初审分数);
			this.firstExamineDate = item.初审日期;
			
			this.lastExamineAcceptDate = item.复审接受日期;
			this.lastExaminer = item.复审人;
			this.lastExaminerName = item.复审人姓名;
			this.lastExamineRank = Number(item.复审分数);
			this.lastExamineDate = item.复审日期;
			
			this.revisionAcceptDate = item.修订接受日期;
			this.revisionDate = item.修订日期;
			
			this.bindingAcceptDate = item.装订接受日期;
			this.bindinger = item.装订人;
			this.bindingerName = item.装订人姓名;
			this.bindingDate = item.装订日期;
			
			this.signAcceptDate = item.签字接受日期;
			this.signer = (item.签字人  == undefined)?"":item.签字人;
			this.otherSigner = item.其他签字人;
			this.signDate = item.签字日期;
			
			this.sendAcceptDate = item.发放接受日期;
			this.sendStatus = item.发放状态;
			//this.sendDate = item.发放日期;
			this.sendGetPeople = item.签收人;
			this.sendGetDate = item.签收日期;
			
			this.fileAcceptDate = item.归档接受日期;
			this.filer = item.归档人;
			this.filerName = item.归档人姓名;
			this.fileDate = item.归档日期;
			this.fileRemark = item.反馈意见;
			
			this.backer = item.退回人;
			this.backerName = item.退回人姓名;
			this.backDate = item.退回日期;
			this.backReson = item.退回原因;
			this.backed = item.重新受理;
			
			this.feedbackNum = (item.反馈数量 == undefined)?"":item.反馈数量;
			
			this.cancelDate = item.退案日期;
			this.cancelReson = (item.退案原因  == undefined)?"":item.退案原因;
			
			this.reportStatus = item.案件状态;
		}
	}
}