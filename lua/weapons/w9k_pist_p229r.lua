
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

-- Sound
SWEP.ShootSound							= ")weapons/sig_p228/p228-1.wav"
SWEP.ShootSound_Level					= 80
SWEP.ShootAmb_Level						= 160
SWEP.ShootAmbInt						= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbExt						= ")w9k/fesiug/distant_pistol.ogg"

-- Recoil
SWEP.RecoilUp							= 2 -- degrees punched
SWEP.RecoilUpDrift						= 0.5 -- 50% will be smoothed
SWEP.RecoilUpDecay						= 10 -- 10 degrees per second
SWEP.RecoilSide							= 2 -- degrees punched, in either direction (-100% to 100%)
SWEP.RecoilSideDrift					= 0.5 -- 50% will be smoothed
SWEP.RecoilSideDecay					= 10 -- 10 degrees per second
SWEP.RecoilFlipChance					= ( 1 / 3 ) -- 1 in 7 chance for recoil flip
SWEP.RecoilADSMult						= ( 1 / 3 ) -- multiply shot recoil by this amount when ads'd

-- Damage
SWEP.DamageNear							= 30
SWEP.DamageFar							= 20
SWEP.RangeNear							= 15
SWEP.RangeFar							= 30

-- Ability
SWEP.Primary.ClipSize					= 12
SWEP.Primary.Ammo						= "pistol"
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

-- Thirdperson
SWEP.TPAnim_Reload						= ACT_HL2MP_GESTURE_RELOAD_PISTOL
SWEP.TPAnim_Fire						= ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
SWEP.HoldTypeHip						= "pistol"
SWEP.HoldTypeSight						= "revolver"
SWEP.HoldTypeSprint						= "normal"

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
		StopSightTime = 2.3,
		LoadIn = 1.9,
	},
}