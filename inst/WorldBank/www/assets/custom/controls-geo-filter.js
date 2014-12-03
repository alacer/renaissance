var axisf=function(){ return function(d){return Math.round(d*10)/10+"%";}};

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
      url: "world.topo.json",
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
        dataSet: "data.csv",
        field: "corruption"
      },
      
    },  
    gdp: {
      title: "GDP per capita, $",
      data: {
        colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "data.csv",
        field: "gdp"
      },
    
    },  
    gini: {
      title: "Gini coefficient",
      data: {
        //colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "data.csv",
        field: "gini"
      },
    },
    le: {
      title: "Life expectancy",
      data: {
        colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "data.csv",
        field: "life_expectancy"
      },
    },
    democracy: {
      title: "Democracy Index",
      data: {
        colorscale: d3.scale.linear().domain([1, 10, 20]).range([ "red", "yellow","green"]).interpolate(d3.cie.interpolateLab),
        dataSet: "data.csv",
        field: "democracy_2011",
      },
    },  
           
  },
  defaults: {
    //colorscale: d3.scale.linear().domain([1, 10, 20]).range(["green", "yellow", "red"]).interpolate(d3.cie.interpolateLab),
    opacity: 0.9,
    order: ["democracy","corruption","gdp","gini","le"],
    active: "corruption"
  },
};
      console.log(config);
      new crosslet.MapView($("#map"),config);