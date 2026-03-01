using SigrunClient.API.Columns;
using SigrunClient.API.Elements;
using SigrunClient.API.Items;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace SigrunClient.API.Tabs
{
	public class ItemListTab : BaseTab
	{
		public ItemListTab(string name, string txd, string txn, SColor color) : base(name, txd, txn, color)
		{
			_identifier = "Page_Items";
			LeftColumn = new ItemListColumn();
			RightColumn = new DescriptionListColumn();
			LeftColumn.Parent = this;
			RightColumn.Parent = this;
		}

		// please work
		public void AddItem(BaseItem item)
		{
			LeftColumn.AddItem(item);
		}

		public override void GoUp()
		{
			if (!Focused) return;
			LeftColumn.GoUp();
		}

		public override void GoDown()
		{
			if (!Focused) return;
			LeftColumn.GoDown();
		}

		public override void GoLeft()
		{
			if (!Focused) return;
			LeftColumn.GoLeft();
		}

		public override void GoRight()
		{
			if (!Focused) return;
			LeftColumn.GoRight();
		}

		public override void Select()
		{
			if (!Focused) return;
			LeftColumn.Select();
		}

		public override void MouseEvent(int eventType, int context, int index)
		{
			var lCol = ((ItemListColumn)LeftColumn);
			switch (eventType)
			{
				case 5:
					if (index == lCol.index)
					{
						lCol.Select();
						return;
					}
					lCol.CurrentSelection = index;
					break;
				case 8:
				case 9:
					lCol.HandleHovering(eventType, index);
					break;
			}
		}

		public void MouseScroll(int dir)
		{
			((ItemListColumn)LeftColumn).MouseScroll(dir);
		}

		public override void Focus()
		{
			base.Focus();
			var lCol = ((ItemListColumn)LeftColumn);
			ClientMain.sigrun.CallFunction("SET_COLUMN_FOCUS", (int)lCol.position, Focused, false, false);
			lCol.Index = lCol.index;
			lCol.UpdateDescription();
			ClientMain.sigrun.CallFunction("SET_COLUMN_HIGHLIGHT", (int)lCol.position, lCol.index);
			lCol.CurrentItem.Selected = true;
		}

		public override void UnFocus()
		{
			var lCol = ((ItemListColumn)LeftColumn);
			lCol.CurrentItem.Selected = false;
			base.UnFocus();
		}

		public override void Populate()
		{
			var lCol = ((ItemListColumn)LeftColumn);
			ClientMain.sigrun.CallFunction("SET_TITLE", (int)lCol.position, Title);
			lCol.Populate();
			lCol.CurrentItem.Selected = true;
		}

		public override void ShowColumns()
		{
			LeftColumn.ShowColumn();
		}
	}
}
