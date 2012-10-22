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
	self.timeStep = 1/60

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
			bodyDef.angle = math.rad(object:getRotation())
		end
	end
	
	local body = self.world:createBody(bodyDef)
	body.type = bodyDef.type
	
	if object then
		body.object = object
		object.body = body
		
		self.bodies[#self.bodies+1] = body
		
		-- TODO link Body's methods to Sprite
		object.set = function(self, param, value)
			if param == "x" then
				local x, y = self.body:getPosition()
				self.body:setPosition(value, y)
			elseif param == "y" then
				local x, y = self.body:getPosition()
				self.body:setPosition(x, value)
			elseif param == "rotation" then
				self.body:setRotation(math.rad(value))
			else
				Sprite.set(self, param, value)
			end
		end
		
		object.setX = function(self, x)
			local _, y = self.body:getPosition()
			self.body:setPosition(x, y)
		end
		
		object.setY = function(self, y)
			local x, _ = self.body:getPosition()
			self.body:setPosition(x, y)
		end
		
		object.setPosition = function(self, x, y)
			self.body:setPosition(x, y)
		end
		
		object.setRotation = function(self, rotation)
			self.body:setRotation(math.rad(rotation))
		end
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
		if fixtures[i].filter ~= nil then fixtureDef.filter = fixtures[i].filter end
		
		local id = "";
		if fixtures[i].id ~= nil then id = fixtures[i].id end
		
		if fixtures[i].shape then
			local shapeDef = fixtures[i].shape
			local shape = nil
			local fixture = nil
			
			if shapeDef.type == "box" then
				if shapeDef.center == nil then shapeDef.center = {x=0, y=0} end
				if shapeDef.angle == nil then shapeDef.angle = 0 end
				shape = b2.PolygonShape.new()
				shape:setAsBox(shapeDef.width*.5, shapeDef.height*.5, shapeDef.center.x, shapeDef.center.y, shapeDef.angle)
				fixtureDef.shape = shape
				fixture = body:createFixture(fixtureDef)
				fixture.id = id
			elseif shapeDef.type == "circle" then
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
				-- TODO
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
	
	-- TODO link Sprite's methods to Body
	body.get = function(self, param)
		if param == "x" then
			local x,y = body:getPosition()
			return x
		elseif param == "y" then
			local x,y = body:getPosition()
			return y
		elseif param == "rotation" then
			return math.deg(body:getAngle())
		end
	end
	
	body.set = function(self, param, value)
		if param == "x" then
			local x,y = body:getPosition()
			body:setPosition(value, y)
		elseif param == "y" then
			local x,y = body:getPosition()
			body:setPosition(x, value)
		elseif param == "rotation" then
			body:setAngle(math.rad(value))
		end
	end
	
	body.getType = function(self)
		return body.type
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
	
	--  TODO revert to original methods
	body.object.set = Sprite.set(self, param, value)
	object.setX = Sprite.setX(self, x)
	object.setY = Sprite.setY(self, y)
	object.setPosition = Sprite.setPosition(self, x, y)
	object.setRotation = Sprite.setRotation(self, rotation)
	
	self.world:destroyBody(body)
	
	body = nil
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
	
	arg = nil
end

-- set debugDraw
function Physics:setDebugDraw(parent)
	if parent == nil then parent = self.scene end
	
	self.debugDraw = b2.DebugDraw.new()
	parent:addChild(self.debugDraw)
	
	self.world:setDebugDraw(self.debugDraw)
end

-- get debugDraw
function Physics:getDebugDraw()
	return self.debugDraw
end

-- set debugDraw flag
function Physics:setDebugFlag(flag)
	if flag ~= nil then
		self.debugDraw:setFlags(flag)
	end
end

-- get time step
function Physics:getTimeStep()
	return self.timeStep
end

-- set time step
function Physics:setTimeStep(timeStep)
	self.timeStep = timeStep
end

-- run physics simulation
-- automatically called when physics object initialized
function Physics:run()
	self.world:step(self.timeStep, 8, 3)
	for i = 1, #self.bodies do
		Sprite.setPosition(self.bodies[i].object, self.bodies[i]:getPosition())
		Sprite.setRotation(self.bodies[i].object, self.bodies[i]:getAngle() * 180 / math.pi)
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