var fs = require('fs');
var _ = require('lodash');
var refModule = require('../refModule');

var constructWholeContext = function(c) {
  var context = [];
  var sufficientdimension = c.condition.substring(0,c.condition.length-2);
  var numDistractors = c.condition.substring(c.condition.length-2,c.condition.length-1);
  var numShared = c.condition.substring(c.condition.length-1,c.condition.length);
  var numDiff = numDistractors - numShared;
  // var othersize = size === "big" ? "small" : "big";
  var othersize = "othersize";
  // var othercolor = "othercolor";    
  context.push(_.pick(c, ['size','color','item'])); //add the target to the context

  var buildUp = function(n,s,c,i) {
    var obj = {size: s,color: c, item: i};
    if (n == 1) {
      context.push(obj);
    } else {
      context.push(obj);
      buildUp(n-1,s,c,i);
    }
  };   

  if (sufficientdimension == "size") {
    buildUp(numShared,othersize,c.color,c.item);
    if (numDiff > 0) { buildUp(numDiff,othersize,c.othercolor,c.item); }
  } else {
    buildUp(numShared,c.size,c.othercolor,c.item);
    if (numDiff > 0) { buildUp(numDiff,othersize,c.othercolor,c.item); }
  }
  return _.extend(c, {context: context});
};

var data = refModule.readCSV("bda_data_colorsize_reduced.csv"); // loads data with 46 "other utterance" cases excluded
console.log(data);
//console.log("Loading data complete...",+data.length+" data points");

var conditions = refModule.readCSV("./unique_conditions_colorsize_reduced.csv"); // loads unique conditions with 46 "other utterance" cases excluded
console.log("Loading unique conditions complete..."+conditions.length+" conditions");

var contexts = _.map(conditions, function(condition) {
  return constructWholeContext(condition);
});

console.log(contexts);
console.log("Constructing contexts complete...");
fs.writeFileSync('./bda_data_colorsize_reduced.json',
		 JSON.stringify(data, null, 2));
