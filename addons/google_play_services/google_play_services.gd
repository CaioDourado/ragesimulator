extends Node

#FUNCTIONS YOU CAN USE FOR:

#ACCOUNT
#signIn(); signOut()

#ACHIEVEMENTS
#unlockAchievement(id); incrementAchievement(id, points)
#showAchievements()

#LEADERBOARD
#submitLeaderboard(id, score); showLeaderboard(id)

#CLOUD
#saveData(data), loadData()

#DON'T MODIFY*******************************************
var play_games_services

signal sign_in_success()
signal sign_in_failed()
signal sign_out_success()
signal sign_out_failed()
signal achievement_unlocked(achievement: String)
signal achievement_unlocking_failed(achievement: String)
signal achievement_incremented(achievement: String)
signal achievement_incrementing_failed(achievement: String)
signal leaderboard_score_submitted(leaderboard_id: String)
signal leaderboard_score_submitting_failed(leaderboard_id: String)
signal save_success()
signal save_failed()
signal load_success(data: Dictionary)
signal load_failed()

#SET-UP
func _ready():
	if Engine.has_singleton("GodotPlayGamesServices"):
		play_games_services = Engine.get_singleton("GodotPlayGamesServices")
		play_games_services.initWithSavedGames(true, "gamename", true, true, "")
		
		play_games_services._on_sign_in_success.connect(_on_sign_in_success) # account_id: String
		play_games_services._on_sign_in_failed.connect(_on_sign_in_failed) # error_code: int
		play_games_services._on_sign_out_success.connect(_on_sign_out_success) # no params
		play_games_services._on_sign_out_failed.connect(_on_sign_out_failed) # no params
		play_games_services._on_achievement_unlocked.connect(_on_achievement_unlocked) # achievement: String
		play_games_services._on_achievement_unlocking_failed.connect(_on_achievement_unlocking_failed) # achievement: String
		play_games_services._on_achievement_incremented.connect(_on_achievement_incremented) # achievement: String
		play_games_services._on_achievement_incrementing_failed.connect(_on_achievement_incrementing_failed) # achievement: String
		play_games_services._on_leaderboard_score_submitted.connect(_on_leaderboard_score_submitted) # leaderboard_id: String
		play_games_services._on_leaderboard_score_submitting_failed.connect(_on_leaderboard_score_submitting_failed) # leaderboard_id: String
		play_games_services._on_game_saved_success.connect(_on_game_saved_success) # no params
		play_games_services._on_game_saved_fail.connect(_on_game_saved_fail) # no params
		play_games_services._on_game_load_success.connect(_on_game_load_success) # data: String
		play_games_services._on_game_load_fail.connect(_on_game_load_fail) # no params

#ACCOUNT
func signIn():
	if play_games_services:
		play_games_services.signIn()

func signOut():
	if play_games_services:
		play_games_services.signOut()

#ACHIEVEMENTS
func unlockAchievement(id):
	if play_games_services:
		play_games_services.unlockAchievement(id)

func incrementAchievement(id, points):
	if play_games_services:
		play_games_services.incrementAchievement(id, points)

func showAchievements():
	if play_games_services:
		play_games_services.showAchievements()

#LEADERBOARD
func submitLeaderboard(id, score):
	if play_games_services:
		play_games_services.submitLeaderBoardScore(id, score)

func showLeaderboard(id):
	if play_games_services:
		play_games_services.showLeaderBoard(id)

#CLOUD
func saveData(data: Dictionary):
	if play_games_services:
		play_games_services.saveSnapshot("data", JSON.stringify(data), "")

func loadData():
	if play_games_services:
		play_games_services.loadSnapshot("data")

#SIGNALS
func _on_sign_in_success(_account_id: String):
	emit_signal("sign_in_success")

func _on_sign_in_failed(_error_code: int):
	emit_signal("sign_in_failed")

func _on_sign_out_success():
	emit_signal("sign_out_success")

func _on_sign_out_failed():
	emit_signal("sign_out_failed")

func _on_achievement_unlocked(achivement: String):
	emit_signal("achievement_unlocked", achivement)

func _on_achievement_unlocking_failed(achievement: String):
	emit_signal("achievement_unlocking_failed", achievement)

func _on_achievement_incremented(achievement: String):
	emit_signal("achievement_incremented", achievement)

func _on_achievement_incrementing_failed(achievement: String):
	emit_signal("achievement_incrementing_failed", achievement)

func _on_leaderboard_score_submitted(leaderboard_id: String):
	emit_signal("leaderboard_score_submitted", leaderboard_id)

func _on_leaderboard_score_submitting_failed(leaderboard_id: String):
	emit_signal("leaderboard_score_submitting_failed", leaderboard_id)

func _on_game_saved_success():
	emit_signal("save_success")

func _on_game_saved_fail():
	emit_signal("save_failed")

func _on_game_load_success(data):
	var game_data: Dictionary = JSON.parse_string(data)
	emit_signal("load_success", game_data)

func _on_game_load_fail():
	emit_signal("load_failed")
