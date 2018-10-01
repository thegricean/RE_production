var _ = require('lodash');
var fs = require('fs');
var babyparse = require('babyparse');

var getCostData = function(modelVersion) {
  // cost files are indexed by experiment number...
  var expNum = modelVersion == 'typicality' ? 'exp2' : 'exp3';
  var rawData = readCSV("../data/cost_" + expNum + ".csv");

  // pre-normalize length
  var maxLength = _.max(_.map(rawData, function(v) {return _.toFinite(v.length);}));
  var minLength = _.min(_.map(rawData, function(v) {return _.toFinite(v.length);}));
  var standardizedLengths = _.map(rawData, function(v) {
    return {label: v.target, lengthCostWeight: (v.length - minLength)/(maxLength - minLength)};
  });

  // pre-normalize freq

  // unfortunately, exp3 freqs aren't already logged so we have to log everything before
  // normalizing to [0,1] with higher frequencies closer to 0
  var flippedFreqs = _.map(rawData, function(v) {
    var freq = expNum == 'exp3' ? Math.log(v.freq) : v.freq;
    return -1 * _.toFinite(freq);
  });
  var maxFreq = _.max(flippedFreqs);
  var minFreq = _.min(flippedFreqs);
  var standardizedFreqs = _.map(rawData, function(v, i) {
    return {label: v.target,
	    freqCostWeight : (flippedFreqs[i] - minFreq)/(maxFreq - minFreq)};
  });

  return {'freq' : _.keyBy(standardizedFreqs, "label"),
	  'length' : _.keyBy(standardizedLengths, "label")};
};

// Preload these...
var costData = {
  'typicality' : getCostData('typicality'),
  'nominal'    : getCostData('nominal')
};


function cartesianProductOf(list_of_lists) {
  return _.reduce(list_of_lists, function(a, b) {
    return _.flatten(_.map(a, function(x) {
      return _.map(b, function(y) {
        return x.concat([y]);
      });
    }), false);
  }, [ [] ]);
};

var obj_product = function(obj) {
  return _.map(cartesianProductOf(_.values(obj)), function(paramSet) {
    return _.zipObject(_.keys(obj), paramSet);
  });
};

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
    return [itemArr.color, itemArr.item, itemArr.color + '_' + itemArr.item];
  })));
};

// utterances are only modifiers
var getColorSizeUtterances = function(context) {
  return _.uniq(_.flattenDeep(_.map(context, function(obj) {
    return _.map(_.filter(powerset([obj.size, obj.color]), v => v != ''),
		 modifier => modifier.join('_'));
  })));
};

// Need to be able to look up what type a word is (includes collapsed versions)...
var colors = ['color', 'othercolor', 'blue', 'red', 'green', 'gray',
	      'brown','orange','black','yellow','purple'];
var sizes = ["size", "othersize", 'big', 'small'];
var types = ['item', 'thing', 'thumbtack', 'couch', 'tv', 'desk', 'chair',
	     'fan', 'banana','tomato','carrot','pepper','pear','avocado','apple'];

var getColorSizeUttMeaning = function(params, utt, obj) {
  var wordMeanings = _.map(utt.split('_'), function(word) {
    if(_.includes(colors, word))
      return word == obj.color ? params.colorTyp : 1 - params.colorTyp;
    else if (_.includes(sizes, word))
      return word == obj.size ? params.sizeTyp : 1 - params.sizeTyp;
    else if (_.includes(types, word))
      return word == obj.item ? params.typeTyp : 1 - params.typeTyp;
    else
      console.error('word ' + word + ' not recognized');
  });
  return _.reduce(wordMeanings, _.multiply);
};

var constructDeterministicLexicon = function(utts, objs, params) {
  var objNames = _.map(objs, obj => _.values(obj).join("_"));
  return _.zipObject(utts, _.map(utts, function(utt) {
    return _.zipObject(objNames, _.map(objs, function(obj) {
      return getColorSizeUttMeaning(params, utt, obj);
    }));
  }));
};

var fruits = ['banana','tomato','carrot','pepper','pear','avocado','apple'];
var fruitColors = ['blue', 'red', 'green', 'gray', 'brown','orange','black','yellow','purple'];
var completeContexts = {
  'colorSize' : [
      {size : 'size', color : 'color', item : 'item'},
      {size : 'othersize', color : 'color', item : 'item'},
      {size : 'size', color : 'othercolor', item : 'item'},
      {size : 'othersize', color : 'othercolor', item : 'item'}
  ],
  'typicality' : _.flatten(_.map(fruits, function(item) {
    return _.map(fruitColors, function(color) {
      return {color: color, item: item};
    });
  }))
};

// TODO: add the fixed semantics for typicality
var constructLexicon = function(params) {
  var completeContext = completeContexts[params.modelVersion];
  if(params.modelVersion === 'colorSize') {
    console.assert(params.semantics == 'fixed', 'empirical semantics not allowed for colorSize');
    var utts = getColorSizeUtterances(completeContext);
    return constructDeterministicLexicon(utts, completeContext, params);
  } else if (params.modelVersion === 'typicality') {
    var empirical = require('./json/typicality-meanings.json');
    var deterministic = require('./json/typicality-meanings-deterministic.json');
    if(params.semantics == 'empirical') {
      return empirical;
    } else {
      var utts = _.keys(deterministic);
      var lex = constructDeterministicLexicon(utts, completeContext, params);
      return params.semantics == 'fixed' ? lex : interpolateLexicons(lex, empirical, params);
    }
  } else if (params.modelVersion === 'nominal') {
    return require('./json/nominal-meanings.json');
  } else {
    return console.error('unknown modelVersion: ' + params.modelVersion);
  }
}

var interpolateLexicons = function(det, emp, params) {
  return _.mapValues(emp, function(subtree, utt) {
    return _.mapValues(subtree, function(empVal, obj) {
      var detVal = det[utt][obj];
      return (1 - params.fixedVsEmpirical) * empVal + (params.fixedVsEmpirical) * detVal;
    });
  });
};

function readCSV(filename){
  return babyparse.parse(fs.readFileSync(filename, 'utf8'),
			 {header:true}).data;
};

function getTestContexts(modelVersion){
  return require('../simulations/testContexts.json');
};

// TODO: these paths could cause problems if we refactor module
function getData(modelVersion) {
  return require('../bdaInput/' + modelVersion + '/bda_data.json');
}

function getConditions(modelVersion) {
  return require('../bdaInput/' + modelVersion + '/unique_conditions.json');
}

function getParamPosterior(modelVersion,costs,semantics) {
  return readCSV('./bdaOutput/' + modelVersion + '_cost-' + costs + '_sem-' + semantics + '_params.csv');
}

function getManualParams(modelVersion) {
  return readCSV('./' + modelVersion + '_manualparams.csv');
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
  var sLst = _.toPairs(s);
  var l = sLst.length;

  for (var i = 0; i < l; i++) {
    fs.writeSync(handle, sLst[i].join(',')+','+p+'\n');
  }
};

var predictiveSupportWriter = function(s, p, handle) {
  var l = s.length;
  for (var i = 0; i < l; i++) {
    fs.writeSync(handle, s[i] + '\n');
  }
};

// TODO: split into checks for cost & semantics values
var getHeader = function(versionStr) {
  var version = versionStr.split('_');
  if(version[0] == 'colorSize') {
    if(version[1] == 'simulation') {
      return ['context','infWeight', "costWeight", 'modelVersion', "colorTyp",
	      "sizeTyp", "typeTyp", "colorVsSizeCost",
	      "typWeight", "utterance", "logModelProb"];
    } else if (version[3] == 'params') {
      return ['infWeight', 'costWeight', 'colorTyp', 'sizeTyp', 'colorVsSizeCost', 'typWeight',
	      'logLikelihood', 'outputProb'];
    } else if (version[3] == 'predictives') {
      return ['color', 'size', 'condition', 'othercolor', 'item', 'utt', 'prob',  "zeros"];
    }
  } else if(version[0] == 'typicality') {
    if (version == 'typicality_cost-empirical_sem-empirical_params') {
      return ['infWeight', 'lengthCostWeight', 'freqCostWeight', 'typWeight',
	      'logLikelihood', 'outputProb'];
    } else if (version == 'typicality_cost-fixed_sem-empirical_params') {
      return ['infWeight', 'colorCost', 'sizeCost', 'typeCost', 'typWeight',
	      'logLikelihood', 'outputProb'];
    } else if (version == 'typicality_cost-empirical_sem-fixed_params') {
      return ['infWeight', 'colorCost', 'sizeCost', 'typeCost', 'typWeight',
	      'logLikelihood', 'outputProb']; 
    } else if (version == 'typicality_cost-fixed_sem-fixed_params') {
      return ['infWeight', 'colorCost', 'sizeCost', 'typeCost', 'colorTyp', 'typeTyp', 'typWeight',
	      'logLikelihood', 'outputProb']; 
    } else if (version == 'typicality_cost-fixed_sem-fixedplusempirical_params') {
      return ['infWeight','colorCost','sizeCost','typeCost','colorTyp','sizeTyp',
	      'typeTyp','typWeight','fixedVsEmpirical','logLikelihood','outputProb'];
    } else if (version == 'typicality_cost-empirical_sem-fixedplusempirical_params') {
      return ['infWeight','lengthCostWeight','freqCostWeight','colorTyp','sizeTyp',
	      'typeTyp','typWeight','fixedVsEmpirical','logLikelihood','outputProb'];

    } else if (version[3] == 'predictives') {
      return ['condition','t_color', "t_item", 'd1_color', "d1_item",
	      "d2_color", "d2_item", "response", "logModelProb",  "zeros"];
    }
  } else if (version[0] == 'nominal') {
    if (version[3] == 'params') {
      return ['infWeight', 'lengthCostWeight', 'freqCostWeight', 'typWeight',
	      'logLikelihood', 'outputProb'];
    } else if (version[3] == 'predictives') {
      return ['condition',"target_item", 'd1_item', "d2_item",
	      "response", "logModelProb", "zeros"];
    }
  } else {
    console.error('unknown version: ' + version);
  }
};


// Note this is highly specific to a single type of erp
var bayesianErpWriter = function(erp) {

  var supp = erp.support();
  var version = supp[0]['version'].split(':');
  var header = getHeader(version[0]);
  console.log(header);
  var fileHandle = fs.openSync('./bdaOutput/' + version[0] + ".csv", 'w');
  fs.writeSync(fileHandle, header.join(',') + '\n');
  supp.forEach(function(s) {
    if(version[1] == 'list')
      predictiveSupportWriter(s.output, erp.score(s), fileHandle);
    else if(version[1] == 'obj')
      supportWriter(s.output, erp.score(s), fileHandle);
  });
  fs.closeSync(fileHandle);
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

var getRelativeLogFrequency = function(params, label) {
  var frequencyData = costData[params.modelVersion]['freq'];
  return frequencyData[label]['freqCostWeight'];
};

var getRelativeLength = function(params, label) {
  var lengthData = costData[params.modelVersion]['length'];
  if(_.isUndefined(lengthData[label]))
    console.log(label);
  return lengthData[label]['lengthCostWeight'];
};

// NOTE: this is 0, not -Infinity or -100 or something
// because we collected empirical values where the minimum is 0
// and it doesn't make sense to have a huge gap between something
// we put into that experiment that got a low score and
// something we purposefully didn't put in that expt because we expected it to
// have a low score (eg for nominal: how typical is this iguana for a sunflower?)
var meaning = function(utt, object, params) {
  var objStr = _.values(object).join("_");
  var lexicalEntry = params.lexicon[utt];
  return _.has(lexicalEntry, objStr) ? lexicalEntry[objStr] : 0; 
};

function _logsumexp(a) {
  var m = Math.max.apply(null, a);
  var sum = 0;
  for (var i = 0; i < a.length; ++i) {
    sum += (a[i] === -Infinity ? 0 : Math.exp(a[i] - m));
  }
  return m + Math.log(sum);
}

var uttCost = function(params, utt) {    
  if (params.costs === 'fixed') {
    var sizeMention = _.intersection(sizes, utt.split('_')).length;
    var colorMention = _.intersection(colors, utt.split('_')).length;
    var typeMention = _.intersection(types, utt.split('_')).length;
    return (params.colorCost * colorMention +
	    params.sizeCost * sizeMention +
            params.typeCost * typeMention);
  } else if (params.costs === 'empirical') {
    console.assert(params.modelVersion != 'colorSize', 'empirical costs not allowed for colorSize');
    return (params.lengthCostWeight * getRelativeLength(params, utt) +
	    params.freqCostWeight * getRelativeLogFrequency(params, utt));
  } else {
    return console.error('unknown costs: ' + params.costs);
  }
};

var getSpeakerUtility = function(target, utt, context, params) {
  // console.log(utt);
  // console.log(getL0score(target, utt, context, params));
  var inf = params.infWeight * getL0score(target, utt, context, params);
  var cost = uttCost(params, utt);
  
  // console.log(utt);
  // console.log('inf' + inf);
  // console.log('cost' + cost);
  return inf - cost; 
}

var getPossibleUtts = function(params, target, context) {
  if (params.modelVersion === 'colorSize') {
    return getColorSizeUtterances(context);
  } else if(params.modelVersion === 'nominal') {
    return getNominalUtterances(target.item, params.lexicon);
  } else if(params.modelVersion === 'typicality') {
    return getTypicalityUtterances(context);
  } else {
    return console.error('unknown modelVersion: ' + params.modelVersion);
  }
};

var getSpeakerScore = function(trueUtt, target, context, params) {
  var possibleUtts = getPossibleUtts(params, target, context);

  var scores = [];
  // note: could memoize this for moderate optimization...
  // (only needs to be computed once per context per param, not for every utt)
  for(var i=0; i<possibleUtts.length; i++){
    var utt = possibleUtts[i];
    var utility = getSpeakerUtility(target, utt, context, params);
    // console.log(utility);
    scores.push(utility);//Math.log(Math.max(utility, Number.EPSILON)));
  }
    var trueUtility = getSpeakerUtility(target, trueUtt, context, params);
  return trueUtility - _logsumexp(scores); // softmax subtraction bc log space,
};

// P(target | sketch) = e^{scale * sim(t, s)} / (\sum_{i} e^{scale * sim(t, s)})
// => log(p) = scale * sim(target, sketch) - log(\sum_{i} e^{scale * sim(t, s)})
var getL0score = function(target, utt, context, params) {
  var lexicon = params.lexicon;
  var scores = [];
  for(var i=0; i<context.length; i++){
    // console.log('object')
    // console.log(context[i]);
    // console.log('fitness' + meaning(utt, context[i], params));    
    var m = meaning(utt, context[i], params);
    scores.push(params.typWeight * m);
  }
  var targetM = meaning(utt, target, params);
  return params.typWeight * targetM - _logsumexp(scores);
};

module.exports = {
  getNominalUtterances, getColorSizeUtterances, getTypicalityUtterances,
  constructLexicon, powerset, getSubset, 
  bayesianErpWriter, writeERP, writeCSV, readCSV, getTestContexts,
  getData, getConditions, getParamPosterior, getManualParams,
  obj_product,
  getL0score,getSpeakerScore, uttCost,
  getRelativeLength, getRelativeLogFrequency, getTypSubset,
  colors, sizes
};
