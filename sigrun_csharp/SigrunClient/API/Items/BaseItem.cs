using SigrunClient.API.Columns;
using SigrunClient.API.Tabs;

namespace SigrunClient.API.Items
{
	public class BaseItem
	{
		public string LabelFont = "$Font2";
		public string Label { get; set; }
		public BaseTab ParentTab { get; set; }
		public Base_Column ParentColumn { get; set; }
		public BaseItem(string label)
		{
			Label = label;
		}
		public BaseItem(string label, string labelFont)
		{
			Label = label;
			LabelFont = labelFont;
		}

		public virtual bool Selected { get; set; }
	}
}
