extends Node

@warning_ignore_start("unused_signal")
signal collectable_grabbed(id) #Emitted From Collectable
signal collectable_following(id,player : Player) #Emitted From Player
signal collectable_collected(id,value) #Emitted From Collectable
signal room_explored(room_id) #Emitted from Room
signal save_and_quit(data) #Emitting From Options
signal tutorial_text_viewed(id) #Emitted From SingleViewText
signal update_current_abilities(abilities) #Emitted From Dna Tab
signal unlock_ability(ability) #Emitted from Crittr Catcher
signal on_hidden_tile_entered(body) #Emitted From Player
signal wall_revealed(id) #Emitted from hidden wall tiles
signal screen_is_black(current_room)
signal player_death()
signal player_respawn()
signal lock_entry(category_name: String, entry_title: String)
signal unlock_entry(key)
