package
{
	import flash.events.MouseEvent;
	
	import gframeWork.uiController.JT_MainUIControllerBase;
	import gframeWork.uiController.JT_UIControllerBase;
	
	import mx.events.FlexEvent;
	
	public class MainUIControler extends JT_MainUIControllerBase
	{
		private var in_out_proxy:ImportAndOutDirectorProxy;
		
		public function MainUIControler()
		{
			super();
		}
		
		
		protected override function uiCreateComplete(event:FlexEvent):void
		{
			super.uiCreateComplete(event);
			in_out_proxy = new ImportAndOutDirectorProxy();
		}
		
		public override function dispose():void
		{
			if(in_out_proxy)
			{
				in_out_proxy.dispose();
				in_out_proxy = null;
			}
		}
		
		public function get gui():MainPanel
		{
			return mGUI as MainPanel;
		}
	}
}