
max_actors = 64
actors = {}

function make_actor (k,x,y,d)
  local a = {
    k=k,
    frame=0,
    frames=1,
    life=1,
    x=x, y=y,
    vx=0, vy=0,
    ax=0, ay=0.05, -- gravity
    fx=0.99, fy=0.99, -- friction
    w=3/8, h=0.5, -- half-width
    d=d or -1, -- direction
    t=0,
    draw=draw_actor,
    update=update_actor,
  }

  -- attributes from actor_dat
  -- for k,v in pairs(actor_dat[k]) do
  --   a[k]=v
  -- end

  if (#actors < max_actors) then
    add(actors, a)
  end

  return a
end

function draw_actor (a)
  local fr = a.k
  fr += a.frame
  local sx = a.x*8-4
  local sy = a.y*8-8
  spr(fr, sx, sy, 1, 1, a.d < 0)
end

function draw_actors ()
  for a in all(actors) do
    a:draw()
  end
end

function update_actor (a)
  if (a.life <= 0) then
    del(actors,a)
    return
  end

  a.x += a.vx
  a.y += a.vy
  a.frame = (a.frame + abs(a.vx)*2) % a.frames

  -- gravity and friction
  a.vx += a.ax
  a.vx *= a.fx
  a.vy += a.ay
  a.vy *= a.fy

  -- counters
  a.t = a.t + 1
end

function update_actors ()
  for a in all(actors) do
    a:update()
  end
end

function collide (a1, a2, on_collide)
  if (not a1) return
  if (not a2) return
  if (a1 == a2) return

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
      collide(ai, aj, on_collide)
    end
  end
end
