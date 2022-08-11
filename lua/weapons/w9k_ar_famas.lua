
SWEP.Base								= "w9k"

SWEP.Category							= "W9K"
SWEP.Spawnable							= true

--
-- Weapon configuration
--
SWEP.PrintName							= "FN FAMAS"
SWEP.Slot								= 1

--
-- Appearance
--
SWEP.ViewModel				= "models/weapons/v_tct_famas.mdl"
SWEP.WorldModel				= "models/weapons/w_tct_famas.mdl"
SWEP.ViewModelFOVBase		= 64

-- Capacity
SWEP.Primary.ClipSize					= 30
SWEP.Primary.Ammo						= "smg1"

-- Sound
SWEP.ShootSound							= {
	")weapons/fokku_tc_famas/shot-1.wav", 
	")weapons/fokku_tc_famas/shot-2.wav"
}
SWEP.ShootSound_Level					= 70
SWEP.ShootAmb_Level						= 140
SWEP.ShootSoundSilenced					= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbInt						= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbExt						= "weapons/pistol/pistol_fire3.wav"

-- Damage
SWEP.DamageNear							= 22
SWEP.DamageFar							= 20
SWEP.RangeNear							= 25
SWEP.RangeFar							= 50

-- Ability
SWEP.Firemodes = {
	{
		Count = math.huge,
		Delay = ( 60 / 950 ),
		PostBurstDelay = 0,
	}
}

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