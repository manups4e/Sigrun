using SigrunClient.API.Elements;
using System;

namespace SigrunClient.API.Items
{
    public class MenuSeparatorItem : MenuItem
    {
        public bool Jumpable = false;
        /// <summary>
        /// Use it to create an Empty item to separate menu Items
        /// </summary>
        public MenuSeparatorItem(string title, bool jumpable) : base(title, "")
        {
            _itemId = 6;
            Jumpable = jumpable;
        }

        public override void SetLeftBadge(string txd, string txn, SColor mainColor, SColor highlightColor)
        {
            throw new Exception("MenuSeparatorItem cannot have a left badge.");
        }
        public override void SetRightBadge(string txd, string txn, SColor mainColor, SColor highlightColor)
        {
            throw new Exception("MenuSeparatorItem cannot have a right badge.");
        }
        public override void SetRightLabel(string text)
        {
            throw new Exception("MenuSeparatorItem cannot have a right label.");
        }
    }
}
