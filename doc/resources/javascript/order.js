function delete_position(url, evt, id)
{
  var form = document.createElement( "form" );
  form.action = url; 
  form.style.display = 'none';
  form.method = 'POST'
  var data = {
    "event": evt
  };
  data["quantity[" + id + "]"] = "0";
  for(var key in data) {
    var input = document.createElement( "input" );
    input.type = "hidden";
    input.name = key;
    input.value = data[key];
    form.appendChild(input);
  }
  document.body.appendChild(form);
  form.submit();
}

function update_order_callback(data)
{
	var name, input, value;
	for(name in data)
	{
		if(input = dojo.byId(name))
		{
			value = data[name];
			if(input.tagName == 'SPAN')
			{
				input.innerHTML = value;	
			}
			else
			{
				input.value = value;
			}
		}
	}
}

function update_order(url, form)
{
  var event = form.event.value;
  form.event.value = 'ajax';
	dojo.io.bind({
    encoding: "utf-8",
    url: url,
		formNode: form,
		load: function(type, data) { update_order_callback(data); },
		mimetype: "text/json"
	});
  form.event.value = event;
}

function zeroise(form) 
{
  for(name in form.elements) { 
    var node = form[name];
    if(node && typeof(node) == 'object' && node.tagName == 'INPUT' && node.type == 'text') {
      node.value = '0'; 
    }

  }
}
