
AddCSLuaFile()
SWEP.Base								= "weapon_base" -- bastard of it all

SWEP.Category							= "W9K"
SWEP.Spawnable							= false
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

-- Sound
SWEP.ShootSound							= ")weapons/sig_p228/p228-1.wav"
SWEP.ShootSound_Level					= 80
SWEP.ShootAmb_Level						= 160
SWEP.ShootSoundSilenced					= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbInt						= "weapons/pistol/pistol_fire3.wav"
SWEP.ShootAmbExt						= ")w9k/fesiug/distant_pistol.ogg"

-- Recoil
SWEP.RecoilUp							= 2 -- degrees punched
SWEP.RecoilUpDrift						= 0.5 -- 50% will be smoothed
SWEP.RecoilUpDecay						= 10 -- 10 degrees per second
SWEP.RecoilSide							= 2 -- degrees punched, in either direction (-100% to 100%)
SWEP.RecoilSideDrift					= 0.5 -- 50% will be smoothed
SWEP.RecoilSideDecay					= 10 -- 10 degrees per second
SWEP.RecoilFlipChance					= ( 1 / 7 ) -- 1 in 7 chance for recoil flip

-- Spread
SWEP.SpreadHip							= 1 -- spread from the hip
SWEP.SpreadSight						= 0 -- spread in sights
SWEP.SpreadMoving						= 2 -- spread when normal walking
SWEP.SpreadSprint						= 5 -- spread when running
SWEP.SpreadShot							= 0.5 -- spread per shot
SWEP.SpreadShotDecay					= 6 -- how much to deaay per second
SWEP.SpreadShotDelay					= 0.04 -- time before spread decays after shot

-- Ability
SWEP.Primary.ClipSize					= -1
SWEP.Primary.Ammo						= "none"
SWEP.IsSuppressable						= false
SWEP.Firemodes = {
	{
		Count = 1,
		Delay = ( 60 / 450 ),
		PostBurstDelay = 0,
	}
}

-- Positioning
SWEP.IronSights = {
	Pos = Vector(0, 0, 0),
	Ang = Angle(0, 0, 0),
	Mag = 1.1,
}

SWEP.RunPose = {
	Pos = Vector(3.444, -7.823, -6.27),
	Ang = Angle(60.695, 0, 0),
}

-- Thirdperson
SWEP.TPAnim_Reload						= ACT_HL2MP_GESTURE_RELOAD_AR2
SWEP.TPAnim_Fire						= ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.HoldTypeHip						= "ar2"
SWEP.HoldTypeSight						= "rpg"
SWEP.HoldTypeSprint						= "passive"

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
	self:NetworkVar("Bool", 0, "FiredLastShot")
	self:NetworkVar("Bool", 1, "FiremodeDebounce")
	self:NetworkVar("Bool", 2, "RecoilFlip")
	self:NetworkVar("Bool", 3, "Suppressed")

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
	self:NetworkVar("Float", 8, "Spread")
	self:NetworkVar("Float", 9, "SpreadDelayTime")
	self:NetworkVar("Float", 10, "NextMechFire")
	self:NetworkVar("Float", 11, "SuppressIn")

	self.Primary.DefaultClip = self:GetMaxClip1() * 2
	self:SetFiremode(1)
	self:SetNextMechFire(0)
	self:SetRecoilFlip( util.SharedRandom( "recoilflipinit", 0, 1, CurTime() ) < 0.5 and true or false )
end

local unavailable = {
	Count = 1,
	Delay = 0.2,
	PostBurstDelay = 0,
}
function SWEP:GetFiremodeTable(cust)
	if !cust and self:Clip1() == 0 then
		return unavailable
	end

	return self.Firemodes[cust or self:GetFiremode()] or unavailable
end

function SWEP:SwitchFiremode(prev)
	-- lol?
	local nextfm = self:GetFiremode() + 1
	if #self.Firemodes < nextfm then
		nextfm = 1
	end
	--self:GetOwner():ChatPrint("Selected " .. self:GetFiremodeName(nextfm))
	self:SetFiremode(nextfm)
end

function SWEP:GetFiremodeName(cust)
	local firemodename
	local cnt = self:GetFiremodeTable(cust).Count
	if cnt == 1 then
		firemodename = "Semi-auto"
	elseif cnt == math.huge then
		firemodename = "Full-auto"
	elseif cnt > 0 then
		firemodename = cnt .. "-round burst"
	else
		firemodename = "Unknown firemode"
	end
	return firemodename
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

	if self:GetNextMechFire() > CurTime() then
		return false
	end

	if self:GetReloadingTime() > CurTime() then
		return false
	end

	if self:GetSprintDelta() > 0.2 then
		return false
	end

	if self:GetFiredLastShot() then
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
	if self:GetSuppressed() then
		self:PSound( self.ShootSoundSilenced, self.ShootSound_Level, 100, 1, CHAN_STATIC )
	else
		self:PSound( self.ShootSound, self.ShootSound_Level, 100, 1, CHAN_STATIC )
		self:PSound( self.ShootAmbExt, self.ShootAmb_Level, 100, 1, CHAN_STATIC )
	end

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
	else
		local p = self:GetOwner()
		if !IsValid(p) then p = false end
		if p then
			p:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, self.TPAnim_Fire, true )
		end
	end

	local p = self:GetOwner()
	if !IsValid(p) then p = false end
	if p then
		local fli = self:GetRecoilFlip() and -1 or 1
		if ( game.SinglePlayer() and SERVER ) or ( CLIENT and !game.SinglePlayer() and IsFirstTimePredicted() ) then
			p:SetEyeAngles( p:EyeAngles() + Angle( -self.RecoilUp * (1-self.RecoilUpDrift), fli * self.RecoilSide * (1-self.RecoilSideDrift) ) )
		end
		self:SetRecoilP( self:GetRecoilP() + (-self.RecoilUp * self.RecoilUpDrift) )
		self:SetRecoilY( self:GetRecoilY() + (fli * -self.RecoilSide * self.RecoilSideDrift) )
		if util.SharedRandom( "recoilflipinit", 0, 1, CurTime() ) < self.RecoilFlipChance then
			self:SetRecoilFlip( !self:GetRecoilFlip() )
		end
	end
	self:SetSpread( self:GetSpread() + self.SpreadShot )
	self:SetSpreadDelayTime( CurTime() + self.SpreadShotDelay )
	
	return true
end

local fuckads = 0
function SWEP:PrimaryAttack_SP()
	fuckads = 2
	local p = self:GetOwner()
	if !IsValid(p) then p = false end
	if p then
		p:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, self.TPAnim_Fire, true )
	end
end

-- Bullets
function SWEP:FireBullet(bullet)
	local dir = self:GetOwner():EyeAngles()
	local dispersion = self:GetDispersion()
	local shared_rand = CurTime()
	local x = util.SharedRandom(shared_rand, -0.5, 0.5) + util.SharedRandom(shared_rand + 1, -0.5, 0.5)
	local y = util.SharedRandom(shared_rand + 2, -0.5, 0.5) + util.SharedRandom(shared_rand + 3, -0.5, 0.5)
	dir = dir:Forward() + (x * math.rad(dispersion) * dir:Right()) + (y * math.rad(dispersion) * dir:Up())

	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Dir = dir
	bullet.Distance = 32768

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
			-- print( math.Round( (1-XD) * 100 ) .. "% effectiveness\t", math.floor( dmg:GetDamage() ) )
		end
		return
	end

	self:GetOwner():FireBullets( bullet )
end

-- No secondary
-- Suppressors, actually
function SWEP:SecondaryAttack()
	if self:GetOwner():KeyDown(IN_USE) and self:GetReloadingTime() < CurTime() and self:GetSightDelta() < 0.5 and self.IsSuppressable then
		if !self:GetSuppressed() then
			self:SendAnim( "sup_on", true )
		else
			self:SendAnim( "sup_off", true )
		end
	end
end

function SWEP:Deploy()
	self:SendAnim( "draw" )
	self:SetPlaybackRate( 1 )
	self:SetReloadingTime( CurTime() + self:SequenceDuration() )
	self:SetStopSightTime( CurTime() + self:SequenceDuration() * 0.5 )
	self:SetLoadIn( -1 )
	self:SetSuppressIn( -1 )
	self:SetSightDelta( 0 )
	self:SetSprintDelta( 0 )
	
	lastfmswitch = CurTime()
	if game.SinglePlayer() then
		self:CallOnClient("FMFix_SP")
	end
	return true
end

function SWEP:Holster()
	--self:SendAnim( "holster" )
	--self:SetPlaybackRate( 1 )
	self:SetReloadingTime( CurTime() + self:SequenceDuration() )
	self:SetLoadIn( -1 )
	self:SetSuppressIn( -1 )
	self:SetSightDelta( 0 )
	self:SetSprintDelta( 0 )
	return true
end

--
-- Reloading
--
local lastfmswitch = 0
function SWEP:Reload()
	if self:GetNextPrimaryFire() > CurTime() then
		return false
	end
	if self:GetNextMechFire() > CurTime() then
		return false
	end
	if self:GetReloadingTime() > CurTime() then
		return false
	end
	if self:GetOwner():KeyDown(IN_USE) then
		if !self:GetFiremodeDebounce() then
			self:SwitchFiremode()
			self:SetFiremodeDebounce( true )
			
			lastfmswitch = CurTime()
			if game.SinglePlayer() then
				self:CallOnClient("FMFix_SP")
			end
		end
		return false
	end

	if self:RefillCount() > 0 then
		self:SendAnim( "reload", true )
		if game.SinglePlayer() then
			self:CallOnClient("Reload_SP")
		else
			local p = self:GetOwner()
			if !IsValid(p) then p = false end
			if p then
				p:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, self.TPAnim_Reload, true )
			end
		end
	end

	return true
end

function SWEP:FMFix_SP()
	lastfmswitch = CurTime()
end

function SWEP:Reload_SP()
	fuckads = 2
	local p = self:GetOwner()
	if !IsValid(p) then p = false end
	if p then
		p:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, self.TPAnim_Reload, true )
	end
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

	if self:GetSuppressIn() > 0 and self:GetSuppressIn() <= CurTime() then
		self:SetSuppressed( !self:GetSuppressed() )
		self:SetSuppressIn( -1 )
	end

	if self:GetIdleIn() > 0 and self:GetIdleIn() <= CurTime() then
		self:SendAnim( "idle", "idle" )
		self:SetPlaybackRate( 1 )
		self:SetIdleIn( -1 )
	end

	local p = self:GetOwner()
	if !IsValid(p) then p = false end
	if p then
		local rp = self:GetRecoilP()
		local ry = self:GetRecoilY()
		if rp != 0 then
			local remove = rp - math.Approach( rp, 0, FrameTime() * self.RecoilUpDecay )
			p:SetEyeAngles( p:EyeAngles() + ( Angle( remove, 0 ) ) )
			self:SetRecoilP( rp - remove )
		end
		if ry != 0 then
			local remove = ry - math.Approach( ry, 0, FrameTime() * self.RecoilSideDecay )
			p:SetEyeAngles( p:EyeAngles() + ( Angle( 0, remove ) ) )
			self:SetRecoilY( math.Approach( ry, ry - remove, math.huge ) )
		end
		local ht = self.HoldTypeHip
		if self:GetSprintDelta() > 0.7 then
			ht = self.HoldTypeSprint
		elseif self:GetSightDelta() > 0.2 then
			ht = self.HoldTypeSight
		end
		self:SetHoldType( ht )
		self:SetWeaponHoldType( ht )
	end
	
	if self:GetFiremodeDebounce() and !self:GetOwner():KeyDown(IN_RELOAD) then
		self:SetFiremodeDebounce( false )
	end

	if self:GetSpreadDelayTime() < CurTime() then
		self:SetSpread( math.Approach(self:GetSpread(), 0, FrameTime() * self.SpreadShotDecay ) )
	end

	local runoff = true
	if runoff and self:GetBurstCount() != 0 then
		if ( ( game.SinglePlayer() and SERVER ) or ( !game.SinglePlayer() ) ) then
			self:PrimaryAttack()
		end
	end
	if self:GetBurstCount() >= self:GetFiremodeTable().Count then
		self:SetBurstCount( 0 )
		self:SetNextMechFire( CurTime() + self:GetFiremodeTable().PostBurstDelay ) -- Can feel uncomfortable.
		self:SetFiredLastShot( true )
	elseif !self:GetOwner():KeyDown(IN_ATTACK) and self:GetBurstCount() != 0 then
		self:SetBurstCount( 0 )
		self:SetNextMechFire( CurTime() + self:GetFiremodeTable().PostBurstDelay ) -- Can feel uncomfortable.
	end
	if !self:GetOwner():KeyDown(IN_ATTACK) then
		self:SetFiredLastShot(false)
	end
end

local fallback = {
	Mult = 1,
}
function SWEP:SendAnim( act, hold )
	local anim = self.Animations[act]
	if self:GetSuppressed() and self.Animations[act .. "_sup"] then
		anim = self.Animations[act .. "_sup"]
	end
	if !anim then
		anim = fallback
		anim.Source = act
	end
	self:SendWeaponAnim( anim.Source )
	self:SetPlaybackRate( anim.Mult or 1 )
	if hold == "idle" then
		hold = false
	else
		self:SetIdleIn( CurTime() + self:SequenceDuration() )
	end

	local stopsight = hold
	local reloadtime = hold
	local loadin = false
	local suppresstime = false

	if anim.StopSightTime then
		stopsight = true
	end
	if anim.ReloadingTime then
		reloadtime = true
	end
	if anim.LoadIn then
		loadin = true
	end
	if anim.SuppressTime then
		suppresstime = true
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
	if suppresstime then
		self:SetSuppressIn( CurTime() + (anim.SuppressTime or self:SequenceDuration()) )
	end

end

function SWEP:TranslateFOV( fov )
	return fov / Lerp( math.ease.InOutQuad( self:GetSightDelta() ), 1, self.IronSights.Mag )
end

function SWEP:AdjustMouseSensitivity()
	return 1 / Lerp( math.ease.InOutQuad( self:GetSightDelta() ), 1, self.IronSights.Mag )
end

-- Dispersion
function SWEP:GetDispersion()
	local move = 0

	local dis = Lerp( self:GetSightDelta(), self.SpreadHip, self.SpreadSight )

	local p = self:GetOwner()

	local s_m = p:GetWalkSpeed()
	--local s_r = p:GetRunSpeed()
	local s_v = p:GetAbsVelocity():Length2D()

	local wa = math.Clamp( math.TimeFraction( 0, s_m, s_v ), 0, 1 )
	--local ru = math.Clamp( math.TimeFraction( s_m, s_r, s_v ), 0, 1 )
	
	dis = dis + Lerp( wa, 0, self.SpreadMoving )
	--dis = dis + Lerp( wa, 0, self.SpreadSprint )

	dis = dis + self:GetSpread()

	return dis
end

-- Get movement
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

--
-- UI & Crosshair
--

if CLIENT then
	surface.CreateFont( "W9K_Firemode", {
		font = "Tahoma",
		size = ScreenScale(8),
		weight = 1000,
	} )
end

local CLR_F = Color( 255, 255, 50, 255 )
local CLR_B = Color( 0, 0, 0, 80 )
function SWEP:DrawHUD()
	local bw, bh = ScreenScale(70), ScreenScale(12)

	local clock = math.TimeFraction( lastfmswitch + 1, lastfmswitch + 0.75, CurTime() )
	clock = Lerp( clock, 0, 1 )
	CLR_F.a = clock * 255
	CLR_B.a = clock * 80

	draw.RoundedBox( ScreenScale(4), (ScrW()/2) - (bw/2), ScrH() - ScreenScale(8) - bh, bw, bh, CLR_B )
	draw.SimpleText( self:GetFiremodeName(self:GetFiremode()), "W9K_Firemode", (ScrW()/2), ScrH() - ScreenScale(8) - (bh/2), CLR_F, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	CLR_F.a = clock * 255 * 0.2
	if self.Firemodes[self:GetFiremode() - 1] then
		draw.SimpleText( self:GetFiremodeName(self:GetFiremode() - 1), "W9K_Firemode", (ScrW()/2), ScrH() - ScreenScale(8) - (bh/2) - ScreenScale( 8 ), CLR_F, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	if self.Firemodes[self:GetFiremode() + 1] then
		draw.SimpleText( self:GetFiremodeName(self:GetFiremode() + 1), "W9K_Firemode", (ScrW()/2), ScrH() - ScreenScale(8) - (bh/2) + ScreenScale( 8 ), CLR_F, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end

local si = {}
if CLIENT then
	si = {
		["parabolic"]	= surface.GetTextureID("scope/gdcw_parabolicsight"),
		["svd"]			= surface.GetTextureID("scope/gdcw_svdsight"),
	}
end

local CHR_F = Color( 255, 255, 100, 255 )
local CHR_B = Color( 0, 0, 0, 100 )
local CHR_S = Color( 255, 255, 255, 255 )
local len = 1.5
local thi = 1
local gap = 10
local sd = 1
function SWEP:DoDrawCrosshair()
	local l = ScreenScale(len)
	local t = ScreenScale(thi)
	local s = sd

	local dispersion = math.rad(self:GetDispersion())
	cam.Start3D()
		local lool = ( EyePos() + ( EyeAngles():Forward() ) + ( dispersion * EyeAngles():Up() ) ):ToScreen()
	cam.End3D()

	local gau = (ScrH()/2)
	gau = ( gau - lool.y )
	gap = gau
	
	if self.IronSights.Scope then
		local sick = Lerp( math.TimeFraction( 0.6, 0.8, self:GetSightDelta() ), 0, 1 )
		CHR_S.a = sick * 255
		surface.SetDrawColor( CHR_S )
		local mat = self.IronSights.Scope
		if isnumber( si[mat] ) then
			mat = si[mat]
		end
		if isnumber( mat ) then
			surface.SetTexture( mat )
		else
			surface.SetMaterial( mat )
		end
		local gaap = gap
		local size = ScrH()--( ScrH() * 1 ) + ( gaap * ScrH() )
		size = size * 1.4
		size = size + ( gap * ScrH() * 0.01 )
		size = size * (0.8+(sick*0.2))
		surface.DrawTexturedRect( ( ScrW() / 2 ) - ( size / 2 ), ( ScrH() / 2 ) - ( size / 2 ), size, size)
	end

	local clock = Lerp( math.max( self:GetSightDelta(), self:GetSprintDelta() ), 1, 0 )
	CHR_F.a = clock * 255
	CHR_B.a = clock * 100
	gap = gap / (clock)
	l = l * clock
	-- bg
	surface.SetDrawColor( CHR_B )
	-- bottom prong
	surface.DrawRect( math.Round(( ScrW() / 2 ) - ( t / 2 ) + s), math.Round(( ScrH() / 2 ) + gap + s), t, l )

	-- top prong
	surface.DrawRect( math.Round(( ScrW() / 2 ) - ( t / 2 ) + s), math.Round(( ScrH() / 2 ) - l - gap + s), t, l )

	-- left prong
	surface.DrawRect( math.Round(( ScrW() / 2 ) - l - gap + s), math.Round(( ScrH() / 2 ) - ( t / 2 ) + s), l, t )

	-- right prong
	surface.DrawRect( math.Round(( ScrW() / 2 ) + gap + s), math.Round(( ScrH() / 2 ) - ( t / 2 ) + s), l, t )

	-- fore
	surface.SetDrawColor( CHR_F )
	-- bottom prong
	surface.DrawRect( math.Round(( ScrW() / 2 ) - ( t / 2 )), math.Round(( ScrH() / 2 ) + gap), t, l )

	-- top prong
	surface.DrawRect( math.Round(( ScrW() / 2 ) - ( t / 2 )), math.Round(( ScrH() / 2 ) - l - gap), t, l )

	-- left prong
	surface.DrawRect( math.Round(( ScrW() / 2 ) - l - gap), math.Round(( ScrH() / 2 ) - ( t / 2 )), l, t )

	-- right prong
	surface.DrawRect( math.Round(( ScrW() / 2 ) + gap), math.Round(( ScrH() / 2 ) - ( t / 2 )), l, t )
	return true
end

function SWEP:ShouldDrawViewModel()
	if self.IronSights.Scope and (self:GetSightDelta() > 0.8) then
		return false
	else
		return true
	end
end