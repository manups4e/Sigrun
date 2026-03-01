using SigrunClient.API.Columns;
using SigrunClient.API.Elements;
using System;
using System.Linq;
using System.Reflection;
namespace SigrunClient.API.Tabs
{
    public class BaseTab
    {
        internal int _type;
        internal string _identifier;
        internal SColor TabColor;
        internal List<Base_Column> LeftColumnStack = new List<Base_Column>();
        internal bool isWarning;
        internal bool animateWarning;
        internal SColor warningColor;
        internal string txd;
        internal string txn;

        public BaseTab(string name, string txd, string txn, SColor color)
        {
            Title = name;
            TabColor = color;
            this.txd = txd;
            this.txn = txn;
        }

        public virtual Base_Column LeftColumn { get; internal set; }
        public virtual Base_Column CenterColumn { get; internal set; }
        public virtual Base_Column RightColumn { get; internal set; }
        public bool Visible { get; set; }
        public virtual bool Focused { get; set; }
        public string Title { get; set; }
        public bool Active { get; set; }

        public MainMenu Parent { get; internal set; }
        public int CurrentColumnIndex { get; internal set; }
        internal bool showArrow;
        internal bool hideTabs;

        public Base_Column CurrentColumn => CurrentColumnIndex switch
        {
            1 => CenterColumn,
            2 => RightColumn,
            _ => LeftColumn,
        };

        public event EventHandler Activated;

        public void OnActivated()
        {
            Activated?.Invoke(this, EventArgs.Empty);
        }

        #region Virtual methods
        public virtual void Populate() { }
        public virtual void Refresh(bool highlightOldIndex) { }
        public virtual void ShowColumns() { }

        public virtual void SetDataSlot(PM_COLUMNS slot, int index) { }
        
        public virtual void UpdateSlot(PM_COLUMNS slot, int index) { }
        
        public virtual void AddSlot(PM_COLUMNS slot, int index) { }
        
        public virtual void Focus() { Focused = true; }
        public virtual void UnFocus() { Focused = false; }

        public virtual void GoUp() { }
        public virtual void GoDown() { }
        public virtual void GoLeft() { }
        public virtual void GoRight() { }
        public virtual void Select() { }
        public virtual void GoBack() { }
        public virtual void Selected() { }

        public virtual void MouseEvent(int eventType, int context, int index) { }

        public virtual void StateChange(int state) { }

        public virtual void PushColumn(Base_Column column, bool showArrow, bool hideTabs)
        {
            if(LeftColumn != null)
            {
                LeftColumn._oldTitle = Title;
                LeftColumn._oldShowArrow = this.showArrow;
                LeftColumn._oldHideTabs = this.hideTabs;
            }

            LeftColumnStack.Add(LeftColumn!);
            ClientMain.sigrun.CallFunction("SET_DATA_SLOT_EMPTY", (int)LeftColumn!.position);

            LeftColumn = column;
            LeftColumn.Parent = this;

            string title = string.IsNullOrWhiteSpace(LeftColumn.Label) ? Title : LeftColumn.Label;

            UpdateTitle(title, showArrow, hideTabs);
            Populate();
            ShowColumns();
            Focus();
		}

        public virtual void PopColumn()
        {
            if (LeftColumnStack.Count == 0) return;

			ClientMain.sigrun.CallFunction("SET_DATA_SLOT_EMPTY", (int)LeftColumn!.position);

            var previousColumn = LeftColumnStack.LastOrDefault();
            if (!string.IsNullOrWhiteSpace(previousColumn._oldTitle))
                UpdateTitle(previousColumn._oldTitle, previousColumn._oldShowArrow, previousColumn._oldHideTabs);

            LeftColumn = previousColumn;
            LeftColumn.Parent = this;

            Populate();
            ShowColumns();

            if (LeftColumn is ItemListColumn ilc)
                ilc.UpdateDescription();
			
            ClientMain.sigrun.CallFunction("SET_COLUMN_HIGHLIGHT", (int)LeftColumn!.position, LeftColumn!.index);
		}
		#endregion

		internal Base_Column GetColumnAtPosition(int position)
        {
            return GetColumnAtPosition((PM_COLUMNS)position);
        }
        internal virtual Base_Column GetColumnAtPosition(PM_COLUMNS position) 
        {
            return position switch
            {
                PM_COLUMNS.LEFT => LeftColumn,
                PM_COLUMNS.MIDDLE => CenterColumn,
                PM_COLUMNS.RIGHT => RightColumn,
                _ => null,
            };
        }

        public void SetWarningTip(bool isWarning, bool animateWarning, SColor warnColor)
        {
            this.isWarning = isWarning;
            this.animateWarning = animateWarning;
            warningColor = warnColor;
            if(Parent!= null && Parent.Visible)
            {
                if (Parent.Tabs.Contains(this))
                {
					int idx = Parent.Tabs.IndexOf(this);
                    ClientMain.sigrun.CallFunction("UPDATE_TABS_SLOT", idx, 0, 0, 0, 0, true, txd, txn, TabColor, isWarning, animateWarning, warningColor);
                }
            }
        }

        public void UpdateTitle(string title, bool showArrow, bool hideTabs)
        {
            Title = title;
            this.showArrow = showArrow;
            this.hideTabs = hideTabs;
            if (Parent != null && Parent.Visible && Parent.CurrentTab == this)
            {
                ClientMain.sigrun.CallFunction("SET_TABS_TITLE", Title, showArrow, !hideTabs);
			}
		}
	}
}