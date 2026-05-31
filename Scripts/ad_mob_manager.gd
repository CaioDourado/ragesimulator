extends Node2D

@onready var admob = $Admob
@onready var ad_timeout_timer = $AdTimeoutTimer

var is_iniatialized : bool = false
var requested_reward = false
var requested_reward_type = null
var reward_apply = false
var reward_return = null
var loaded_rewarded_ad_id : String = ""

const AD_LOAD_TIMEOUT = 5.0

func _ready() -> void:
	admob.initialize()
	ad_timeout_timer.wait_time = AD_LOAD_TIMEOUT
	ad_timeout_timer.one_shot = true
	if not ad_timeout_timer.timeout.is_connected(_on_ad_timeout):
		ad_timeout_timer.timeout.connect(_on_ad_timeout)

func check_initialized() -> bool:
	return is_iniatialized

func get_reward(reward_type : String):
	if requested_reward:
		return
	
	if not is_iniatialized:
		requested_reward = true
		requested_reward_type = reward_type
		_handle_ad_fail()
		return
	
	requested_reward = true
	requested_reward_type = reward_type
	reward_apply = false
	reward_return = null
	loaded_rewarded_ad_id = ""
	admob.load_rewarded_ad()
	ad_timeout_timer.start()
	Notifier.notificar("Chamada efetuada para Ad.")

func _on_admob_initialization_completed(status_data: InitializationStatus) -> void:
	Notifier.notificar("O Admob foi inicializado")
	is_iniatialized = true

func _on_admob_rewarded_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	if not requested_reward:
		return
	
	ad_timeout_timer.stop()
	loaded_rewarded_ad_id = ad_info.get_ad_id()
	admob.show_rewarded_ad(loaded_rewarded_ad_id)

func _on_admob_rewarded_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
	if requested_reward:
		_handle_ad_fail()

func _on_admob_rewarded_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError) -> void:
	if requested_reward:
		_handle_ad_fail()

func _on_admob_rewarded_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem) -> void:
	Notifier.notificar("Recompensa concedida")
	reward_apply = true
	reward_return = [ad_info, reward_data]

func _on_admob_rewarded_ad_dismissed_full_screen_content(ad_info: AdInfo) -> void:
	if requested_reward:
		if reward_apply:
			match requested_reward_type:
				"Continue":
					GameManager.adContinue()
		else:
			match requested_reward_type:
				"Continue":
					GameManager.adContinueGameOver()
	reset_reward_request()

func _handle_ad_fail():
	if not requested_reward:
		return
	
	ad_timeout_timer.stop()
	Notifier.notificar("Ad falhou ao carregar ou demorou muito.")
	GameManager.adContinueFail()
	reset_reward_request()

func _on_ad_timeout():
	if requested_reward:
		_handle_ad_fail()

func reset_reward_request():
	requested_reward = false
	requested_reward_type = null
	reward_apply = false
	reward_return = null
	loaded_rewarded_ad_id = ""
