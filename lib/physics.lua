--[[

 Bismillahirahmanirrahim
 
 Box2D physics wrapper for Gideros
 by: Edwin Zaniar Putra (zaniar@nightspade.com)

 This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
 Copyright © 2012 Nightspade (http://nightspade.com).
 
--]]

Physics = gideros.class()

function Physics:init(scene, gx, gy, doSleep)
	self.scene = scene

	self.world = b2.World.new(gx, gy, doSleep)
	self.bodies = {}
	
	self.scene:addEventListener(Event.REMOVED_FROM_STAGE, self.stop, self)
end

-- add new body
function Physics:addBody(object, bodyDef, fixtures)
	local object = object
	local bodyDef = bodyDef or {}
	local fixtures = fixtures
	
	if object then
		if bodyDef.position == nil then
			bodyDef.position = {x = object:getX(), y = object:getY()}
		end
		if bodyDef.angle == nil then
			bodyDef.angle = object:getRotation() * math.pi / 180
		end
	end
	
	local body = self.world:createBody(bodyDef)
	
	if object then
		body.object = object
		object.body = body
		
		self.bodies[#self.bodies+1] = body
	end
	
	if fixtures.density or fixtures.friction or fixtures.restitution or fixtures.isSensor or fixtures.shape then
		fixtures = {fixtures}
	end

	for i = 1, #fixtures do
		local fixtureDef = {}
		if fixtures[i].density ~= nil then fixtureDef.density = fixtures[i].density end
		if fixtures[i].friction ~= nil then fixtureDef.friction = fixtures[i].friction end
		if fixtures[i].restitution ~= nil then fixtureDef.restitution = fixtures[i].restitution end
		if fixtures[i].isSensor ~= nil then fixtureDef.isSensor = fixtures[i].isSensor end
		
		local id = "";
		if fixtures[i].id ~= nil then id = fixtures[i].id end
		
		if fixtures[i].shape then
			local shapeDef = fixtures[i].shape
			local shape = nil
			local fixture = nil
			
			if shapeDef.type == "circle" then
				if shapeDef.center == nil then shapeDef.center = {x=0, y=0} end
				shape = b2.CircleShape.new(shapeDef.center.x, shapeDef.center.y, shapeDef.radius)
				fixtureDef.shape = shape
				fixture = body:createFixture(fixtureDef)
				fixture.id = id
			elseif shapeDef.type == "polygon" then
				for i = 1, #shapeDef.polygons do
					shape = b2.PolygonShape.new()
					shape:set(unpack(shapeDef.polygons[i]))
					fixtureDef.shape = shape
					fixture = body:createFixture(fixtureDef)
					fixture.id = id
				end
			elseif shapeDef.type == "edge" then
			elseif shapeDef.type == "chain" then
				shape = b2.ChainShape.new()
				shape:createChain(unpack(shapeDef.vertices))
				fixtureDef.shape = shape
				fixture = body:createFixture(fixtureDef)
				fixture.id = id
			elseif shapeDef.type == "loop" then
				shape = b2.ChainShape.new()
				shape:createLoop(unpack(shapeDef.vertices))
				fixtureDef.shape = shape
				fixture = body:createFixture(fixtureDef)
				fixture.id = id
			end
		end
	end
	
	body.get = function(self, param)
		if param == "x" then
			local x,y = body:getPosition()
			return x
		elseif param == "y" then
			local x,y = body:getPosition()
			return y
		end
	end
	
	body.set = function(self, param, value)
		if param == "x" then
			local x,y = body:getPosition()
			body:setPosition(value, y)
		elseif param == "y" then
			local x,y = body:getPosition()
			body:setPosition(x, value)
		end
	end
	
	return body
end

-- remove body
function Physics:removeBody(arg)
	local body = nil
	
	if arg.body then
		body = arg.body
	elseif arg.object then
		body = arg
	end
	
	for i = 1, #self.bodies do
		if self.bodies[i] == body then
			table.remove(self.bodies, i)
			break
		end
	end
	
	self.world:destroyBody(body)
end

-- load fixtures definition from file
function Physics.loadFixtures(path)
	local loader = loadfile(path)
	return loader()
end

-- add new joint
function Physics:addJoint(jointDef)
	return self.world:createJoint(jointDef)
end

-- remove joint
function Physics:removeJoint(arg)
	self.world:destroyJoint(arg)
end

-- set debugDraw
function Physics:setDebugDraw(flag)
	self.debugDraw = b2.DebugDraw.new()
	if flag ~= nil then
		self.debugDraw:setFlags(flag)
	end
	self.scene:addChild(self.debugDraw)
	
	self.world:setDebugDraw(self.debugDraw)
end

-- get debugDraw
function Physics:getDebugDraw()
	return self.debugDraw
end

-- run physics simulation
-- automatically called when physics object initialized
function Physics:run()
	self.world:step(1/60, 8, 3)
	for i = 1, #self.bodies do
		self.bodies[i].object:setPosition(self.bodies[i]:getPosition())
		self.bodies[i].object:setRotation(self.bodies[i]:getAngle() * 180 / math.pi)
	end
end

-- start physics simulation
function Physics:start()
	self.scene:addEventListener(Event.ENTER_FRAME, self.run, self)
end

-- pause physics simulation
function Physics:pause()
  self.scene:removeEventListener(Event.ENTER_FRAME, self.run, self)
end

-- stop physics simulation
function Physics:stop()
  self.scene:removeEventListener(Event.ENTER_FRAME, self.run, self)
end