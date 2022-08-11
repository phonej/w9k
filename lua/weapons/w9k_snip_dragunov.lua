
SWEP.Base								= "w9k"

SWEP.Category							= "W9K"
SWEP.Spawnable							= true

--
-- Weapon configuration
--
SWEP.PrintName							= "SVD Dragunov"
SWEP.Slot								= 2

--
-- Appearance
--
SWEP.ViewModel				= "models/weapons/v_dragunov02.mdl"
SWEP.WorldModel				= "models/weapons/w_svd_dragunov.mdl"
SWEP.ViewModelFOVBase		= 64

-- Sound
SWEP.ShootSound							= ")weapons/SVD/g3sg1-1.wav"
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

-- Damage
SWEP.DamageNear							= 90
SWEP.DamageFar							= 90
SWEP.RangeNear							= 60
SWEP.RangeFar							= 120

-- Ability
SWEP.Primary.ClipSize					= 10
SWEP.Primary.Ammo						= "ar2"
SWEP.Firemodes = {
	{
		Count = 1,
		Delay = ( 60 / 400 ),
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
	Pos = Vector(-1.241, -1.476, 0),
	Ang = Angle(0, 0, 0),
	Mag = 4,
	Scope = "svd"
}

SWEP.RunPose = {
	Pos = Vector(3.934, -5.41, 0),
	Ang = Angle(-11.476, 35, 0),
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
		StopSightTime = 3.7,
		LoadIn = 2.8,
	},
}