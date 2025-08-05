extends Node2D

@onready var admob = $Admob
@onready var ad_timeout_timer = $AdTimeoutTimer

var is_iniatialized : bool = false
var requested_reward = false
var requested_reward_type = null
var reward_apply = false
var reward_return = null

const AD_LOAD_TIMEOUT = 5.0

func _ready() -> void:
	admob.initialize()
	ad_timeout_timer.wait_time = AD_LOAD_TIMEOUT
	ad_timeout_timer.one_shot = true

func check_initialized() -> bool:
	return is_iniatialized

func get_reward(reward_type : String):
	if is_iniatialized:
		requested_reward = true
		requested_reward_type = reward_type
		admob.load_rewarded_ad()
		
		ad_timeout_timer.start()
		Notifier.notificar("Chamada efetuada para Ad.")
		# Aguarda o carregamento do Ad ou o timeout
		var ad_loaded = await admob.rewarded_ad_loaded or ad_timeout_timer.timeout
		
		if ad_loaded:
			admob.show_rewarded_ad()
		else:
			_handle_ad_fail()

func _on_admob_initialization_completed(status_data: InitializationStatus) -> void:
	Notifier.notificar("O Admob foi inicializado")
	is_iniatialized = true

func _on_admob_rewarded_ad_user_earned_reward(ad_id: String, reward_data: RewardItem) -> void:
	Notifier.notificar("Recompensa concedida")
	reward_apply = true
	reward_return = [ad_id, reward_data]

func _on_admob_rewarded_ad_dismissed_full_screen_content(ad_id: String) -> void:
	if requested_reward:
		if reward_apply:
			match reward_return[1].get_type():
				"Continue":
					GameManager.adContinue()
		else:
			match requested_reward_type:
				"Continue":
					GameManager.adContinueGameOver()
	reset_reward_request()

func _handle_ad_fail():
	Notifier.notificar("Ad falhou ao carregar ou demorou muito.")
	GameManager.adContinueFail()  # Chamar a função de falha do Ad
	reset_reward_request()

func reset_reward_request():
	requested_reward = false
	reward_apply = false
	reward_return = null
