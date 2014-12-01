
function d3mapXbrushFn() {
   var curBrush = d3mapXbrush.empty() ? "" : d3mapXbrush.extent();
   var prec = d3.format(".5r");
   if(curBrush == "") {
      $("#mapFilterPlotRange").text("");
      // make sure filter icon is hidden
      $("#mapFilterSelect li.active i").addClass("hidden");
   } else {
      $("#mapFilterPlotRange").text(prec(curBrush[0]) + " to " + prec(curBrush[1]));
      // show filter icon
      if(curBrush[0] != curBrush[1])
         $("#mapFilterSelect li.active i").removeClass("hidden");
   }
}

function d3mapYbrushFn() {
   var curBrush = d3mapYbrush.empty() ? "" : d3mapYbrush.extent();
   var prec = d3.format(".5r");
   if(curBrush == "") {
      $("#mapFilterPlotRange").text("");
      // make sure filter icon is hidden
      $("#mapFilterSelect li.active i").addClass("hidden");
   } else {
      $("#mapFilterPlotRange").text(prec(curBrush[0]) + " to " + prec(curBrush[1]));
      // show filter icon
      if(curBrush[0] != curBrush[1])
         $("#mapFilterSelect li.active i").removeClass("hidden");
   }
}

var d3mapMargin = {top: 10, right: 10, bottom: 60, left: 60},
    d3mapWidth = 585 - d3mapMargin.left - d3mapMargin.right,
    d3mapHeight = 440 - d3mapMargin.top - d3mapMargin.bottom;

var d3mapX = d3.scale.linear()
    .range([0, d3mapWidth]);

var d3mapY = d3.scale.linear()
    .range([d3mapHeight, 0]);

var d3mapXaxis = d3.svg.axis()
    .scale(d3mapX)
    .orient("bottom");

var d3mapYaxis = d3.svg.axis()
    .scale(d3mapY)
    .orient("left");

var d3mapXbrush = d3.svg.brush()
    .x(d3mapX)
    .on("brush", d3mapXbrushFn);

var d3mapYbrush = d3.svg.brush()
    .y(d3mapY)
    .on("brush", d3mapYbrushFn);

function d3map(data, id) {
   
   var plotType = data.plotType[0];
   var xlab = data.name[0];
   var ylab = "Frequency";
   var yAxisOffset = -45;
   if(plotType == "quant") {
      ylab = data.name[0];
      xlab = "f-value";
   } else if(plotType == "bar") {
      ylab = data.name[0];
      xlab = "Frequency";
      yAxisOffset = -20;
   }
   
   data = data.data;
   
   $("#" + id).html("");
   $("#" + id).append("<div id=\"" + id + "Range\" class=\"filterRange\"></div>");
   
   var svg = d3.select("#" + id).append("svg:svg")
       .attr("width", d3mapWidth + d3mapMargin.left + d3mapMargin.right)
       .attr("height", d3mapHeight + d3mapMargin.top + d3mapMargin.bottom)
     .append("g")
       .attr("transform", "translate(" + d3mapMargin.left + "," + d3mapMargin.top + ")");
   
   // if there is a filter for this variable
   // we will use that to make sure the extent of the axes
   // reaches far enough
   activeVar = $("#mapFilterSelect li.active");
   var filter;
   if(activeVar) {
      var filterData = $("#mapFilterState").data("filterData");
      if(!filterData)
         filterData = {};
      var varName = activeVar.data("name");
      filter = filterData[varName];
   }
   
   if(plotType == "hist") {
      var delta = data[1].xdat - data[0].xdat;
      
      var xrange = d3.extent(data.map(function(d) { return d.xdat; }));
      xrange[0] = xrange[0] - (xrange[1] - xrange[0]) * 0.07;
      xrange[1] = xrange[1] + (xrange[1] - xrange[0]) * 0.07;
      
      if(filter != undefined) {
         xrange[0] = Math.min(xrange[0], filter.from);
         xrange[1] = Math.max(xrange[1], filter.to);
      }
      
      d3mapX.domain(xrange);
      d3mapY.domain([0, d3.max(data.map(function(d) { return d.ydat; }))]);
      
      svg.selectAll(".bar")
         .data(data)
        .enter().append("rect")
         .attr("class", "bar")
         .attr("x", function(d) { return d3mapX(d.xdat); })
         .attr("width", d3mapX(delta) - d3mapX(0) - 0.75)
         .attr("y", function(d) { return d3mapY(d.ydat); })
         .attr("height", function(d) { return d3mapHeight - d3mapY(d.ydat); });
      
      svg.append("g")
         .attr("class", "x brush")
         .call(d3mapXbrush)
       .selectAll("rect")
         .attr("y", -6)
         .attr("height", d3mapHeight + 7);
            
   } else if(plotType == "quant") {
      var xrange = d3.extent(data.map(function(d) { return d.x; }));
      xrange[0] = xrange[0] - (xrange[1] - xrange[0]) * 0.07;
      xrange[1] = xrange[1] + (xrange[1] - xrange[0]) * 0.07;
      
      var yrange = d3.extent(data.map(function(d) { return d.y; }));
      yrange[0] = yrange[0] - (yrange[1] - yrange[0]) * 0.07;
      yrange[1] = yrange[1] + (yrange[1] - yrange[0]) * 0.07;
      
      if(filter != undefined) {
         yrange[0] = Math.min(yrange[0], filter.from);
         yrange[1] = Math.max(yrange[1], filter.to);
      }
      
      d3mapX.domain(xrange);
      d3mapY.domain(yrange);
      
      svg.selectAll(".points")
         .data(data)
        .enter().append("svg:circle")
         .attr("class", "map-points")
         // .style("fill", function(d){ return d.color; })
         .attr("r", function(d) { return 4; })
         .attr("cx", function(d) { return d3mapX(d.x); })
         .attr("cy", function(d) { return d3mapY(d.y); });
      
      svg.append("g")
         .attr("class", "y brush")
         .call(d3mapYbrush)
       .selectAll("rect")
         .attr("x", 0)
         .attr("width", d3mapWidth);
   } else if(plotType == "bar") {
      // remove last dummy record
      data.pop();
      
      var delta = data[1].ind - data[0].ind;
      
      d3mapX.domain([0, d3.max(data.map(function(d) { return d.Freq; }))]);
      var yMax = d3.max(data.map(function(d) { return d.ind; }));
      d3mapY.domain([0, yMax]);
      
      // console.log(data);
      // console.log(d3mapY.domain);
      // console.log(d3mapX.domain);
      
      function hasClass(el, cls) {
         return($(el).attr("class").split(/\s/).indexOf(cls) >= 0)
      }
      
      var isMouseDown = false, isSelected;
            
      // svg.selectAll("*").remove();
      svg.selectAll(".bar")
         .data(data)
        .enter().append("rect")
         .attr("class", "mapfilter-bar")
         .attr("x", function(d) { return 0; })
         .attr("width", function(d) { return d3mapX(d.Freq); })
         .attr("y", function(d) { return d3mapY(yMax + 1 - d.ind); })
         .attr("height", d3mapY(0) - d3mapY(delta) - 2)
         .on("mouseover", function() {
            if(isMouseDown) {
               d3.select(this).classed("selected", isSelected);
               // change filter icon if more than one is selected
               if(d3.selectAll("#mapFilterPlot svg rect.selected")[0].length > 0) {
                  $("#mapFilterSelect li.active i").removeClass("hidden");
               } else {
                  $("#mapFilterSelect li.active i").addClass("hidden");
               }
            } else {
               d3.select(this).classed("hover", true);
            }
         })
         .on("mouseout", function() {
            d3.select(this).classed("hover", false);
         })
         .on("mousedown", function() {
            isMouseDown = true;
            if(hasClass(this, "selected")) {
               d3.select(this).classed("selected", false);
            } else {
               d3.select(this).classed("selected", true);
            }
            // change filter icon if more than one is selected
            if(d3.selectAll("#mapFilterPlot svg rect.selected")[0].length > 0) {
               $("#mapFilterSelect li.active i").removeClass("hidden");
            } else {
               $("#mapFilterSelect li.active i").addClass("hidden");
            }
            isSelected = d3.select(this).classed("selected");
         })
         .on("mouseup", function() {
            isMouseDown = false;
         });

      // svg.selectAll("text").remove();
      svg.append("g")
         .attr("class", "bar-labels")
         .selectAll(".text")
         .data(data)
        .enter().append("text")
         .attr("class", "mapfilter-bar-text")
         .attr("x", function(d) { return 10; })
         .attr("y", function(d) { return d3mapY(yMax + 1 - d.ind - delta / 2) + 4; })
         .text(function(d) { return d.label; });
   }
   
   svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + d3mapHeight + ")")
      .call(d3mapXaxis);
   
   svg.append("text")
      .attr("class", "axis-label")
      .attr("text-anchor", "middle")
      .attr("transform", "translate(" + (d3mapWidth / 2) + "," + (d3mapHeight + 50) + ")")
      .text(xlab);
   
   if(plotType != "bar") {
      svg.append("g")
         .attr("class", "y axis")
         .call(d3mapYaxis);      
   }
   svg.append("text")
      .attr("class", "axis-label")
      .attr("text-anchor", "middle")
      .attr("transform", "translate(" + yAxisOffset + "," + (d3mapHeight / 2) + ")rotate(-90)")
      .text(ylab);
      
}



// // if the update button is clicked, change the values of the lower and upper inputs and trigger a change
// $(document).on("click", "#mapFilterPlotSubmit", function(evt) {
//    var curRange = d3mapXbrush.empty() ? "" : d3mapXbrush.extent();
//    
//    if(curRange != "") {
//       // clear out all columns
//       // (this currently doesn't operate as a marginal filter)
//       $(".columnFilterFrom,.columnFilterTo").each(function() { 
//          $(this).val(""); $(this).trigger("change"); 
//       })
//       
//       // get the current column
//       var el = $(evt.target);
//       var column = el.attr("name");
//       
//       console.log("column" + column);
//       
//       // trigger a change on the appropriate range
//       $("#lower_column_" + column).val(curRange[0]);
//       $("#upper_column_" + column).val(curRange[1]);
//       $("#lower_column_" + column).trigger("change");
//       $("#upper_column_" + column).trigger("change");
//       updated3footHist(column);
//    }
//    
//    d3mapXbrush.clear()
// });
// 
// 
