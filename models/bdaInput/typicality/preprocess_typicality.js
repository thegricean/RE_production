var fs = require('fs');
var _ = require('lodash');
var refModule = require('../refModule');

// Convert data to json
// TODO: use raw data from ../../data/ here
// TODO: make sure original actually has a header...
var rawData = refModule.readCSV("./bda_data.csv"); 
fs.writeFileSync('./bda_data.json',
		 JSON.stringify(rawData, null, 2));

// Convert conditions to json with unified context field
// TODO: generate this from rawData by _.distinct()? 
var rawConditions = refModule.readCSV("./unique_conditions.csv"); 
var conditions = _.map(rawConditions, function(c) {
  return _.extend(c, {context: [
    {color: c.t_color, item: c.t_item},
    {color: c.d1_color, item: c.d1_item},
    {color: c.d2_color, item: c.d2_item}
  ]});
});

console.log(conditions);
fs.writeFileSync('./unique_conditions.json',
		 JSON.stringify(rawData, null, 2));
console.log("Constructing contexts complete...");
