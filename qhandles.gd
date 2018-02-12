extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var is_master=false
var is_started=false

var currentcorrect='1'
var score={}
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if get_tree().is_network_server():
		is_master=true
		master_configure()
	else:
		client_configure()
	makecard()
	
func makecard():
	for x in multiplayer.players:
		if x !=1:
			score[x]=0
	scoreupdate()

sync func scoreupdate():
	var finaltext=''
	for x in score:
		finaltext+=multiplayer.players[x]+' : '+str(score[x])+ ' | '
	$Scorecard.text=finaltext 
func master_configure():
	$Question.readonly=false
	$Question/send.visible=true
	$correct.visible=true
func client_configure():
	visible=false
	$GridContainer.visible=true
	for ch in $GridContainer.get_children():
		ch.connect("pressed",self,"ButtonPressed",[ch])

sync func settext(text,correct):
	$Question.text=text
	restclient()
	print(correct)
	currentcorrect=correct

sync func answered(who):
	for ch in $GridContainer.get_children():
		ch.disabled=true
	score[who]+=1
	scoreupdate()
func _on_send_pressed():
	if is_master:
		rpc('settext',$Question.text,$correct/Button.group.get_pressed_button().name)


remote func restclient():
	visible=true
	for ch in $GridContainer.get_children():
		ch.disabled=false
		ch.pressed=false

#Buttons Pressed

func ButtonPressed(button):
	for b in $GridContainer.get_children():
		b.disabled=true
	if button.name==currentcorrect:
		print("Correct Answer")
		#score[get_tree().get_network_unique_id()]+=1
		#rset('score[get_tree().get_network_unique_id()]',score[get_tree().get_network_unique_id()])
		#rpc('scoreupdate')
		rpc('answered',get_tree().get_network_unique_id())
		