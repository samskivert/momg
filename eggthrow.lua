splash_mode = true
score = 0
games_played = 0
high_score = 1
new_high_score = false

eggs_remain = 0
floory = 14.5
press_time = 0
power = 0
max_power = 10
start_egg_y = floory

function print_center (text, y)
  local x = (128 - #text*4)/2
  print(text, x, y, 7)
end

function draw_splash ()
  if (games_played == 0) then
    print_center("throw the eggs", 40)
    print_center("high score:"..high_score, 56)
    print_center("press X to start", 72)
  else
    if (new_high_score) then
      print_center("new high score!", 26)
      print_center(tostr(high_score), 40)
    else
      if (score == high_score) then
        print_center("so close!", 26)
      else
        print_center("good job!", 26)
      end
      print_center("score:"..score, 40)
      print_center("high score:"..high_score, 56)
    end
    print_center("press X to play again", 72)
  end
end

function draw_hud ()
  print("eggs:"..eggs_remain, 10, 0, 7)
  print("score:"..score, 78, 0, 7)
end

function draw_meter ()
  -- draw the power meter
  if (egg and power > 0) then
    local my = egg.y*8+2
    line(egg.x, my, egg.x+max_power, my-max_power+0.5, 1)
    line(egg.x, my, egg.x+power, my-power+0.5, egg.meter_color)
  end
end

function create_nest (x)
  local nest = make_actor(1, x, floory, 0)
  nest.h = 0.1
  nest.ay = 0
  nest.fx = 0.5
  return nest
end

function move_nest (a)
  local atime = time()-a.ctime
  local fx = cos(atime/5)/2
  local fy = sin(atime/5)/2
  a.x = a.vx + fx*a.ax
  a.y = a.vy + fy*a.ay
end

function add_next_nest ()
  local xvar = 3+min(score, 7)
  local nest = create_nest(3+rnd(xvar))
  nest.ctime = time()
  nest.move = move_nest
  if (score > 15) then
    nest.ax = 2 + rnd(2)
    nest.ay = 2 + rnd(2)
  elseif (score > 9) then
    nest.ax = 2 + rnd(2)
  elseif (score > 4) then
    nest.ay = 2 + rnd(2)
  end
  nest.x += nest.ax/2
  nest.y -= nest.ay/2
  nest.vx = nest.x
  nest.vy = nest.y
end

function is_egg (k)
  return k == 4 or k == 20 or k == 36
end

function create_egg ()
  if (egg and egg.life > 0) then
    printh("Already have egg?")
    return
  end
  egg = make_actor(4, 0.5, start_egg_y, 0)
  local r = rnd(10)
  if (score > 3 and r <= 1) then
    egg.k = 20
    egg.points = 3
    egg.caughtfx = 0
    egg.boost = 1
    egg.meter_color = 12
  elseif (score > 6 and r <= 2) then
    egg.k = 36
    egg.points = 5
    egg.caughtfx = 1
    egg.boost = 2 -- 2x power
    egg.meter_color = 8
  else
    egg.points = 1
    egg.caughtfx = 0
    egg.boost = 1
    egg.meter_color = 12
  end
  eggs_remain -= 1
end

function throw_egg (power)
  egg.vx = 0.025 * power
  egg.vy = -0.05 * power
  egg.ay = 0.01
end

function make_bird (k, x, y, tx)
  local bird = make_particle(k, x, y, 1)
  bird.frames = 2
  bird.dframe = 0.5
  bird.life = 50
  bird.dlife = 1
  bird.vx = (tx - x)/10
  bird.vy = -0.1 - rnd(0.2)
  bird.ay = -0.05
  return bird
end

function kill_actor (a)
  a.life = 0
end

function splat_egg (a)
  a.life = 0
  local splat = make_particle(a.k+1, a.x, a.y, a.d)
  splat.frames = 6
  splat.dframe = 1
  splat.life = 5
  splat.dlife = 1
  sfx(2)
end

function start_game ()
  splash_mode = false
  score = 0
  eggs_remain = 25
  start_egg_y = floory
  create_egg()
  add_next_nest()
  sfx(4)
end

function game_over ()
  games_played += 1
  new_high_score = score > high_score
  high_score = max(score, high_score)
  dset(0, high_score)
  foreach(actors, kill_actor)
  splash_mode = true
end

function _init ()
  cartdata("eggthrow")
  high_score = dget(0)
end

function on_collide (nest, aegg)
  if (nest.k != 1 or aegg != egg) then
    return
  end
  local hatched = aegg.y <= nest.y+0.2
  if (hatched) then
    nest.life = 0
    aegg.life = 0
    score += aegg.points
    sfx(aegg.caughtfx)
    local crack = make_particle(aegg.k+8, aegg.x, aegg.y, aegg.d)
    crack.frames = 4
    crack.dframe = 1
    crack.life = 3
    crack.dlife = 1
    local bird = make_bird(aegg.k-2, aegg.x, aegg.y, rnd(16))
  else
    splat_egg(aegg)
  end
  if (eggs_remain > 0) then
    create_egg()
    if (hatched) then
      add_next_nest()
    end
  else
    game_over()
  end
end

function _update ()
  local t = time()

  if (splash_mode) then
    if (btnp(5)) then
      start_game()
    end
  else
    if (btnp(5) and egg.vx == 0 and press_time == 0) then
      press_time = t
    end
    if (btn(5)) then
      if (press_time > 0) then
        local pt = t-press_time
        power = abs(sin(pt/5*egg.boost))*max_power
      end
    elseif (press_time > 0) then
      if (power > 2) then
        throw_egg(power)
      end -- otherwise abort move
      press_time = 0
      power = 0
    end
  end

  update_actors()
  collide_actors(on_collide)

  for a in all(actors) do
    if a.y > floory+0.5 and is_egg(a.k) then
      splat_egg(a)
      if (eggs_remain > 0) then
        create_egg()
      else
        game_over()
      end
    end
  end

  if (egg and egg.vx == 0) then
    if (btn(2)) then
      egg.y = max(10, egg.y-1/8)
    elseif (btn(3)) then
      egg.y = min(floory, egg.y+1/8)
    end
    start_egg_y = egg.y
  end
end

function _draw ()
  cls()
  draw_actors()
  if (splash_mode) then
    draw_splash()
  else
    draw_hud()
    draw_meter()
  end
end
