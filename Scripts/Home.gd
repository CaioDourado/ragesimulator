extends Node2D

@onready var bt_login : Button = $CanvasLayer/Control/btPlay/BtLogin
@onready var bt_play : Button = $CanvasLayer/Control/btPlay
@onready var bt_stages : Button = $CanvasLayer/Control/btPlay/btStages

func _ready() -> void:
	bt_play.pressed.connect(goToGMPlayNow)
	bt_stages.pressed.connect(goToGMStages)
	if SaveManager.get_save() == null:
		var local_save = SaveManager.load_local()
		if local_save == null:
			local_save = SaveManager.create_save()
		else:
			SaveManager.load_save(local_save)
		#if OS.get_name() == "Android":
			#print("Setting Google Plays Services")
			#GooglePlayServices.sign_in_success.connect(_signInSuccess)
			#GooglePlayServices.sign_in_failed.connect(_signInFail)
			#GooglePlayServices.load_success.connect(onLoadGame)
			#GooglePlayServices.load_failed.connect(onLoadGameFail)
			#GooglePlayServices.save_success.connect(onSaveSuccess)
			#GooglePlayServices.save_failed.connect(onSaveFail)
			#signInAndLoad()
	else:
		print("==> Game: Saved Game Already Loaded")
		print(SaveManager.memory_card)

func goToGMPlayNow():
	GameManager.play_now()
	
func goToGMStages():
	GameManager.go_to_stages()
	
func signInAndLoad():
	GooglePlayServices.signIn()

func _on_bt_login_pressed() -> void:
	signInAndLoad()

func _signInSuccess():
	bt_login.visible = false
	GooglePlayServices.loadData()

func _signInFail():
	bt_login.visible = true

func onLoadGame(data):
	print("==> GAME: Load Success")
	if(data==null or data == {}):
		createNewSave()
	else:
		print("==> GAME: Load Data Success")
		print(str(data))
		GameManager.load_save(data)

func onLoadGameFail():
	print("==> GAME: Load Fail")
	GooglePlayServices.signOut()
	bt_login.visible = true

func onSaveSuccess():
	print("==> GAME: Save Success")

func onSaveFail():
	print("==> GAME: Save Fail")

func createNewSave():
	var data = GameManager.new_save()
	GooglePlayServices.saveData(data)
	print("==> New Saved Data")

func _on_bt_rm_data_pressed() -> void:
	#GooglePlayServices.saveData({})
	SaveManager.delete_save()
