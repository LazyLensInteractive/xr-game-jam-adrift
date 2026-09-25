#data autoload to keep track of data between scene changes
extends Node
var hunger_pts:float = 100.0 # 100 full
var amount_food = 10 #how much food in the oat currently?
var flare_used = false
var boat_dmg = 0 #0 no dmg to boat 100 means game over only 4 hitpoints so goes up by 25 each time
var storm_day = false
var bottle_thrown = false
var fished = false
var cup_day = false
var cup_out = false
