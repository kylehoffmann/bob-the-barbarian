/* SCR_CUTSCENE_TEXT_BOX()
    Renders the window for dialog.
        TO_DO: Make the window less hard coded. Currently it is locked in one place.

*/

// Set border colour.
draw_set_colour(c_gray);
// Draw border large box a distance from the edge of the window defined 
//  by macro text_box_distance_from_edge.
draw_rectangle(0 + text_box_distance_from_edge, 576, 1024 - text_box_distance_from_edge, 768 - text_box_distance_from_edge, false);
// Set window colour.
draw_set_colour(c_white);
// Draw smaller box inside the border box. 
// -    It is smaller than the border box by macro text_box_border.
draw_rectangle(0 + text_box_distance_from_edge + text_box_border, 576 + text_box_border, 1024 - text_box_border - text_box_distance_from_edge, 768 - text_box_border - text_box_distance_from_edge, false);
// Reset colour to black.
// -    Colour is black by default, keep the defualt
//          to avoid bugs.
draw_set_colour(c_black);    

