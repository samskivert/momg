
max_particles = 64
actors = {}
particles = {}

function new_actor (k, x, y, d)
  return {
    k=k,
    frame=0,
    frames=1,
    anim=anim_by_vel,
    life=1,
    dlife=0,
    x=x, y=y,
    vx=0, vy=0,
    ax=0, ay=0,
    fx=0.99, fy=0.99,
    w=3/8, h=0.5, -- half-width
    d=d or -1, -- direction
    t=0,
    move=move_actor,
    draw=draw_actor,
  }
end

function anim_by_vel (a)
  a.frame = (a.frame + abs(a.vx)*2) % a.frames
end

function anim_by_time (a)
  a.frame = (a.frame + a.dframe) % a.frames
end

function make_actor (k, x, y, d)
  local a = new_actor(k, x, y, d)
  a.table = actors
  add(actors, a)
  return a
end

function make_particle (k, x, y, d)
  local p = new_actor(k, x, y, d)
  p.table = particles
  p.anim=anim_by_time
  p.dframe=1
  if (#particles < max_particles) add(particles, p)
  return p
end

function make_text (text, x, y, color)
  local a = new_actor(0, x, y, 1)
  a.table = particles
  a.text = text
  a.draw = draw_text
  a.color = color or 7 -- default to white
  add(particles, a)
  return a
end

function draw_actor (a)
  local fr = a.k
  fr += a.frame
  local sx = a.x*8-4
  local sy = a.y*8-8
  spr(fr, sx, sy, 1, 1, a.d < 0)
end

function draw_text (a)
  local wid = #(a.text)*4
  local sx = a.x*8-wid/2
  local sy = a.y*8-8
  -- fade out on the last four frames (TODO: support custom colors/palettes?)
  local color = a.color
  if (a.life < 2) then
    color -= 2
  elseif (a.life < 4) then
    color -= 1
  end
  print(a.text, sx, sy, color)
end

function draw_actors ()
  for a in all(actors) do
    a:draw()
  end
  for p in all(particles) do
    p:draw()
  end
end

function move_actor (a)
  a.x += a.vx
  a.y += a.vy
  a.vx += a.ax
  a.vx *= a.fx
  a.vy += a.ay
  a.vy *= a.fy
end

function update_actor (a)
  if (a.life <= 0) then
    del(a.table, a)
  else
    a.life -= a.dlife
    a.t = a.t + 1
    a:move()
    a:anim()
  end
end

function update_actors ()
  foreach(actors, update_actor)
  foreach(particles, update_actor)
end

function check_collide (a1, a2, on_collide)
  if (a1 == a2) return
  if (not a1 or a1.life <= 0) return
  if (not a2 or a2.life <= 0) return

  local dx = a1.x - a2.x
  local dy = a1.y - a2.y
  if (abs(dx) < a1.w + a2.w) then
    if (abs(dy) < a1.h + a2.h) then
      on_collide(a1, a2)
      on_collide(a2, a1)
    end
  end
end

function collide_actors (on_collide)
  for i=1, #actors do
    local ai = actors[i]
    for j=i+1, #actors do
      local aj = actors[j]
      check_collide(ai, aj, on_collide)
    end
  end
end
