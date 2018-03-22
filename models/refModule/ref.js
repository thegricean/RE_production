var _ = require('lodash');
var fs = require('fs');
var babyparse = require('babyparse');

var powerset = function (set) {
  if (set.length == 0)
    return [[]];
  else {
    var rest = powerset(set.slice(1));
    return rest.map(
      function(element) {
        return [set[0]].concat(element);
      }).concat(rest);
  }
};

var getNominalUtterances = function(object, tax) {
  return _.keys(_.pickBy(tax, function(value, key) {
    return _.has(value, object);
  }));
};

var getTypicalityUtterances = function(context) {
  return _.uniq(_.flatten(_.map(context, function(itemArr) {
    return [itemArr[0], itemArr[1], itemArr.join('_')];
  })));
};

// utterances are only modifiers
var getColorSizeUtterances = function(context) {
  return _.uniq(_.flattenDeep(_.map(context, function(obj) {
    return _.map(_.filter(powerset([obj.size, obj.color]), v => v != ''),
		 modifier => modifier.join('_'));
      // return _.map([obj.item], function(noun) {
    //return modifier.join('_');
      // });
  })));
};

// Working with collapsed color utterances
var colors = ['color', 'othercolor'];
var sizes = ["size", "othersize"];
var types = ['item'];       

var makeArr = function(n, v) {
  return _.repeat(n, v);
};

var makeColorSizeLists = function(wordsOrObjects) {
  var colorList = wordsOrObjects === 'words' ? colors.concat('') : colors;
  var sizeList = wordsOrObjects === 'words' ? sizes.concat('') : sizes;
  var typeList = wordsOrObjects === 'words' ? types.concat('') : types;

  return _.flattenDepth(_.map(sizeList, function(size) {
    return _.map(colorList, function(color) {
      return _.map(typeList, function(type) {
        return [size, color, type];
      });
    });
  }), 2);
};

var colorSizeWordMeanings = function(params) {
  return _.extend(
    _.zipObject(colors, _.times(colors.length, _.constant(params.colorTyp))),
    _.zipObject(sizes, _.times(sizes.length, _.constant(params.sizeTyp))),
    _.zipObject(types, _.times(types.length, _.constant(1))),
    {'thing' : 1}
 );
};

var constructLexicon = function(params) {
  if(params.modelVersion === 'colorSize') {
    var allUtts = makeColorSizeLists('words');
    var uttKeys = _.map(allUtts, (utt) => _.filter(utt, u => u != '').join('_'));
    var allObjs = makeColorSizeLists('objects');
    var objKeys = _.map(allObjs, (obj) => obj.join('_'));
    var wordMeaning = colorSizeWordMeanings(params);
    return _.zipObject(uttKeys, _.map(allUtts, function(utt) {
      return _.zipObject(objKeys, _.map(allObjs, function(obj) {
	var meanings = _.map(_.zip(utt, obj), function(tuple) {
          var uttWord = tuple[0], objProp = tuple[1];
          return (uttWord === '' ? 1 :
                  (uttWord === 'thing' || uttWord === objProp) ? wordMeaning[uttWord] :
                  (1 - wordMeaning[uttWord]));
	});
	return _.reduce(meanings, _.multiply);
      }));
    }));
  } else if (params.modelVersion === 'typicality') {
    return require('./json/typicality-meanings.json');
  } else if (params.modelVersion === 'nominal') {
    return require('./json/nominal-meanings.json');
  } else {
    return console.error('unknown modelVersion: ' + params.modelVersion);
  }
}

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'),
			 {header:true}).data;
};

// TODO: these paths could cause problems if we refactor module
function getData(modelVersion) {
  return require('../bdaInput/bda_data_' + modelVersion + '.json');
}

function getConditions(modelVersion) {
  return require('../bdaInput/unique_conditions_' + modelVersion + '.json');
}

function writeCSV(jsonCSV, filename){
  fs.writeFileSync(filename, babyparse.unparse(jsonCSV) + '\n');
}

function appendCSV(jsonCSV, filename){
  fs.appendFileSync(filename, babyparse.unparse(jsonCSV) + '\n');
}

var writeERP = function(erp, labels, filename, fixed) {
  var data = _.filter(erp.support().map(
   function(v) {
     var prob = Math.exp(erp.score(v));
     if (prob > 0.0){
      if(v.slice(-1) === ".")
        out = butLast(v);
      else if (v.slice(-1) === "?")
        out = butLast(v).split("Is")[1].toLowerCase();
      else 
        out = v
      return labels.concat([out, String(prob.toFixed(fixed))]);

    } else {
      return [];
    }
  }
  ), function(v) {return v.length > 0;});
  appendCSV(data, filename);
};

var supportWriter = function(s, p, handle) {
  var sLst = _.pairs(s);
  var l = sLst.length;

  for (var i = 0; i < l; i++) {
    fs.writeSync(handle, sLst[i].join(',')+','+p+'\n');
  }
};

// Note this is highly specific to a single type of erp -- extend to capture colorsize contexts
var bayesianErpWriter = function(erp, filePrefix) {
  var predictiveFile = fs.openSync(filePrefix + "Predictives.csv", 'w');
  fs.writeSync(predictiveFile, ["condition", "TargetColor","TargetType","Dist1Color","Dist1Type","Dist2Color","Dist2Type",
				"value", "prob", "MCMCprob"] + '\n');

  var paramFile = fs.openSync(filePrefix + "Params.csv", 'w');
  fs.writeSync(paramFile, ["parameter", "value", "MCMCprob"] + '\n');

  var supp = erp.support();
  supp.forEach(function(s) {
    supportWriter(s.predictive, erp.score(s), predictiveFile);
    supportWriter(s.params, erp.score(s), paramFile);
  });
  fs.closeSync(predictiveFile);
  fs.closeSync(paramFile);
  console.log('writing complete.');
};

var getSubset = function(data, properties) {
  var matchProps = _.matches(properties);
  return _.filter(data, matchProps);
};

var getTypSubset = function(data, obj_features) {
  var cond = function(row) {
    return row[0] === obj_features;
  };
  return _.filter(data, cond);
};

var locParse = function(filename) {
  return babyparse.parse(fs.readFileSync(filename, 'utf8'),
       {header: true,
        skipEmptyLines : true}).data;
};

var getFrequencyData = function(modelVersion) {
  return require("./json/" + modelVersion + "-freq.json");
};

var getLengthData = function(modelVersion) {
  return require("./json/" + modelVersion + "-length.json");
};

var standardizeVal = function(data, val) {
  var maxVal = _.max(_.values(data));
  var minVal = _.min(_.values(data));
  return (val - minVal)/(maxVal - minVal);
};

var getRelativeLogFrequency = function(params, label) {
  var frequencyData = getFrequencyData(params.modelVersion);
  return 1-standardizeVal(frequencyData, frequencyData[label]);
};

var getRelativeLength = function(params, label) {
  var lengthData = getLengthData(params.modelVersion);
  return standardizeVal(lengthData, lengthData[label]);
};

module.exports = {
  getNominalUtterances, getColorSizeUtterances, getTypicalityUtterances,
  constructLexicon, powerset, getSubset, 
  bayesianErpWriter, writeERP, writeCSV, readCSV,
  getData, getConditions,
  getRelativeLength, getRelativeLogFrequency, getTypSubset,
  colors, sizes
};
