package application
{
	import gframeWork.uiController.JT_UserInterfaceManager;

	public class AppUI
	{
		
		public static const MAINUI_PANEL:int = 1;
		
		public function AppUI()
		{
			JT_UserInterfaceManager.registerGUI(AppUI.MAINUI_PANEL,MainPanel,MainUIControler);
		}
	}
}