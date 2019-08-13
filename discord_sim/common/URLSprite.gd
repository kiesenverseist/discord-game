extends Sprite
class_name URLSprite

var url : String setget set_url
var req : HTTPRequest
var url_hash : int
export var default : Texture = preload("res://icon.png")
var url_texture : ImageTexture

signal request_completed

func _ready():
	connect("texture_changed", self, "change_texture")
	
	self.url = "https://cdn.discordapp.com/attachments/310694793355198465/607842030181154818/hdfhfdgb.gif"
	
	var dir = Directory.new()
	dir.open("user://")
	if not dir.dir_exists("downloaded_images"):
		dir.make_dir("downloaded_images")
	
	if url_texture:
		texture = url_texture
	else:
		texture = default

func set_url(u : String) -> void:
	
	url = u
	url_hash = hash(url)
	
	var img = Image.new()
	var load_err = img.load("user://downloaded_images/%s.png" % str(url_hash))
	
	if load_err != OK:
		print("downloading image: %s" % url)
		
		req = HTTPRequest.new()
		add_child(req)
		
		req.use_threads = true
		req.request(url)
		req.connect("request_completed", self, "data_ready")
	else:
		url_texture = ImageTexture.new()
		url_texture.create_from_image(img)
		texture = url_texture
	
func data_ready(result, response_code, headers, body):
	var img = Image.new()
	var load_err = img.load_webp_from_buffer(body)
	if load_err:
		load_err = img.load_png_from_buffer(body)
	if load_err:
		load_err = img.load_jpg_from_buffer(body)
	
	if not load_err:
		url_texture = ImageTexture.new()
		url_texture.create_from_image(img)
		texture = url_texture
		
		img.save_png("user://downloaded_images/%s.png" % str(url_hash))

func change_texture():
	var size : Vector2 = texture.get_size()
	scale = Vector2(64, 64) / size
	print(scale)
