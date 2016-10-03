#define SCR_CORE_CONTROLS
/*SCR_CORE_CONTROLS ()
    Controls for when the player is in game.
    Not allowed during full map cutscenes.
*/

// Checks if the user is trying to open the ingame menu.
if ( SCR_KEY_CHECK( MENU_KEY ) )
{
    // Checks if the menu button has been released before the menu's state will change again.
    if (!global.menu_button_still_pressed)
    {
        // Notes that the script has processed the current button press before processing it.
        global.menu_button_still_pressed = true;
        
        // Checks if menu is open by seeing if player movement is possible.
        // -    The first case is movement is possible, so menu is currently being opened.
        if (global.bob_can_move) 
        {
            // Stops player from moving during menu.
            // -    FIX: should change to a pause boolean.
            global.bob_can_move = false;
            // Notes menu is open.
            global.menu_open = true;
            // Menu options limit.
            global.menu_options = 3;
            // Sets current menu choice to the top item on the list.
            global.menu_current_option = 0;
        }
        else 
        {
            // Menu is being closed
            
            // Player can move again.
            global.bob_can_move = true;
            // Notes menu is now closed.
            global.menu_open = false;
        }
    }
}
else
{
    global.menu_button_still_pressed = false;
}

// The pre menu way of quitting the game. 
// -    Conflicts with defualt menu key, but also dosen't use SCR_KEY_CHECK(KEY_ID)
//          to check if the desired key is being pressed.
/*
if ( keyboard_check( vk_escape ))
{
    // Quit game.
    game_end();
}*/

// The pre menu way of restarting the game. 
// -    Dosen't use SCR_KEY_CHECK(KEY_ID) to check if the desired key is being pressed.
/*
if ( keyboard_check( vk_f5 ) && false )
{
    // This is the only reason to keep the global reset_key_timer in SCR_START_UP.
    // Checks if its been a bit since the game was last reset.
    // -    Sets with macro KEY_PRESS_COOLDOWN.
    //      Necessary otherwise the game could just spam resetting.
    //      (It won't anyway because the game cant be reset from the title map.
    //      but as insurance incase the first map changes, this is here.)
    if (global.reset_key_timer == 0)
    {
        // Sets timer for above reset loop fix.
        global.reset_key_timer = KEY_PRESS_COOLDOWN;
        // Restart game.
        game_restart();
    }
}*/

// Toggles full screen. 
// -    Checks if f11 is pressed then if fulls creen hasn't toggled for a moment (set by
//          macro KEY_PRESS_COOLDOWN) then it toggles full screen.
//      TO_DO: Should swap to the method of requring the player to release the key for the 
//          map to allow fullscreen to toggle again instead of a cooldown timer.
//      Note: more likely to add an options sub menu to ingame menu.
if ( keyboard_check( vk_f11 ) )
{
    // Checks if successful toggle was "KEY_PRESS_COOLDOWN" frames ago.
    // -    Stops game from flickering in and out of full screen.
    if (global.full_screen_key_timer == 0)
    {
        // Sets timer to start next cooldown before a toggle
        global.full_screen_key_timer = KEY_PRESS_COOLDOWN;
        // Checks status of the screen currently then swaps it's state.
        // -    Code adapted from "Drag-and-drop Icons to GameMaker 
        //          Language Refrence".
        if (window_get_fullscreen())
        {
            // Fullscreen was active.
            
            // Deactivate fullscreen.
            window_set_fullscreen(false);
        }
        else
        {
            // Fullscreen wasn't active.
            
            // Activate fullscreen.
            window_set_fullscreen(true);
        }
    }
}

#define SCR_VIEW_0_CONTROLS
/*SCR_VIEW_0_CONTROLS ()
    Test code for moving the view around.
    Not used in game.
*/


// Values that remember how much the screen needs to move.
h_scroll_current = 0;
v_scroll_current = 0;

// Check if a valid "Up" key is pressed.
//  When true sets the screen to attempt to scroll up by
//  marco H_SCROLL_SPEED. (-y).
if ( keyboard_check( ord('W') ) || keyboard_check(vk_up) )
{
    v_scroll_current = -1 * V_SCROLL_SPEED;
}

// Check if a valid "Down" key is pressed.
//  When true sets the screen to attempt to scroll down by
//  marco H_SCROLL_SPEED. (+y).
if ( keyboard_check( ord('S') ) || keyboard_check(vk_down) )
{
    v_scroll_current = V_SCROLL_SPEED;
}

// Check if a valid "Left" key is pressed.
//  When true sets the screen to attempt to scroll left by
//  marco H_SCROLL_SPEED. (-x).
if ( keyboard_check( ord('A') ) || keyboard_check(vk_left) )
{
    h_scroll_current = -1 * H_SCROLL_SPEED;
}

// Check if a valid "Right" key is pressed.
//  When true sets the screen to attempt to scroll right by
//  marco H_SCROLL_SPEED. (x).
if ( keyboard_check( ord('D') ) || keyboard_check(vk_right) )
{
    h_scroll_current = H_SCROLL_SPEED;
}

// Process Vertical Screen movement.
// -    First checks if View would leave the top of the map, and if so
//          it sets it the the top edge. Second it checks if the view
//          is trying to leave the bottom of the map, and sets it to
//          to the bottom edge if it does. Finally, if the view isn't
//          attempting to leave the map on the y coordinate then it moves
//          the view by the set amount.
if (0 > view_yview[0] + v_scroll_current)
{
    view_yview[0] = 0;
}
else if (room_height < view_yview[0] + v_scroll_current)
{
    view_yview[0] = room_height;
}
else
{
    view_yview[0] += v_scroll_current;
}

//Process Horizontal Screen movement.
// -    First checks if View would leave the left of the map, and if so
//          it sets it the the left edge. Second it checks if the view
//          is trying to leave on the right egde of the map, and sets it to
//          to the right edge if it does. Finally, if the view isn't
//          attempting to leave the map on the x coordinate then it moves
//          the view by the set amount.
if (0 > view_xview[0] + h_scroll_current)
{
    view_xview[0] = 0;
}
else if (room_width < view_xview[0] + h_scroll_current)
{
    view_xview[0] = room_width;
}
else
{
    view_xview[0] += h_scroll_current;
}


#define SCR_START_UP
/*SCR_START_UP ()
    Initalizes all the global variables, sets the game into full screen, and moves to the title map.
    Note: Most of the games constant values are defined in Macros/All Configurations.

*/

// Value used to know the current map, used for navigating to the next map (SCR_MAP_DONE()) and for printing text on the correct rooms floors (OBJ_FLOOR_TEXT_CONTROLLER).
global.current_map = 0;
// Similar to global.current map in that it is used for navigating to the next map (SCR_MAP_DONE()), 
//  it also lets MAP_CUT_SCENE know which cutsecne
global.cutscene_id = 0;

// - Values used for menu navigation - 
// Total options for current menu.
global.menu_options = 0;
// Current vaule for the menu open. 
//  -   Presently this is always reset to 0 at a new menu but for multi level menus the menu definer should store old menu values
//          for when the user returns to a previous menu.
global.menu_current_option = 0;

// Used for map transfers. By defualt it is set to 0 (by the exit the player collides with). 
//  -   By default
global.teleport_id = 0;

// Used by OBJ_BARREL_FORCE_DOOR to know if the level is free of OBJ_BREAKABLE_RUN objects.
//  -   In practice this is used to make the player distroy all the barrels in a level to continue.
global.barrel_count = 0;

// - Timers to make it so keys don't register every frame. - 
// -    All set by the KEY_PRESS_COOLDOWN macro.
// Menu openeing and closing cooldown.
global.menu_key_timer = 0;
// A cool down for the reset key. 
// -    Obsolete: replaced with reset option in menu.
//global.reset_key_timer = 0;
// Fullscreen key cooldown
global.full_screen_key_timer = 0;

// - Character movement variables -
// Timer for walking sound effect
// -    Limited by mmacro FOOT_STEP_DELAY.
global.foot_step_timer = 0;
// Timer for monitoring run_state.
// -    As the character runs his state changes, 
//          the is the timer to make it so the change dosen't happen 
//          after every frame.
//          Set by RUN_STATE_DELAY macro.
global.run_state_timer = 0;
// Timer to count between steps.
// -    Set with WALK_ANIMATION_DELAY.
global.walk_animation_timer = 0;
// Boolean to see if bob is allowed to move.
// -    More practically this decides of the player is allowed to control the character
//          on screen. This is meant for cutscenes and menus.
global.bob_can_move = true;
// The player's run state
// -    This is used to see if the player is running at "full speed".
//          The higher the state the darker Bob's overlay and afterimages are.
//          When bob is at max state he can break OBJ_BREAKABLE_RUN.
//          The max state is set by the macro RUN_STATE_MAX.
global.run_state = 0;
// The player's walk cycle.
// -    Limited by macro WALK_ANIMATION_CYCLES.
global.walk_animation_cycle = 0;
// Tells if the player is not in motion.
// -    default true, false when direction is chosen. 
//      Used to reset running.
global.idle = true;
// Tells if Bob's run key is active
// -    Defualt: false.
global.run = false;

// Timer used in cutscenes. 
// -    Default 0. Timer is set at start of cutscene by OBJ_CUTSCENE_CONTROLLER.
global.cutscene_timer = 0;

// Value denoting if the ingame menu is open.
// -    Default false;
global.menu_open = false;

// Used to check if the button to open the menu was released.
// -    Default false.
//      Keeps menu from flickering open and closed.
global.menu_button_still_pressed = false;

// Saves the values of the last 10 places the player was standing.
// -    Values are used to generate an afterimage when bob is running.
for (i = 0; i < 10; i++)
{
    global.bob_last_x_array[i] = 0;
    global.bob_last_y_array[i] = 0;
}

// Menu Display settings.
// -    Replace ASAP with better menu system.
global.menu_options_start_x = 360;
global.menu_options_start_y = 420;
global.menu_options_scale = 3;
global.menu_options_spacing = 50;

// Make the game display as Fullscreen.
window_set_fullscreen(true);

// Hide the mouse cursor
window_set_cursor(cr_none);

// Load into the first Map.
// -    Done by calling SCR_MAP_DONE(LEAVING_MAP_ID).
//          Note: It was decided not to put the debug room warp here
//              so stable map would be loaded first.
SCR_MAP_DONE(INITIAL_MAP_ID);


#define SCR_MAP_DONE
/*SCR_MAP_DONE ()
    Decides which map to transition to baised on the map that is being left and 
        the exit used. (The exit is controlled by global.teleport_id and must
        be set by the exit, a default exit will always set global.teleport_id to
        0 unless told to do otherwise when initalized.)
        TO_DO: Script should have a clearer name.
*/

// Checks if the script was called with a parameter. 
// -    Note: GML will let you run a script with too many paramaters just fine.
if !is_real(argument0)
{
   return false;
}
else
{
    // Resets the barrel counter before loading a new room.
    // -    Note: Can not put this in SCR_NEW_MAP() because it is called by
    //          OBJ_MAP_CONTROLLER at the same approximate time as the barrels
    //          are initalized, thus it is better for stability to reset the 
    //          counter here. If more values need to be reset before a room
    //          I would recomend putting this and them into a new script.
    global.barrel_count = 0;
    
    // Cycles through all of the possible warp points and connects maps.
    // -    map ID's are integers saved as macros for readability.
    //      Note: If the macro DEV_TOOLS is true the title screen pretends to
    //          be the map before the map you want to load. (The map is selected
    //          with the macro MAP_CHEAT.)
    //          Note-Note: Warp point was set from title screen so DEV can see
    //              that the game is still loading even if a bug is making 
    //              the intended map to be tested is unloadable.
    if (argument0 == INITIAL_MAP_ID)
    {
        // Warp from MAP_INITILIZATION.
        
        
        // Turns off audio for title screen.
        // -    Defualt: macro MUSIC_TITLE.
        audio_play_sound(MUSIC_TITLE, 0, true);
        
        // Updates map id to the next map.
        // -    In this case the title screen, thus the value stored in 
        //          the macro TITLE_SCREEN_ID.
        global.current_map = TITLE_SCREEN_ID;
        
        // Load the title screen.
        // -    Defualt: macro MAP_TITLE.
        room_goto(MAP_TITLE);
    }
    else if (argument0 == TITLE_SCREEN_ID)
    {
        // Warp from MAP_TITLE.
                
        // Turns off audio for title screen.
        // -    Defualt: macro MUSIC_TITLE.
        audio_stop_sound(MUSIC_TITLE);
        
        // This checks if the level warp is active.
        // -    It is always active when DEV_TOOLS is active.
        //      CAUTION: Reloading the title screen with MAP_CHEAT = TITLE_SCREEN_ID
        //          causes the audio to flip out and the wrong map to load.
        if (DEV_TOOLS)
        {
            // Updates map to the map to be tested.
            // -    Default: macro MAP_CHEAT.
            //      Set as a macro for easy updating during testing.
            //      CAUTION: Reloading the title screen with MAP_CHEAT = TITLE_SCREEN_ID
            //          causes the audio to flip out and the wrong map to load.
            SCR_MAP_DONE(MAP_CHEAT);
        }
        else
        {
            // Turns on audio for main game.
            // -    Defualt: macro MUSIC_LEVEL_1.
            audio_play_sound(MUSIC_LEVEL_1, 0, true);
            
            // Updates map id to the next map.
            // -    In this case the floor 1, thus the value stored in 
            //          the macro FLOOR_1_ID.
            global.current_map = FLOOR_1_ID;
            
            // Load the first level.
            // -    Defualt: macro MAP_FLOOR_1.
            room_goto(MAP_FLOOR_1);
        }
    }
    else if (argument0 == FLOOR_1_ID)
    {
        // Warp from MAP_FLOOR_1.
        
        // Updates map id to the next map.
        // -    In this case the floor 2, thus the value stored in 
        //          the macro FLOOR_2_ID.
        global.current_map = FLOOR_2_ID;
        
        // Load the next level.
        // -    Defualt: macro MAP_FLOOR_2.
        room_goto(MAP_FLOOR_2);
    }
    else if (argument0 == FLOOR_2_ID)
    {
        // Warp from MAP_FLOOR_2.
        
        // Updates map id to the next map.
        // -    In this case the floor 3, thus the value stored in 
        //          the macro FLOOR_3_ID.
        global.current_map = FLOOR_3_ID;
        // Load the next level.
        // -    Defualt: macro MAP_FLOOR_3.
        room_goto(MAP_FLOOR_3);
    }
    else if (argument0 == FLOOR_3_ID)
    {
        // Warp from MAP_FLOOR_3.
        // -    This is a special case as there is a hidden exit.
        //          For now the secret is access to the test maps.
        
        // Check to see which exit was used to leave the map.
        // -    global.teleport_id store the id of the exit used.
        //          By default OBJ_EXIT sets global.teleport_id to 0, but 
        //          during instance creation setting hidden_path = true will
        //          cause global.teleport_id = 1 if that exit is used.
        //      Note: This currrently could be a boolean, but just incase
        //          I want to allow 3+ exits later using an int is safer.
        if (global.teleport_id == 0)
        {
            // The normal exit was used.
        
            // Updates map id to the next main map.
            // -    In this case the floor 4, thus the value stored in 
            //          the macro FLOOR_4_ID.
            global.current_map = FLOOR_4_ID;
            // Load the next level.
            // -    Defualt: macro MAP_FLOOR_4.
            room_goto(MAP_FLOOR_4);
        }
        else
        {
            // The secret exit was used.
            
            // Updates map id to the first hidden map.
            // -    In this case the the first test map, thus the value stored in 
            //          the macro TEST_MAP_ID.
            global.current_map = TEST_MAP_ID;
            // Load the next level.
            // -    Defualt: macro MAP_TEST.
            room_goto(MAP_TEST);
        }
    }
    else if (argument0 == FLOOR_4_ID)
    {
        // Warp from MAP_FLOOR_4.
        // -    Loads a cutscene so global.cutscene_id is updated instead of
        //          global.current_map. The cutscene and floor ID's CAN NOT 
        //          conflict as global.cutscene_id is passed back like each
        //          cutscene was a new map even though the cutscenes all take
        //          place on the same map.
        
        // Updates map id to the next cutscene.
        // -    In this case the cutcene 1, thus the value stored in 
        //          the macro CUTSCENE_1_ID.
        global.cutscene_id = CUTSCENE_1_ID;
        // Turns off audio for main game.
        // -    Defualt: macro MUSIC_LEVEL_1.
        audio_stop_sound(MUSIC_LEVEL_1);
        // Turns on audio for the first cutscene.
        // -    Defualt: macro MUSIC_TESNION.
        audio_play_sound(MUSIC_TESNION, 1, true);
            // Load the next cutscene.
            // -    Defualt: macro MAP_CUTSCENE.
        room_goto(MAP_CUTSCENE);
    }
    else if (argument0 == CUTSCENE_1_ID)
    {
        // Warp from MAP_CUTSCENE, specifically the first cutscene.
        
        // Updates map id to the next map.
        // -    In this case the boss fight, thus the value stored in 
        //          the macro BOSS_MAP_ID.
        global.current_map = BOSS_MAP_ID;
        
        // Turns off audio for the first cutscene.
        // -    Defualt: macro MUSIC_TESNION.
        audio_stop_sound(MUSIC_TESNION);
        // Turns on audio for the "climactic" boss fight.
        // -    Defualt: macro MUSIC_BOSS_FIGHT.
        audio_play_sound(MUSIC_BOSS_FIGHT, 1, true);
        
        // Load the next level.
        // -    Defualt: macro MAP_BOSS_CHAMBER_TEMP.
        room_goto(MAP_BOSS_CHAMBER_TEMP);
    }
    else if (argument0 == BOSS_MAP_ID)
    {
        // Warp from the boss fight.
        
        // There is no level after the boss fight, only a kill screen so no
        // -    map id is set/needed.
        
        // Turns off audio for the boss fight.
        // -    Defualt: macro MUSIC_BOSS_FIGHT.
        audio_stop_sound(MUSIC_BOSS_FIGHT);
        // Turns on audio for the kill screen.
        // -    Defualt: macro MUSIC_KILL_SCREEN.
        audio_play_sound(MUSIC_KILL_SCREEN, 1, true);
        
        // Load the kill screen.
        // -    Defualt: macro MAP_YOU_WIN.
        room_goto(MAP_YOU_WIN);
    }
    else if (argument0 == TEST_MAP_ID)
    {
        // Warp from MAP_TEST.
        
        // Updates map id to the next map.
        // -    In this case the second test map, thus the value stored in 
        //          the macro TEST_MAP_2_ID.
        global.current_map = TEST_MAP_2_ID;
        
        // Load the next level.
        // -    Defualt: macro MAP_TEST_2.
        room_goto(MAP_TEST_2);
    }
    else if (argument0 == TEST_MAP_2_ID)
    {
        // Warp from MAP_TEST_2.
        
        // Updates map id to the next map.
        // -    In this case it returns to the map where the secret path was found,
        //      thus the value stored in the macro FLOOR_3_ID.
        global.current_map = FLOOR_3_ID;
        
        // Load the next level.
        // -    Defualt: macro MAP_FLOOR_3.
        room_goto(MAP_FLOOR_3);
    }
    else
    {
        // Debug code to let the user know transiton they were wanting
        // -    to use is either not coded or broken.
        return false;
    }
    
    // Transiton was successful.
    return true;
}


#define SCR_MENU_NAVIGATE
/*SCR_MENU_NAVIGATE ()
    Code used for navigating a menu. In practice this code is only for 
        reading user input for moving up and down in the menu. Confirming a menu
        choice should be done by the code calling this.
        
    TO_DO: only supports key inputs, consider either adding mouse support here or
        in a seperate script. 
        TO_DO Note: As a mouse select is also a confirm action, adapting this
            script to return the value of the current selection might be
            adviseable.
*/

// Checks if the user is trying to move up an option.
// -    Loops to the bottom if the user is at the top.
//      Defualt macro UP_KEY.
if ( SCR_KEY_CHECK(UP_KEY) )
{
    // Observes a key cooldown so the menu dosen't change options
    // -    every frame while the button is held.
    if (global.menu_key_timer == 0)
    {
        // Change the value noting which menu option is chosen.
        // -    User is trying to choose the next item up on the menu, 
        //          which is lower on the list. Out of bounds indexes are
        //          caught later.
        global.menu_current_option--;
        
        // Sets cooldown for next key press.
        // -    Default: macro KEY_PRESS_COOLDOWN.
        global.menu_key_timer = KEY_PRESS_COOLDOWN;
        
        // Plays the cursor sound effect
        // -    Default: macro CURSOR_SOUND
        audio_play_sound(CURSOR_SOUND, 0, false);
    }
}

// Checks if the user is trying to move down an option.
// -    Loops to the top if the user is at the bottom.
//      Defualt macro DOWN_KEY.
if ( SCR_KEY_CHECK(DOWN_KEY) )
{
    // Observes a key cooldown so the menu dosen't change options
    // -    every frame while the button is held.
    if (global.menu_key_timer == 0)
    {
        // Change the value noting which menu option is chosen.
        // -    User is trying to choose the next item down on the menu, 
        //          which is higher on the list. Out of bounds indexes are
        //          caught later.
        global.menu_current_option++;
        
        // Sets cooldown for next key press.
        // -    Default: macro KEY_PRESS_COOLDOWN.
        global.menu_key_timer = KEY_PRESS_COOLDOWN;
        
        // Plays the cursor sound effect
        // -    Default: macro CURSOR_SOUND
        audio_play_sound(CURSOR_SOUND, 0, false);
    }
}

// Checks if the menu index fell off of the start of the list.
// -    It was decided the menu would loop so this sets the cursor to go
//          to the bottom of the list.
if (global.menu_current_option < 0)
{
    // Sets the current menu selection to 1 less than the total number
    //  of menu options. (selections index 0 to MaxOptions - 1.)
    global.menu_current_option = global.menu_options - 1;
}

// Checks if the menu index fell off of the end of the list.
// -    It was decided the menu would loop so this sets the cursor to go
//          to the top of the list.
if (global.menu_current_option == global.menu_options)
{
    // Sets the current menu selection to 0. (The starting index of the menus
    //  possible options.
    global.menu_current_option = 0;
}

#define SCR_KEY_COOLDOWN
/*SCR_MENU_NAVIGATE ()
    Counts down all of the games timers by 1. It also sets any timers with a negative value to 0.
     -  As a general rule this is called every frame.
        Note: Timers that use non-whole numbers will round up to the nearest int. (3.2 = 4 Frames).
        
        TO_DO: should rebuild timers to run down independant of frame rate.
        
        POSSIBLE_CHANGE: round the time down to the nearest whole number and have a way to return the remainder.
*/

// Timer countdowns
// -    Checks if greater than 0, and reduces by one.
//
// Obsolete Was used when f5 reset the game.
// -    Used in SCR_CORE_CONTROLS
//if (global.reset_key_timer != 0) global.reset_key_timer--;
// Used to make it so pressing the fullscreen button dosen't 
//  cause the game to jump in and out of fullscreen rapidly.
// -    TO_DO: Like with the menu switch to a boolean that checks 
//          if the key has been released.
//      Used in SCR_CORE_CONTROLS
if (global.full_screen_key_timer != 0) global.full_screen_key_timer--;
// Used to give the menu cursor a delay, so holding the menu key dosen't cycle
//  through the options too quickly.
// -    TO_DO: Currently its possible to spam the menu's keys and have nothing
//          happen because of the delay. Could reset timer if key is detected to be
//          released.
if (global.menu_key_timer != 0) global.menu_key_timer--;
// Timer used to sync footstep noise with the animation.
// -    TO_DO: change animation to use a single timer and a conditon on the animation
//          frame to sync the frame. Currently the footstep noise desyncs due to the 
//          timers using fractions. 
//          TO_DO Note: Having the two seperate timers was intended originally so 
//              it would be easy to change the value in the case I added more frames
//              of animation. However given how much the animation would likely
//              get overhauled anyway adjusting the timer in the animation script
//              isn't a big issue.
if (global.foot_step_timer != 0) global.foot_step_timer--;
// Timer used to animate bob.
if (global.walk_animation_timer != 0) global.walk_animation_timer--;
// Timer used to keep track of the time between each run_state. 
// -    Used to delay the runstate's animation and extend the amount of
//      time it takes to get to full speed.
if (global.run_state_timer != 0) global.run_state_timer--;
// Timer used to control cutscenes.
// -    Currently dialoge can't be sped up so the cutscene runs for a set time.
//          In practice the cutscene actually looks at total_duration-timer for readability.
//          It was left here as a reduction timer for consistancy and so there was 
//          no extra checks against total time in this function.
if (global.cutscene_timer != 0) global.cutscene_timer--;

// Timer resets
// -    Makes all timers register as 0 unless they are actively in use.
//          This allows the timers to receive floats and still operate.
//          Note: Most of the code that waits for timers expects a 0
//              input. 
//
//  For detailed notes on each timer look above.

//if (global.reset_key_timer <= 0) global.reset_key_timer = 0;
if (global.full_screen_key_timer <= 0) global.full_screen_key_timer = 0;
if (global.menu_key_timer <= 0) global.menu_key_timer = 0;
if (global.foot_step_timer <= 0) global.foot_step_timer = 0;
if (global.walk_animation_timer <= 0) global.walk_animation_timer = 0;
if (global.run_state_timer <= 0) global.run_state_timer = 0;

#define SCR_NEW_MAP
/*SCR_NEW_MAP ()
    Resets a global variables and spawns additional controllers for the room.
    
        TO-DO: Use this to spawn BOB into the room for more flexible teleports.
        
        TO_DO: add a delay so bob dosen't immediatly start walking when spawned 
            into a new room.
*/

// Resets Bob's animation. Specificaly the walk cycle.
// -    Unnessary, but this way bob's walk cycle always starts out on 
//          the right foot. (Our right.)
global.walk_animation = 0;
// Sets bob to idle. 
global.idle = true;
// Resets Bob's Run state.
global.run_state = 0;
// Resets Bob's Run state, sepcifically the delay timer between states.
global.run_state_timer = 0;

// Resets Bob's after image.
for (i = 0; i < 10; i++)
{
    global.bob_last_x_array[i] = 0;
    global.bob_last_y_array[i] = 0;
}

// Creates the object that puts text on the floor of certian levels.
instance_create(0, 0, OBJ_FLOOR_TEXT_CONTROLLER);

#define SCR_KEY_CHECK
/*SCR_KEY_CHECK (key_macro(int))
    Checks if a key/button/control stick is in use, returns true if in use, false if not.
        It is controlled by checking for the button associated with the macro specified by
        the function call.
        
        TO_CONSIDER: With modifications it could be possible to rebind keys. Have the argument check call a seperate
            script that checks a button given an id and have the id that is passed by this script set
            by a data structure (global values).
        
        TO_DO: Change the return value for it the script is called without a proper argument,
            for a key that is incomplete/incorrect, or an index associated with no key.
            Currently there is no distinction between errors.
        
*/

// Check ot see if an argument was passed to the script.
if !is_real(argument0)
{
   // Returns a generic error.
   // -     Currently overloaded, thus, less than useless.
   return false;
}
else
{
    // Checks the for key presses based on the intent of the program. 
    // -    Keys could be safely checked for multiple checks because this script
    //          only cares about the type of press not the specific key.
    if(argument0 == UP_KEY)
    {
        // User is trying to make bob go up, or scroll up on a menu.
        // -    Checks W, up arrow, left thumbstick up, and up on the 
        //          directional pad.
        if (keyboard_check( ord('W') ) || keyboard_check(vk_up) || gamepad_button_check(0, gp_padu) || gamepad_axis_value(0, gp_axislv) < -AXIS_TOLERANCE )
        {
            // At least one valid key is pressed. Return a hit. (true)
            return true;
        }
        else
        {
            // No keys pressed. Return a miss. (false)
            // -     Currently overloaded, the rest of the code acts like
            //          this is the only way a false value can be returned.
            return false;
        }
    }
    else if(argument0 == DOWN_KEY)
    {
        // User is trying to make bob go down, or scroll down on a menu.
        // -    Checks S, down arrow, left thumbstick down, and down on the 
        //          directional pad.
        if ( keyboard_check( ord('S') ) || keyboard_check(vk_down) || gamepad_button_check(0, gp_padd) || gamepad_axis_value(0, gp_axislv) > AXIS_TOLERANCE )
        {
            // At least one valid key is pressed. Return a hit. (true)
            return true;
        }
        else
        {
            // No keys pressed. Return a miss. (false)
            // -     Currently overloaded, the rest of the code acts like
            //          this is the only way a false value can be returned.
            return false;
        }
    }
    else if(argument0 == RIGHT_KEY)
    {
        // User is trying to make bob go right.
        // -    Checks D, right arrow, left thumbstick right, and right on the 
        //          directional pad.
        if ( keyboard_check( ord('D') ) || keyboard_check(vk_right) || gamepad_button_check(0, gp_padr) || gamepad_axis_value(0, gp_axislh) > AXIS_TOLERANCE)
        {
            // At least one valid key is pressed. Return a hit. (true)
            return true;
        }
        else
        {
            // No keys pressed. Return a miss. (false)
            // -     Currently overloaded, the rest of the code acts like
            //          this is the only way a false value can be returned.
            return false;
        }
    }
    else if(argument0 == LEFT_KEY)
    {
        // User is trying to make bob go right.
        // -    Checks A, left arrow, left thumbstick left, and left on the 
        //          directional pad.
        if ( keyboard_check( ord('A') ) || keyboard_check(vk_left) || gamepad_button_check(0, gp_padl) || gamepad_axis_value(0, gp_axislh) < -AXIS_TOLERANCE)
        {
            // At least one valid key is pressed. Return a hit. (true)
            return true;
        }
        else
        {
            // No keys pressed. Return a miss. (false)
            // -     Currently overloaded, the rest of the code acts like
            //          this is the only way a false value can be returned.
            return false;
        }
    }
    else if(argument0 == SHIFT_KEY)
    {
        // User is trying to make bob run.
        // -    Checks shift, and the right shoulder button.
        if ( keyboard_check(vk_shift) || gamepad_button_check(0, gp_shoulderr) )
        {
            // At least one valid key is pressed. Return a hit. (true)
            return true;
        }
        else
        {
            // No keys pressed. Return a miss. (false)
            // -     Currently overloaded, the rest of the code acts like
            //          this is the only way a false value can be returned.
            return false;
        }
    }
    else if(argument0 == MENU_KEY)
    {
        // User is trying to open a menu.
        // -    Checks escape, and the start button.
        if ( keyboard_check(vk_escape) || gamepad_button_check(0, gp_start) )
        {
            // At least one valid key is pressed. Return a hit. (true)
            return true;
        }
        else
        {
            // No keys pressed. Return a miss. (false)
            // -     Currently overloaded, the rest of the code acts like
            //          this is the only way a false value can be returned.
            return false;
        }
    }
    else if(argument0 == CONFIRM_KEY )
    {
        // User is trying to confirm a selection.
        // -    Checks enter and the "A" button on a controller.
        if ( keyboard_check(vk_enter) || gamepad_button_check(0, gp_face1) )
        {
            // At least one valid key is pressed. Return a hit. (true)
            return true;
        }
        else
        {
            // No keys pressed. Return a miss. (false)
            // -     Currently overloaded, the rest of the code acts like
            //          this is the only way a false value can be returned.
            return false;
        }
    }
    else
    {
        // The ID given either wasn't for a defined action or a mistake was made
        //  in defining the action.
        // -     As it returns false it can be confused with the case the 
        //          action is defined but no keys are pressed.
        return false;
    }
}


#define SCR_IN_GAME_MENU
/*SCR_IN_GAME_MENU ()
    The main menu's script. It stores the logic behind each selection.
        currently it is a one level menu so it dosen't need to store the 
        previous menu level's position.
        
*/


// Checks that the menu is actually open.
// -    global.menu_open is used both for this check and also to note if
//          the menu should be rendered on screen. global.bob_can_move
//          is used to stop bob from moving.
if (global.menu_open)
{
    // Calls a script to handling the players input to move up and down the current menu.
    SCR_MENU_NAVIGATE();
    // Checks to see if the user has made a slection.
    if ( SCR_KEY_CHECK( CONFIRM_KEY ) )
    {
        // - Menu Logic -
        
        // Loops through possible choices in menu.
        if (global.menu_current_option == 0)
        {
            // First option was selected. The user wants to 
            //  reset the current level.
            
            // Call to reset the level.
            room_restart();
            
            // Exits menu and returns the player to control bob.
            global.bob_can_move = true;
            global.menu_open = false;
        }
        else if (global.menu_current_option == 1)
        {
            // Second option was selected. The user wants to 
            //  reset the game.
            
            // Call to reset the game.
            game_restart();
        }
        else
        {
            // Third option was selected. The user wants to 
            //  quit the game.
            
            // Call to quit the program.
            game_end();
        }
    }   
}