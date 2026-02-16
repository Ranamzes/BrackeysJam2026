extends Control

@onready var backgroun_texture:TextureRect = $BackgroundTexture
@onready var item_texture:TextureRect = $ItemTexture

@export var inventory_slot : ItemSlot

func update_slot(bg_texture : Texture2D, item_tex : Texture2D):
	backgroun_texture.texture = bg_texture
	item_texture.texture = item_tex
