var fs = require('fs');
var _ = require('lodash');
var babyparse = require('babyparse');
var lookupTable = require('../../refModule/json/nominal-labels.json');

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'),
			 {header:true, keepEmptyRows:false,     skipEmptyLines: true}).data;
};

var getConditions = function(c) {
  var newResponseName = (_.has(c, 'response') ?
			 {response: lookupTable[c.targetName][c.response]} :
			 {});
  return _.extend(c, newResponseName, {context: [
    {item: c.targetName},
    {item: c.alt1Name},
    {item: c.alt2Name}
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
