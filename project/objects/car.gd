
extends CharacterBody2D

class_name Car

var wheel_base = 60 # 前轮和后轮之间的距离

@export var max_steering_angle = 10 # 前轮最大转角
@export var steering_speed = 0.1
var current_steering_angle = 0.0 # 逐渐以转向速度lerp到最大转角

@export var max_acc = 1200
var current_acc = 0.0
@export var reverse_acc = -450
@export var max_speed_reverse = 250
# 摩擦力针对地面（沙土/冰雪）
@export var friction = -0.2
# 阻力是风阻，基于车辆的截面积
# 摩擦力基于速度，阻力基于速度的平方
# 在低速时，摩擦力更显著，在高速时，阻力更显著
@export var drag = -0.001

@export var drift_speed = 800 # 超过此速度开始打滑
@export var drift_angle = 9 # 帧之间的转向角度
var drift_timer = 0.5
@export var traction_fast = 0.001 # 当速度高于此值时，会更容易打滑
@export var traction_slow = 0.995 # 低于打滑速度。如果为1.0，会立即改变速度
@onready var current_traction = traction_slow
var drifting = false
var prev_heading = Vector2()
var new_heading = Vector2()

var acc = Vector2()
var vel = Vector2()

@onready var trail1 = $TrailPos1/Trail
@onready var trail2 = $TrailPos2/Trail
@onready var trail3 = $TrailPos3/Trail
@onready var trail4 = $TrailPos4/Trail
@onready var trails = [trail1, trail2, trail3, trail4]

var trail = preload('res://objects/trail.tscn')

func _physics_process(delta):
	acc = Vector2()
	control()
	drift(delta)
	calculate_steering(delta)
	collide(delta)
	
	apply_friction()
		
	vel += acc * delta
	physics_process(delta)

func collide(delta):
	var collision = move_and_collide(vel * delta)
	if collision:
		vel = vel.slide(collision.get_normal()) # 使用super.lerp(vel.bounce(collision.normal), 0.1)来滑行
		
		rotation = lerp_angle(rotation, vel.angle(), 0.1)
	
func apply_friction():
	# 如果速度非常慢，停止
	if vel.length() < 5: vel = Vector2()
	# 反向速度的力
	var friction_force = vel * friction
	# 速度的平方乘以阻力
	var drag_force = vel * vel.length() * drag
	# 添加摩擦力和阻力向量以减速
	acc += friction_force + drag_force
	
func drift(delta):
	# 如果速度大于打滑速度，并且当前转向角度的绝对值大于打滑角度：
	if vel.length() > drift_speed and abs(rad_to_deg(current_steering_angle)) > drift_angle: 
		drifting = true
		drift_timer = 0.5
	# 当速度/角度刚好在阈值上时，打滑会烦人地反复打开和关闭
	# 我们不是基于速度切换它，而是在速度越过一个阈值后打开它，
	# 一段时间后再关闭
	drift_timer -= delta
	if drift_timer <= 0:
		drifting = false
		
	if drifting:
		current_traction = lerp(current_traction, traction_fast, 0.1)
		for trail in trails:
			trail.leave_tracks = true
			
	else:
		current_traction = lerp(current_traction, traction_slow, 0.01) 
		for trail in trails:
			trail.leave_tracks = false

func calculate_steering(delta):
	# 轮子的位置
	var rear_wheel = position - transform.x * wheel_base/2
	var front_wheel = position + transform.x * wheel_base/2
	rear_wheel += vel * delta 	# 后轮按速度前进
	front_wheel += vel.rotated(current_steering_angle) * delta # 前轮按方向前进，方向是转向的方向
	new_heading = (front_wheel - rear_wheel).normalized() # 指向新方向的向量
	rotation = new_heading.angle()

	var is_moving_forward = new_heading.dot(vel.normalized()) > -0.5
	if is_moving_forward: 
		var target_vel = new_heading * vel.length()  # 将速度旋转到新方向，保持速度不变
		vel = vel.lerp(target_vel, current_traction)
	else:
		vel = -new_heading * min(vel.length(), max_speed_reverse)  # 不能超过倒车速度
	
func physics_process(delta):
	pass
func control():
	pass # 在继承的场景中定义，如Enemy.gd或Player.gd
