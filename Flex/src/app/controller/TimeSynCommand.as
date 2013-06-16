package app.controller
{
	import app.ApplicationFacade;
	
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.formatters.DateTimeFormatter;
	
	public class TimeSynCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void
		{			 			
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd";
			
			ApplicationFacade.NOW = dateF.format(new Date);
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,["SELECT Format(Now(),'yyyy-mm-dd') AS NOW"]
					,false
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				if(result.length > 0)
				{					
					ApplicationFacade.NOW = result[0].NOW;
				}
				
				flash.utils.setTimeout(sendNotification,10000,ApplicationFacade.NOTIFY_TIME_SYN);
			}
		}
	}
}