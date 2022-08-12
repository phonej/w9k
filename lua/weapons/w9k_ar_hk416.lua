
SWEP.Base								= "w9k"

SWEP.Category							= "W9K"
SWEP.Spawnable							= true

--
-- Weapon configuration
--
SWEP.PrintName							= "H&K HK416"
SWEP.Slot								= 2

--
-- Appearance
--
SWEP.ViewModel				= "models/weapons/v_hk416rif.mdl"
SWEP.WorldModel				= "models/weapons/w_hk_416.mdl"
SWEP.ViewModelFOVBase		= 74

-- Sound
SWEP.ShootSound							= ")weapons/twinkie_hk416/m4a1_unsil-1.wav"
SWEP.ShootSoundSilenced					= ")weapons/twinkie_hk416/m4a1-1.wav"
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
SWEP.DamageNear							= 27
SWEP.DamageFar							= 22
SWEP.RangeNear							= 30
SWEP.RangeFar							= 100

-- Ability
SWEP.Primary.ClipSize					= 30
SWEP.Primary.Ammo						= "smg1"
SWEP.IsSuppressable						= true
SWEP.Firemodes = {
	{
		Count = math.huge,
		Delay = ( 60 / 800 ),
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
	Pos = Vector(-2.892, -2.132, 0.5),
	Ang = Angle(-0.033, 0.07, 0),
	Mag = 1.3,
}

SWEP.RunPose = {
	Pos = Vector(2.125, -0.866, 1.496),
	Ang = Angle(-18.08, 30.59, 0),
}

SWEP.Animations = {
	["idle"] = {
		Source = ACT_VM_IDLE,
	},
	["idle_sup"] = {
		Source = ACT_VM_IDLE_SILENCED,
	},
	["fire"] = {
		Source = ACT_VM_PRIMARYATTACK,
	},
	["fire_sup"] = {
		Source = ACT_VM_PRIMARYATTACK_SILENCED,
	},
	["draw"] = {
		Source = ACT_VM_DRAW,
	},
	["draw_sup"] = {
		Source = ACT_VM_DRAW_SILENCED,
	},
	["sup_on"] = {
		Source = ACT_VM_ATTACH_SILENCER,
		Mult = 1,
		SuppressTime = 1,
		StopSightTime = 1.3,
	},
	["sup_off"] = {
		Source = ACT_VM_DETACH_SILENCER,
		Mult = 1,
		SuppressTime = 0.7,
		StopSightTime = 1.8,
	},
	["reload"] = {
		Source = ACT_VM_RELOAD,
		Mult = 1,
		StopSightTime = 2.8,
		LoadIn = 2.2,
	},
	["reload_sup"] = {
		Source = ACT_VM_RELOAD_SILENCED,
		Mult = 1,
		StopSightTime = 2.8,
		LoadIn = 2.2,
	},
}