#define SCR_ULITLIES
//UNUSED
// Here for organiztion.

#define SCR_COLLIOSION_CHECK
/*  SCR_COLLIOSION_CHECK(Checking_X, How_many_pixels_is_bob_doing)
        Checks if Bob collides with an object that he can't pass though.
            The first argument decides if we are checking x or y movements.
                true = x, false = y.
            The second argument is the amount Bob is moving. The value passed
                needs to retian its sign so it can determine the movement's direction.
*/

// Storage for the change to Bob's location.
// -    The direction bob is not moving is initalized to 0.
x_mod = 0;
y_mod = 0;

// Decides the direction to test.
// -    true = x, false = y.
//      It only changes 
if(argument0 == true)
{
    x_mod = argument1;
}
else
{
    y_mod = argument1;
}

// Uses gameMaker's built in collision to see if Bob would 
//     collide with a solid object. (OBJ_WALL and its children)
//      Bob will also collide with OBJ_BREAKABLE_RUN if he is not at
//          full speed.
if(place_meeting(self.x + x_mod, self.y + y_mod , OBJ_WALL) || (place_meeting(self.x + x_mod, self.y + y_mod , OBJ_BREAKABLE_RUN) && global.run_state != RUN_STATE_MAX) )
{
    // Return that there was no collision (true)
    return true;
}
else
{
    // Return that there was a collision (false)
    return false;
}