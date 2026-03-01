using SigrunClient.API.Tabs;
using System;
using SigrunClient.API.Columns;
using CitizenFX.Core.UI;

namespace SigrunClient.API
{
	public delegate void OpenEvent(MainMenu menu);
	public delegate void CloseEvent(MainMenu menu);
	public delegate void TabChanged(MainMenu menu, BaseTab tab, int i);
	public delegate void FocusChanged(MainMenu menu, BaseTab tab, int focusLevel);
	public delegate void ColumnItemEvent(MainMenu menu, BaseTab tab, PM_COLUMNS column, int index);

	internal enum eFRONTEND_INPUT
	{
		FRONTEND_INPUT_UP = 0,
		FRONTEND_INPUT_DOWN,
		FRONTEND_INPUT_LEFT,
		FRONTEND_INPUT_RIGHT,
		FRONTEND_INPUT_RDOWN,
		FRONTEND_INPUT_RLEFT,
		FRONTEND_INPUT_RRIGHT,
		FRONTEND_INPUT_RUP,
		FRONTEND_INPUT_ACCEPT,
		FRONTEND_INPUT_X,
		FRONTEND_INPUT_Y,
		FRONTEND_INPUT_BACK,
		FRONTEND_INPUT_START,
		FRONTEND_INPUT_SPECIAL_UP,
		FRONTEND_INPUT_SPECIAL_DOWN,
		FRONTEND_INPUT_RSTICK_LEFT,
		FRONTEND_INPUT_RSTICK_RIGHT,
		FRONTEND_INPUT_LT,
		FRONTEND_INPUT_RT,
		FRONTEND_INPUT_LB,
		FRONTEND_INPUT_RB,
		FRONTEND_INPUT_LT_SPECIAL,
		FRONTEND_INPUT_RT_SPECIAL,
		FRONTEND_INPUT_SELECT,
		FRONTEND_INPUT_R3,
		// Used for pointing devices (mouse button, touch pad etc).
		FRONTEND_INPUT_CURSOR_ACCEPT,
		FRONTEND_INPUT_CURSOR_BACK,
		FRONTEND_INPUT_CURSOR_SCROLL_UP,
		FRONTEND_INPUT_CURSOR_SCROLL_DOWN,
		FRONTEND_INPUT_L3,
		FRONTEND_INPUT_MAX
	};


	public class MainMenu
	{
		/*
        ShowCursorThisFrame();
        */
		public static string AUDIO_LIBRARY = "HUD_FRONTEND_DEFAULT_SOUNDSET";
		public static string AUDIO_UPDOWN = "NAV_UP_DOWN";
		public static string AUDIO_LEFTRIGHT = "NAV_LEFT_RIGHT";
		public static string AUDIO_SELECT = "SELECT";
		public static string AUDIO_BACK = "BACK";
		public static string AUDIO_ERROR = "ERROR";
		private bool isBuilding = false;
		public List<BaseTab> Tabs { get; set; }
		private int index;
		internal bool IsHovered;
		private bool firstTick = true;
		private int eventType = 0;
		private int itemId = 0;
		private int context = 0;
		private int unused = 0;
		internal bool _mouseAllowed = true;
		internal bool _animateDescriptions = true;
		internal float _maxExtensionPixels = 450f;

		// thanks R*
		private int sm_uDisableInputDuration = 250; // milliseconds.
		private int FRONTEND_ANALOGUE_THRESHOLD = 80;  // out of 128
		private int BUTTON_PRESSED_DOWN_INTERVAL = 250;
		private int BUTTON_PRESSED_REFIRE_ATTRITION = 45;
		private int BUTTON_PRESSED_REFIRE_MINIMUM = 100;
		private int s_iLastRefireTimeUp = 250;
		private int s_iLastRefireTimeDn = 250;
		private int s_pressedDownTimer = GetGameTimer();
		private int s_lastGameFrame = 0;

		[Flags]
		enum CHECK_INPUT_OVERRIDE_FLAG : byte
		{
			CHECK_INPUT_OVERRIDE_FLAG_NONE = 0,
			CHECK_INPUT_OVERRIDE_FLAG_WARNING_MESSAGE = (1 << 0),
			CHECK_INPUT_OVERRIDE_FLAG_STORAGE_DEVICE = (1 << 1),
			CHECK_INPUT_OVERRIDE_FLAG_RESTART_SAVED_GAME_STATE = (1 << 2),
			CHECK_INPUT_OVERRIDE_FLAG_IGNORE_ANALOGUE_STICKS = (1 << 3),
			CHECK_INPUT_OVERRIDE_FLAG_IGNORE_D_PAD = (1 << 4),
			CHECK_INPUT_OVERRIDE_FLAG_IGNORE_MOUSE_WHEEL = (1 << 5)
		}


		public bool TemporarilyHidden { get; set; }
		public bool HideTabs { get; set; }

		internal Scaleform _pause;
		internal bool _loaded;

		public event OpenEvent OnMenuOpen;
		public event CloseEvent OnMenuClose;
		public event TabChanged OnTabChanged;
		public event ColumnItemEvent OnColumnItemChange;
		public event ColumnItemEvent OnColumnItemSelect;

		public MainMenu(string title)
		{
			Tabs = new List<BaseTab>();
			index = 0;
			TemporarilyHidden = false;
		}

		public bool MouseEnabled
		{
			get => _mouseAllowed;
			set
			{
				_mouseAllowed = value;
				if (Visible)
				{
					ClientMain.sigrun.CallFunction("INIT_MOUSE_EVENTS", _mouseAllowed);
				}
			}
		}

		public bool ScrollOnlyOnMenuHover { get; set; }

		public bool Visible
		{
			get { return _visible; }
			set
			{
				_visible = value;
				Game.IsPaused = value;
				if (value)
				{
					isBuilding = true;
					Tabs[0].Visible = true;
					BuildComplete();
					SendOpen();
					ClientMain.instance = this;
				}
				else
				{
					ClientMain.instance = null;
					SendClose();
					ClientMain.sigrun.Dispose();
					ClientMain.sigrun = null;
				}
			}
		}


		public int Index
		{
			get => index; set
			{
				Tabs[Index].Visible = false;
				index = value;
				if (index > Tabs.Count - 1) index = 0;
				if (index < 0) index = Tabs.Count - 1;
				Tabs[Index].Visible = true;
				ClientMain.sigrun.CallFunction("HIGHLIGHT_TAB", index);
				ClientMain.sigrun.CallFunction("SET_TABS_TITLE", CurrentTab.Title, CurrentTab.showArrow, !CurrentTab.hideTabs);
				if (Visible) Build();
				SendTabChange();
			}
		}

		public bool AnimateDescriptions { get; set; }
		public float SetMaxMenuWidth { get => _maxExtensionPixels; set => _maxExtensionPixels = value; }

		public void AddTab(BaseTab tab)
		{
			tab.Parent = this;
			Tabs.Add(tab);
		}

		private bool _visible;
		internal int focusLevel;
		private int _timer;

		public async void BuildComplete()
		{
			isBuilding = true;
			if (ClientMain.sigrun == null || ClientMain.sigrun.Handle == 0)
			{
				ClientMain.sigrun = new ScaleformWideScreen("sigrun");
				while (!ClientMain.sigrun.IsLoaded) await BaseScript.Delay(0);
			}
			ClientMain.sigrun.CallFunction("INIT_MOUSE_EVENTS", _mouseAllowed);
			ClientMain.sigrun.CallFunction("SET_TABS_SLOT_EMPTY", 0);
			for (int i = 0; i < Tabs.Count; i++)
			{
				var tab = Tabs[i];
				ClientMain.sigrun.CallFunction("SET_TABS_SLOT", i, 0, 0, 0, 0, 1, tab.txd, tab.txn, tab.TabColor, tab.isWarning, tab.animateWarning, tab.warningColor);
			}
			ClientMain.sigrun.CallFunction("DISPLAY_TABS", 0);
			ClientMain.sigrun.CallFunction("HIGHLIGHT_TAB", index);
			ClientMain.sigrun.CallFunction("SET_TABS_TITLE", CurrentTab.Title, CurrentTab.showArrow, !CurrentTab.hideTabs);
			Build();
		}

		public async void Build()
		{
			isBuilding = true;
			if (!HasStreamedTextureDictLoaded("commonmenu"))
				RequestStreamedTextureDict("commonmenu", true);
			BaseTab tab = Tabs[Index];
			ClientMain.sigrun.CallFunction("LOAD_CHILD_PAGE", tab._identifier);
			tab.Populate();
			tab.ShowColumns();
			tab.Focus();
			isBuilding = false;
		}

		private bool controller = false;
		public void Draw()
		{
			if (!Visible || TemporarilyHidden || isBuilding) return;
			ClientMain.sigrun.Render2D();
			GetIsMenuHovered();
		}
		private async void GetIsMenuHovered()
		{
			IsHovered = await ClientMain.sigrun.CallFunctionReturnValueBool("IS_MOUSE_ON_MENU");
		}
		bool changed;

		public void GoBack()
		{
			if (CurrentTab.LeftColumnStack.Count > 0)
				CurrentTab.PopColumn();
			else
				Visible = false;
		}

		public async void ProcessMouse()
		{
			if (!IsUsingKeyboard(2))
			{
				return;
			}
			// check for is using keyboard (2) to use Mouse or not.
			SetMouseCursorActiveThisFrame();
			SetInputExclusive(2, 239);
			SetInputExclusive(2, 240);
			SetInputExclusive(2, 237);
			SetInputExclusive(2, 238);

			if (_mouseAllowed && (!ScrollOnlyOnMenuHover || IsHovered))
			{
				SetInputExclusive(2, 241);
				SetInputExclusive(2, 242);
				HideHudComponentThisFrame(19);
				HideHudComponentThisFrame(20);
			}

			bool success = GetScaleformMovieCursorSelection(ClientMain.sigrun.Handle, ref eventType, ref context, ref itemId, ref unused);
			if (success)
			{
				if (context == 1000)
				{
					if (eventType == 5)
					{
						Index = itemId;
					}
				}
				else
				{
					Tabs[Index].MouseEvent(eventType, context, itemId);
				}
			}
		}


		float iPreviousXAxis = GetDisabledControlNormal(2, 195) * 128.0f;
		float iPreviousYAxis = GetDisabledControlNormal(2, 196) * 128.0f;
		float iPreviousXAxisR = GetDisabledControlNormal(2, 197) * 128.0f;
		float iPreviousYAxisR = GetDisabledControlNormal(2, 198) * 128.0f;
		private bool CheckInput(eFRONTEND_INPUT input, bool bPlaySound, CHECK_INPUT_OVERRIDE_FLAG OverrideFlags, bool bCheckForButtonJustPressed)
		{
			bool bOnlyCheckForDown = false;
			int interval = (input == eFRONTEND_INPUT.FRONTEND_INPUT_UP) ? s_iLastRefireTimeUp : (input == eFRONTEND_INPUT.FRONTEND_INPUT_DOWN) ? s_iLastRefireTimeDn : BUTTON_PRESSED_DOWN_INTERVAL;

			if (s_lastGameFrame != GetFrameCount() && GetGameTimer() > (s_pressedDownTimer + interval))
			{
				bOnlyCheckForDown = true;
			}

			bool bInputTriggered = false;

			// We use GetNorm() but we convert back to the old value range as the frontend might be heavely dependent on this range.
			float iXAxis = 0;
			float iYAxis = 0;
			float iYAxisR = 0;
			float iXAxisR = 0;

			bool c_ignoreDpad = (OverrideFlags & CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_D_PAD) != 0;
			bool c_ignoreScrollWheel = (OverrideFlags & CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_MOUSE_WHEEL) != 0;

			// not needed
			//if (!OverrideFlags.HasFlag(CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_ANALOGUE_STICKS))
			//{
			//    iXAxis = GetDisabledControlNormal(2, 195) * 128.0f;
			//    iYAxis = GetDisabledControlNormal(2, 196) * 128.0f;
			//    iYAxisR = GetDisabledControlNormal(2, 198) * 128.0f;
			//    iXAxisR = GetDisabledControlNormal(2, 197) * 128.0f;
			//}


			switch (input)
			{
				case eFRONTEND_INPUT.FRONTEND_INPUT_UP:
					{
						if (iXAxis > -FRONTEND_ANALOGUE_THRESHOLD && iXAxis < FRONTEND_ANALOGUE_THRESHOLD)
						{
							if (bOnlyCheckForDown)
							{
								if (iYAxis < -FRONTEND_ANALOGUE_THRESHOLD || (IsDisabledControlPressed(2, 188) && !c_ignoreDpad))
									bInputTriggered = true;
							}
							else if ((iPreviousYAxis > -FRONTEND_ANALOGUE_THRESHOLD && iYAxis < -FRONTEND_ANALOGUE_THRESHOLD) || (IsDisabledControlJustPressed(2, 188) && !c_ignoreDpad))
								bInputTriggered = true;
						}

						if (s_lastGameFrame != GetFrameCount())
						{
							// can't just do bInputTriggered because we may be waiting for an up
							if (iYAxis < -FRONTEND_ANALOGUE_THRESHOLD || (IsDisabledControlPressed(2, 188) && !c_ignoreDpad))
							{
								if (bInputTriggered)
									s_iLastRefireTimeUp = Math.Max(s_iLastRefireTimeUp - BUTTON_PRESSED_REFIRE_ATTRITION, BUTTON_PRESSED_REFIRE_MINIMUM);
							}
							else
								s_iLastRefireTimeUp = BUTTON_PRESSED_DOWN_INTERVAL;
						}
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_DOWN:
					{
						if (iXAxis > -FRONTEND_ANALOGUE_THRESHOLD && iXAxis < FRONTEND_ANALOGUE_THRESHOLD)
						{
							if (bOnlyCheckForDown)
							{
								if (iYAxis > FRONTEND_ANALOGUE_THRESHOLD || (IsDisabledControlPressed(2, 187) && !c_ignoreDpad))
									bInputTriggered = true;
							}
							else if ((iPreviousYAxis < FRONTEND_ANALOGUE_THRESHOLD && iYAxis > FRONTEND_ANALOGUE_THRESHOLD) || (IsDisabledControlJustPressed(2, 187) && !c_ignoreDpad))
								bInputTriggered = true;
						}

						if (s_lastGameFrame != GetFrameCount())
						{
							// can't just do bInputTriggered because we may be waiting for an up
							if (iYAxis > FRONTEND_ANALOGUE_THRESHOLD || (IsDisabledControlPressed(2, 187) && !c_ignoreDpad))
							{
								if (bInputTriggered)
									s_iLastRefireTimeDn = Math.Max(s_iLastRefireTimeDn - BUTTON_PRESSED_REFIRE_ATTRITION, BUTTON_PRESSED_REFIRE_MINIMUM);
							}
							else
								s_iLastRefireTimeDn = BUTTON_PRESSED_DOWN_INTERVAL;
						}
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_LEFT:
					{
						if (iYAxis > -FRONTEND_ANALOGUE_THRESHOLD && iYAxis < FRONTEND_ANALOGUE_THRESHOLD)
						{
							if (bOnlyCheckForDown)
							{
								if (iXAxis < -FRONTEND_ANALOGUE_THRESHOLD || (IsDisabledControlPressed(2, 189) && !c_ignoreDpad))
									bInputTriggered = true;
							}
							else if ((iPreviousXAxis > -FRONTEND_ANALOGUE_THRESHOLD && iXAxis < -FRONTEND_ANALOGUE_THRESHOLD) || (IsDisabledControlJustPressed(2, 189) && !c_ignoreDpad))
								bInputTriggered = true;
						}

						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_RIGHT:
					{
						if (iYAxis > -FRONTEND_ANALOGUE_THRESHOLD && iYAxis < FRONTEND_ANALOGUE_THRESHOLD)
						{
							if (bOnlyCheckForDown)
							{
								if (iXAxis > FRONTEND_ANALOGUE_THRESHOLD || (IsDisabledControlPressed(2, 190) && !c_ignoreDpad))
									bInputTriggered = true;

							}
							else if ((iPreviousXAxis < FRONTEND_ANALOGUE_THRESHOLD && iXAxis > FRONTEND_ANALOGUE_THRESHOLD) || (IsDisabledControlJustPressed(2, 190) && !c_ignoreDpad))
								bInputTriggered = true;
						}
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_RUP:
					{
						if (bOnlyCheckForDown)
						{
							if (iYAxisR < -FRONTEND_ANALOGUE_THRESHOLD)
								bInputTriggered = true;
						}
						else if (iPreviousYAxisR > -FRONTEND_ANALOGUE_THRESHOLD && iYAxisR < -FRONTEND_ANALOGUE_THRESHOLD)
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_RDOWN:
					{
						if (bOnlyCheckForDown)
						{
							if (iYAxisR > FRONTEND_ANALOGUE_THRESHOLD)
								bInputTriggered = true;
						}
						else if (iPreviousYAxisR < FRONTEND_ANALOGUE_THRESHOLD && iYAxisR > FRONTEND_ANALOGUE_THRESHOLD)
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_RLEFT:
					{
						if (bOnlyCheckForDown)
						{
							if (iXAxisR < -FRONTEND_ANALOGUE_THRESHOLD)
								bInputTriggered = true;
						}
						else if (iPreviousXAxisR > -FRONTEND_ANALOGUE_THRESHOLD && iXAxisR < -FRONTEND_ANALOGUE_THRESHOLD)
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_RRIGHT:
					{
						if (bOnlyCheckForDown)
						{
							if (iXAxisR > FRONTEND_ANALOGUE_THRESHOLD)
								bInputTriggered = true;
						}
						else if (iPreviousXAxisR < FRONTEND_ANALOGUE_THRESHOLD && iXAxisR > FRONTEND_ANALOGUE_THRESHOLD)
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_ACCEPT:
					{
						bool bAcceptHasBeenPressed = false;

						if (bCheckForButtonJustPressed)
						{
							if (IsDisabledControlJustPressed(2, 201))
								bAcceptHasBeenPressed = true;
						}
						else
						{
							if (IsDisabledControlJustReleased(2, 201))
								bAcceptHasBeenPressed = true;
						}

						if (bAcceptHasBeenPressed)
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_X:
					{
						if (IsDisabledControlJustReleased(2, 203))
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_Y:
					{
						if (IsDisabledControlJustReleased(2, 204))
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_BACK:
					{
						if (bCheckForButtonJustPressed)
						{
							if (IsDisabledControlJustPressed(2, 202))
								bInputTriggered = true;
						}
						else
						{
							if (IsDisabledControlJustReleased(2, 202))
								bInputTriggered = true;
						}
						// allowed fall through
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_BACK:
					{
						if (bCheckForButtonJustPressed)
						{
							if (IsDisabledControlJustPressed(0, 238))
								bInputTriggered = true;
						}
						else
						{
							if (IsDisabledControlJustReleased(0, 238))
								bInputTriggered = true;
						}

						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_START:
					{
						if (IsDisabledControlJustReleased(0, 199))
						{
							bInputTriggered = true;
							break;
						}

						if (IsDisabledControlJustReleased(0, 200))
						{
							bInputTriggered = true;
							break;
						}


						break;
					}
				case eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_UP:
					bInputTriggered = IsDisabledControlPressed(2, 241) && !c_ignoreScrollWheel;
					break;

				case eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_DOWN:
					bInputTriggered = IsDisabledControlPressed(2, 242) && !c_ignoreScrollWheel;
					break;

				case eFRONTEND_INPUT.FRONTEND_INPUT_SPECIAL_UP:
					{
						//if (GetPreviousYAxisR() > -FRONTEND_ANALOGUE_THRESHOLD && iYAxisR < -FRONTEND_ANALOGUE_THRESHOLD)
						if (iYAxisR < -FRONTEND_ANALOGUE_THRESHOLD)
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_SPECIAL_DOWN:
					{
						//if (GetPreviousYAxisR() < FRONTEND_ANALOGUE_THRESHOLD && iYAxisR > FRONTEND_ANALOGUE_THRESHOLD)
						if (iYAxisR > FRONTEND_ANALOGUE_THRESHOLD)
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_RT_SPECIAL:
				case eFRONTEND_INPUT.FRONTEND_INPUT_RT:
					{
						if (IsDisabledControlJustPressed(2, 208))
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_LT_SPECIAL:
				case eFRONTEND_INPUT.FRONTEND_INPUT_LT:
					{
						if (IsDisabledControlJustPressed(2, 207))
							bInputTriggered = true;
						break;
					}
				case eFRONTEND_INPUT.FRONTEND_INPUT_LB:
					{
						if (IsDisabledControlJustPressed(2, 205))
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_RB:
					{
						if (IsDisabledControlJustPressed(2, 206))
							bInputTriggered = true;
						break;
					}

				case eFRONTEND_INPUT.FRONTEND_INPUT_RSTICK_LEFT:
					{
						if (iXAxisR > FRONTEND_ANALOGUE_THRESHOLD)
							bInputTriggered = true;
					}
					break;

				case eFRONTEND_INPUT.FRONTEND_INPUT_RSTICK_RIGHT:
					{
						if (iXAxisR < -FRONTEND_ANALOGUE_THRESHOLD)
							bInputTriggered = true;
					}
					break;

				case eFRONTEND_INPUT.FRONTEND_INPUT_SELECT:
					{
						if (IsDisabledControlJustReleased(2, 217))
							bInputTriggered = true;
					}
					break;

				case eFRONTEND_INPUT.FRONTEND_INPUT_R3:
					{
						if (IsDisabledControlJustReleased(2, 231))
							bInputTriggered = true;
					}
					break;

				case eFRONTEND_INPUT.FRONTEND_INPUT_L3:
					{
						if (IsDisabledControlJustReleased(2, 230))
							bInputTriggered = true;
					}
					break;

				case eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_ACCEPT:
					{
						if (IsDisabledControlJustReleased(2, 237))
							bInputTriggered = true;
					}
					break;
			}

			if (bInputTriggered)
			{
				if (s_lastGameFrame != GetFrameCount())
				{
					s_pressedDownTimer = GetGameTimer();  // reset the timer to check for holding button down
					s_lastGameFrame = GetFrameCount();
					iPreviousXAxis = iXAxis;
					iPreviousYAxis = iYAxis;
					iPreviousXAxisR = iXAxisR;
					iPreviousYAxisR = iYAxisR;
				}

				if (bPlaySound)
				{
					var sound = "SELECT";
					switch (input)
					{
						case eFRONTEND_INPUT.FRONTEND_INPUT_UP:
						case eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_UP:
						case eFRONTEND_INPUT.FRONTEND_INPUT_DOWN:
						case eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_DOWN:
							sound = "NAV_UP_DOWN";
							break;
						case eFRONTEND_INPUT.FRONTEND_INPUT_LEFT:
						case eFRONTEND_INPUT.FRONTEND_INPUT_RIGHT:
							sound = "NAV_LEFT_RIGHT";
							break;
						case eFRONTEND_INPUT.FRONTEND_INPUT_BACK:
						case eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_BACK:
							sound = "BACK";
							break;
					}
					PlaySoundFrontend(-1, sound, "HUD_FRONTEND_DEFAULT_SOUNDSET", false);
				}

				//if(input == eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_ACCEPT)
				//{
				//    ClientMain.sigrun.CallFunction("CLEAR_ALL_HOVER");
				//}
			}
			return (bInputTriggered);
		}


		public void ProcessControls()
		{
			if (firstTick)
			{
				firstTick = false;
				return;
			}

			if (!Visible || TemporarilyHidden || isBuilding) return;

			CHECK_INPUT_OVERRIDE_FLAG scrollWheelFlags = CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_MOUSE_WHEEL;
			if (_mouseAllowed && (!ScrollOnlyOnMenuHover || IsHovered))
			{
				scrollWheelFlags = CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE;
			}

			if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_UP, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false))
				CurrentTab.GoUp();
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_DOWN, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false))
				CurrentTab.GoDown();
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_LEFT, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false))
				CurrentTab.GoLeft();
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_RIGHT, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false))
				CurrentTab.GoRight();
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_LB, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false))
				Index--;
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_RB, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false))
				Index++;
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_ACCEPT, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false))
				CurrentTab.Select();
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_BACK, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false) ||
				CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_BACK, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_NONE, false))
				GoBack();
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_UP, true, scrollWheelFlags, false))
				CurrentTab.LeftColumn.MouseScroll(-1);
			else if (CheckInput(eFRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_DOWN, true, scrollWheelFlags, false))
				CurrentTab.LeftColumn.MouseScroll(1);
		}

		public BaseTab CurrentTab => Tabs[Index];

		internal void SendOpen()
		{
			OnMenuOpen?.Invoke(this);
		}

		internal void SendClose()
		{
			OnMenuClose?.Invoke(this);
		}

		internal void SendTabChange()
		{
			OnTabChanged?.Invoke(this, Tabs[Index], Index);
		}

		internal void SendColumnItemSelect(Base_Column col)
		{
			OnColumnItemSelect.Invoke(this, CurrentTab, col.position, col.Index);
		}
		internal void SendColumnItemChange(Base_Column col)
		{
			OnColumnItemSelect.Invoke(this, CurrentTab, col.position, col.Index);
		}
	}
}