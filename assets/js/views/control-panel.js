$(function() {
  var Currency = Backbone.Model.extend({});
  var CurrencyList = Backbone.Collection.extend({
    model: Currency,
    url:   '/api/v1/currencies'
  });

  var currencyList = new CurrencyList();
  currencyList.fetch({success: function() { controlPanelView.render(); }});

  var ControlPanelView = Backbone.View.extend({
    collection: currencyList,

    events: {
      'change select': 'changeCurrency'
    },

    changeCurrency: function() {
      graphView.render();
    },

    render: function() {
      var data = this.collection.map(function(c) {
        return {
          symbol: c.get('symbol'),
          name:   c.get('name')
        };
      });

      this.$el.html(JST['jst/control-panel']({currencies: data}));
    }
  });
  var controlPanelView = new ControlPanelView({el: $("#control-panel")});


  var GraphView = Backbone.View.extend({
    render: function() {
      var DailyRate = Backbone.Model.extend({});
      var DailyRateList = Backbone.Collection.extend({
        model: DailyRate,
          url:   '/api/v1/daily_rates/' + $("select").val()
      });

      var rateList = new DailyRateList();
      rateList.fetch({success: function(list) { 
        var data = list.map(function(rate) { 
          return { 
            price: rate.get('price'),
            date: d3.time.format("%Y-%m-%d").parse(rate.get('date'))
          }
        });

        new Fortune.LineChart(data).draw();
      }});
    }
  });

  var graphView = new GraphView({el: $("#graph")});
});
