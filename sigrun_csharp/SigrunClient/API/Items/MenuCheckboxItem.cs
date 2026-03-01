using SigrunClient.API.Elements;
using System;

namespace SigrunClient.API.Items
{
    public enum MenuCheckboxStyle
    {
        Cross,
        Tick
    }

	public delegate void ItemCheckboxEvent(MenuCheckboxItem sender, bool Checked);
	public class MenuCheckboxItem : MenuItem
    {
        private bool _checked;

        /// <summary>
        /// Triggered when the checkbox state is changed.
        /// </summary>
        public event ItemCheckboxEvent CheckboxEvent;

        public MenuCheckboxStyle Style { get; }

        /// <summary>
        /// Checkbox item with a toggleable checkbox.
        /// </summary>
        /// <param name="text">Item label.</param>
        /// <param name="check">Boolean value whether the checkbox is checked.</param>
        public MenuCheckboxItem(string text, bool check) : this(text, check, "")
        {
        }

        /// <summary>
        /// Checkbox item with a toggleable checkbox.
        /// </summary>
        /// <param name="text">Item label.</param>
        /// <param name="check">Boolean value whether the checkbox is checked.</param>
        /// <param name="description">Description for this item.</param>
        public MenuCheckboxItem(string text, bool check, string description) : this(text, MenuCheckboxStyle.Tick, check, description, SColor.HUD_Pause_bg, SColor.HUD_White)
        {
        }

        /// <summary>
        /// Checkbox item with a toggleable checkbox.
        /// </summary>
        /// <param name="text">Item label.</param>
        /// <param name="style">CheckBox style (Tick or Cross).</param>
        /// <param name="check">Boolean value whether the checkbox is checked.</param>
        /// <param name="description">Description for this item.</param>
        public MenuCheckboxItem(string text, MenuCheckboxStyle style, bool check, string description) : this(text, style, check, description, SColor.HUD_Pause_bg, SColor.HUD_White)
        {
        }

        /// <summary>
        /// Checkbox item with a toggleable checkbox.
        /// </summary>
        /// <param name="text">Item label.</param>
        /// <param name="style">CheckBox style (Tick or Cross).</param>
        /// <param name="check">Boolean value whether the checkbox is checked.</param>
        /// <param name="description">Description for this item.</param>
        /// <param name="mainColor">Main item color.</param>
        /// <param name="highlightColor">Highlight item color.</param>
        public MenuCheckboxItem(string text, MenuCheckboxStyle style, bool check, string description, SColor mainColor, SColor highlightColor) : base(text, description, mainColor, highlightColor)
        {
            Style = style;
            _checked = check;
            _itemId = 2;
        }


        /// <summary>
        /// Change or get whether the checkbox is checked.
        /// </summary>
        public bool Checked
        {
            get => _checked;
            set
            {
                _checked = value;
                if (ParentColumn != null && ParentColumn.visible)
                    ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
            }
        }

        public void CheckboxEventTrigger()
        {
            CheckboxEvent?.Invoke(this, Checked);
        }

        public override void SetRightBadge(string txd, string txn, SColor mainColor, SColor highlightColor)
		{
            throw new Exception("MenuCheckboxItem cannot have a right badge.");
        }

        public override void SetRightLabel(string text)
        {
            throw new Exception("MenuCheckboxItem cannot have a right label.");
        }
    }
}