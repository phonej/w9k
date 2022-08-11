
SWEP.Base								= "w9k"

SWEP.Category							= "W9K"
SWEP.Spawnable							= true

--
-- Weapon configuration
--
SWEP.PrintName							= "SIG P229R"
SWEP.Slot								= 2

--
-- Appearance
--
SWEP.ViewModel				= "models/weapons/v_sick_p228.mdl"
SWEP.ViewModelFOV			= 64
SWEP.WorldModel				= "models/weapons/w_sig_229r.mdl"

-- Capacity
SWEP.Primary.ClipSize					= 12
SWEP.Primary.Ammo						= "pistol"

-- Damage
SWEP.DamageNear							= 30
SWEP.DamageFar							= 20
SWEP.RangeNear							= 15
SWEP.RangeFar							= 30

-- Ability
SWEP.Firemodes = {
	{
		Count = 1,
		Delay = ( 60 / 450 ),
		PostBurstDelay = 0,
	}
}

SWEP.IronSights = {
	Pos = Vector(-2.653, -0.686, 1.06),
	Ang = Angle(0.3, 0, 0),
	FOV = 70,
	VFOV = 60,
}

SWEP.Animations = {
	["reload"] = {
		Source = ACT_VM_RELOAD,
		Mult = 1,
		StopSightTime = 2.3,
		LoadIn = 1.9,
	},
}