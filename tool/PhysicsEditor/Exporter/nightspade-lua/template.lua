return {{% for body in bodies %}
    {{body.name}} = {{% for fixture in body.fixtures %}
		{
			id = "{{fixture.id}}",
		    density = {{fixture.density}},
            friction = {{fixture.friction}},
            restitution = {{fixture.restitution}},
            isSensor = {% if fixture.isSensor %}true{% else %}false{% endif %},
{% if fixture.isCircle %}
			shape = {
				type = "circle",
				radius = {{fixture.radius|floatformat:3}},
				center = {x = {{fixture.center.x|floatformat:3}}, y = {{fixture.center.y|floatformat:3}}}
			}
		{%else%}
			shape = {
				type = "polygon",
				polygons = {{% for polygon in fixture.polygons %}
					{{% for point in polygon %} {% if not forloop.first %}, {% endif %}{{point.x}}, {{point.y}} {% endfor %}}{% if not forloop.last %},{% endif %}{% endfor %}
				}
			}
		{% endif %}}{% if not forloop.last %},{% endif %}{% endfor %}
	}{% if not forloop.last %}, {% endif %}
{% endfor %}
}