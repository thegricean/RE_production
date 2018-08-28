var fs = require('fs');
var _ = require('lodash');
var babyparse = require('babyparse');

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'),
			 {header:true, keepEmptyRows:false,     skipEmptyLines: true}).data;
};

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

// TODO: read in from raw data
var data = readCSV("./bda_data.csv");
var data_with_contexts = _.map(data, function(datum) {
  return constructWholeContext(datum);
});

fs.writeFileSync('./bda_data.json',
		 JSON.stringify(data_with_contexts, null, 2));

// TODO: create from raw data?
var conditions = readCSV("./unique_conditions.csv");
var contexts = _.map(conditions, function(condition) {
  return constructWholeContext(condition);
});
fs.writeFileSync('./unique_conditions.json',
		 JSON.stringify(contexts, null, 2));
