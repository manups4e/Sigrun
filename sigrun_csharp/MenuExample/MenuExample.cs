using CitizenFX.Core;
using CitizenFX.Core.Native;
using SigrunClient.API;
using SigrunClient.API.Columns;
using SigrunClient.API.Elements;
using SigrunClient.API.Items;
using SigrunClient.API.Tabs;
using System;
using System.Collections.Generic;

namespace MenuExample
{
	public class MenuExample : BaseScript
	{
		private MainMenu mainMenu;
		private List<string> randDescriptions = new List<string>()
		{
			"This is a required field for a valid mission.",
			"In sit amet justo a dui fringilla suscipit.",
			"Quisque porta neque et urna pharetra, sed vehicula metus dapibus.",
			"Pellentesque placerat magna quis nunc scelerisque, vitae ullamcorper nunc lobortis.",
			"Curabitur hendrerit odio non urna varius pellentesque",
			"Aliquam et ex ac velit imperdiet laoreet quis eu magna",
			"Vestibulum semper turpis in bibendum feugiat",
			"Nulla eu orci nec est pulvinar bibendum",
			"Phasellus quis nisi a lectus pharetra interdum.",
			"In et justo at orci imperdiet vestibulum vitae ac lorem.",
			"Etiam semper tellus in sem porta pretium."
		};
		public void BuildMenu()
		{
			if (mainMenu != null)
			{
				mainMenu.Visible = false;
				return;
			}

			mainMenu = new MainMenu("Sigrun Mission Creator");
			mainMenu.MouseEnabled = true;
			mainMenu.ScrollOnlyOnMenuHover = true;
			var firstTab = new ItemListTab($"Tab #1", "mppublicmissioncreatoricons", "mission_creator_details_icon", SColor.FromRandomValues());
			mainMenu.AddTab(firstTab);
			var secondTab = new ItemListTab($"Tab #2", "mppublicmissioncreatoricons", "mission_creator_details_icon", SColor.FromRandomValues());
			mainMenu.AddTab(secondTab);
			secondTab.SetWarningTip(true, true, SColor.HUD_Red);

			/*
			 * 
			 * SHOWCASE ITEMS
			 * 
			 */

			firstTab.UpdateTitle("SHOWCASE", false, false);
			var submenuColumn = new ItemListColumn("HIERARCHY", 10);
			for (int i = 0; i < 15; i++)
			{
				submenuColumn.AddItem(new MenuItem($"Sub Item #{(i + 1)}", "this is inside a sub-column"));
			}

			var subItem = new MenuItem("Open SubColumn", "Click here to explore the sub columns universe!");
			subItem.SetRightLabel("Explore >>>");
			/* SetSubColumn will automatically add an Activated event to the item with the submenu switch.. you can manually do this doing
			 * item.Activated += (col, item) => 
			 * {
			 *		col.Parent.PushColumn(newColumn, true, true) - Params are (ItemListColumn, showArrow, hideTabs);
			 * }
			 * When HideTabs is true, it will be impossible to switch tabs while in submenu.
			 */
			subItem.SetSubColumn(submenuColumn, true, true);
			firstTab.AddItem(subItem); // left column is the main item list column. right column is the description column.

			var itemRich = new MenuItem("Advanced Item", randDescriptions[0]);
			itemRich.SetRightLabel("Value: $500");
			//Differently than ScaleformUI, Sigrun wants you to input your badge textures, this is to allow further customizations
			//changing textures at any time and color on need.
			itemRich.SetLeftBadge("commonmenu", "shop_lock", SColor.HUD_White, SColor.HUD_Black);
			itemRich.SetRightBadge("commonmenu", "mp_alerttriangle", SColor.HUD_White, SColor.HUD_White);
			// Items have 3 descriptions, you can change them using this function.
			// the default desctription you add at item creation is at index 1.
			itemRich.Description(1, "Second description slot with icon", SColor.HUD_Orange, "commonmenu", "mp_alerttriangle");
			itemRich.Description(2, "Third slot for more info", SColor.HUD_Pure_white);
			// IsImportant will add a little colored highlight on the left side of the item.
			// params are(enabled, color, animateHighlight)
			itemRich.IsImportant(true, SColor.HUD_Gold, true);
			firstTab.AddItem(itemRich);

			var itemCheck = new MenuCheckboxItem("Toggle Feature", MenuCheckboxStyle.Tick, true, "Enable or disable this experimental feature");
			itemCheck.CheckboxEvent += (item, _checked) =>
			{
				Debug.WriteLine("Checkbox is now: " + _checked);
			};
			firstTab.AddItem(itemCheck);

			// List Item (Static)
			var itemList = new MenuListItem("Select Character", new List<dynamic> { "Franklin", "Michael", "Trevor" }, 0, "Choose your starting character");
			itemList.OnListChanged += (item, index) =>
			{

				Debug.WriteLine("Selected character index: " + index);
			};
			firstTab.AddItem(itemList);

			// Colored MenuItem
			var itemColor = new MenuItem("~HUD_COLOUR_FREEMODE~Custom ~w~Colors", "Color text using standard Rockstar tokens", SColor.FromHudColor((HudColor)21), SColor.FromHudColor((HudColor)24));
			firstTab.AddItem(itemColor);

			// Separators
			firstTab.AddItem(new MenuSeparatorItem("WIDGET SECTION", false)); // Selectable;;

			// Slider Item
			var itemSlider = new MenuSliderItem("Difficulty", "Adjust the game difficulty level", 100, 10, 50, false);
			firstTab.AddItem(itemSlider);

			// Progress Item (Disabled Example)
			var itemProgress = new MenuProgressItem("Experience Level", 100, 75, "Your current rank progress")
			{
				Enabled = false
			};
			firstTab.AddItem(itemProgress);

			firstTab.AddItem(new MenuSeparatorItem("Separator (Jumped)", true)); // Jumped ;;

			// Batch of generic items
			for (int i = 0; i < 5; i++)
			{
				var generic = new MenuItem("Extra Item " + i, randDescriptions[new Random(i).Next(1, randDescriptions.Count - 1)]);
				firstTab.AddItem(generic);
			}

			/*
			 * 
			 * EMPTY TAB EXAMPLE
			 * 
			 */

			secondTab.LeftColumn.AddItem(new MenuItem("Settings", "Change your preferences here"));
			secondTab.LeftColumn.AddItem(new MenuCheckboxItem("Notifications", false, "Toggle HUD notifications"));


			mainMenu.Visible = true;
		}

		public MenuExample()
		{
			API.RegisterCommand("sigrunc", new Action<int, List<object>, string>((a, b, c) =>
			{
				BuildMenu();
			}), false);
		}
	}
}
