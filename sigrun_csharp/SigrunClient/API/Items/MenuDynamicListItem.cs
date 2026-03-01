using SigrunClient.API.Elements;
using System;
using System.Threading.Tasks;

namespace SigrunClient.API.Items
{
    public enum ChangeDirection
    {
        Left,
        Right
    }
    public delegate Task<string> DynamicListItemChangeCallback(MenuDynamicListItem sender, ChangeDirection direction);
	public class MenuDynamicListItem : MenuItem, IListItem
    {

        private string currentListItem;

        public string CurrentListItem
        {
            get => currentListItem;
            set
            {
                currentListItem = value;
                if (ParentColumn != null && ParentColumn.visible)
                    ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
            }
        }


        public override bool Enabled
        {
            get => base.Enabled;
            set
            {
                base.Enabled = value;
                if (ParentColumn != null && ParentColumn.visible)
                    ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
            }
        }

        public override bool Selected
        {
            get => base.Selected;
            set
            {
                base.Selected = value;
                if (ParentColumn != null && ParentColumn.visible)
                    ParentColumn.SendItemToScaleform(ParentColumn.Items.IndexOf(this), true);
            }
        }


        public DynamicListItemChangeCallback Callback { get; set; }

        /// <summary>
        /// List item with items generated at runtime
        /// </summary>
        /// <param name="text">Label text</param>
        public MenuDynamicListItem(string text, string startingItem, DynamicListItemChangeCallback changeCallback) : this(text, null, startingItem, changeCallback)
        {
        }

        /// <summary>
        /// List item with items generated at runtime
        /// </summary>
        /// <param name="text">Label text</param>
        /// <param name="description">Item description</param>
        public MenuDynamicListItem(string text, string description, string startingItem, DynamicListItemChangeCallback changeCallback) : base(text, description)
        {
            _itemId = 1;
            currentListItem = startingItem;
            Callback = changeCallback;
        }

        internal MenuDynamicListItem(string text, string description, string startingItem) : base(text, description)
        {
            _itemId = 1;
            currentListItem = startingItem;
        }

        public override void SetRightBadge(string txd, string txn, SColor mainColor, SColor highlightColor)
		{
            throw new Exception("MenuDynamicListItem cannot have a right badge.");
        }

        public override void SetRightLabel(string text)
        {
            throw new Exception("MenuDynamicListItem cannot have a right label.");
        }

        public string CurrentItem()
        {
            return CurrentListItem;
        }
    }
}