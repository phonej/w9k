
SWEP.Base								= "w9k"

SWEP.Category							= "W9K"
SWEP.Spawnable							= true

--
-- Weapon configuration
--
SWEP.PrintName							= "SIG P229R"
SWEP.Slot								= 1

--
-- Appearance
--
SWEP.ViewModel				= "models/weapons/v_sick_p228.mdl"
SWEP.WorldModel				= "models/weapons/w_sig_229r.mdl"
SWEP.ViewModelFOVBase		= 64

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
	Mag = 1.1,
}

SWEP.RunPose = {
	Pos = Vector(3.444, -7.823, -6.27),
	Ang = Angle(60.695, 0, 0),
}

SWEP.Animations = {
	["fire"] = {
		Source = ACT_VM_PRIMARYATTACK,
		Mult = 1,
	},
	["reload"] = {
		Source = ACT_VM_RELOAD,
		Mult = 1,
		StopSightTime = 2.3,
		LoadIn = 1.9,
	},
}