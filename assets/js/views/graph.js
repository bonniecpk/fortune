$(function() { 
  var DailyRate = Backbone.Model.extend({});
  var dailyRate = new DailyRate({
    name:     "Daily Rate Object"
  });

  var DailyRateList = Backbone.Collection.extend({
    model: DailyRate,
    url:   '/api/v1/daily_rates/eur'
  });

  var rateList = new DailyRateList();
  rateList.fetch({success: function() { graphView.render(); }});

  var GraphView = Backbone.View.extend({
    render: function() {
      var data = rateList.map(function(rate, index) { 
        return { 
          price: rate.get('price'),
          date: index
          //date: rate.get('date')
        }
      });
      
      //this.$el.html(JST['jst/graph/daily']({data: data}));
      line_graph(data);
    }
  });

  var graphView = new GraphView({model: graph, el: $("#graph")});
});
