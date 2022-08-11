
AddCSLuaFile()
SWEP.Base								= "weapon_base" -- bastard of it all

SWEP.Category							= "W9K"
SWEP.Spawnable							= true
SWEP.DrawCrosshair						= true

--
-- Weapon configuration
--
SWEP.PrintName							= "W9K"
SWEP.Slot								= 2

--
-- Appearance
--
SWEP.ViewModel							= "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel							= "models/weapons/w_rif_famas.mdl"
SWEP.ViewModelFOVBase					= 75

SWEP.Primary.ClipSize					= -1
SWEP.Primary.DefaultClip				= 0
SWEP.Primary.Ammo						= "none"


SWEP.ShootSound							= ")weapons/sig_p228/p228-1.wav"
SWEP.ShootSound_Level					= 70
SWEP.ShootAmb_Level						= 140
SWEP.ShootSoundSilenced					= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbInt						= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbExt						= "weapons/pistol/pistol_fire3.wav"

SWEP.Firemodes = {
	{
		Count = 1,
		Delay = ( 60 / 450 ),
		PostBurstDelay = 0,
	}
}

SWEP.IronSights = {
	Pos = Vector(0, 0, 0),
	Ang = Angle(0, 0, 0),
	FOV = 70,
	VFOV = 50,
}

--
-- Useless shit that you should NEVER touch
--
SWEP.Weight								= 5
SWEP.AutoSwitchTo						= false
SWEP.AutoSwitchFrom						= false
SWEP.m_WeaponDeploySpeed				= 10
-- Don't touch this
SWEP.UseHands							= true
SWEP.Primary.Automatic					= true -- This should ALWAYS be true.
SWEP.Secondary.ClipSize					= -1
SWEP.Secondary.DefaultClip				= 0
SWEP.Secondary.Automatic				= true
SWEP.Secondary.Ammo						= "none"

function SWEP:Initalize()
	self.Primary.Automatic = true
	self.Secondary.Automatic = true
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "BurstCount")
	self:NetworkVar("Int", 1, "Firemode")

	self:NetworkVar("Float", 0, "SightDelta")
	self:NetworkVar("Float", 1, "LoadIn")
	self:NetworkVar("Float", 2, "IdleIn")
	self:NetworkVar("Float", 3, "ReloadingTime")
	self:NetworkVar("Float", 4, "StopSightTime")

	self:SetFiremode(1)
end

local unavailable = {
	Count = 1,
	Delay = 0.2,
	PostBurstDelay = 0.2,
}
function SWEP:GetFiremodeTable()
	if self:Clip1() == 0 then
		return unavailable
	end

	return self.Firemodes[self:GetFiremode()] or unavailable
end

function SWEP:SwitchFireMode(next)
	-- lol?
end

--
-- Firing function
--
function SWEP:PrimaryAttack()
	local ammototake = 1

	if self:GetNextPrimaryFire() > CurTime() then
		return false
	end

	if self:GetReloadingTime() > CurTime() then
		return false
	end

	if (self:GetBurstCount() + 1) > self:GetFiremodeTable().Count then
		return false
	end

	if self:Clip1() < ammototake then
		self:SetNextPrimaryFire( CurTime() + self:GetFiremodeTable().Delay )
		self:SetBurstCount( self:GetBurstCount() + 1 )
		self:EmitSound( "Weapon_Pistol.Empty" )
		return false
	end

	self:TakePrimaryAmmo( ammototake )
	self:SetNextPrimaryFire( CurTime() + self:GetFiremodeTable().Delay )
	self:SetBurstCount( self:GetBurstCount() + 1 )
	self:EmitSound( self.ShootSound, self.ShootSound_Level )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	return true
end

-- No secondary
function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetPlaybackRate( 1 )
	self:SetReloadingTime( CurTime() + self:SequenceDuration() )
	return true
end

function SWEP:Holster()
	self:SendWeaponAnim( ACT_VM_HOLSTER )
	self:SetPlaybackRate( 1 )
	self:SetReloadingTime( CurTime() + self:SequenceDuration() )
	return true
end

--
-- Reloading
--
function SWEP:Reload()
	if self:GetNextPrimaryFire() > CurTime() then
		return false
	end
	if self:GetReloadingTime() > CurTime() then
		return false
	end

	if self:RefillCount() > 0 then
		self:SendAnim( "reload", true )
	end

	return true
end

function SWEP:RefillCount(amount)
	local spent = self:GetMaxClip1() - self:Clip1()
	local refill = math.min( spent, self:Ammo1(), (amount or math.huge) )

	return refill
end

function SWEP:Refill()
	local refill = self:RefillCount()

	self:GetOwner():SetAmmo( self:Ammo1() - refill, self:GetPrimaryAmmoType() )
	self:SetClip1( self:Clip1() + refill )
end

function SWEP:TakePrimaryAmmo( amount )
	assert( self:Clip1() - amount >= 0, "Trying to reduce ammo below zero!" )

	self:SetClip1( self:Clip1() - 1 )
end

-- Thinking
function SWEP:Think()
	local capableofads = self:GetStopSightTime() <= CurTime() -- replace with GetReloading
	self:SetSightDelta( math.Approach( self:GetSightDelta(), (capableofads and self:GetOwner():KeyDown(IN_ATTACK2) and 1 or 0), FrameTime() / 0.4 ) )

	if self:GetLoadIn() > 0 and self:GetLoadIn() <= CurTime() then
		self:Refill(self:Clip1())
		self:SetLoadIn(-1)
	end
	
	if self:GetIdleIn() > 0 and self:GetIdleIn() <= CurTime() then
		self:SendAnim( ACT_VM_IDLE, 1, false )
	end

	if !self:GetOwner():KeyDown(IN_ATTACK) and self:GetBurstCount() != 0 and self:GetBurstCount() == self:GetFiremodeTable().Count then
		self:SetBurstCount( 0 )
	end
end

function SWEP:SendAnim( act, hold )
	local anim = self.Animations["reload"]
	self:SendWeaponAnim( anim.Source )
	self:SetPlaybackRate( anim.Mult or 1 )

	local stopsight = hold
	local reloadtime = hold
	local loadin = false

	if anim.StopSightTime then
		stopsight = true
	end
	if anim.ReloadingTime then
		reloadtime = true
	end
	if anim.LoadIn then
		loadin = true
	end

	if reloadtime then
		self:SetReloadingTime( CurTime() + (anim.ReloadingTime or self:SequenceDuration()) )
	end
	if stopsight then
		self:SetStopSightTime( CurTime() + (anim.StopSightTime or self:SequenceDuration()) )
	end
	if loadin then
		self:SetLoadIn( CurTime() + (anim.LoadIn or self:SequenceDuration()) )
	end
end

function SWEP:TranslateFOV( fov )
	return fov / Lerp( math.ease.InOutQuad( self:GetSightDelta() ), 1, 1.1 )
end

SWEP.BobScale = 1
SWEP.SwayScale = 1

function SWEP:GetViewModelPosition(pos, ang)
	local opos, oang = Vector(), Angle()

	do -- ironsighting
		local b_pos, b_ang = Vector(), Angle()
		local si = self:GetSightDelta()
		self.BobScale = 1-si
		self.SwayScale = 1-si
		--self:GetOwner():SetFOV( math.sin(CurTime())*45 + 45, 0 )
		self.ViewModelFOV = self.ViewModelFOVBase--Lerp( si, self.ViewModelFOVBase, self.IronSights.VFOV )

		b_pos:Add( self.IronSights.Pos )
		b_pos:Mul( math.ease.InOutSine( si ) )
		b_ang:Add( self.IronSights.Ang )
		b_ang:Mul( math.ease.InOutSine( si ) )

		opos:Add( b_pos )
		oang:Add( b_ang )
		
		local b_pos, b_ang = Vector(), Angle()
		local xi = si

		if xi >= 0.5 then
			xi = xi - 0.5
			xi = 0.5 - xi
		end
		xi = xi * 2

		b_pos:Add( Vector( -0.5, -2, -0 ) )
		b_pos:Mul( math.ease.InOutSine( xi ) )
		b_ang:Add( Angle( -4, 0, -5 ) )
		b_ang:Mul( math.ease.InOutSine( xi ) )

		opos:Add( b_pos )
		oang:Add( b_ang )
	end
	
	ang:RotateAroundAxis( ang:Right(),		oang.x )
	ang:RotateAroundAxis( ang:Up(),			oang.y )
	ang:RotateAroundAxis( ang:Forward(),	oang.z )

	pos:Add( opos.x * ang:Right() )
	pos:Add( opos.y * ang:Forward() )
	pos:Add( opos.z * ang:Up() )

	return pos, ang
end