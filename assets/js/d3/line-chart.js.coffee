class Fortune.LineChart
  constructor: (data) ->
    @data = data

  draw: ->
    margin = {top: 80, right: 80, bottom: 80, left: 80}
    width  = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    parse = d3.time.format("%Y-%m-%d").parse

    # Scales and axes. Note the inverted domain for the y-scale: bigger is up!
    x     = d3.time.scale().range([0, width])
    y     = d3.scale.linear().range([height, 0])
    xAxis = d3.svg.axis().scale(x).tickSize(-height).tickSubdivide(true)
    yAxis = d3.svg.axis().scale(y).ticks(4).orient("right")

    # An area generator, for the light fill.
    area = d3.svg.area()
           .interpolate("monotone")
           .x((d) -> return x(d.date))
           .y0(height)
           .y1((d) -> return y(d.price))
  
    # A line generator, for the dark stroke.
    line = d3.svg.line()
           .interpolate("monotone")
           .x((d) -> return x(d.date))
           .y((d) -> return y(d.price))
    
    # Compute the minimum and maximum date, and the maximum price.
    x.domain([@data[0].date, @data[@data.length - 1].date])
    y.domain([d3.min(@data, (d) -> return d.price),
              d3.max(@data, (d) -> return d.price)]).nice()
  
    # Add an SVG element with the desired dimensions and margin.
    svg = d3.select("#graph").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      .on("click", click)
  
    # Add the clip path.
    svg.append("clipPath")
      .attr("id", "clip")
      .append("rect")
      .attr("width", width)
      .attr("height", height)
    
    # Add the area path.
    svg.append("path")
      .attr("class", "area")
      .attr("clip-path", "url(#clip)")
      .attr("d", area(@data))
    
    # Add the x-axis.
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
    
    # Add the y-axis.
    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + width + ",0)")
      .call(yAxis)
    
    # Add the line path.
    svg.append("path")
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", line(@data))
    
    # Add a small label for the symbol name.
    svg.append("text")
      .attr("x", width - 6)
      .attr("y", height - 6)
      .style("text-anchor", "end")
      .text($("select").val() + " Chart")
    
    # On click, update the x-axis.
    click = ->
      n = @data.length - 1
      i = Math.floor(Math.random() * n / 2)
      j = i + Math.floor(Math.random() * n / 2) + 1

      x.domain([@data[i].date, @data[j].date])
      t = svg.transition().duration(750)
      t.select(".x.axis").call(xAxis)
      t.select(".area").attr("d", area(@data))
      t.select(".line").attr("d", line(@data))
