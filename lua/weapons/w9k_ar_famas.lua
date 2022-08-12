
SWEP.Base								= "w9k"

SWEP.Category							= "W9K"
SWEP.Spawnable							= true

--
-- Weapon configuration
--
SWEP.PrintName							= "FN FAMAS"
SWEP.Slot								= 2

--
-- Appearance
--
SWEP.ViewModel				= "models/weapons/v_tct_famas.mdl"
SWEP.WorldModel				= "models/weapons/w_tct_famas.mdl"
SWEP.ViewModelFOVBase		= 64

-- Sound
SWEP.ShootSound							= {
	")weapons/fokku_tc_famas/shot-1.wav", 
	")weapons/fokku_tc_famas/shot-2.wav"
}
SWEP.ShootSound_Level					= 80
SWEP.ShootAmb_Level						= 160
SWEP.ShootAmbInt						= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbExt						= "w9k/fesiug/distant_rifle.ogg"

-- Recoil
SWEP.RecoilUp							= 2 -- degrees punched
SWEP.RecoilUpDrift						= 0.5 -- 50% will be smoothed
SWEP.RecoilUpDecay						= 10 -- 10 degrees per second
SWEP.RecoilSide							= 3 -- degrees punched, in either direction (-100% to 100%)
SWEP.RecoilSideDrift					= 0.6 -- 50% will be smoothed
SWEP.RecoilSideDecay					= 6 -- 10 degrees per second
SWEP.RecoilFlipChance					= ( 1 / 4 ) -- 1 in 7 chance for recoil flip
SWEP.RecoilADSMult						= ( 1 / 3 ) -- multiply shot recoil by this amount when ads'd

-- Damage
SWEP.DamageNear							= 23
SWEP.DamageFar							= 18
SWEP.RangeNear							= 30
SWEP.RangeFar							= 100

-- Ability
SWEP.Primary.ClipSize					= 30
SWEP.Primary.Ammo						= "smg1"
SWEP.Firemodes = {
	{
		Count = math.huge,
		Delay = ( 60 / 950 ),
		PostBurstDelay = 0,
	},
	{
		Count = 3,
		Delay = ( 60 / 1300 ),
		PostBurstDelay = 0.15,
	},
	{
		Count = 1,
		Delay = ( 60 / 500 ),
		PostBurstDelay = 0,
	},
}

-- Thirdperson
SWEP.TPAnim_Reload						= ACT_HL2MP_GESTURE_RELOAD_AR2
SWEP.TPAnim_Fire						= ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.HoldTypeHip						= "ar2"
SWEP.HoldTypeSight						= "rpg"
SWEP.HoldTypeSprint						= "passive"

SWEP.IronSights = {
	Pos = Vector(-3.342, 0, 0.247),
	Ang = Angle(0, -0.438, 0),
	Mag = 1.3,
}

SWEP.RunPose = {
	Pos = Vector(0.9926, -3.6313, 0.4169),
	Ang = Angle(-9.1165, 43.8507, -18.2067),
}

SWEP.Animations = {
	["idle"] = {
		Source = ACT_VM_IDLE,
	},
	["draw"] = {
		Source = ACT_VM_DRAW,
	},
	["fire"] = {
		Source = ACT_VM_PRIMARYATTACK,
		Mult = 1,
	},
	["reload"] = {
		Source = ACT_VM_RELOAD,
		Mult = 1,
		StopSightTime = 2.8,
		LoadIn = 2.2,
	},
}