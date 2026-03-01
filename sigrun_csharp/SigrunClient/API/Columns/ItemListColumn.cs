using SigrunClient.API.Elements;
using SigrunClient.API.Items;
using SigrunClient.Elements;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace SigrunClient.API.Columns
{
	public delegate void ItemSelected(MenuItem item, int index);
	public class ItemListColumn : Base_Column
	{
		public event IndexChanged OnIndexChanged;
		private List<BaseItem> _unfilteredItems;
		private int _unfilteredSelection;
		public event ItemSelected OnSettingItemActivated;
		private int _topEdge = 0;
		private float mWidth = 300f;
		private int _currentlyHighlighted = -1;

		public ItemListColumn(string label, int maxItems = 12) : base(0)
		{
			Label = label;
			VisibleItems = maxItems;
		}

		public ItemListColumn() : base(0)
		{
			Label = "";
			VisibleItems = 12;
		}

		public void SetVisibleItems(int maxItems)
		{
			VisibleItems = maxItems;
			if (visible)
			{
				Populate();
				ShowColumn();
			}
		}

		public override void AddItem(BaseItem item)
		{
			AddMenuItem((MenuItem)item);
		}
		public void AddMenuItem(MenuItem item)
		{
			item.ParentColumn = this;
			if (item.MainColor.ArgbValue == SColor.HUD_Pause_bg.ArgbValue)
			{
				item.MainColor = (Items.Count % 2 == 0) ? SColor.HUD_Pausemap_tint : SColor.HUD_Pause_bg;
			}
			Items.Add(item);
			if (visible && Items.Count <= VisibleItems)
			{
				var idx = Items.Count - 1;
				AddSlot(idx);
				UpdateDescription();
				item.Selected = idx == index;
			}
		}

		public void RemoveItem(MenuItem item)
		{
			if (Items.Contains(item))
			{
				int idx = Items.IndexOf(item);
				RemoveSlot(idx);
				UpdateDescription();
			}
		}

		public void RemoveItemAt(int index)
		{
			if (index >= Items.Count) return;
			RemoveSlot(index);
			UpdateDescription();
		}

		public override void RemoveSlot(int idx)
		{
			base.RemoveSlot(idx);
			UpdateDescription();
		}

		private float GetStringWidth(string label)
		{
			SetTextFont(0); // set the default font to $Font2 or Chalet-London (classic)
			SetTextScale(0.0f, 0.35f); // FIX this makes the text the right size for the screen.
			BeginTextCommandGetWidth(label);
			return EndTextCommandGetWidth(true) * 1280; // we want it in scaleform size.
		}
		public override void ShowColumn(bool show = true)
		{
			if (!visible) return;
			base.ShowColumn(show);
			ClientMain.sigrun.CallFunction("SET_COLUMN_FOCUS", (int)position, Focused, false, false);
			if (Items.Count > 0 && CurrentItem is MenuSeparatorItem it && it.Jumpable)
			{
				CurrentItem.Selected = false;
				index++;
				if (index >= Items.Count)
					index = 0;
				CurrentItem.Selected = true;
			}
			ClientMain.sigrun.CallFunction("UPDATE_MENU_WIDTH", mWidth, Parent.Parent._maxExtensionPixels);
			InitColumnScroll(Items.Count >= VisibleItems, VisibleItems, Items.Count, index);
			SetColumnScroll(Items.Count >= VisibleItems, index);
		}

		public override void Populate()
		{
			if (!visible) return;
			ClientMain.sigrun.CallFunction("SET_DATA_SLOT_EMPTY", (int)position);
			ClientMain.sigrun.CallFunction("SET_COLUMN_MAX_ITEMS", (int)position, VisibleItems);
			ClientMain.sigrun.CallFunction("INIT_SCROLL_BAR", (int)position, false, 0, 0, 0);
			for (var i = 0; i < Items.Count; i++)
			{
				SetDataSlot(i);
			}
		}

		public override void SetDataSlot(int index)
		{
			if (index >= Items.Count) return;
			if (visible)
				SendItemToScaleform(index);

			float lwidth = GetStringWidth("SIGRUN_ITMLST_LBL");
			float rwidth = GetStringWidth("SIGRUN_ITMLST_RLBL");
			if (Math.Round(rwidth, 2) == 1.28f)
				rwidth = GetStringWidth("SIGRUN_ITMLST_LSTITM_RLBL");
			float totW = lwidth + rwidth;
			if (totW > mWidth )
				mWidth = totW;	
		}

		public override void UpdateSlot(int index)
		{
			if (index >= Items.Count) return;
			if (visible)
				SendItemToScaleform(index, true);
			float lwidth = GetStringWidth("SIGRUN_ITMLST_LBL");
			float rwidth = GetStringWidth("SIGRUN_ITMLST_RLBL");
			if (Math.Round(rwidth, 2) == 1.28f)
				rwidth = GetStringWidth("SIGRUN_ITMLST_LSTITM_RLBL");
			float totW = lwidth + rwidth;
			if(totW > mWidth)
				mWidth = totW;
		}

		public override void AddSlot(int index)
		{
			if (index >= Items.Count) return;
			if (visible)
				SendItemToScaleform(index, false, false, true);
			float lwidth = GetStringWidth("SIGRUN_ITMLST_LBL");
			float rwidth = GetStringWidth("SIGRUN_ITMLST_RLBL");
			if (Math.Round(rwidth, 2) == 1.28f)
				rwidth = GetStringWidth("SIGRUN_ITMLST_LSTITM_RLBL");
			float totW = lwidth + rwidth;
			if(totW > mWidth )
				mWidth = totW;
		}

		public void AddItemAt(MenuItem item, int idx)
		{
			if (!visible) return;
			if (idx >= Items.Count) return;
			Items.Insert(idx, item);
			if (visible)
			{
				SendItemToScaleform(idx, false, true, false);
				item.Selected = idx == index;
				float lwidth = GetStringWidth("SIGRUN_ITMLST_LBL");
				float rwidth = GetStringWidth("SIGRUN_ITMLST_RLBL");
				if (Math.Round(rwidth, 2) == 1.28f)
					rwidth = GetStringWidth("SIGRUN_ITMLST_LSTITM_RLBL");
				float totW = lwidth + rwidth;
				if(totW > mWidth )
					mWidth = totW;
			}
		}

		internal void SendItemToScaleform(int i, bool update = false, bool newItem = false, bool isSlot = false)
		{
			if (i >= Items.Count) return;

			MenuItem item = (MenuItem)Items[i];
			string str = "SET_DATA_SLOT";
			if (update)
				str = "UPDATE_DATA_SLOT";
			if (newItem)
				str = "SET_DATA_SLOT_SPLICE";
			if (isSlot)
				str = "ADD_SLOT";

			AddTextEntry("SIGRUN_ITMLST_LSTITM_RLBL", "");
			AddTextEntry("SIGRUN_ITMLST_RLBL", "");


			BeginScaleformMovieMethod(ClientMain.sigrun.Handle, str);
			PushScaleformMovieFunctionParameterInt((int)position);
			PushScaleformMovieFunctionParameterInt(i);
			PushScaleformMovieFunctionParameterInt(0);
			PushScaleformMovieFunctionParameterInt(0);
			PushScaleformMovieFunctionParameterInt(item._itemId);
			switch (item._itemId)
			{
				case 1:
					MenuDynamicListItem dit = (MenuDynamicListItem)item;
					AddTextEntry("SIGRUN_ITMLST_LSTITM_RLBL", dit.CurrentListItem);
					BeginTextCommandScaleformString("SIGRUN_ITMLST_LSTITM_RLBL");
					EndTextCommandScaleformString_2();
					break;
				case 2:
					MenuCheckboxItem check = (MenuCheckboxItem)item;
					PushScaleformMovieMethodParameterBool(check.Checked);
					break;
				case 3:
					MenuSliderItem prItem = (MenuSliderItem)item;
					PushScaleformMovieFunctionParameterInt(prItem.Value);
					break;
				case 4:
					MenuProgressItem slItem = (MenuProgressItem)item;
					PushScaleformMovieFunctionParameterInt(slItem.Value);
					break;
				default:
					PushScaleformMovieFunctionParameterInt(0);
					break;
			}
			PushScaleformMovieFunctionParameterBool(item.Enabled);
			AddTextEntry("SIGRUN_ITMLST_LBL", item.Label);
			BeginTextCommandScaleformString("SIGRUN_ITMLST_LBL");
			EndTextCommandScaleformString_2();
			PushScaleformMovieFunctionParameterBool(false); // ex blinkDesc.. unused here
			switch (item)
			{
				case MenuDynamicListItem:
					PushScaleformMovieFunctionParameterInt(item.MainColor.ArgbValue);
					PushScaleformMovieFunctionParameterInt(item.HighlightColor.ArgbValue);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXD);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXN);
					PushScaleformMovieMethodParameterString(item.labelFont);
					PushScaleformMovieMethodParameterString(item.rightLabelFont);
					break;
				case MenuCheckboxItem check:
					PushScaleformMovieFunctionParameterInt((int)check.Style);
					PushScaleformMovieFunctionParameterInt(check.MainColor.ArgbValue);
					PushScaleformMovieFunctionParameterInt(check.HighlightColor.ArgbValue);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXD);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXN);
					PushScaleformMovieMethodParameterString(item.labelFont);
					break;
				case MenuSliderItem prItem:
					PushScaleformMovieFunctionParameterInt(prItem._max);
					PushScaleformMovieFunctionParameterInt(prItem._multiplier);
					PushScaleformMovieFunctionParameterInt(prItem.MainColor.ArgbValue);
					PushScaleformMovieFunctionParameterInt(prItem.HighlightColor.ArgbValue);
					PushScaleformMovieFunctionParameterInt(prItem.SliderColor.ArgbValue);
					PushScaleformMovieFunctionParameterBool(prItem._heritage);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXD);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXN);
					PushScaleformMovieMethodParameterString(item.labelFont);
					break;
				case MenuProgressItem slItem:
					PushScaleformMovieFunctionParameterInt(slItem._max);
					PushScaleformMovieFunctionParameterInt(slItem._multiplier);
					PushScaleformMovieFunctionParameterInt(slItem.MainColor.ArgbValue);
					PushScaleformMovieFunctionParameterInt(slItem.HighlightColor.ArgbValue);
					PushScaleformMovieFunctionParameterInt(slItem.SliderColor.ArgbValue);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXD);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXN);
					PushScaleformMovieMethodParameterString(item.labelFont);
					break;
				case MenuSeparatorItem separatorItem:
					PushScaleformMovieFunctionParameterBool(separatorItem.Jumpable);
					PushScaleformMovieFunctionParameterInt(item.MainColor.ArgbValue);
					PushScaleformMovieFunctionParameterInt(item.HighlightColor.ArgbValue);
					PushScaleformMovieMethodParameterString(item.labelFont);
					break;
				default:
					PushScaleformMovieFunctionParameterInt(item.MainColor.ArgbValue);
					PushScaleformMovieFunctionParameterInt(item.HighlightColor.ArgbValue);
					AddTextEntry("SIGRUN_ITMLST_RLBL", item.RightLabel);
					BeginTextCommandScaleformString("SIGRUN_ITMLST_RLBL");
					EndTextCommandScaleformString_2();
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXD);
					PushScaleformMovieMethodParameterString(item.customLeftBadge.TXN);
					PushScaleformMovieMethodParameterString(item.customRightBadge.TXD);
					PushScaleformMovieMethodParameterString(item.customRightBadge.TXN);
					PushScaleformMovieMethodParameterString(item.labelFont);
					PushScaleformMovieMethodParameterString(item.rightLabelFont);
					break;
			}
			PushScaleformMovieFunctionParameterBool(item.KeepTextColorWhite);
			string exstr = string.Format("{0},{1},{2},{3},{4},{5},{6}",
				item.isImportant,
				item.importantColor.ToArgb(),
				item.importantAnimate,
				item.customLeftBadge.MainColor.ToArgb(),
				item.customLeftBadge.HighlightColor.ToArgb(),
				item.customRightBadge.MainColor.ToArgb(),
				item.customRightBadge.HighlightColor.ToArgb());
			AddTextEntry("SIGRUN_EXTRA_PARAM", exstr);
			BeginTextCommandScaleformString("SIGRUN_EXTRA_PARAM");
			EndTextCommandScaleformString(); // no weird conversions needed
			EndScaleformMovieMethod();
		}

		public void UpdateDescription()
		{
			AddTextEntry("Sigrun_Description_0", CurrentItem.Descriptions[0].Label ?? "");
			AddTextEntry("Sigrun_Description_1", CurrentItem.Descriptions[1].Label ?? "");
			AddTextEntry("Sigrun_Description_2", CurrentItem.Descriptions[2].Label ?? "");
			((DescriptionListColumn)Parent.RightColumn).UpdateSlot(0, CurrentItem);
			((DescriptionListColumn)Parent.RightColumn).UpdateSlot(1, CurrentItem);
			((DescriptionListColumn)Parent.RightColumn).UpdateSlot(2, CurrentItem);
		}

		public void PreviewDescription(int idx)
		{
			MenuItem item = (MenuItem)Items[idx];
			AddTextEntry("Sigrun_Description_0", item.Descriptions[0].Label ?? "");
			AddTextEntry("Sigrun_Description_1", item.Descriptions[1].Label ?? "");
			AddTextEntry("Sigrun_Description_2", item.Descriptions[2].Label ?? "");
			((DescriptionListColumn)Parent.RightColumn).UpdateSlot(0, item);
			((DescriptionListColumn)Parent.RightColumn).UpdateSlot(1, item);
			((DescriptionListColumn)Parent.RightColumn).UpdateSlot(2, item);
		}

		public override async void GoUp()
		{
			if (!visible || Items.Count == 0) return;
			try
			{
				bool didWrap = false;
				CurrentItem.Selected = false;
				do
				{
					index--;
					if (index < 0)
					{
						index = Items.Count - 1;
						didWrap = true;
					}
					await BaseScript.Delay(0);
				}
				while (CurrentItem is MenuSeparatorItem sp && sp.Jumpable);
				if (didWrap)
				{
					_topEdge = Items.Count - VisibleItems;
					if (_topEdge < 0) _topEdge = 0;
				}
				else if (index < _topEdge)
					_topEdge = index;

				bool isScrollVisible = Items.Count >= VisibleItems;
				SetColumnScroll(isScrollVisible, index);
				CurrentItem.Selected = true;
				IndexChangedEvent();
				ClientMain.sigrun.CallFunction("SET_COLUMN_HIGHLIGHT", (int)position, index);
				if (_currentlyHighlighted != -1)
				{
					PreviewDescription(_currentlyHighlighted);
					int relativeDescIdx = _currentlyHighlighted - _topEdge;
					SendDescriptionCommand(relativeDescIdx);
				}
				else
				{
					UpdateDescription();
					SendDescriptionCommand(index - _topEdge);
				}
			}
			catch (Exception e)
			{
				Debug.WriteLine(e.ToString());
			}
		}

		public override async void GoDown()
		{
			if (!visible || Items.Count == 0) return;
			try
			{
				bool didWrap = false;
				CurrentItem.Selected = false;
				do
				{
					index++;
					if (index >= Items.Count)
					{
						index = 0;
						didWrap = true;
					}
					await BaseScript.Delay(0);
				}
				while (CurrentItem is MenuSeparatorItem sp && sp.Jumpable);
				if (didWrap)
				{
					_topEdge = 0;
				}
				else if (index < _topEdge)
				{
					int visibleEnd = _topEdge + VisibleItems;
					if (index > visibleEnd)
						_topEdge = index - VisibleItems;
				}
				bool isScrollVisible = Items.Count >= VisibleItems;
				SetColumnScroll(isScrollVisible, index);
				CurrentItem.Selected = true;
				IndexChangedEvent();
				ClientMain.sigrun.CallFunction("SET_COLUMN_HIGHLIGHT", (int)position, index);
				if (_currentlyHighlighted != -1)
				{
					PreviewDescription(_currentlyHighlighted);
					int relativeDescIdx = _currentlyHighlighted - _topEdge;
					SendDescriptionCommand(relativeDescIdx);
				}
				else
				{
					UpdateDescription();
					SendDescriptionCommand(index - _topEdge);
				}
			}
			catch (Exception e)
			{
				Debug.WriteLine(e.ToString());
			}
		}

		public override async void GoLeft()
		{
			if (!visible) return;
			if (!CurrentItem.Enabled)
			{
				Game.PlaySound(MainMenu.AUDIO_ERROR, MainMenu.AUDIO_LIBRARY);
				return;
			}
			switch (CurrentItem)
			{
				case MenuListItem it:
					{
						it.Index--;
						it.ListChangedTrigger(it.Index);
						break;
					}
				case MenuDynamicListItem it:
					{
						string newItem = await it.Callback(it, ChangeDirection.Left);
						it.CurrentListItem = newItem;
						break;
					}
				case MenuSliderItem it:
					{
						it.Value -= it.Multiplier;
						break;
					}
				case MenuProgressItem it:
					{
						it.Value -= it.Multiplier;
						break;
					}
			}
			UpdateDescription();
			SendDescriptionCommand(index - _topEdge);
		}

		public override async void GoRight()
		{
			if (!visible) return;
			if (!CurrentItem.Enabled)
			{
				Game.PlaySound(MainMenu.AUDIO_ERROR, MainMenu.AUDIO_LIBRARY);
				return;
			}
			switch (CurrentItem)
			{
				case MenuListItem it:
					{
						it.Index++;
						it.ListChangedTrigger(it.Index);
						break;
					}
				case MenuDynamicListItem it:
					{
						string newItem = await it.Callback(it, ChangeDirection.Left);
						it.CurrentListItem = newItem;
						break;
					}
				case MenuSliderItem it:
					{
						it.Value += it.Multiplier;
						break;
					}
				case MenuProgressItem it:
					{
						it.Value += it.Multiplier;
						break;
					}
			}
			UpdateDescription();
			SendDescriptionCommand(index - _topEdge);
		}

		public override void Select()
		{
			if (!visible) return;
			MenuItem item = CurrentItem;
			if (!item.Enabled)
			{
				Game.PlaySound(MainMenu.AUDIO_ERROR, MainMenu.AUDIO_LIBRARY);
				return;
			}
			switch (item)
			{
				case MenuCheckboxItem it:
					{
						it.Checked = !it.Checked;
						it.CheckboxEventTrigger();
						break;
					}
				case MenuListItem it:
					{
						it.ListSelectedTrigger(it.Index);
						item.ItemActivate();
						SelectItem();
						break;
					}
				default:
					item.ItemActivate();
					SelectItem();
					break;
			}
			UpdateDescription();
		}

		public async override void MouseScroll(int dir)
		{
			if (!visible || Items.Count == 0) return;

			if (!ScrollNewStyle)
			{
				if (dir == 1) GoDown();
				else GoUp();
				return;
			}

			int numItems = Items.Count;
			int maxVisible = VisibleItems;
			int maxTopEdge = numItems - maxVisible;

			if (maxTopEdge < 0) maxTopEdge = 0;

			int oldTopEdge = _topEdge;
			int newTopEdge = _topEdge + dir;

			if (newTopEdge < 0) newTopEdge = 0;
			if (newTopEdge > maxTopEdge) newTopEdge = maxTopEdge;
			if (newTopEdge == oldTopEdge) return;

			int actualDelta = newTopEdge - _topEdge;
			_topEdge = newTopEdge;

			int visibleStart = _topEdge;
			int visibleEnd = _topEdge + maxVisible - 1;
			bool indexChanged = false;
			int targetIndex = index;

			if (index < visibleStart)
			{
				targetIndex = visibleStart;
				while (targetIndex < visibleEnd && targetIndex < numItems - 1 && Items[targetIndex] is MenuSeparatorItem sp && sp.Jumpable)
				{
					await BaseScript.Delay(0);
					targetIndex++;
				}
			}
			else if (index > visibleEnd)
			{
				targetIndex = visibleEnd;
				while (targetIndex > visibleStart && Items[targetIndex] is MenuSeparatorItem sp && sp.Jumpable)
				{
					await BaseScript.Delay(0);
					targetIndex--;
				}
			}

			if (targetIndex != index)
			{
				CurrentItem.Selected = false;
				index = targetIndex;
				CurrentItem.Selected = true;
				indexChanged = true;
			}

			ClientMain.sigrun.CallFunction("SET_INPUT_EVENT", (int)position, dir);

			if (indexChanged)
			{
				ClientMain.sigrun.CallFunction("SET_COLUMN_HIGHLIGHT", (int)position, index);
				IndexChangedEvent();
			}

			SetColumnScroll(numItems >= maxVisible, _topEdge);

			if (_currentlyHighlighted != -1)
			{
				int predictedHoverIndex = _currentlyHighlighted + actualDelta;

				if (predictedHoverIndex >= 0 && predictedHoverIndex < numItems)
				{
					if (Items[_currentlyHighlighted] is MenuItem oldItem) oldItem.Hovered = false;

					_currentlyHighlighted = predictedHoverIndex;

					if (Items[_currentlyHighlighted] is MenuItem newItem)
					{
						newItem.Hovered = true;
						PreviewDescription(_currentlyHighlighted);
						int relativeDescIdx = _currentlyHighlighted - _topEdge;
						SendDescriptionCommand(relativeDescIdx);
					}
				}
				else
				{
					int relativeSelectionIdx = _currentlyHighlighted - _topEdge;
					UpdateDescription();
					SendDescriptionCommand(relativeSelectionIdx);
				}
			}
			else
			{
				int relativeSelectionIdx = index - _topEdge;
				UpdateDescription();
				SendDescriptionCommand(relativeSelectionIdx);
			}
		}

		public void HandleHovering(int type, int item)
		{
			if (Items.Count == 0) return;
			MenuItem _item = (MenuItem)Items[item];
			MenuItem oldItem = null;
			if (_currentlyHighlighted != -1)
				oldItem = (MenuItem)Items[_currentlyHighlighted];
			switch (type)
			{
				case 9: // hovered
					if (!_item.Hovered)
					{
						oldItem?.Hovered = false;
						_currentlyHighlighted = item;
						_item.Hovered = true;
						if (_item.HasDescriptions)
						{
							PreviewDescription(item);
							SendDescriptionCommand(item - _topEdge);
						}
						else
						{
							UpdateDescription();
							SendDescriptionCommand(index - _topEdge);
						}
					}
					break;
				case 8:
					oldItem?.Hovered = false;
					_currentlyHighlighted = -1;
					_item.Hovered = false;
					UpdateDescription();
					SendDescriptionCommand(index - _topEdge);
					break;
			}
		}

		public MenuItem CurrentItem => (MenuItem)Items[Index];
		public int CurrentSelection
		{
			get => index;
			set
			{
				CurrentItem.Selected = false;
				index = value;
				if (index < 0)
					index = Items.Count - 1;
				else if (index >= Items.Count)
					index = 0;
				CurrentItem.Selected = true;

				if (visible)
				{
					UpdateDescription();
					ClientMain.sigrun.CallFunction("SET_COLUMN_HIGHLIGHT", (int)position, index, true, true);
				}
				IndexChangedEvent();
			}
		}

		public void UpdateItemLabels(int index, string leftLabel, string rightLabel)
		{
			if (visible)
			{
				if (index >= Items.Count) return;
				((MenuItem)Items[index]).Label = leftLabel;
				((MenuItem)Items[index]).SetRightLabel(rightLabel);
			}
		}

		public void UpdateItemLabel(int index, string label)
		{
			if (visible)
			{
				if (index >= Items.Count) return;
				((MenuItem)Items[index]).Label = label;
			}
		}

		public void UpdateItemRightLabel(int index, string label)
		{
			if (visible)
			{
				if (index >= Items.Count) return;
				((MenuItem)Items[index]).SetRightLabel(label);
			}
		}

		public void UpdateItemLeftBadge(int index, string txd, string txn, SColor mainColor, SColor highlightColor)
		{
			if (visible)
			{
				if (index >= Items.Count) return;
				((MenuItem)Items[index]).SetLeftBadge(txd, txn, mainColor, highlightColor);
			}
		}

		public void UpdateItemRightBadge(int index, string txd, string txn, SColor mainColor, SColor highlightColor)
		{
			if (visible)
			{
				if (index >= Items.Count) return;
				((MenuItem)Items[index]).SetRightBadge(txd, txn, mainColor, highlightColor);
			}
		}

		public void EnableItem(int index, bool enable)
		{
			if (visible)
			{
				if (index >= Items.Count) return;
				((MenuItem)Items[index]).Enabled = enable;
			}
		}

		public void SortSettings(Comparison<MenuItem> compare)
		{
			if (!visible) return;
			try
			{
				CurrentItem.Selected = false;
				_unfilteredItems = Items.ToList();
				_unfilteredSelection = CurrentSelection;
				Clear();
				List<MenuItem> list = _unfilteredItems.Cast<MenuItem>().ToList();
				list.Sort(compare);
				Items = list.Cast<BaseItem>().ToList();
				if (visible)
				{
					Populate();
					ShowColumn();
				}
			}
			catch (Exception ex)
			{
				ResetFilter();
				Debug.WriteLine("Sigrun - " + ex.ToString());
			}
		}

		public void FilterSettings(Func<MenuItem, bool> predicate)
		{
			if (!visible) return;
			if (predicate == null)
				throw new ArgumentNullException(nameof(predicate));
			try
			{
				_unfilteredItems = Items.ToList();
				_unfilteredSelection = CurrentSelection;
				//_unfilteredTopEdge = topEdge;

				var filteredItems = Items.Cast<MenuItem>().Where(predicate).ToList();

				if (!filteredItems.Any())
				{
					Debug.WriteLine("^1Sigrun - No items were found, resetting the filter");
					_unfilteredItems.Clear();
					_unfilteredSelection = 0;
					//_unfilteredTopEdge = 0;
					return;
				}

				Items[CurrentSelection].Selected = false;
				Clear();

				Items = filteredItems.Cast<BaseItem>().ToList();
				CurrentSelection = 0;
				//topEdge = 0;

				if (visible)
				{
					Populate();
					ShowColumn();
				}
			}
			catch (Exception ex)
			{
				ResetFilter();
				Debug.WriteLine($"^1Sigrun - Error filtering menu items: {ex}");
				throw;
			}
		}

		public void ResetFilter()
		{
			if (!visible) return;
			try
			{
				if (_unfilteredItems != null && _unfilteredItems.Count > 0)
				{
					CurrentItem.Selected = false;
					Clear();
					Items = _unfilteredItems.ToList();
					CurrentSelection = _unfilteredSelection;
					if (visible)
					{
						Populate();
						ShowColumn();
					}
				}
			}
			catch (Exception ex)
			{
				Debug.WriteLine("Sigrun - " + ex.ToString());
			}
		}

		public override void ClearColumn()
		{
			base.ClearColumn();
			AddTextEntry("Sigrun_Description_0", "");
			AddTextEntry("Sigrun_Description_1", "");
			AddTextEntry("Sigrun_Description_2", "");
			UpdateDescription();
			SetColumnScroll(false, 0);
		}

		public void SelectItem()
		{
			OnSettingItemActivated?.Invoke(CurrentItem, CurrentSelection);
		}
		public void IndexChangedEvent()
		{
			OnIndexChanged?.Invoke(CurrentSelection);
		}

		public void SendDescriptionCommand(int index)
		{
			if (visible)
			{
				ClientMain.sigrun.CallFunction("SET_DESCRIPTION", (int)position, index, Parent.Parent._animateDescriptions);
			}
		}
	}
}
