/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/
/*
==============================================================================

SOLDIER / PLAYER (Grunt)

==============================================================================
*/

$cd id1/models/soldier3
$origin 0 -6 24
$base base
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11

$frame load1 load2 load3 load4 load5 load6 load7 load8 load9 load10 load11

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8 painc9 painc10
$frame painc11 painc12 painc13

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8 shoot9

$frame prowl_1 prowl_2 prowl_3 prowl_4 prowl_5 prowl_6 prowl_7 prowl_8
$frame prowl_9 prowl_10 prowl_11 prowl_12 prowl_13 prowl_14 prowl_15 prowl_16
$frame prowl_17 prowl_18 prowl_19 prowl_20 prowl_21 prowl_22 prowl_23 prowl_24

/*
==============================================================================
SOLDIER CODE
==============================================================================
*/

void() army_fire;

void()	army_stand1	=[	$stand1,	army_stand2	] {ai_stand();};
void()	army_stand2	=[	$stand2,	army_stand3	] {ai_stand();};
void()	army_stand3	=[	$stand3,	army_stand4	] {ai_stand();};
void()	army_stand4	=[	$stand4,	army_stand5	] {ai_stand();};
void()	army_stand5	=[	$stand5,	army_stand6	] {ai_stand();};
void()	army_stand6	=[	$stand6,	army_stand7	] {ai_stand();};
void()	army_stand7	=[	$stand7,	army_stand8	] {ai_stand();};
void()	army_stand8	=[	$stand8,	army_stand1	] {ai_stand();};

void()	army_walk1	=[	$prowl_1,	army_walk2	]
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	ai_walk(1);
};
void()	army_walk2	=[	$prowl_2,	army_walk3	] {ai_walk(1);};
void()	army_walk3	=[	$prowl_3,	army_walk4	] {ai_walk(1);};
void()	army_walk4	=[	$prowl_4,	army_walk5	] {ai_walk(1);};
void()	army_walk5	=[	$prowl_5,	army_walk6	] {ai_walk(2);};
void()	army_walk6	=[	$prowl_6,	army_walk7	] {ai_walk(3);};
void()	army_walk7	=[	$prowl_7,	army_walk8	] {ai_walk(4);};
void()	army_walk8	=[	$prowl_8,	army_walk9	] {ai_walk(4);};
void()	army_walk9	=[	$prowl_9,	army_walk10	] {ai_walk(2);};
void()	army_walk10	=[	$prowl_10,	army_walk11	] {ai_walk(2);};
void()	army_walk11	=[	$prowl_11,	army_walk12	] {ai_walk(2);};
void()	army_walk12	=[	$prowl_12,	army_walk13	] {ai_walk(1);};
void()	army_walk13	=[	$prowl_13,	army_walk14	] {ai_walk(0);};
void()	army_walk14	=[	$prowl_14,	army_walk15	] {ai_walk(1);};
void()	army_walk15	=[	$prowl_15,	army_walk16	] {ai_walk(1);};
void()	army_walk16	=[	$prowl_16,	army_walk17	] {ai_walk(1);};
void()	army_walk17	=[	$prowl_17,	army_walk18	] {ai_walk(3);};
void()	army_walk18	=[	$prowl_18,	army_walk19	] {ai_walk(3);};
void()	army_walk19	=[	$prowl_19,	army_walk20	] {ai_walk(3);};
void()	army_walk20	=[	$prowl_20,	army_walk21	] {ai_walk(3);};
void()	army_walk21	=[	$prowl_21,	army_walk22	] {ai_walk(2);};
void()	army_walk22	=[	$prowl_22,	army_walk23	] {ai_walk(1);};
void()	army_walk23	=[	$prowl_23,	army_walk24	] {ai_walk(1);};
void()	army_walk24	=[	$prowl_24,	army_walk1	] {ai_walk(1);};

void()	army_run1	=[	$run1,		army_run2	]
{
	// TDA-Jules: Retreat logic
	if (self.is_retreating == 1)
	{
		if (time >= self.retreat_finished)
		{
			self.is_retreating = 0; // TDA-Jules: Retreat time finished
			// TDA-Jules: Proceed to normal run logic below
		}
		else
		{
			// TDA-Jules: Continue retreating
			// TDA-Jules: self.ideal_yaw was set in army_pain to face away. ai_turn will handle turning.
			ai_turn(); // TDA-Jules: Ensure monster turns towards ideal_yaw (away from enemy)
			ai_run(15); // TDA-Jules: Run speed while retreating
			return; // TDA-Jules: Skip strafing/normal engagement
		}
	}

	// TDA-Jules: Check for strafe conditions (only if not retreating)
	// TDA-Jules: Player visibility and range (512 units) are checked. Cooldown self.strafe_finished < time.
	// TDA-Jules: Random chance of 30% to strafe.
	if (self.enemy != world && self.strafe_finished < time && random() < 0.3 && visible(self.enemy) && vlen(self.origin - self.enemy.origin) < 512)
	{
		ai_face(); // TDA-Jules: Ensure facing the enemy before deciding to strafe.
		// TDA-Jules: Check if monster is roughly facing the player (e.g. within 20 degrees yaw).
		if (fabs(self.ideal_yaw - self.angles_y) < 20)
		{
			makevectors(self.angles); // TDA-Jules: Calculate v_right based on current facing direction for lateral movement.
			if (random() < 0.5)
			{
				// TDA-Jules: Strafe left. Set velocity directly for one frame.
				self.velocity_x = v_right_x * -150; // TDA-Jules: Strafe speed.
				self.velocity_y = v_right_y * -150;
			}
			else
			{
				// TDA-Jules: Strafe right.
				self.velocity_x = v_right_x * 150;
				self.velocity_y = v_right_y * 150;
			}
			self.strafe_finished = time + 1; // TDA-Jules: Cooldown for 1 second.
            // TDA-Jules: Call ai_run with 0 speed to prevent forward movement during strafe, but keep animation and next frame logic.
			ai_run(0); 
		}
		else
		{
			// TDA-Jules: Not facing player sufficiently, run normally.
			if (random() < 0.2)
				sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
			ai_run(11);
		}
	}
	else
	{
		// TDA-Jules: Conditions for strafe not met, run normally.
		if (random() < 0.2)
			sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
		ai_run(11); // TDA-Jules: This will also call ai_face() if enemy is visible via CheckAttack
	}
};
// TDA-Jules: Simplified retreat checks in subsequent run frames. army_run1 handles the core logic.
void()	army_run2	=[	$run2,		army_run3	] { if(self.is_retreating == 1 && time < self.retreat_finished) { ai_turn(); ai_run(15); return; } ai_run(15);};
void()	army_run3	=[	$run3,		army_run4	] { if(self.is_retreating == 1 && time < self.retreat_finished) { ai_turn(); ai_run(10); return; } ai_run(10);};
void()	army_run4	=[	$run4,		army_run5	] { if(self.is_retreating == 1 && time < self.retreat_finished) { ai_turn(); ai_run(10); return; } ai_run(10);};
void()	army_run5	=[	$run5,		army_run6	] { if(self.is_retreating == 1 && time < self.retreat_finished) { ai_turn(); ai_run(8); return; } ai_run(8);};
void()	army_run6	=[	$run6,		army_run7	] { if(self.is_retreating == 1 && time < self.retreat_finished) { ai_turn(); ai_run(15); return; } ai_run(15);};
void()	army_run7	=[	$run7,		army_run8	] { if(self.is_retreating == 1 && time < self.retreat_finished) { ai_turn(); ai_run(10); return; } ai_run(10);};
void()	army_run8	=[	$run8,		army_run1	] { if(self.is_retreating == 1 && time < self.retreat_finished) { ai_turn(); ai_run(8); return; } ai_run(8);};

void()	army_atk1	=[	$shoot1,	army_atk2	] 
{
	// TDA-Jules: Prevent attack if retreating
	if (self.is_retreating == 1 && time < self.retreat_finished)
	{
		army_run1(); // TDA-Jules: Go back to run state if retreating
		return;
	}
	ai_face();
};
void()	army_atk2	=[	$shoot2,	army_atk3	] {ai_face();};
void()	army_atk3	=[	$shoot3,	army_atk4	] {ai_face();};
void()	army_atk4	=[	$shoot4,	army_atk5	] {ai_face();};
void()	army_atk5	=[	$shoot5,	army_atk6	]
{
	// TDA-Jules: Prevent attack if retreating (though army_atk1 should catch it)
	if (self.is_retreating == 1 && time < self.retreat_finished)
	{
		army_run1(); // TDA-Jules: Go back to run state
		return;
	}
	ai_face(); // TDA-Jules: Ensure monster is facing the enemy.
	// TDA-Jules: Strafe logic during attack. Higher chance (50%) to strafe.
	// TDA-Jules: Visibility, range, and cooldown are checked.
	if (self.enemy != world && self.strafe_finished < time && random() < 0.5 && visible(self.enemy) && vlen(self.origin - self.enemy.origin) < 512)
	{
		// TDA-Jules: ai_face() was already called. Check if monster is roughly facing the player.
		if (fabs(self.ideal_yaw - self.angles_y) < 20) 
		{
			makevectors(self.angles); // TDA-Jules: Calculate v_right for lateral movement.
			if (random() < 0.5)
			{
				// TDA-Jules: Strafe left. Slower speed during attack.
				self.velocity_x = v_right_x * -100; 
				self.velocity_y = v_right_y * -100;
			}
			else
			{
				// TDA-Jules: Strafe right.
				self.velocity_x = v_right_x * 100;
				self.velocity_y = v_right_y * 100;
			}
			self.strafe_finished = time + 0.8; // TDA-Jules: Shorter cooldown (0.8 seconds) during attack.
		}
	}
	
	army_fire();
	self.effects = self.effects | EF_MUZZLEFLASH;
};
void()	army_atk6	=[	$shoot6,	army_atk7	] {ai_face();};
void()	army_atk7	=[	$shoot7,	army_atk8	] 
{
	// TDA-Jules: Prevent re-fire if retreating
	if (self.is_retreating == 1 && time < self.retreat_finished)
	{
		army_run1();
		return;
	}
	ai_face();
	SUB_CheckRefire (army_atk1);
};
void()	army_atk8	=[	$shoot8,	army_atk9	] {ai_face();};
void()	army_atk9	=[	$shoot9,	army_run1	] {ai_face();};


void()	army_pain1	=[	$pain1,		army_pain2	] {};
void()	army_pain2	=[	$pain2,		army_pain3	] {};
void()	army_pain3	=[	$pain3,		army_pain4	] {};
void()	army_pain4	=[	$pain4,		army_pain5	] {};
void()	army_pain5	=[	$pain5,		army_pain6	] {};
void()	army_pain6	=[	$pain6,		army_run1	] {/* TDA-Jules: Original was ai_pain(1) */};

void()	army_painb1	=[	$painb1,	army_painb2	] {};
void()	army_painb2	=[	$painb2,	army_painb3	] {ai_painforward(13);};
void()	army_painb3	=[	$painb3,	army_painb4	] {ai_painforward(9);};
void()	army_painb4	=[	$painb4,	army_painb5	] {};
void()	army_painb5	=[	$painb5,	army_painb6	] {};
void()	army_painb6	=[	$painb6,	army_painb7	] {};
void()	army_painb7	=[	$painb7,	army_painb8	] {};
void()	army_painb8	=[	$painb8,	army_painb9	] {};
void()	army_painb9	=[	$painb9,	army_painb10] {};
void()	army_painb10=[	$painb10,	army_painb11] {};
void()	army_painb11=[	$painb11,	army_painb12] {};
void()	army_painb12=[	$painb12,	army_painb13] {/* TDA-Jules: Original was ai_pain(2) */};
void()	army_painb13=[	$painb13,	army_painb14] {};
void()	army_painb14=[	$painb14,	army_run1	] {};

void()	army_painc1	=[	$painc1,	army_painc2	] {};
void()	army_painc2	=[	$painc2,	army_painc3	] {/* TDA-Jules: Original was ai_pain(1) */};
void()	army_painc3	=[	$painc3,	army_painc4	] {};
void()	army_painc4	=[	$painc4,	army_painc5	] {};
void()	army_painc5	=[	$painc5,	army_painc6	] {ai_painforward(1);};
void()	army_painc6	=[	$painc6,	army_painc7	] {ai_painforward(1);};
void()	army_painc7	=[	$painc7,	army_painc8	] {};
void()	army_painc8	=[	$painc8,	army_painc9	] {/* TDA-Jules: Original was ai_pain(1) */};
void()	army_painc9	=[	$painc9,	army_painc10] {ai_painforward(4);};
void()	army_painc10=[	$painc10,	army_painc11] {ai_painforward(3);};
void()	army_painc11=[	$painc11,	army_painc12] {ai_painforward(6);};
void()	army_painc12=[	$painc12,	army_painc13] {ai_painforward(8);};
void()	army_painc13=[	$painc13,	army_run1] {};

void(entity attacker, float damage)	army_pain =
{
	local float r;

    // TDA-Jules: If already decided to retreat from this pain instance (retreat_finished is set for future), 
    // and pain animation just started, let retreat take over.
	if (self.is_retreating == 1 && self.retreat_finished > time && self.pain_finished < time)
	{
        // TDA-Jules: If we are in the process of initiating a retreat from this very pain event,
        // ensure we don't get stuck in a long pain animation.
        // The actual transition to army_run1 is now handled after setting retreat flags.
	    return; 
	}

	if (self.pain_finished > time) // TDA-Jules: Already in a pain animation
		return;

	// TDA-Jules: Retreat Condition Check
	// TDA-Jules: Check if health is below 30% of max_health, not already retreating, and previous retreat (if any) is finished.
	if (self.health < (self.max_health * 0.3) && self.is_retreating == 0 && self.retreat_finished < time && self.enemy != world)
	{
		self.is_retreating = 1; // TDA-Jules: Set retreating flag
		self.retreat_finished = time + 3; // TDA-Jules: Retreat for 3 seconds
		self.ideal_yaw = anglemod(self.angles_y + 180); // TDA-Jules: Turn 180 degrees
		
		// TDA-Jules: Play a retreat sound (using sight sound as placeholder)
		sound (self, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM); 
		
        // TDA-Jules: Don't play a long pain animation, just a short one or skip to run
		self.pain_finished = time + 0.1; // TDA-Jules: Minimal pain animation time
		
		// TDA-Jules: Set state to run and call it to immediately start retreating
		army_run1(); // TDA-Jules: This will handle the actual running away logic
		return; // TDA-Jules: Skip normal pain animation sequence
	}

	// TDA-Jules: Normal pain animation sequence if not retreating
	r = random();
	if (r < 0.2)
	{
		self.pain_finished = time + 0.6;
		army_pain1 ();
		sound (self, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
	}
	else if (r < 0.6)
	{
		self.pain_finished = time + 1.1;
		army_painb1 ();
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
	else
	{
		self.pain_finished = time + 1.1;
		army_painc1 ();
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
};


void() army_fire =
{
	local vector dir;
	local entity en;

	ai_face();

	sound (self, CHAN_WEAPON, "soldier/sattck1.wav", 1, ATTN_NORM);

	// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;

	dir = en.origin - en.velocity*0.2;
	dir = normalize (dir - self.origin);

	FireBullets (4, dir, '0.1 0.1 0');
};



void()	army_die1	=[	$death1,	army_die2	] {};
void()	army_die2	=[	$death2,	army_die3	] {};
void()	army_die3	=[	$death3,	army_die4	]
{
	self.solid = SOLID_NOT;
	self.ammo_shells = 5;
	DropBackpack();
};
void()	army_die4	=[	$death4,	army_die5	] {};
void()	army_die5	=[	$death5,	army_die6	] {};
void()	army_die6	=[	$death6,	army_die7	] {};
void()	army_die7	=[	$death7,	army_die8	] {};
void()	army_die8	=[	$death8,	army_die9	] {};
void()	army_die9	=[	$death9,	army_die10	] {};
void()	army_die10	=[	$death10,	army_die10	] {};

void()	army_cdie1	=[	$deathc1,	army_cdie2	] {};
void()	army_cdie2	=[	$deathc2,	army_cdie3	] {ai_back(5);};
void()	army_cdie3	=[	$deathc3,	army_cdie4	]
{
	self.solid = SOLID_NOT;
	self.ammo_shells = 5;
	DropBackpack();
	ai_back(4);
};
void()	army_cdie4	=[	$deathc4,	army_cdie5	] {ai_back(13);};
void()	army_cdie5	=[	$deathc5,	army_cdie6	] {ai_back(3);};
void()	army_cdie6	=[	$deathc6,	army_cdie7	] {ai_back(4);};
void()	army_cdie7	=[	$deathc7,	army_cdie8	] {};
void()	army_cdie8	=[	$deathc8,	army_cdie9	] {};
void()	army_cdie9	=[	$deathc9,	army_cdie10	] {};
void()	army_cdie10	=[	$deathc10,	army_cdie11	] {};
void()	army_cdie11	=[	$deathc11,	army_cdie11	] {};


void() army_die =
{
	// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_guard.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

	// regular death
	sound (self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	if (random() < 0.5)
		army_die1 ();
	else
		army_cdie1 ();
};


/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_army =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/soldier.mdl");
	precache_model ("progs/h_guard.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_sound ("soldier/death1.wav");
	precache_sound ("soldier/idle.wav");
	precache_sound ("soldier/pain1.wav");
	precache_sound ("soldier/pain2.wav");
	precache_sound ("soldier/sattck1.wav");
	precache_sound ("soldier/sight1.wav"); // TDA-Jules: Used as placeholder retreat sound

	// gib death
	precache_sound ("player/udeath.wav");


	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/soldier.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 30;
	// TDA-Jules: Initialize variables for retreat logic
	self.max_health = self.health; 
	self.is_retreating = 0; 
	self.retreat_finished = 0; 

	self.th_stand = army_stand1;
	self.th_walk = army_walk1;
	self.th_run = army_run1;
	self.th_missile = army_atk1;
	self.th_pain = army_pain;
	self.th_die = army_die;

	// TDA-Jules: Initialize strafe cooldown variable
	self.strafe_finished = 0; 

	walkmonster_start ();
};
