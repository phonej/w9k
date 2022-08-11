
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
SWEP.ViewModelFOV			= 64
SWEP.WorldModel				= "models/weapons/w_tct_famas.mdl"

-- Capacity
SWEP.Primary.ClipSize					= 30
SWEP.Primary.Ammo						= "smg1"

-- Damage
SWEP.DamageNear							= 30
SWEP.DamageFar							= 20
SWEP.RangeNear							= 15
SWEP.RangeFar							= 30

-- Ability
SWEP.Firemodes = {
	{
		Count = math.huge,
		Delay = ( 60 / 450 ),
		PostBurstDelay = 0,
	}
}

SWEP.IronSights = {
	Pos = Vector(-2.653, -0.686, 1.06),
	Ang = Angle(0.3, 0, 0),
	Mag = 1.1,
}

SWEP.RunPose = {
	Pos = Vector(3.444, -7.823, -6.27),
	Ang = Angle(60.695, 0, 0),
}

SWEP.Animations = {
	["reload"] = {
		Source = ACT_VM_RELOAD,
		Mult = 1,
		StopSightTime = 2.3,
		LoadIn = 1.9,
	},
}