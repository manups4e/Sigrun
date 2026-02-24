---@class DescriptionListColumn : BaseColumn
---@field VisibleItems number
---@field OnIndexChange fun(index:number)
---@field OnItemSelect fun(item:any, index:number)
---@field Items table
---@field index number
---@field position number
DescriptionListColumn = {}
DescriptionListColumn.__index = DescriptionListColumn
setmetatable(DescriptionListColumn, { __index = BaseColumn })
DescriptionListColumn.__call = function() return "DescriptionListColumn" end

---Creates a new DescriptionListColumn instance providing item navigation and scaleform slot management.
---@return DescriptionListColumn
function DescriptionListColumn.New()
    local base = BaseColumn.New(1)
    base.VisibleItems = 3
    return setmetatable(base, DescriptionListColumn)
end

---Updates an existing data slot in the scaleform.
---@param index number
function DescriptionListColumn:UpdateSlot(index, item)
    if not index then index = 0 end
    if not item then
        -- failsafe.. if no item in menu this will erase and hide the description
        BeginScaleformMovieMethod(SH.scaleform.handle, "UPDATE_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(self.position)
        ScaleformMovieMethodAddParamInt(index - 1)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(1)
        BeginTextCommandScaleformString(string.format("Sigrun_Description_%s", index - 1))
        EndTextCommandScaleformString_2()
        EndScaleformMovieMethod()
        return
    end

    BeginScaleformMovieMethod(SH.scaleform.handle, "UPDATE_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(self.position)
    ScaleformMovieMethodAddParamInt(index - 1)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(1)
    BeginTextCommandScaleformString(string.format("Sigrun_Description_%s", index - 1))
    EndTextCommandScaleformString_2()
    ScaleformMovieMethodAddParamInt(item.Descriptions[index].color:ToArgb())
    if not (item.Descriptions[index].txd == nil or item.Descriptions[index].txd == "" or item.Descriptions[index].txn == nil or item.Descriptions[index].txn == "") then
        PushScaleformMovieMethodParameterString(item.Descriptions[index].txd)
        PushScaleformMovieMethodParameterString(item.Descriptions[index].txn)
    end
    EndScaleformMovieMethod()
end
