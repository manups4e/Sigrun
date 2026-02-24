---Defines the Component current status.
---@enum ComponentStatus
ComponentStatus = {
    NOT_IN_LIST = -1,
    NOT_LOADED = 0,
    STREAMING = 1,
    LOADING = 2,
    LOAD_IN_PROGRESS = 3,
    LOAD_COMPLETE = 4,
    LOADED = 5,
    LOAD_ERROR = 6,
    ONSCREEN = 7,
    HIDDEN = 8,
    DEACTIVATED = 9
}

---@enum Components
Components = {
    EIR_HUD = 0, -- UNUSED BY SCRIPT, NEEDED BY SCALEFORM.
    HUD_COMPASS = 1,
    HUD_RESERVED_SLOTS = 2,
    HUD_WORLD_ELEMENTS = 3,
    HUD_INTERACTION = 4,
    HUD_SERVER_LOGO = 5,
    HUD_SERVER_INFO = 6,
    HUD_AUDIO_VOICE = 7,
    HUD_AUDIO_RADIO = 8,
    HUD_NOTIFICATIONS = 9,
    HUD_STATUS_BARS = 10,
    HUD_VEHICLE_DASHBOARD = 11,
    HUD_PROGRESS_BAR = 12,
    HUD_EQUIPPED_WEAPON = 13,

    [0] = "EIR_HUD", -- UNUSED BY SCRIPT, NEEDED BY SCALEFORM.
    [1] = "HUD_COMPASS",
    [2] = "HUD_RESERVED_SLOTS",
    [3] = "HUD_WORLD_ELEMENTS",
    [4] = "HUD_INTERACTION",
    [5] = "HUD_SERVER_LOGO",
    [6] = "HUD_SERVER_INFO",
    [7] = "HUD_AUDIO_VOICE",
    [8] = "HUD_AUDIO_RADIO",
    [9] = "HUD_NOTIFICATIONS",
    [10] = "HUD_STATUS_BARS",
    [11] = "HUD_VEHICLE_DASHBOARD",
    [12] = "HUD_PROGRESS_BAR",
    [13] = "HUD_EQUIPPED_WEAPON"
}

VehicleDashboardSymbols = {
    indicator_left = 0,
    indicator_right = 1,
    handbrake = 2,
    engine_light = 3,
    abs_light = 4,
    petrol_light = 5,
    temp_light = 6,
    oil_light = 7,
    oil_temp = 8,
    headlights = 9,
    full_beam = 10,
    battery_light = 11,
    seatbelt = 12,
    hood = 13,
    trunk = 14,
    doors = 15,
    towmode = 16,
    wheel = 7
}

---@enum NotificationIcon
NotificationIcon = {
    BLANK = 0,
    MESSAGE = 1,
    EMAIL = 2,
    NEW_CONTACT = 3,
    DRIVER = 4,
    HACKER = 5,
    SHOOTER = 6,
    INVITE = 7,
    RP = 8,
    CASH = 9,
    AP = 10,
    XP_ALT = 11,
    CASH_ALT = 12
}

---@enum ReplayNotificationType
ReplayNotificationType = {
    TYPE_DIRECTOR_RECORDING = 0,
	TYPE_BUTTON_ICON = 1,
	TYPE_ACTION_REPLAY = 2,
}

---@enum ReplayNotificationIcon
ReplayNotificationType = {
	RECORDING_BUFFER_ICON = 0,
	RECORDING_START_STOP_ICON = 1,
}

---@enum InstructionalButtonEnums
InstructionalButtonEnums = {
    UP = 0,
    DOWN = 1,
    LEFT = 2,
    RIGHT = 3,
    DPAD_UP = 4,
    DPAD_DOWN = 5,
    DPAD_LEFT = 6,
    DPAD_RIGHT = 7,
    DPAD_NONE = 8,
    DPAD_ALL = 9,
    DPAD_UPDOWN = 10,
    DPAD_LEFTRIGHT = 11,
    LSTICK_UP = 12,
    LSTICK_DOWN = 13,
    LSTICK_LEFT = 14,
    LSTICK_RIGHT = 15,
    LSTICK_NONE = 16,
    LSTICK_ALL1 = 17,
    LSTICK_UPDOWN = 18,
    LSTICK_LEFTRIGHT = 19,
    LSTICK_ROTATE = 20,
    RSTICK_UP = 21,
    RSTICK_DOWN = 22,
    RSTICK_LEFT = 23,
    RSTICK_RIGHT = 24,
    RSTICK_NONE = 25,
    RSTICK_ALL = 26,
    RSTICK_UPDOWN = 27,
    RSTICK_LEFTRIGHT = 28,
    RSTICK_ROTATE = 29,
    BUTTON_A = 30,
    BUTTON_B = 31,
    BUTTON_X = 32,
    BUTTON_Y = 33,
    BUTTON_LB = 34,
    BUTTON_LT = 35,
    BUTTON_RB = 36,
    BUTTON_RT = 37,
    BUTTON_START = 38,
    BUTTON_BACK = 39,
    SIXAXIS_DRIVE = 40,
    SIXAXIS_PITCH = 41,
    SIXAXIS_RELOAD = 42,
    SIXAXIS_ROLL = 43,
    ICON_SPINNER = 44,
}