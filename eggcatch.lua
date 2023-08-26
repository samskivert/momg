score = 0
next_egg = 1
egg_freq = 2
gravity = 0.01
speed_factor = 1
best_speed = 1

function adjust_score (ds)
  score = max(0, score+ds)
  speed_factor = (score+10)/10
  best_speed = max(speed_factor, best_speed)
end

function draw_hud ()
  print("speed: "..speed_factor.."x", 0, 0)
  print("best: "..best_speed.."x", 80, 0)
end

function drop_egg ()
  local x = rnd(16)
  local egg = make_actor(1, x, 1, 0)
  egg.frames = 2
  egg.h = 0.1
  egg.fx = 0.99
  egg.ay = gravity * speed_factor
end

function _init ()
  nest = make_actor(3, 6, 13, 0)
  nest.ay = 0
end

function on_collide (a1, a2)
  if (a1.k == 3) then
    adjust_score(1)
    a2.life = 0
  end
end

function _update ()
  local t = time()

  if (t > next_egg) then
    drop_egg()
    next_egg += egg_freq * 1/speed_factor
  end

  update_actors()
  collide_actors(on_collide)

  for a in all(actors) do
    if a.y > 16 then
      a.life = 0
      adjust_score(-1)
    end
  end

  if (btn(0)) then
    nest.x -= 0.2 * speed_factor
  elseif (btn(1)) then
    nest.x += 0.2 * speed_factor
  end
end

function _draw ()
  cls()
  draw_actors()
  draw_hud()
end
