using CitizenFX.Core.Native;
using SigrunClient.API.Columns;
using SigrunClient.API.Elements;
using SigrunClient.API.Tabs;
using System.Linq;

namespace SigrunClient.API.Items
{
	public delegate void ItemActivatedEvent(ItemListColumn sender, MenuItem selectedItem);
	public delegate void ItemHighlightedEvent(ItemListColumn sender, MenuItem selectedItem);


	/// <summary>
	/// Simple item with a label.
	/// </summary>
	public class MenuItem : BaseItem
	{
		internal int _itemId = 0;
		internal bool _selected = false;
		private string _label = "";
		private string _rightLabel = "";
		private bool _enabled;
		private bool blinkDescription;
		internal SColor mainColor;
		internal SColor highlightColor;
		internal string labelFont = "$Font2";
		internal string rightLabelFont = "$Font2";
		internal Badge customLeftBadge = new Badge("", "", SColor.HUD_White, SColor.HUD_Black);
		internal Badge customRightBadge = new Badge("", "", SColor.HUD_White, SColor.HUD_Black);
		internal List<Description> Descriptions = new List<Description>()
		{
			new Description(),
			new Description(),
			new Description()
		};
		internal bool isImportant;
		internal SColor importantColor;
		internal bool importantAnimate;

		/// <summary>
		///     This will override all the text color formatting to a pure white color both when highlighted and not.
		/// </summary>
		public bool KeepTextColorWhite = false;

		/// <summary>
		/// The item color when not highlighted
		/// </summary>
		public SColor MainColor
		{
			get => mainColor;
			set
			{
				mainColor = value;
				if (ParentColumn != null && ParentColumn.visible)
					ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
			}
		}
		/// <summary>
		/// The item color when highlighted
		/// </summary>
		public SColor HighlightColor
		{
			get => highlightColor;
			set
			{
				highlightColor = value;
				if (ParentColumn != null && ParentColumn.visible)
					ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
			}
		}
		/// <summary>
		/// The item text color when not highlighted
		/// </summary>

		public string LabelFont
		{
			get => labelFont;
			set
			{
				labelFont = value;
				if (ParentColumn != null && ParentColumn.visible)
					ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
			}
		}

		public string RightLabelFont
		{
			get => rightLabelFont;
			set
			{
				rightLabelFont = value;
				if (ParentColumn != null && ParentColumn.visible)
					ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
			}
		}


		// Allows you to attach data to a menu item if you want to identify the menu item without having to put identification info in the visible text or description.
		// Taken from MenuAPI (Thanks Tom).
		public dynamic ItemData { get; set; }


		/// <summary>
		/// Whether this item is currently selected.
		/// </summary>
		public override bool Selected
		{
			get => _selected;
			set
			{
				_selected = value;
				if (value)
					Highlighted?.Invoke(ParentColumn, this);
				if (ParentColumn != null && ParentColumn.visible)
					ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
			}
		}


		/// <summary>
		/// Whether this item is currently being hovered on with a mouse.
		/// </summary>
		public virtual bool Hovered { get; internal set; }


		public bool HasDescriptions => Descriptions.Any(x => !string.IsNullOrWhiteSpace(x.Label));

		/// <summary>
		/// Whether this item is enabled or disabled (text is greyed out and you cannot select it).
		/// </summary>
		public virtual bool Enabled
		{
			get => _enabled;
			set
			{
				_enabled = value;
				if (ParentColumn != null && ParentColumn.visible)
					ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
			}
		}

		internal virtual void ItemActivate()
		{
			Activated?.Invoke(ParentColumn, this);
		}



		/// <summary>
		/// Returns this item's label.
		/// </summary>
		public new virtual string Label
		{
			get => _label;
			set
			{
				_label = value;
				if (ParentColumn != null && ParentColumn.visible)
					ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
			}
		}

		/// <summary>
		/// Returns the current right label.
		/// </summary>
		public virtual string RightLabel
		{
			get => _rightLabel;
			private set
			{
				_rightLabel = value;
				if (ParentColumn != null && ParentColumn.visible)
					ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
			}
		}

		/// <summary>
		/// Returns the lobby this item is in.
		/// </summary>
		public ItemListColumn ParentColumn { get; internal set; }


		/// <summary>
		/// Called when user selects the current item.
		/// </summary>
		public event ItemActivatedEvent Activated;
		public event ItemActivatedEvent OnTabPressed;

		/// <summary>
		/// Called when user "highlights" the current item.
		/// </summary>
		public event ItemHighlightedEvent Highlighted;

		/// <summary>
		/// Basic menu button.
		/// </summary>
		/// <param name="text">Button label.</param>
		public MenuItem(string text) : this(text, "") { }

		/// <summary>
		/// Basic menu button with description.
		/// </summary>
		/// <param name="text">Button label.</param>
		/// <param name="description">Description.</param>
		public MenuItem(string text, string description) : this(text, description, SColor.HUD_Pause_bg, SColor.HUD_Pure_white) { }

		/// <summary>
		/// Basic menu item with description and colors.
		/// </summary>
		/// <param name="text">Item's label.</param>
		/// <param name="description">Item's description</param>
		/// <param name="color">Main Color</param>
		/// <param name="highlightColor">Highlighted Color</param>
		public MenuItem(string text, string description, SColor color, SColor highlightColor) : base(text)
		{
			_enabled = true;
			MainColor = color;
			HighlightColor = highlightColor;
			Label = text;
			Descriptions[0] = new(description);
		}


		/// <summary>
		/// Set the left badge. Set it to None to remove the badge.
		/// </summary>
		/// <param name="badge"></param>
		public virtual void SetLeftBadge(string txd, string txn, SColor mainColor, SColor highlightColor)
		{
			customLeftBadge = new(txd, txn, mainColor, highlightColor);
			if (ParentColumn != null && ParentColumn.visible)
				ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
		}

		/// <summary>
		/// Set the right badge. Set it to None to remove the badge.
		/// </summary>
		/// <param name="badge"></param>
		public virtual void SetRightBadge(string txd, string txn, SColor mainColor, SColor highlightColor)
		{
			customRightBadge = new(txd, txn, mainColor, highlightColor);
			if (ParentColumn != null && ParentColumn.visible)
				ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
		}

		/// <summary>
		/// Set the right label.
		/// </summary>
		/// <param name="text">Text as label. Set it to "" to remove the label.</param>
		public virtual void SetRightLabel(string text)
		{
			RightLabel = text;
		}

		public virtual void IsImportant(bool isImportant, SColor highlightColor, bool animate)
		{
			this.isImportant = isImportant;
			importantColor = highlightColor;
			importantAnimate = animate;
			if (ParentColumn != null && ParentColumn.visible)
				ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
		}

		public void Description(int index, string label, SColor color, string txd = "", string txn = "")
		{
			if (index < 0 || index > 2) return;

			if (!string.IsNullOrWhiteSpace(label)) Descriptions[index].Label = label;
			Descriptions[index].Color = color;
			Descriptions[index].TXD = txd;
			Descriptions[index].TXN = txn;
			if (ParentColumn != null && ParentColumn.visible)
				ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
		}

		internal virtual void TabItemActivate()
		{
			OnTabPressed?.Invoke(ParentColumn, this);
		}

		public void SetSubColumn(ItemListColumn column, bool showArrow, bool hideTabs)
		{
			Activated += (_, _) =>
			{
				ItemListTab tab = (ItemListTab)ParentColumn.Parent;
				tab.PushColumn(column, showArrow, hideTabs);
			};
		}
	}

	internal class Badge
	{
		public string TXD { get; set; }
		public string TXN { get; set; }
		public SColor MainColor { get; set; }
		public SColor HighlightColor { get; set; }
		public Badge(string txd, string txn, SColor mainColor, SColor highlightColor)
		{
			TXD = txd;
			TXN = txn;
			MainColor = mainColor;
			HighlightColor = highlightColor;
		}
	}

	internal class Description
	{
		public string Label { get; set; }
		public SColor Color { get; set; } = SColor.HUD_White;
		public string TXD { get; set; }
		public string TXN { get; set; }

		public Description()
		{
			Label = "";
			Color = SColor.HUD_White;
			TXD = "";
			TXN = "";
		}

		public Description(string label)
		{
			Label = label;
			Color = SColor.HUD_White;
			TXD = "";
			TXN = "";
		}

		public Description(string label, SColor color, string txd, string txn)
		{
			Label = label;
			Color = color;
			TXD = txd;
			TXN = txn;
		}
	}
}
