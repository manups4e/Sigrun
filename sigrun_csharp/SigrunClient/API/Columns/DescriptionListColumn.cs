using SigrunClient.API.Items;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SigrunClient.API.Columns
{
	public class DescriptionListColumn : Base_Column
	{
		public DescriptionListColumn() : base(1)
		{
			VisibleItems = 3;
		}

		public void UpdateSlot(int index, MenuItem item)
		{
			if (item == null)
			{
				BeginScaleformMovieMethod(ClientMain.sigrun.Handle, "UPDATE_DATA_SLOT");
		        ScaleformMovieMethodAddParamInt((int)position);
				ScaleformMovieMethodAddParamInt(index);
				ScaleformMovieMethodAddParamInt(0);
				ScaleformMovieMethodAddParamInt(0);
				ScaleformMovieMethodAddParamInt(0);
				ScaleformMovieMethodAddParamInt(0);
				ScaleformMovieMethodAddParamInt(1);
				BeginTextCommandScaleformString($"Sigrun_Description_{0}");
				EndTextCommandScaleformString_2();
				EndScaleformMovieMethod();
				return;
			}

			BeginScaleformMovieMethod(ClientMain.sigrun.Handle, "UPDATE_DATA_SLOT");
			ScaleformMovieMethodAddParamInt((int)position);
			ScaleformMovieMethodAddParamInt(index);
			ScaleformMovieMethodAddParamInt(0);
			ScaleformMovieMethodAddParamInt(0);
			ScaleformMovieMethodAddParamInt(0);
			ScaleformMovieMethodAddParamInt(0);
			ScaleformMovieMethodAddParamInt(1);
			BeginTextCommandScaleformString($"Sigrun_Description_{index}");
			EndTextCommandScaleformString_2();
			ScaleformMovieMethodAddParamInt(item.Descriptions[index].Color.ArgbValue);
			if (!string.IsNullOrWhiteSpace(item.Descriptions[index].TXD) && !string.IsNullOrWhiteSpace(item.Descriptions[index].TXN))
			{
				PushScaleformMovieMethodParameterString(item.Descriptions[index].TXD);
				PushScaleformMovieMethodParameterString(item.Descriptions[index].TXN);
			}
			EndScaleformMovieMethod();
		}
	}
}
