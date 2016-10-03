#define SCR_BOB_MOVE
/*SCR_BOB_MOVE ()
    Controls the input for the user controlling bob.
*/

// Variables to store the x&y position of bob's current move
// -    If both are '0' bob either can't move, or he isn't moving. 
h_speed_current = 0;
v_speed_current = 0;

// Checks if the user is trying to make bob run.
if( SCR_KEY_CHECK(SHIFT_KEY) )
{
    // Bob is currently running.
    
    // Set global that notes if the user is running to
    //  say bob is running. (global.run = true)
    global.run = true;
}
else
{
    // Bob is not running.
    
    // Set global that notes if the user is not running to
    //  say bob isn't. (global.run = false)
    global.run = false;
}

// If the user is trying to go up make bob's y value less.
if ( SCR_KEY_CHECK(UP_KEY)  )
{
    // Bob's move value is equal to the macro BOB_Y_SPEED.
    // -    As bob is going up the vertical move should be negative
    v_speed_current = -1 * BOB_Y_SPEED;
}

// If the user is trying to go down make bob's y value greater.
if ( SCR_KEY_CHECK(DOWN_KEY) )
{
    // Checks if the user is pressing two conflicting keys.
    //  if a conflict is found he won't move. 
    //  If the user is only trying to move bob down then
    //  set the vertical move to macro BOB_Y_SPEED.
    // -    As bob is going down the vertical move should be positive
    if ( v_speed_current!= 0) v_speed_current = 0;
    else  v_speed_current = BOB_Y_SPEED;
}

// If the user is trying to go left make bob's x value less.
if ( SCR_KEY_CHECK(LEFT_KEY) )
{
    // Bob's move value is equal to the macro BOB_X_SPEED.
    // -    As bob is going left the horizontal move should be negative
    h_speed_current = -1 * BOB_X_SPEED;
}

// If the user is trying to go right make bob's x value greater.
if ( SCR_KEY_CHECK(RIGHT_KEY) )
{
    // Checks if the user is pressing two conflicting keys.
    //  if a conflict is found he won't move. 
    //  If the user is only trying to move bob right then
    //  set the horizontal move to macro BOB_X_SPEED.
    // -    As bob is going right the horizontal move should be positive.
    if ( h_speed_current!= 0) h_speed_current = 0;
    else  h_speed_current = BOB_X_SPEED;
}

// Checks if the player is in motion. If so it handles the footstep noise.
// -    TO_DO: Change so that it works off the global.walk_animation_timer. Currently
//          the sound effect desyncs if the player walks for too long or swaps between
//          running and walking too often.
//          Note: letting Bob idle resets this.
if ( (v_speed_current != 0 || h_speed_current != 0) && global.foot_step_timer == 0) 
{
    // Bob made a step sound.
    
    // Set a delay before the next step.
    // -     Set by macro FOOT_STEP_DELAY.
    //      TO_DO: Change so its based on the animation frame and timer.
    global.foot_step_timer = FOOT_STEP_DELAY;
    
    // Reduces the sound effect delay by half if bob is running.
    // -    time is reduced by the speed multiplier (If bob is moveing twice 
    //          as fast it stands to reason he takes twice the steps.)
    //      Set by timer/macro RUN_MULTIPLIER.
    if ( global.run == true ) global.foot_step_timer /= RUN_MULTIPLIER;
    
    // Finally play the stepping sound effect.
    // -    Sound effect defined by macro STEP_SOUND.
    audio_play_sound(STEP_SOUND, 0, false);
}

// Checks if the player is in motion and if the delay after the last animation frame is done.
//  If done it handles Bob's animation.
if ( (v_speed_current != 0 || h_speed_current != 0) && global.walk_animation_timer == 0) 
{
    // Bob's animation has moved to the next step.

    // Set the delay to the next step of animation.
    global.walk_animation_timer = WALK_ANIMATION_DELAY;
    
    //  - Special Case -
    // Bob had stopped walking. He had returned to an idle. 
    // -    If Bob's next frame should have been the neutral position it would make him look 
    //          like he was skating so this is caught and made so that the next frame is instead
    //          Bob taking a step.
    //      Note: global.walk_animation%2 should be global.walk_animation%n, where n is the number of
    //          frames per side of bob's cycle.
    if (global.walk_animation%2 == 1 && global.idle = true ) global.walk_animation++;
    
    // Reduces the animation delay by half if Bob is running.
    // -    Time is reduced by the speed multiplier (If Bob is moveing twice 
    //          as fast it stands to reason he takes twice the steps.)
    //      Set by timer/macro RUN_MULTIPLIER.
    if ( global.run == true ) global.walk_animation_timer /= RUN_MULTIPLIER;
    
    // Move to the next frame of animation.
    // -    Controlled by global.walk_animation_cycle.
    global.walk_animation_cycle++;
    
    // Checks if the cycle would be out of bounds and then sets it to the start if it would be.
    if (global.walk_animation_cycle >= WALK_ANIMATION_CYCLES) global.walk_animation_cycle = 0;
}

// Handles whether Bob is idle or not.
// -    Is assumed to take place after Bob's animation, for a special animation case.
if (v_speed_current == 0 && h_speed_current == 0)
{
    // The case Bob isn't trying to move.
    
    // Sets a vaiable to note that Bob is idle.
    // -    Controlled by global.idle = true.
    global.idle = true;
    
    // Resets animation timer.
    global.walk_animation_timer = 0;
    
    // Resets run state, so user can't build up speed by standing still and 
    //  holding the run key.
    global.run_state = 0;
    // Resets the phase between run states.
    global.run_state_timer = 0;
}
else
{
    // The case Bob is trying to move.
    
    // Sets a vaiable to note that Bob isn't idle.
    // -    Controlled by global.idle = false.
    global.idle = false;
}

// Checks if Bob is currently running.
// -    Must take place after key check.
//      Doubles the assumed move distance for Bob.   
if (global.run)
{
    v_speed_current *= RUN_MULTIPLIER;
    h_speed_current *= RUN_MULTIPLIER;
}

// - Testing Hack -
// Allows a no-clipping mode if in DEV mode and ctrl is pressed.
// -    TO_DO: move the key press to SCR_KEY_CHECK.
//      When Dev tools are not active it checks for a wall and bounces the player back
//          if their next move would collide them into a wall. It then tests 
//          if the player can first move vertically then move horizontally. 
//          Then it also animates an after image. The after Image won't appear if 
//          the run state is '0', or more clearly it won't animate if the run key isn't
//          pressed.
//          Note: The after image breaks if the user is using the no clipping hack.
if (DEV_TOOLS == true && keyboard_check(vk_control))
{
    // No-clip mode. Ignore collision.
    
    // Update Bob's position.
    // -    Assumes OBJ_BOB is the object calling the script.
    self.x += h_speed_current;
    self.y += v_speed_current;
}
else
{
    // Normal movement.
    
    // Checks if vertical movement is possible, if not it bounces the player 
    //  backward half their forward momentum.    
    if(SCR_COLLIOSION_CHECK(false, v_speed_current))
    {
        // Reduce and reverse vertical movement.
        v_speed_current *= -1/2;
        
        // Reset run action.
        global.run_state = 0;
        global.run_state_timer = 0;
    }
    
    // Checks if horizontal movement is possible, if not it bounces the player 
    //  backward half their forward momentum. 
    if(SCR_COLLIOSION_CHECK(true, h_speed_current) )
    {
        // Reduce and reverse horizontal movement.
        h_speed_current *= -1/2;
        
        // Reset run action.
        global.run_state = 0;
        global.run_state_timer = 0;
    }
    
    // Checks if vertical movement is possible. 
    // -    Due to the bounce earlier this should always be true
    //          when the player holds down a movement key.
    if(!SCR_COLLIOSION_CHECK(false, v_speed_current))
    {
        // Loop for updating Bob's afterimage.
        // -    The lower the index the more reicent the move.
        //          TO_DO: Make the array a linked list or cylical array 
        //              to redue the number of operations per frame.
        for (i = 10; i > 0; i--)
        {
            global.bob_last_y_array[i] = global.bob_last_y_array[i-1];
        }
        // Copy Bob's y last position into the array.
        global.bob_last_y_array[0] = self.y;
        // Update Bob's current y position.
        self.y += v_speed_current;
    }
    
    // Checks if horizontal movement is possible. 
    // -    Due to the bounce earlier this should always be true
    //          when the player holds down a movement key.
    if(!SCR_COLLIOSION_CHECK(true, h_speed_current))
    {
        // Loop for updating Bob's afterimage.
        // -    The lower the index the more reicent the move.
        //          TO_DO: Make the array a linked list or cylical array 
        //              to redue the number of operations per frame.
        for (i = 10; i > 0; i--)
        {
            global.bob_last_x_array[i] = global.bob_last_x_array[i-1];
        }
        // Copy Bob's x last position into the array.
        global.bob_last_x_array[0] = self.x;
        // Update Bob's current y position.
        self.x += h_speed_current;
    }
}


// - UNFINIHSED -
// Check if bob collided with an exit.
// -    Need to find a way to access the instance data to get a more accturate
//          warp destination. This would allow me to remove the collision event
//          in OBJ_EXIT. 
if(place_meeting(self.x, self.y, OBJ_EXIT) = true)
{
    //if !SCR_MAP_DONE(global.current_map) {show_message("Next Map Broken");}
}

#define SCR_GAME_CRASH_unused_
/*SCR_GAME_CRASH()
    A script to end the game.
    
        Note: I don't remember why this is here.

*/

// End the game.
game_end();

#define SCR_BOB_WALK
/* SCR_BOB_WALK()
    Controls Bob's walking animation.
     -  We are expecting OBJ_BOB to call this script in his draw cycle.
        Bob sways back and forth rather than having an animtated sprite.
            As a result he is a single still image saving animation time
            and looking funny.
            TO_DO Option 1: Give Bob unlocable costumes and put them at the end of the secret rooms.
            TO_DO Option 2: Animate Bob properly. - Less likely because the crappy animation fits the
                current asthetic.

*/

// Checks the state of Bob.
// -    First if no motion key is pressed draw his idle position.
//      Second, in frame 1 (second frame) Bob wobbles his head to our left. (Rotate Bob's 
//          sprite by the value in macro WALK_ANIMATION_ROTATE_ANGLE)
//      Second, in frame 3 (fourth frame) Bob wobbles his head to our right. (Rotate Bob's 
//          sprite by negative the value in macro WALK_ANIMATION_ROTATE_ANGLE)
//
if (global.idle == true)draw_sprite( SPR_BOB, 0, x, y);
else if (global.walk_animation_cycle = 1) draw_sprite_ext( SPR_BOB, 0, x, y, 1, 1, WALK_ANIMATION_ROTATE_ANGLE, c_white, 1 );
else if (global.walk_animation_cycle = 3) draw_sprite_ext( SPR_BOB, 0, x, y, 1, 1, -WALK_ANIMATION_ROTATE_ANGLE, c_white, 1 );
else draw_sprite( SPR_BOB, 0, x, y);

// Handles Bob'sfter Image. 
// -    Only runs when the run key is pressed, a direction key is pressed and 
//          Bob isn't colliding with anything. All calculated by SCR_BOB_MOVE.
if ( global.run_state > 0)
{
    // This is the same basic check as above for Bob's normal animation. 
    // -    The difference is that we don't need to check for bob being idle,
    //          and draw three semi transparent Bobs.
    //      The colour bob turns is defined by marco RUN_COLOUR.
    //      Bob's basic colour change is the max opacity of the colour layer 
    //          divided by diffrence of bob's total run states less Bob's current 
    //          state plus 1 for indexing.
    //      The first bob is drawn on the walking Bob to give him a colour that gets
    //          darker as he runs but because its semi-transparent it needs to have a 
    //          solid bob underneath, thus the two Bobs animated on the same spot.
    //          This bob is drawn at full opacity.
    //      The second bob is drawn at the position defined by RUN_AFTER_IMAGE_1.
    //          this Bob's opacity is reduced by RUN_AFTER_IMAGE_1_FADE_MULTIPLIER.
    //      The third Bob is drawn at the position defined by RUN_AFTER_IMAGE_2.
    //          this Bob's opacity is reduced by RUN_AFTER_IMAGE_2_FADE_MULTIPLIER. 
    //
    //      TO_DO Option: Spread Bob's after images further out the further he gets 
    //          in run states it might make it look like he is running faster.
    if (global.walk_animation_cycle == 1) 
    {
        draw_sprite_ext( SPR_BOB, 0, x, y, 1, 1, WALK_ANIMATION_ROTATE_ANGLE, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1) );
        draw_sprite_ext( SPR_BOB, 0, global.bob_last_x_array[RUN_AFTER_IMAGE_1], global.bob_last_y_array[RUN_AFTER_IMAGE_1], 1, 1, WALK_ANIMATION_ROTATE_ANGLE, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1) * RUN_AFTER_IMAGE_1_FADE_MULTIPLIER );
        draw_sprite_ext( SPR_BOB, 0, global.bob_last_x_array[RUN_AFTER_IMAGE_2], global.bob_last_y_array[RUN_AFTER_IMAGE_2], 1, 1, WALK_ANIMATION_ROTATE_ANGLE, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1) * RUN_AFTER_IMAGE_2_FADE_MULTIPLIER );
    }
    else if (global.walk_animation_cycle == 3)
    {
        draw_sprite_ext( SPR_BOB, 0, x, y, 1, 1, -WALK_ANIMATION_ROTATE_ANGLE, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1) );
        draw_sprite_ext( SPR_BOB, 0, global.bob_last_x_array[RUN_AFTER_IMAGE_1], global.bob_last_y_array[RUN_AFTER_IMAGE_1], 1, 1, -WALK_ANIMATION_ROTATE_ANGLE, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1) * RUN_AFTER_IMAGE_1_FADE_MULTIPLIER);
        draw_sprite_ext( SPR_BOB, 0, global.bob_last_x_array[RUN_AFTER_IMAGE_2], global.bob_last_y_array[RUN_AFTER_IMAGE_2], 1, 1, -WALK_ANIMATION_ROTATE_ANGLE, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1) * RUN_AFTER_IMAGE_2_FADE_MULTIPLIER);
    }    
    else 
    {
        draw_sprite_ext( SPR_BOB, 0, x, y, 1, 1, 0, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1 ) );
        draw_sprite_ext( SPR_BOB, 0, global.bob_last_x_array[RUN_AFTER_IMAGE_1], global.bob_last_y_array[RUN_AFTER_IMAGE_1], 1, 1, 0, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1 ) * RUN_AFTER_IMAGE_1_FADE_MULTIPLIER);
        draw_sprite_ext( SPR_BOB, 0, global.bob_last_x_array[RUN_AFTER_IMAGE_2], global.bob_last_y_array[RUN_AFTER_IMAGE_2], 1, 1, 0, RUN_COLOUR, RUN_MAX_FADE/ ( RUN_STATE_MAX - global.run_state + 1 ) * RUN_AFTER_IMAGE_2_FADE_MULTIPLIER);
    }
}

#define SCR_BOB_RUN
/* SCR_BOB_RUN()
    Handles Bob's current run state.
     -  Dosen't require Bob to run the script but having him call it means it will only
            run when bob is on a map.
        TO_DO: Set it so it runs on a controller so it won't be replicated if 
            OBJ_BOB's are on the screen.

*/

// Checks if the player is running.
if(global.run == true)
{
    // If the user can run it attempts to update Bob's run state.
    // -    It will only update if the state delay has elapsed and 
    //          Bob isn't already at max run state.
    if (global.run_state_timer == 0 && global.run_state < RUN_STATE_MAX)
    {
        // The state change delay has elasped so the state need to change.
        
        // Move to next run state.
        global.run_state++;
        // Set delay for next state change.
        global.run_state_timer = RUN_STATE_DELAY;
    }
}
else
{
    // Bob is not moving or otherwise unable to run.
    
    // Sets Bob's runstate to the lowest
    global.run_state = 0;
    // Resets the delay between run states.
    global.run_state_timer = 0;
}