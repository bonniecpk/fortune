$(function() { 
  var ControlPanel = Backbone.Model.extend({});
  var controlPanel = new ControlPanel({name: "Control Panel"});

  var ControlPanelView = Backbone.View.extend({
    render: function() {
      this.$el.html(JST['jst/control-panel']());
    }
  });

  var controlPanelView = new ControlPanelView({model: controlPanel, el: $("#control-panel")});
  controlPanelView.render();
});
