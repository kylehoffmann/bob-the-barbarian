#define Core_Controls
if ( SCR_KEY_CHECK( MENU_KEY ) )
{
    if (global.menu_key_timer == 0 && !global.menu_button_still_pressed)
    {
        global.menu_key_timer = KEY_PRESS_COOLDOWN;
        global.menu_button_still_pressed = true;
        if (global.bob_can_move) 
        {
            global.bob_can_move = false;
            global.menu_open = true;
            global.menu_options = 3;
            global.menu_current_option = 0;
        }
        else 
        {
            global.bob_can_move = true;
            global.menu_open = false;
        }
    }
}
else
{
    global.menu_button_still_pressed = false;
}

if ( keyboard_check( vk_escape ) && false)
{
    game_end();
}

if ( keyboard_check( vk_f5 ) && false )
{
    if (global.reset_key_timer == 0)
    {
        global.reset_key_timer = KEY_PRESS_COOLDOWN;
        game_restart();
    }
}

if ( keyboard_check( vk_f11 ) )
{
    if (global.full_screen_key_timer == 0)
    {
        global.full_screen_key_timer = KEY_PRESS_COOLDOWN;
        if (window_get_fullscreen())
        {
            window_set_fullscreen(false);
        }
        else
        {
            window_set_fullscreen(true);
        }
    }
}

#define view_0_controls
h_scroll_current = 0;
v_scroll_current = 0;

if ( keyboard_check( ord('W') ) || keyboard_check(vk_up) )
{
    h_scroll_current = -1 * H_SCROLL_SPEED;
}

if ( keyboard_check( ord('S') ) || keyboard_check(vk_down) )
{
    h_scroll_current = H_SCROLL_SPEED;
}

if ( keyboard_check( ord('A') ) || keyboard_check(vk_left) )
{
    v_scroll_current = -1 * V_SCROLL_SPEED;
}

if ( keyboard_check( ord('D') ) || keyboard_check(vk_right) )
{
    v_scroll_current = V_SCROLL_SPEED;
}

//Process Horizontal Screen movement.
if (0 > view_yview[0] + h_scroll_current)
{
    view_yview[0] = 0;
}
else if (CAMERA_Y_LIMIT < view_yview[0] + h_scroll_current)
{
    view_yview[0] = CAMERA_Y_LIMIT;
}
else
{
    view_yview[0] += h_scroll_current;
}

//Process Vertical Screen movement.
if (0 > view_xview[0] + v_scroll_current)
{
    view_xview[0] = 0;
}
else if (CAMERA_X_LIMIT < view_xview[0] + v_scroll_current)
{
    view_xview[0] = CAMERA_X_LIMIT;
}
else
{
    view_xview[0] += v_scroll_current;
}


#define SCR_Startup
global.current_map = 4;

global.menu_options = 0;
global.menu_current_option = 0;

global.menu_key_timer = 0;
global.reset_key_timer = 0;
global.full_screen_key_timer = 0;
global.menu_key_timer = 0;
global.foot_step_timer = 0;
global.run_state_timer = 0;
global.walk_animation_timer = 0;

global.run_state = 0;
global.walk_animation_cycle = 0;
global.idle = true;

global.bob_can_move = true;
global.menu_open = false;

global.menu_button_still_pressed = false;

global.bob_last_x = 0;
global.bob_second_last_x = 0;
global.bob_last_y = 0;
global.bob_second_last_y = 0;
for (i = 0; i < 10; i++)
{
    global.bob_last_x_array[i] = 0;
    global.bob_last_y_array[i] = 0;
}

global.menu_options_start_x = 360;
global.menu_options_start_y = 420;
global.menu_options_scale = 3;
global.menu_options_spacing = 50;

#define SCR_MAP_DONE
if !is_real(argument0)
{
   return false;
}
else
{
    if (argument0 == FLOOR_1_ID)
    {
        global.current_map = FLOOR_2_ID;
        room_goto(MAP_FLOOR_2);
    }
    else if (argument0 == FLOOR_2_ID)
    {
        global.current_map = TEST_MAP_ID;
        room_goto(MAP_TEST);
    }
    else if (argument0 == TEST_MAP_ID)
    {
        global.current_map = TEST_MAP_2_ID;
        room_goto(MAP_TEST_2);
    }
    else
    {
        //audio_stop_sound(SND_OVERWORLD_Kevin_MacLeod_incompetech_com);
        room_goto(MAP_YOU_WIN);
    }
    return (true);
}


#define SCR_MENU_NAVIGATE

if ( SCR_KEY_CHECK(UP_KEY) )
{
    if (global.menu_key_timer == 0)
    {
        global.menu_current_option--;
        global.menu_key_timer = KEY_PRESS_COOLDOWN;
        audio_play_sound(CURSOR_SOUND, 0, false);
    }
}

if ( SCR_KEY_CHECK(DOWN_KEY) )
{
    if (global.menu_key_timer == 0)
    {
        global.menu_current_option++;
        global.menu_key_timer = KEY_PRESS_COOLDOWN;
        audio_play_sound(CURSOR_SOUND, 0, false);
    }
}

if (global.menu_current_option < 0)
{
    global.menu_current_option = global.menu_options - 1;
}

if (global.menu_current_option == global.menu_options)
{
    global.menu_current_option = 0;
}

#define SCR_KEY_COOLDOWN
if (global.menu_key_timer != 0) global.menu_key_timer--;
if (global.reset_key_timer != 0) global.reset_key_timer--;
if (global.full_screen_key_timer != 0) global.full_screen_key_timer--;
if (global.menu_key_timer != 0) global.menu_key_timer--;
if (global.foot_step_timer != 0) global.foot_step_timer--;
if (global.walk_animation_timer != 0) global.walk_animation_timer--;
if (global.run_state_timer != 0) global.run_state_timer--;

if (global.menu_key_timer <= 0) global.menu_key_timer = 0;
if (global.reset_key_timer <= 0) global.reset_key_timer = 0;
if (global.full_screen_key_timer <= 0) global.full_screen_key_timer = 0;
if (global.menu_key_timer <= 0) global.menu_key_timer = 0;
if (global.foot_step_timer <= 0) global.foot_step_timer = 0;
if (global.walk_animation_timer <= 0) global.walk_animation_timer = 0;
if (global.run_state_timer <= 0) global.run_state_timer = 0;

#define SCR_NEW_MAP
global.walk_animation = 0;
global.idle = true;
global.run_state = 0;
global.run_state_timer = 0;
for (i = 0; i < 10; i++)
{
    global.bob_last_x_array[i] = 0;
    global.bob_last_y_array[i] = 0;
}

instance_create(0, 0, OBJ_FLOOR_TEXT_CONTROLLER);

#define SCR_ANIMATION_RESET
//Reset animation timers
global.walk_animation_timer = 0;

//Reset animation cycles
global.walk_animation_cycle = 0;


#define SCR_KEY_CHECK
if !is_real(argument0)
{
   return false;
}
else
{
    if(argument0 == UP_KEY)
    {
        if (keyboard_check( ord('W') ) || keyboard_check(vk_up) || gamepad_button_check(0, gp_padu) || gamepad_axis_value(0, gp_axislv) < -AXIS_TOLERANCE )
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else if(argument0 == DOWN_KEY)
    {
        if ( keyboard_check( ord('S') ) || keyboard_check(vk_down) || gamepad_button_check(0, gp_padd) || gamepad_axis_value(0, gp_axislv) > AXIS_TOLERANCE )
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else if(argument0 == RIGHT_KEY)
    {
        if ( keyboard_check( ord('D') ) || keyboard_check(vk_right) || gamepad_button_check(0, gp_padr) || gamepad_axis_value(0, gp_axislh) > AXIS_TOLERANCE)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else if(argument0 == LEFT_KEY)
    {
        if ( keyboard_check( ord('A') ) || keyboard_check(vk_left) || gamepad_button_check(0, gp_padl) || gamepad_axis_value(0, gp_axislh) < -AXIS_TOLERANCE)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else if(argument0 == SHIFT_KEY)
    {
        if ( keyboard_check(vk_shift) || gamepad_button_check(0, gp_shoulderr) )
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else if(argument0 == MENU_KEY)
    {
        if ( keyboard_check(vk_escape) || gamepad_button_check(0, gp_start) )
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else if(argument0 == CONFIRM_KEY )
    {
        if ( keyboard_check(vk_enter) || gamepad_button_check(0, gp_face1) )
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}


#define SCR_IN_GAME_MENU
if (global.menu_open)
{
    SCR_MENU_NAVIGATE();
    if ( SCR_KEY_CHECK( CONFIRM_KEY ) )
    {
        if (global.menu_current_option == 0)
        {
            room_restart();
            global.bob_can_move = true;
            global.menu_open = false;
        }
        else if (global.menu_current_option == 1)
        {
            game_restart();
        }
        else
        {
            game_end();
        }
    }   
}
