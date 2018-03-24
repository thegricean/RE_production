// Returns a random integer between min (included) and max (excluded)
// Using Math.round() will give you a non-uniform distribution!
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

function startsWith(str, substrings) {
    for (var i = 0; i != substrings.length; i++) {
       var substring = substrings[i];
       if (str.indexOf(substring) == 0) {
         return 1;
       }
    }
    return -1; 
}

function make_slides(f) {
  var   slides = {};
// 	preload(
// ["images/bathrobe.png","images/belt.jpg"],
// {after: function() { console.log("everything's loaded now") }}
// )  

  slides.i0 = slide({
     name : "i0",
     start: function() {
      exp.startT = Date.now();
     }
  });

  slides.instructions = slide({
    name : "instructions",
    button : function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.objecttrial = slide({
    name : "objecttrial",
    present : exp.all_stims,
    start : function() {
	$(".err").hide();
    },
      present_handle : function(stim) {
    	this.trial_start = Date.now();
    	this.init_sliders();
      exp.sliderPost = {};
	//$("#objectlabel").val("");	
	  this.stim = stim;

	var contextsentence = "How typical is this for <strong>"+stim.label+"</strong>?";
	var objimagehtml = '<img src="images/'+stim.size+'_'+stim.color+'_'+stim.item+'.jpg" style="height:190px;">';

	$("#contextsentence").html(contextsentence);
	$("#objectimage").html(objimagehtml);
	  console.log(this);
	},
	button : function() {
	  if (exp.sliderPost > -1 && exp.sliderPost < 16) {
        $(".err").hide();
        this.log_responses();
        _stream.apply(this); //use exp.go() if and only if there is no "present" data.
      } else {
        $(".err").show();
      }
    },
    init_sliders : function() {
      utils.make_slider("#single_slider", function(event, ui) {
        exp.sliderPost = ui.value;
        //$("#number_guess").html(Math.round(ui.value*N));
      });
    },
    log_responses : function() {
        exp.data_trials.push({
          "label" : this.stim.label,
          "slide_number_in_experiment" : exp.phase,
          "item": this.stim.item,
          "rt" : Date.now() - _s.trial_start,
	      "response" : exp.sliderPost,
	      "color": this.stim.color,
	      "size": this.stim.size,
        "condition": this.stim.condition
        });
    }
  });

  slides.subj_info =  slide({
    name : "subj_info",
    submit : function(e){
      //if (e.preventDefault) e.preventDefault(); // I don't know what this means.
      exp.subj_data = {
        language : $("#language").val(),
        enjoyment : $("#enjoyment").val(),
        asses : $('input[name="assess"]:checked').val(),
        age : $("#age").val(),
        gender : $("#gender").val(),
        education : $("#education").val(),
        comments : $("#comments").val(),
      };
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  slides.thanks = slide({
    name : "thanks",
    start : function() {
      exp.data= {
          "trials" : exp.data_trials,
          "catch_trials" : exp.catch_trials,
          "system" : exp.system,
          "condition" : exp.condition,
          "subject_information" : exp.subj_data,
          "time_in_minutes" : (Date.now() - exp.startT)/60000
      };
      setTimeout(function() {turk.submit(exp.data);}, 1000);
    }
  });

  return slides;
}

/// init ///
function init() {

  var items = _.shuffle([
	
	{
"item": "avocado",
"label": "avocado",
"size": ["big", "small"],
"color": ["green", "black"]
},
{
"item": "balloon",
"label": "balloon",
"size": ["big", "small"],
"color": ["pink", "yellow"]
},
{
"item": "cap",
"label": "cap",
"size": ["big", "small"],
"color": ["blue", "orange"]
},
{
"item": "belt",
"label": "belt",
"size": ["big", "small"],
"color": ["black", "brown"]
},
{
"item": "bike",
"label": "bike",
"size": ["big", "small"],
"color": ["purple", "red"]
},
{
"item": "billiardball",
"label": "billiard ball",
"size": ["big", "small"],
"color": ["orange", "purple"]
},
{
"item": "binder",
"label": "binder",
"size": ["big", "small"],
"color": ["blue", "green"]
},
{
"item": "book",
"label": "book",
"size": ["big", "small"],
"color": ["black", "blue"]
},
{
"item": "bracelet",
"label": "bracelet",
"size": ["big", "small"],
"color": ["green", "purple"]
},
{
"item": "bucket",
"label": "bucket",
"size": ["big", "small"],
"color": ["pink", "red"]
},
{
"item": "butterfly",
"label": "butterfly",
"size": ["big", "small"],
"color": ["blue", "purple"]
},
{
"item": "candle",
"label": "candle",
"size": ["big", "small"],
"color": ["blue", "red"]
},
{
"item": "chair",
"label": "chair",
"size": ["big", "small"],
"color": ["green", "red"]
},
{
"item": "coathanger",
"label": "coat hanger",
"size": ["big", "small"],
"color": ["orange", "purple"]
},
{
"item": "comb",
"label": "comb",
"size": ["big", "small"],
"color": ["black", "blue"]
},
{
"item": "cushion",
"label": "cushion",
"size": ["big", "small"],
"color": ["blue", "orange"]
},
{
"item": "guitar",
"label": "guitar",
"size": ["big", "small"],
"color": ["blue", "green"]
},
{
"item": "flower",
"label": "flower",
"size": ["big", "small"],
"color": ["purple", "red"]
},
{
"item": "framee",
"label": "frame",
"size": ["big", "small"],
"color": ["green", "pink"]
},
{
"item": "golfball",
"label": "golf ball",
"size": ["big", "small"],
"color": ["blue", "pink"]
},
{
"item": "hairdryer",
"label": "hair dryer",
"size": ["big", "small"],
"color": ["pink", "purple"]
},
{
"item": "jacket",
"label": "jacket",
"size": ["big", "small"],
"color": ["brown", "green"]
},
{
"item": "napkin",
"label": "napkin",
"size": ["big", "small"],
"color": ["orange", "yellow"]
},
{
"item": "ornament",
"label": "ornament",
"size": ["big", "small"],
"color": ["blue", "purple"]
},
{
"item": "pepper",
"label": "pepper",
"size": ["big", "small"],
"color": ["green", "red"]
},
{
"item": "phone",
"label": "phone",
"size": ["big", "small"],
"color": ["pink", "white"]
},
{
"item": "rock",
"label": "rock",
"size": ["big", "small"],
"color": ["green", "purple"]
},
{
"item": "rug",
"label": "rug",
"size": ["big", "small"],
"color": ["blue", "purple"]
},
{
"item": "shoe",
"label": "shoe",
"size": ["big", "small"],
"color": ["white", "yellow"]
},
{
"item": "stapler",
"label": "stapler",
"size": ["big", "small"],
"color": ["purple", "red"]
},
{
"item": "tack",
"label": "tack",
"size": ["big", "small"],
"color": ["blue", "red"]
},
{
"item": "teacup",
"label": "teacup",
"size": ["big", "small"],
"color": ["pink", "white"]
},
{
"item": "toothbrush",
"label": "toothbrush",
"size": ["big", "small"],
"color": ["blue", "red"]
},
{
"item": "turtle",
"label": "turtle",
"size": ["big", "small"],
"color": ["black", "brown"]
},
{
"item": "weddingcake",
"label": "wedding cake",
"size": ["big", "small"],
"color": ["pink", "white"]
},
{
"item": "yarn",
"label": "yarn",
"size": ["big", "small"],
"color": ["purple", "red"]
}

//{
//"item": "wardrobe",
//"label": "clothing"
//}
	
  ]).slice(0,36);

  function makeStim(i) {
    //get item
    var item = items[i];
    var item_id = item.item;
    var size = "big";
    var color = _.shuffle(item.color)[0];
    var condition = _.shuffle(["unmodified","modified","modified"])[0];
    var label = "bla";
    var article = "";

    if (condition == "unmodified")
    {
    	if (item.label == "yarn") {
    		article = "";
    	} else {
    		if (startsWith(item.label, ["a","e","i","o","u"]) == 1) {
    			article = "an";
    		} else {
    			article = "a";
    		}    	
    	}
		label = article+" "+item.label;    	
    } else {
    	if (item.label == "yarn") {
    		article = "";
    	} else {    	
    		if (startsWith(color, ["a","e","i","o","u"]) == 1) {
    			article = "an";
    		} else {
    			article = "a";
    	}
    }
    	label = article+" "+color+" "+item.label;
    }
      

      return {
	  "item": item_id,
	  "label": label,
	  "size": size,
	  "color": color,
	  "condition": condition
    }
  }
  exp.all_stims = [];
  for (var i=0; i<items.length; i++) {
    exp.all_stims.push(makeStim(i));
  }

	console.log(exp.all_stims);
  exp.trials = [];
  exp.catch_trials = [];
  exp.condition = {}; //can randomize between subject conditions here
  exp.system = {
      Browser : BrowserDetect.browser,
      OS : BrowserDetect.OS,
      screenH: screen.height,
      screenUH: exp.height,
      screenW: screen.width,
      screenUW: exp.width
    };
  //blocks of the experiment:
  exp.structure=["i0", "objecttrial", 'subj_info', 'thanks'];
  
  exp.data_trials = [];
  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length(); //this does not work if there are stacks of stims (but does work for an experiment with this structure)
                    //relies on structure and slides being defined
  $(".nQs").html(exp.nQs);

  $('.slide').hide(); //hide everything

  //make sure turkers have accepted HIT (or you're not in mturk)
  $("#start_button").click(function() {
    if (turk.previewMode) {
      $("#mustaccept").show();
    } else {
      $("#start_button").click(function() {$("#mustaccept").show();});
      exp.go();
    }
  });

  exp.go(); //show first slide
}
