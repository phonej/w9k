
SWEP.Base								= "w9k"

SWEP.Category							= "W9K"
SWEP.Spawnable							= true

--
-- Weapon configuration
--
SWEP.PrintName							= "AS VAL"
SWEP.Slot								= 2

--
-- Appearance
--
SWEP.ViewModel				= "models/weapons/v_dmg_vally.mdl"
SWEP.WorldModel				= "models/weapons/w_dmg_vally.mdl"
SWEP.ViewModelFOVBase		= 74

-- Sound
SWEP.ShootSound							= "weapons/dmg_val/galil-1.wav"
SWEP.ShootSound_Level					= 80
SWEP.ShootAmb_Level						= 160
SWEP.ShootAmbInt						= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbExt						= "w9k/fesiug/distant_rifle.ogg"

-- Recoil
SWEP.RecoilUp							= 1 -- degrees punched
SWEP.RecoilUpDrift						= 0.5 -- 50% will be smoothed
SWEP.RecoilUpDecay						= 10 -- 10 degrees per second
SWEP.RecoilSide							= 2 -- degrees punched, in either direction (-100% to 100%)
SWEP.RecoilSideDrift					= 0.5 -- 50% will be smoothed
SWEP.RecoilSideDecay					= 10 -- 10 degrees per second
SWEP.RecoilFlipChance					= ( 1 / 7 ) -- 1 in 7 chance for recoil flip
SWEP.RecoilADSMult						= ( 1 / 3 ) -- multiply shot recoil by this amount when ads'd

-- Damage
SWEP.DamageNear							= 23
SWEP.DamageFar							= 19
SWEP.RangeNear							= 50
SWEP.RangeFar							= 100

-- Ability
SWEP.Primary.ClipSize					= 20
SWEP.Primary.Ammo						= "ar2"
SWEP.IsSuppressable						= true
SWEP.Firemodes = {
	{
		Count = math.huge,
		Delay = ( 60 / 900 ),
		PostBurstDelay = 0,
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
	Pos = Vector(-2.2142, -1.8353, 1.0599),
	Ang = Angle(1.0513, 0.0322, 0),
	Mag = 1.3,
}

SWEP.RunPose = {
	Pos = Vector(0.3339, -2.043, 0.6273),
	Ang = Angle(-11.5931, 48.4648, -19.7039),
}

SWEP.Animations = {
	["idle"] = {
		Source = ACT_VM_IDLE,
	},
	["fire"] = {
		Source = ACT_VM_PRIMARYATTACK,
	},
	["draw"] = {
		Source = ACT_VM_DRAW,
	},
	["reload"] = {
		Source = ACT_VM_RELOAD,
		Mult = 1,
		StopSightTime = 2.5,
		LoadIn = 1.6,
	},
}