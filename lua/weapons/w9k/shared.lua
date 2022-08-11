
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
	Mag = 1.1,
}

SWEP.RunPose = {
	Pos = Vector(3.444, -7.823, -6.27),
	Ang = Angle(60.695, 0, 0),
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

SWEP.RecoilUp = 2 -- degrees punched
SWEP.RecoilUpDrift = 0.5 -- 50% will be smoothed
SWEP.RecoilDecay = 10 -- 10 degrees per second
SWEP.RecoilCS = false -- recoil returns

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
	self:NetworkVar("Float", 5, "SprintDelta")

	self:NetworkVar("Float", 6, "RecoilP")
	self:NetworkVar("Float", 7, "RecoilY")

	self.Primary.DefaultClip = self:GetMaxClip1() * 2
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

local HUToM = 0.0254

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

	if self:GetSprintDelta() > 0.2 then
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
	self:PSound( self.ShootSound, self.ShootSound_Level )

	if self:GetSightDelta() < 0.5 then
		self:SendAnim( "fire" )
	end

	local bullet = {
		RangeNear = self.RangeNear / HUToM,
		RangeFar = self.RangeFar / HUToM,
		DamageNear = self.DamageNear,
		DamageFar = self.DamageFar,
	}
	self:FireBullet(bullet)

	if game.SinglePlayer() then
		self:CallOnClient("PrimaryAttack_SP")
	end

	local p = self:GetOwner()
	if !IsValid(p) then p = false end
	if p then
		if ( game.SinglePlayer() and SERVER ) or ( CLIENT and !game.SinglePlayer() and IsFirstTimePredicted() ) then
			p:SetEyeAngles( p:EyeAngles() + Angle( (-self.RecoilUp * ( self.RecoilCS and 1 or self.RecoilUpDrift ) ), 0 ) )
		end
		self:SetRecoilP( self:GetRecoilP() + (-self.RecoilUp * ( self.RecoilCS and 1 or self.RecoilUpDrift ) ) )
	end
	
	return true
end

local fuckads = 0
function SWEP:PrimaryAttack_SP()
	fuckads = 2
end

-- Bullets
function SWEP:FireBullet(bullet)
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Callback = function( atk, tr, dmg )
		-- Thank you Arctic, very cool
		local ent = tr.Entity

		dmg:SetDamage( bullet.DamageNear )
		dmg:SetDamageType( DMG_BULLET )

		if IsValid(ent) then
			local d = dmg:GetDamage()
			local min, max = bullet.RangeNear, bullet.RangeFar
			local range = atk:GetPos():Distance(ent:GetPos())
			local XD = 0
			if range < min then
				XD = 0
			else
				XD = math.Clamp((range - min) / (max - min), 0, 1)
			end


			dmg:SetDamage( Lerp( 1-XD, bullet.DamageFar, bullet.DamageNear ) )
			print( math.Round( (1-XD) * 100 ) .. "% effectiveness\t", math.floor( dmg:GetDamage() ) )
		end
		return
	end

	self:GetOwner():FireBullets( bullet )
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

-- Play sound
function SWEP:PSound(snd, lvl, pitch, vol, chan)
	local sond = snd
	if istable(snd) then
		sond = table.Random(snd)
	end
	self:EmitSound(sond, lvl, pitch, vol, chan)
end

-- Thinking
function SWEP:Think()
	local capableofads = self:GetStopSightTime() <= CurTime() and !self:GetOwner():IsSprinting() -- replace with GetReloading
	self:SetSightDelta( math.Approach( self:GetSightDelta(), (capableofads and self:GetOwner():KeyDown(IN_ATTACK2) and 1 or 0), FrameTime() / 0.4 ) )
	self:SetSprintDelta( math.Approach( self:GetSprintDelta(), (self:GetOwner():IsSprinting() and 1 or 0), FrameTime() / 0.4 ) )

	if self:GetLoadIn() > 0 and self:GetLoadIn() <= CurTime() then
		self:Refill(self:Clip1())
		self:SetLoadIn(-1)
	end
	
	if self:GetIdleIn() > 0 and self:GetIdleIn() <= CurTime() then
		self:SendAnim( ACT_VM_IDLE, 1, false )
	end

	local p = self:GetOwner()
	if !IsValid(p) then p = false end
	if p then
		local rp = self:GetRecoilP()
		local ry = self:GetRecoilY()
		if rp != 0 then
			local remove = rp - math.Approach( rp, 0, FrameTime() * ( self.RecoilDecay or 4 ) )
			p:SetEyeAngles( p:EyeAngles() + ( Angle( remove*1, 0 ) * ( self.RecoilCS and -1 or 1 ) ) )
			self:SetRecoilP( rp - remove )
		end
	end

	if !self:GetOwner():KeyDown(IN_ATTACK) and self:GetBurstCount() != 0 and self:GetBurstCount() == self:GetFiremodeTable().Count then
		self:SetBurstCount( 0 )
	end
end

function SWEP:SendAnim( act, hold )
	local anim = self.Animations[act]
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
	return fov / Lerp( math.ease.InOutQuad( self:GetSightDelta() ), 1, self.IronSights.Mag )
end

function SWEP:GetMovement()
	local p = self:GetOwner()
	if !IsValid(p) then
		return 0
	end

	if !p:IsPlayer() then
		return 0
	end

	if p:IsSprinting() then
		return 2
	end
end

SWEP.BobScale = 1
SWEP.SwayScale = 1

local cancelsprint = 0

function SWEP:GetViewModelPosition(pos, ang)
	local opos, oang = Vector(), Angle()

	do -- ironsighting
		local b_pos, b_ang = Vector(), Angle()
		local si = self:GetSightDelta()
		self.BobScale = 1-si
		self.SwayScale = 1-si
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

	do -- sprinting
		local b_pos, b_ang = Vector(), Angle()
		local si = self:GetSprintDelta()

		cancelsprint = math.Approach( cancelsprint, (self:GetStopSightTime() > CurTime() and 0 or 1), FrameTime() / 0.4 )
		si = math.min(si, cancelsprint)

		b_pos:Add( self.RunPose.Pos )
		b_pos:Mul( math.ease.InOutSine( si ) )
		b_ang:Add( self.RunPose.Ang )
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

		b_pos:Add( Vector( -2, -1, -2 ) )
		b_pos:Mul( math.ease.InOutSine( xi ) )
		b_ang:Add( Angle( -4, 0, -15 ) )
		b_ang:Mul( math.ease.InOutSine( xi ) )

		opos:Add( b_pos )
		oang:Add( b_ang )
	end

	do -- fuck ads
		local b_pos, b_ang = Vector(), Angle()

		b_pos:Add( oang:Right() * fuckads )
		fuckads = math.Approach( fuckads, 0, FrameTime() * 10 )

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