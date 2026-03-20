extends Node

@warning_ignore_start("unused_signal")
signal collectable_collected(id,value) #Emitted From Collectable
signal room_explored(room_id) #Emitted from Room
signal save_and_quit(data) #Emitting From Options
signal tutorial_text_viewed(id) #Emitted From SingleViewText
signal update_current_abilities(abilities) #Emitted From Dna Tab
signal unlock_ability(ability) #Emitted from Crittr Catcher
signal on_hidden_tile_entered(body) #Emitted From Player
signal wall_revealed(id) #Emitted from hidden wall tiles
signal player_death()
