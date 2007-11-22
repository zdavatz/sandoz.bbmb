dojo.provide("ywesee.widget.ContentToggler");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.html");

ywesee.widget.ContentToggler = function() {
	dojo.widget.HtmlWidget.call(this);

	this.widgetType = "ContentToggler";
	this.templatePath = dojo.uri.dojoUri("../javascript/widget/templates/ContentToggler.html");

  this.css_class = 'toggler';
	this.togglee = '';
	this.message_open = '';
	this.message_close = '';
	this.status = '';
  this.duration = 1;

	this.toggleContent = function() {
    var tmp = this.status;
    if(tmp == 'change') return;
    this.status = 'change';
		if(tmp == 'open') {
			this.implode();
		}	else {
			this.explode();
		}
	}
	this.implode = function() { 
    var _this = this;
    var callback = function() {
      _this.toggler.innerHTML = _this.message_open;
		  _this.status = 'closed';
    };
		dojo.lfx.html.wipeOut(this.togglee, this.duration, 
                          dojo.lfx.easeOut, callback).play();
	}
	this.explode = function(){
    var _this = this;
    var callback = function() {
      _this.toggler.innerHTML = _this.message_close;
		  _this.status = 'open';
    };
		dojo.lfx.html.wipeIn(this.togglee, this.duration, 
                          dojo.lfx.easeOut, callback).play();
	}
	this.fillInTemplate = function() {
    if(this.status == 'closed') {
      this.implode();
    } else {
      this.toggler.innerHTML = this.message_close;
    }
    this.duration = 500;
    this.toggler.className = this.css_class;
	}
}


dojo.inherits(ywesee.widget.ContentToggler, dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:contenttoggler");

