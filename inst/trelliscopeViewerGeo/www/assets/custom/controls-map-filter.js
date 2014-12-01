function updateMapPlot() {
   // remove gray background and restart spinner
   $("#mapFilterPlot").addClass("not");
   var target = document.getElementById("mapFilterPlot");
   mapSpinner.stop(target);
   mapSpinner.spin(target);

   // set data to be currently-selected variable, hist/quant, and marg/cond
   // then trigger the shiny input$mapFilterSelect to get this data
   // the input will be used to get plot data and trigger plot output
   var dat = {
      "distType" : $("#mapDistType .active").data("dist-type"),
      "plotType" : $("#mapPlotType .active").html().toLowerCase(),
      "varName"  : $("#mapFilterSelect li.active .map-filter-var-name").html()
   };
   $("#mapFilterSelect").data("myShinyData", dat);
   $("#mapFilterSelect").trigger("change");
}

function removeMapPlot() {
   // first remove the plot
   $("#mapFilterPlot").html("");
   
   // set data to emtpy and trigger change
   $("#mapFilterSelect").data("myShinyData", null);
   $("#mapFilterSelect").trigger("change");
   
   // add gray background, stop spinner (if running)
   $("#mapFilterPlot").removeClass("not");
   var target = document.getElementById("mapFilterPlot");
   mapSpinner.stop(target);
}

mapFilterLocalSave = function() {
   activeVar = $("#mapFilterSelect li.active");
   if(activeVar.length > 0) {
      var filterData = $("#mapFilterState").data("filterData");
      if(!filterData)
         filterData = {};
      
      var varName = activeVar.data("name");
      
      if(activeVar.data("type") == "numeric") {
         if($("#mapPlotType button.histogram-button").hasClass("active")) {
            var curBrush = d3mapXbrush;
         } else {
            var curBrush = d3mapYbrush;
         }
         
         if(!curBrush.empty()) {
            var filter = curBrush.extent();
            if(!filterData[varName])
               filterData[varName] = {};
            filterData[varName] = { from: filter[0], to: filter[1]};
            // console.log(filterData);
         } else {
            // remove the element
            delete filterData[varName];
         }
      } else {
         if(!filterData[varName])
            filterData[varName] = {};
         
         var res = [];
         d3.selectAll("#mapFilterPlot svg rect.selected").each(function(d) {
            res.push(d.label);
         });
         if(res.length > 0) {
            filterData[varName]["select"] = res;            
         } else {
            delete filterData[varName];
         }
      }
      $("#mapFilterState").data("filterData", filterData);
   }
}

mapFilterLocalLoad = function() {
   activeVar = $("#mapFilterSelect li.active");
   if(activeVar) {
      var filterData = $("#mapFilterState").data("filterData");
      if(!filterData)
         filterData = {};
      var varName = activeVar.data("name");
      var filter = filterData[varName];
      // console.log(filter);
      
      if(activeVar.data("type") == "numeric") {
         // filter is stored as {from: , to:} - make it array
         if($("#mapPlotType button.histogram-button").hasClass("active")) {
            if(filter) {
               var dm = d3mapX.domain();
               if(filter.from == undefined)
                  filter.from = dm[0];
               if(filter.to == undefined)
                  filter.to = dm[1];
               filter = [filter.from, filter.to];
               d3.select("#mapFilterPlot")
                  .select(".brush")
                  .call(d3mapXbrush.extent(filter));
               d3mapXbrushFn();
            } else {
               d3.select("#mapFilterPlot")
                  .select(".brush")
                  .call(d3mapXbrush.clear());
               d3mapXbrushFn();
            }
         } else { // quantile
            if(filter) {
               filter = [filter.from, filter.to];
               d3.select("#mapFilterPlot")
                  .select(".brush")
                  .call(d3mapYbrush.extent(filter));
               d3mapYbrushFn();
            } else {
               d3.select("#mapFilterPlot")
                  .select(".brush")
                  .call(d3mapYbrush.clear());
               d3mapYbrushFn();
            }
         }
      } else {
         // highlighted selected bars in barchart
         if(filter) {
            if(filter["select"]) {
               d3.selectAll("#mapFilterPlot svg rect").attr("class", function(d) {
                  if($.inArray(d.label, filter["select"]) >= 0 && !filter["empty"]) {
                     return("mapfilter-bar selected");
                  } else {
                     return("mapfilter-bar");
                  }
               });               
            }
         }
      }
   }
}

function cogMapFilterControlsOutputApplyButton() {
   // reset to page one
   $("#curPanelPageInput").val("1");
   $("#curPanelPageInput").trigger("change");
   
   // trigger save in case currently-active filter hasn't been saved
   mapFilterLocalSave();
   // trigger change
   var filterData = $("#mapFilterState").data("filterData");
   $("#filterStateInput").data("myShinyData", filterData);
   $("#filterStateInput").trigger("change");
   
   $("#mapFilterSelect li").removeClass("active");
   removeMapPlot();
}

function cogMapFilterControlsOutputCancelButton() {
   mapFilterSetFromExposedState();
}

function mapFilterSetFromExposedState() {
   // trigger save in case currently-active filter hasn't been saved
   mapFilterLocalSave();
   
   // for testing:
   // make a copy of filter data
   // var filterData = jQuery.extend(true, {}, $("#univarFilterState").data("filterData"));
   // var state = {};
   // state["filter"] = filterData;
   // $("#exposedStateDataOutput").data("myShinyData", state);
   
   // get state data
   // make it a copy so it doesn't edit the exposed state data
   var state = jQuery.extend(true, {}, $("#exposedStateDataOutput").data("myShinyData"));
   
   if(!state.filter) {
      state.filter = null;
   }
   
   // deactivate all
   $("#mapFilterSelect li").removeClass("active");
   // remove all filter icons
   $("#mapFilterSelect li i").addClass("hidden");      
   
   if(state.filter) {
      // set filter icons for those in state
      $.each(state.filter, function(key, value) {
         $("#map-var-" + key + " i").removeClass("hidden");
      });
   }
   
   // remove plot
   removeMapPlot();
   // set state data
   $("#mapFilterState").data("filterData", state.filter);
}

function cogMapFilterControlsOutputPostRender() {
   $(".list-group").on("click", "a", function() {
      $(this).toggleClass("selected").siblings().removeClass("selected");
   });
   
   // add tooltips
   $("#mapFilterSelect li").each(function() {
      $(this).tooltip({'placement': 'right', 'delay': { show: 500, hide: 100 }});
   });
   
   buttonToggleHandler();
   
   $("#mapFilterSelect li").click(function(e) {

      // first save the filter state of the current one
      mapFilterLocalSave();
      
      if(!$(this).hasClass("active")) {
         // make selected item active and all others not
         $(this).toggleClass("active");
         $(this).siblings().removeClass("active");
         
         // make sure the appropriate distribution type buttons are enabled
         var buttons = $("#mapPlotType");
         if($(this).data("type") == "numeric") {
            // only change them if we need to
            if(buttons.find("button.histogram-button.active,button.quantile-button.active").length == 0) {
               buttons.find("button.quantile-button")
                  .prop("disabled", false)
                  .addClass("active")
                  .removeClass("btn-default")
                  .addClass("btn-info");
               buttons.find("button.histogram-button")
                  .prop("disabled", false)
                  .removeClass("active")
                  .removeClass("btn-info").addClass("btn-default");
               buttons.find("button.bar-button")
                  .prop("disabled", true)
                  .removeClass("active")
                  .removeClass("btn-info").addClass("btn-default");               
            }
         } else {
            buttons.find("button.histogram-button")
               .prop("disabled", true)
               .removeClass("active")
               .removeClass("btn-info")
               .addClass("btn-default");
            buttons.find("button.quantile-button")
               .prop("disabled", true)
               .removeClass("active")
               .removeClass("btn-info")
               .addClass("btn-default");
            buttons.find("button.bar-button")
               .prop("disabled", false)
               .addClass("active")
               .addClass("btn-info")
               .removeClass("btn-default");
         }
         
         updateMapPlot();
      } else {
         // at this point there should be nothing selected and no plot
         $(this).removeClass("active");
         removeMapPlot();
      }
   });
}