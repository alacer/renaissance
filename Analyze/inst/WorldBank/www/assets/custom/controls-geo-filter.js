


var axisf=function(){ return function(d){return Math.round(d*10)/10+"%";}};
var yearsf =function(){ return Math.round};

var config = {
  map: {
    leaflet: {
      url: "https://{s}.tiles.mapbox.com/v3/kseibel.j24pe78h/{z}/{x}/{y}.png",
      key: "pk.eyJ1Ijoia3NlaWJlbCIsImEiOiJZR3I3ekNnIn0.7rF28e0PJN4bu64sG0fsIw"
    },
    view: {
      center: [53.505, -2.09],
      zoom: 6
    },
    geo: {
      url: "assets/crosslet/data/world.topo.json",
      name_field: "NAME",
      id_field: "NAME",
      topo_object: "world"
    }
  },
  data: {
    version: "1.0",
    id_field: "country"
  },
  dimensions: {
    corruption: {
      title: "Corruption index",
      data: {
        colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "assets/crosslet/data/data.tsv",
        field: "corruption",

      },
      format: {
        short: function() {return Math.round},
        input: function() {return Math.round},

      }
      
    },  
    gdp: {
      title: "GDP per capita, $",
      data: {
        colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "assets/crosslet/data/data.tsv",
        field: "gdp",
        exponent:0.4,
        ticks: [2000,10000,25000,50000,80000]

      },
      format: {
        short: function(){return function(d) {return "$"+d3.format(",")(Math.round(d))}},

        input: function(){return Math.round},
        axis: function(){return function(d) {return "$"+Math.round(d/1000)+"k"}},

      }
    
    },  
    gini: {
      title: "Gini coefficient",
      data: {
        //colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "assets/crosslet/data/data.tsv",
        field: "gini"
      },
    },
    le: {
      title: "Life expectancy, years",
      data: {
        colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "assets/crosslet/data/data.tsv",
        field: "life_expectancy",
        exponent: 2.4
      },
      format:{
        short: function(dd) { return function(d){return Math.round(d)+" years"}},
        long: function(dd) { return function(d){return Math.round(d)+" years"}},
        input: function() {return Math.round},
        axis: function(dd) { return function(d){return Math.round(d)+"y"}},

      }
    },
    democracy: {
      title: "Democracy Index",
      data: {
        colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "assets/crosslet/data/data.tsv",
        field: "democracy_2011",
      },
    },  
           
  },
  defaults: {
    //colorscale: d3.scale.linear().domain([1, 10, 20]).range(["green", "yellow", "red"]).interpolate(d3.cie.interpolateLab),
    opacity: 0.9,
    order: ["corruption","gdp","le"],
    active: "corruption"
  },
};

console.log(config);
cross = new crosslet.MapView($("#map"),config);