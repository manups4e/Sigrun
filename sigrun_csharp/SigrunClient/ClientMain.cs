global using CitizenFX.Core;
global using static CitizenFX.Core.Native.API;
global using System.Collections.Generic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SigrunClient.API;

namespace SigrunClient
{
	public class ClientMain : BaseScript
	{
		/*
			You can move and / or replace this whole file within your own logic..
			make sure to keep the scaleform and instance logic because tabview and the whole API depends on these.
			⚠️ This is basically the whole "if it's set as visible.. draw it and handle it"
		*/
		internal static ScaleformWideScreen sigrun { get; set; }
		internal static MainMenu instance { get; set; }
		private bool allowMouse = true;

		public ClientMain()
		{
			EventHandlers["onResourceStop"] += new Action<string>(OnStop);
			Tick += ControlTick;
			Tick += RenderTick;
		}

		private async Task ControlTick()
		{
			if (instance != null && instance.Visible)
			{
				if (instance._mouseAllowed && IsUsingKeyboard(2))
				{
					if (!allowMouse)
					{
						allowMouse = true;
						sigrun.CallFunction("INIT_MOUSE_EVENTS", allowMouse);
					}
					instance.ProcessMouse();
				}
				else
				{
					if (allowMouse)
					{
						allowMouse = false;
						sigrun.CallFunction("INIT_MOUSE_EVENTS", allowMouse);
					}
				}
				instance.ProcessControls();
			}
		}

		private async Task RenderTick()
		{
			if (instance != null && instance.Visible)
			{
				instance.Draw();
			}
		}

		private void OnStop(string resName)
		{
			if (resName == GetCurrentResourceName())
			{
				if (sigrun != null && sigrun.IsLoaded)
					sigrun.Dispose();
			}
		}


	}
}
