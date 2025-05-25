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

DOG (Rottweiler)

==============================================================================
*/
$cd id1/models/dog
$origin 0 0 24
$base base
$skin skin

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 death7 deathb8
$frame deathb9

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14 painb15 painb16

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11 run12

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8


void() dog_leap1;
void() dog_run1;
void() dog_stand1; 
void() dog_walk1;  
void() dog_bark_stand; 

/*
================
dog_bite

================
*/
void() dog_bite =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
		return;

	ai_charge(10);

	if (!CanDamage (self.enemy, self))
		return;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;

	ldmg = (random() + random() + random()) * 8;
	T_Damage (self.enemy, self, self, ldmg);
};

void()	Dog_JumpTouch =
{
	local float ldmg;

	if (self.health <= 0)
		return;

	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 300 )
		{
			ldmg = 10 + 10*random();
			T_Damage (other, self, self, ldmg);
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{
			self.touch = SUB_Null;
			self.think = dog_leap1;
			self.nextthink = time + 0.1;
		}
		return;	
	}

	self.touch = SUB_Null;
	self.think = dog_run1;
	self.nextthink = time + 0.1;
};

void() dog_bark_stand = [ $stand1, dog_bark_stand ] 
{
    if (self.enemy != world)
        ai_face(); 
    
    ai_stand();

    if (time > self.bark_time)
    {
        dog_run1(); 
        return;
    }
    self.nextthink = time + 0.1; 
};


void() dog_stand1	=[	$stand1,	dog_stand2	] 
{
    if (self.enemy == world && self.is_investigating_sound == 0 && self.track_time < time) 
    {
        if (FindTarget ()) 
            return;
        
        if (self.target != world && (self.target.flags & FL_CLIENT) && !visible(self.target) && time > (self.investigate_sound_time + 5) ) 
        {
            self.sound_target_pos = self.target.origin; 
            self.investigate_sound_time = time + 7; 
            self.is_investigating_sound = 1;
            if (random() < 0.5) sound(self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_IDLE); 
            dog_run1(); 
            return;
        }
    } else if (self.enemy != world && self.is_investigating_sound == 0 && self.track_time < time && /* self.is_retreating == 0 && */ time >= self.last_bark_alert_time && !DogCheckAttack() && visible(self.enemy) && random() < 0.3) { // TDA-Jules: is_retreating not on dog, but good for pattern
        self.last_bark_alert_time = time + 10 + random()*5; 
        self.bark_time = time + 2 + random(); 
        sound(self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM); 
        self.think = dog_bark_stand; 
        self.nextthink = time + 0.1;
        
        entity head = findradius(self.origin, 768);
        while (head)
        {
            if ( (head.flags & FL_MONSTER) && head.health > 0 && head != self )
            {
                if (head.enemy == world || head.enemy == self || (head.enemy != self.enemy && !(head.enemy.flags & FL_CLIENT) ) )
                {
                    head.enemy = self.enemy; 
                    if (head.th_run && !(head.flags & FL_FLY) && head.enemy && head.enemy.classname == "player")
                    {
                        head.show_hostile = time + 1; 
                        if (head.classname == "monster_dog") { sound (head, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM); }
                        else if (head.classname == "monster_ogre") { sound (head, CHAN_VOICE, "ogre/ogwake.wav", 1, ATTN_NORM); }
                        else if (head.classname == "monster_knight") { sound (head, CHAN_VOICE, "knight/ksight.wav", 1, ATTN_NORM); }
                        else if (head.classname == "monster_enforcer") { sound (head, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NORM); }
                        else if (head.classname == "monster_army") { sound (head, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM); }
                        
                        head.goalentity = head.enemy;
                        head.think = head.th_run;
                        head.ideal_yaw = vectoyaw(head.enemy.origin - head.origin);
                        head.nextthink = time + 0.1 + (random() * 0.2);
                    }
                }
            }
            head = head.chain; // TDA-Jules: Corrected findradius iteration
        }
        return; 
    }
    ai_stand(); 
};
void() dog_stand2	=[	$stand2,	dog_stand3	] {ai_stand();};
void() dog_stand3	=[	$stand3,	dog_stand4	] {ai_stand();};
void() dog_stand4	=[	$stand4,	dog_stand5	] {ai_stand();};
void() dog_stand5	=[	$stand5,	dog_stand6	] {ai_stand();};
void() dog_stand6	=[	$stand6,	dog_stand7	] {ai_stand();};
void() dog_stand7	=[	$stand7,	dog_stand8	] {ai_stand();};
void() dog_stand8	=[	$stand8,	dog_stand9	] {ai_stand();};
void() dog_stand9	=[	$stand9,	dog_stand1	] {ai_stand();};

void() dog_walk1	=[	$walk1 ,	dog_walk2	]
{
    if (self.enemy == world && self.is_investigating_sound == 0 && self.track_time < time) 
    {
        if (FindTarget ())
            return;
        if (self.target != world && (self.target.flags & FL_CLIENT) && !visible(self.target) && time > (self.investigate_sound_time + 5) )
        {
            self.sound_target_pos = self.target.origin;
            self.investigate_sound_time = time + 7; 
            self.is_investigating_sound = 1;
            if (random() < 0.5) sound(self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_IDLE);
            dog_run1(); 
            return;
        }
    }
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);
	ai_walk(8); 
};
void() dog_walk2	=[	$walk2 ,	dog_walk3	] {ai_walk(8);};
void() dog_walk3	=[	$walk3 ,	dog_walk4	] {ai_walk(8);};
void() dog_walk4	=[	$walk4 ,	dog_walk5	] {ai_walk(8);};
void() dog_walk5	=[	$walk5 ,	dog_walk6	] {ai_walk(8);};
void() dog_walk6	=[	$walk6 ,	dog_walk7	] {ai_walk(8);};
void() dog_walk7	=[	$walk7 ,	dog_walk8	] {ai_walk(8);};
void() dog_walk8	=[	$walk8 ,	dog_walk1	] {ai_walk(8);};

// TDA-Jules: Corrected function signature
void DogRunSharedLogic(float move_speed) 
{
    // TDA-Jules: Sound Investigation Logic
    if (self.is_investigating_sound == 1)
    {
        if (FindTarget()) { return; } // FoundTarget resets is_investigating_sound via ai.qc
        if (time > self.investigate_sound_time) 
        {
            self.is_investigating_sound = 0;
            dog_stand1(); 
            return;
        }
        if (vlen(self.origin - self.sound_target_pos) < 64) 
        {
            self.is_investigating_sound = 0;
            self.pausetime = time + 2; 
            dog_stand1(); 
            return;
        }
        self.ideal_yaw = vectoyaw(self.sound_target_pos - self.origin);
        ai_turn(); 
        ai_run(move_speed); 
        return; 
    }

    // TDA-Jules: Short-Term Visual Tracking Logic
    if (self.enemy != world && self.bark_time < time && /* self.is_retreating == 0 && */ TRUE) // Ensure has enemy, not barking, not retreating (dog has no retreat)
    {
        local float is_currently_visible = visible(self.enemy);
        if (is_currently_visible)
        {
            self.last_known_player_pos = self.enemy.origin; // Continuously update LKP when visible
            self.was_visible = 1;
            if(self.track_time != 0) self.track_time = 0; // Reset track_time if enemy is re-acquired visually
        }
        else if (self.was_visible == 1) // LoS just lost (was_visible is true, but now not visible)
        {
            // self.last_known_player_pos was set in the last frame enemy was visible
            self.track_time = time + 3 + 2*random(); // Track for 3-5 seconds
            self.was_visible = 0; // Reset was_visible as we are now tracking based on LoS loss
            // Optional: sound(self, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE); // Whimper/search sound
        }

        if (self.track_time > time) // Actively tracking non-visible enemy
        {
            if (FindTarget()) // Check if player becomes visible again
            { 
                self.track_time = 0; 
                self.was_visible = 1; 
                // FoundTarget calls HuntTarget, which calls th_run, so normal run will continue.
                return; // Let the new FoundTarget logic take over.
            }
            else if (vlen(self.origin - self.last_known_player_pos) < 64) // Reached last known spot
            {
                self.track_time = 0; 
                self.enemy = world; // Give up on current enemy until re-sighted
                self.pausetime = time + 1.5 + random(); 
                dog_stand1(); 
                return;
            }
            else // Continue moving to LKP
            {
                self.ideal_yaw = vectoyaw(self.last_known_player_pos - self.origin);
                ai_turn();
                ai_run(move_speed); 
                return; 
            }
        }
        else if (self.track_time != 0 && time >= self.track_time) // Tracking time expired
        {
            self.track_time = 0;
            self.enemy = world; 
            dog_stand1(); 
            return;
        }
    }
    
    // TDA-Jules: Bark/Alert Logic (if not investigating sound or tracking LKP)
    if (self.enemy != world && /* self.is_retreating == 0 && */ self.bark_time < time && time >= self.last_bark_alert_time && !DogCheckAttack() && visible(self.enemy) && random() < 0.4)
    {
        self.last_bark_alert_time = time + 10 + random()*5; 
        self.bark_time = time + 2 + random(); 
        sound(self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM); 
        self.think = dog_bark_stand; 
        self.nextthink = time + 0.1;
        
        entity head = findradius(self.origin, 768);
        while (head)
        {
            if ( (head.flags & FL_MONSTER) && head.health > 0 && head != self )
            {
                if (head.enemy == world || head.enemy == self || (head.enemy != self.enemy && !(head.enemy.flags & FL_CLIENT) ) )
                {
                    head.enemy = self.enemy; 
                    if (head.th_run && !(head.flags & FL_FLY) && head.enemy && head.enemy.classname == "player")
                    {
                        head.show_hostile = time + 1; 
                        if (head.classname == "monster_dog") { sound (head, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM); }
                        else if (head.classname == "monster_ogre") { sound (head, CHAN_VOICE, "ogre/ogwake.wav", 1, ATTN_NORM); }
                        else if (head.classname == "monster_knight") { sound (head, CHAN_VOICE, "knight/ksight.wav", 1, ATTN_NORM); }
                        else if (head.classname == "monster_enforcer") { sound (head, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NORM); }
                        else if (head.classname == "monster_army") { sound (head, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM); }
                        
                        head.goalentity = head.enemy;
                        head.think = head.th_run;
                        head.ideal_yaw = vectoyaw(head.enemy.origin - head.origin);
                        head.nextthink = time + 0.1 + (random() * 0.2);
                    }
                }
            }
            head = head.chain; // TDA-Jules: Corrected findradius iteration
        }
        return; 
    }
    // TDA-Jules: If not investigating, not tracking LKP, and not barking, proceed with normal ai_run
    ai_run(move_speed);
}


void() dog_run1		=[	$run1  ,	dog_run2	]
{
	if (random() < 0.2 && self.is_investigating_sound == 0 && self.bark_time < time && self.track_time < time) 
		sound (self, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);
    DogRunSharedLogic(16);
};
void() dog_run2		=[	$run2  ,	dog_run3	] { DogRunSharedLogic(32); };
void() dog_run3		=[	$run3  ,	dog_run4	] { DogRunSharedLogic(32); };
void() dog_run4		=[	$run4  ,	dog_run5	] { DogRunSharedLogic(20); };
void() dog_run5		=[	$run5  ,	dog_run6	] { DogRunSharedLogic(64); };
void() dog_run6		=[	$run6  ,	dog_run7	] { DogRunSharedLogic(32); };
void() dog_run7		=[	$run7  ,	dog_run8	] { DogRunSharedLogic(16); };
void() dog_run8		=[	$run8  ,	dog_run9	] { DogRunSharedLogic(32); };
void() dog_run9		=[	$run9  ,	dog_run10	] { DogRunSharedLogic(32); };
void() dog_run10	=[	$run10 ,	dog_run11	] { DogRunSharedLogic(20); };
void() dog_run11	=[	$run11 ,	dog_run12	] { DogRunSharedLogic(64); };
void() dog_run12	=[	$run12 ,	dog_run1	] { DogRunSharedLogic(32); };

void() dog_atta1	=[	$attack1,	dog_atta2	] {ai_charge(10);};
void() dog_atta2	=[	$attack2,	dog_atta3	] {ai_charge(10);};
void() dog_atta3	=[	$attack3,	dog_atta4	] {ai_charge(10);};
void() dog_atta4	=[	$attack4,	dog_atta5	]
{
	sound (self, CHAN_VOICE, "dog/dattack1.wav", 1, ATTN_NORM);
	dog_bite();
};
void() dog_atta5	=[	$attack5,	dog_atta6	] {ai_charge(10);};
void() dog_atta6	=[	$attack6,	dog_atta7	] {ai_charge(10);};
void() dog_atta7	=[	$attack7,	dog_atta8	] {ai_charge(10);};
void() dog_atta8	=[	$attack8,	dog_run1	] {ai_charge(10);};

void() dog_leap1	=[	$leap1,		dog_leap2	] 
{
    if (self.is_investigating_sound == 1 || self.bark_time > time || self.track_time > time) { dog_run1(); return; } 
    ai_face();
};
void() dog_leap2	=[	$leap2,		dog_leap3	]
{
    if (self.is_investigating_sound == 1 || self.bark_time > time || self.track_time > time) { dog_run1(); return; } 
	ai_face();

	self.touch = Dog_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 300 + '0 0 200';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};

void() dog_leap3	=[	$leap3,		dog_leap4	] {};
void() dog_leap4	=[	$leap4,		dog_leap5	] {};
void() dog_leap5	=[	$leap5,		dog_leap6	] {};
void() dog_leap6	=[	$leap6,		dog_leap7	] {};
void() dog_leap7	=[	$leap7,		dog_leap8	] {};
void() dog_leap8	=[	$leap8,		dog_leap9	] {};
void() dog_leap9	=[	$leap9,		dog_leap9	] {};

void() dog_pain1	=[	$pain1 ,	dog_pain2	] {};
void() dog_pain2	=[	$pain2 ,	dog_pain3	] {};
void() dog_pain3	=[	$pain3 ,	dog_pain4	] {};
void() dog_pain4	=[	$pain4 ,	dog_pain5	] {};
void() dog_pain5	=[	$pain5 ,	dog_pain6	] {};
void() dog_pain6	=[	$pain6 ,	dog_run1	] {};

void() dog_painb1	=[	$painb1 ,	dog_painb2	] {};
void() dog_painb2	=[	$painb2 ,	dog_painb3	] {};
void() dog_painb3	=[	$painb3 ,	dog_painb4	] {ai_pain(4);};
void() dog_painb4	=[	$painb4 ,	dog_painb5	] {ai_pain(12);};
void() dog_painb5	=[	$painb5 ,	dog_painb6	] {ai_pain(12);};
void() dog_painb6	=[	$painb6 ,	dog_painb7	] {ai_pain(2);};
void() dog_painb7	=[	$painb7 ,	dog_painb8	] {};
void() dog_painb8	=[	$painb8 ,	dog_painb9	] {ai_pain(4);};
void() dog_painb9	=[	$painb9 ,	dog_painb10	] {};
void() dog_painb10	=[	$painb10 ,	dog_painb11	] {ai_pain(10);};
void() dog_painb11	=[	$painb11 ,	dog_painb12	] {};
void() dog_painb12	=[	$painb12 ,	dog_painb13	] {};
void() dog_painb13	=[	$painb13 ,	dog_painb14	] {};
void() dog_painb14	=[	$painb14 ,	dog_painb15	] {};
void() dog_painb15	=[	$painb15 ,	dog_painb16	] {};
void() dog_painb16	=[	$painb16 ,	dog_run1	] {};

void(entity attacker, float damage) dog_pain =
{
    self.is_investigating_sound = 0;
    self.bark_time = 0; 
    self.track_time = 0; // TDA-Jules: Stop visual tracking if pained
    self.was_visible = 0; // TDA-Jules: Reset LoS memory

	sound (self, CHAN_VOICE, "dog/dpain1.wav", 1, ATTN_NORM);

	if (random() > 0.5)
		dog_pain1 ();
	else
		dog_painb1 ();
};

void() dog_die1		=[	$death1,	dog_die2	] {};
void() dog_die2		=[	$death2,	dog_die3	] {};
void() dog_die3		=[	$death3,	dog_die4	] {};
void() dog_die4		=[	$death4,	dog_die5	] {};
void() dog_die5		=[	$death5,	dog_die6	] {};
void() dog_die6		=[	$death6,	dog_die7	] {};
void() dog_die7		=[	$death7,	dog_die8	] {};
void() dog_die8		=[	$death8,	dog_die9	] {};
void() dog_die9		=[	$death9,	dog_die9	] {};

void() dog_dieb1		=[	$deathb1,	dog_dieb2	] {};
void() dog_dieb2		=[	$deathb2,	dog_dieb3	] {};
void() dog_dieb3		=[	$deathb3,	dog_dieb4	] {};
void() dog_dieb4		=[	$deathb4,	dog_dieb5	] {};
void() dog_dieb5		=[	$deathb5,	dog_dieb6	] {};
void() dog_dieb6		=[	$deathb6,	dog_dieb7	] {};
void() dog_dieb7		=[	$deathb7,	dog_dieb8	] {};
void() dog_dieb8		=[	$deathb8,	dog_dieb9	] {};
void() dog_dieb9		=[	$deathb9,	dog_dieb9	] {};


void() dog_die =
{
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowHead ("progs/h_dog.mdl", self.health);
		return;
	}

	sound (self, CHAN_VOICE, "dog/ddeath.wav", 1, ATTN_NORM);
	self.solid = SOLID_NOT;

	if (random() > 0.5)
		dog_die1 ();
	else
		dog_dieb1 ();
};

//============================================================================

float()	CheckDogMelee =
{
    if (self.is_investigating_sound == 1 || self.bark_time > time || self.track_time > time)
        return FALSE;

	if (enemy_range == RANGE_MELEE)
	{	
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
};

float()	CheckDogJump =
{
	local vector dist;
	local float	d;

    if (self.is_investigating_sound == 1 || self.bark_time > time || self.track_time > time)
        return FALSE;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z + 0.75 * self.enemy.size_z)
		return FALSE;

	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z + 0.25 * self.enemy.size_z)
		return FALSE;

	dist = self.enemy.origin - self.origin;
	dist_z = 0;

	d = vlen(dist);

	if (d < 80)
		return FALSE;

	if (d > 150) 
		return FALSE;

	return TRUE;
};

float()	DogCheckAttack =
{
    if (self.is_investigating_sound == 1 || self.bark_time > time || self.track_time > time) 
        return FALSE;

	if (CheckDogMelee ())
	{
		return TRUE;
	}

	if (CheckDogJump ())
	{
		self.attack_state = AS_MISSILE; 
		return TRUE;
	}

	return FALSE;
};


//===========================================================================

/*QUAKED monster_dog (1 0 0) (-32 -32 -24) (32 32 40) Ambush
*/
void() monster_dog =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/h_dog.mdl");
	precache_model ("progs/dog.mdl");

	precache_sound ("dog/dattack1.wav");
	precache_sound ("dog/ddeath.wav");
	precache_sound ("dog/dpain1.wav");
	precache_sound ("dog/dsight.wav"); 
	precache_sound ("dog/idle.wav");

    precache_sound ("ogre/ogwake.wav");
    precache_sound ("knight/ksight.wav");
    precache_sound ("enforcer/sight1.wav");
    precache_sound ("soldier/sight1.wav");


	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/dog.mdl");

	setsize (self, '-32 -32 -24', '32 32 40');
	self.health = 25;
    self.max_health = self.health; 

    self.sound_target_pos = '0 0 0';
    self.investigate_sound_time = 0;
    self.is_investigating_sound = 0;

    self.bark_time = 0;
    self.last_bark_alert_time = 0;

    // TDA-Jules: Initialize visual tracking fields
    self.last_known_player_pos = '0 0 0';
    self.track_time = 0;
    self.was_visible = 0; // TDA-Jules: Flag to detect when LoS is first lost


	self.th_stand = dog_stand1;
	self.th_walk = dog_walk1;
	self.th_run = dog_run1;
	self.th_pain = dog_pain;
	self.th_die = dog_die;
	self.th_melee = dog_atta1;
	self.th_missile = dog_leap1;

	walkmonster_start();
};

[end of qc/dog.qc]
