score = 0
next_egg = 0
egg_freq = 2
gravity = 0.01
speed_factor = 1
best_speed = 1
splash_time = 1

function adjust_score (ds)
  score = max(0, score+ds)
  speed_factor = (score+10)/10
  best_speed = max(speed_factor, best_speed)
end

function draw_splash ()
  print("catch the eggs", 40, 60)
end

function draw_hud ()
  print("speed: "..speed_factor.."x", 0, 0)
  print("best: "..best_speed.."x", 80, 0)
end

function create_nest()
  nest = make_actor(3, 6, 13, 0)
  nest.ay = 0
  nest.fx = 0.5
end

function drop_egg ()
  local x = 8 + (rnd(6) - 3) * min(speed_factor, 2)
  local egg = make_actor(1, x, 1, 0)
  egg.frames = 2
  egg.h = 0.1
  egg.fx = 0.99
  egg.ay = gravity * speed_factor
end

function _init ()
end

function on_collide (a1, a2)
  if (a1.k == 3) then
    adjust_score(1)
    a2.life = 0
    local crack = make_particle(12, a2.x, a2.y, a2.d)
    crack.frames = 4
    crack.dframe = 1
    crack.life = 3
    crack.dlife = 1
    local bird = make_particle(16, a2.x, a2.y, a2.d)
    bird.frames = 2
    bird.dframe = 0.5
    bird.life = 50
    bird.dlife = 1
    bird.vx = -0.5 + rnd(1)
    bird.vy = -0.1 - rnd(0.2)
    bird.ay = -0.05
  end
end

function _update ()
  local t = time()
  if (t < splash_time) then
    return
  elseif (splash_time > 0) then
    splash_time = 0
    create_nest()
    next_egg = t + 1
  end

  if (t > next_egg) then
    drop_egg()
    next_egg += egg_freq * 1/speed_factor
  end

  update_actors()
  collide_actors(on_collide)

  for a in all(actors) do
    if a.y > 15 then
      a.life = 0
      local splat = make_particle(5, a.x, a.y, a.d)
      splat.frames = 6
      splat.dframe = 1
      splat.life = 5
      splat.dlife = 1
      adjust_score(-1)
    end
  end

  if (btn(0)) then
    nest.ax = -0.5
  elseif (btn(1)) then
    nest.ax = 0.5
  else
    nest.ax = 0
  end
end

function _draw ()
  cls()
  if (splash_time > 0) then
    draw_splash()
  else
    draw_actors()
    draw_hud()
  end
end
