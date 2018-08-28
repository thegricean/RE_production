var fs = require('fs');
var _ = require('lodash');
var babyparse = require('babyparse');

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'),
			 {header:true, keepEmptyRows:false,     skipEmptyLines: true}).data;
};

var getConditions = function(c) {
  return _.extend(c, {context: [
    {color: c.t_color, item: c.t_item},
    {color: c.d1_color, item: c.d1_item},
    {color: c.d2_color, item: c.d2_item}
  ]});
};

// Convert data to json
var rawData = readCSV("./bda_data.csv");
var data = _.map(rawData, getConditions);
fs.writeFileSync('./bda_data.json',
		 JSON.stringify(data, null, 2));

// Convert conditions to json with unified context field
// TODO: generate this from rawData by _.distinct()? 
var rawConditions = readCSV("./unique_conditions.csv"); 
var conditions = _.map(rawConditions, getConditions);
console.log(conditions);
fs.writeFileSync('./unique_conditions.json',
		 JSON.stringify(conditions, null, 2));
console.log("Constructing contexts complete...");
