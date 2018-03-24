// Returns a random integer between min (included) and max (excluded)
// Using Math.round() will give you a non-uniform distribution!
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

function make_slides(f) {
  var   slides = {};
// 	preload(
// ["images/bathrobe.png","images/belt.jpg"],
// {after: function() { console.log("everything's loaded now") }}
// )  
preload(["images/apple_blue.png","images/apple_green.png","images/apple_red.png","images/avocado_black.png","images/avocado_green.png","images/avocado_red.png","images/banana_blue.png","images/banana_brown.png","images/banana_yellow.png","images/carrot_brown.png","images/carrot_orange.png","images/carrot_pink.png","images/pear_green.png","images/pear_orange.png","images/pear_yellow.png","images/pepper_black.png","images/pepper_green.png","images/pepper_orange.png","images/pepper_red.png","images/tomato_green.png","images/tomato_pink.png","images/tomato_red.png"],
 {after: function() { console.log("everything's loaded now") }});

function startsWith(str, substrings) {
    for (var i = 0; i != substrings.length; i++) {
       var substring = substrings[i];
       if (str.indexOf(substring) == 0) {
         return 1;
       }
    }
    return -1; 
}

function getArticleItem(item_id) {

  var article = "";

  if (startsWith(item_id, ["a","e","i","o","u"]) == 1) {
    article = "an ";
  } else {
    article = "a ";
  }
  return article;
}

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
    // stim.item = _.shuffle(stim.item);
	  console.log(this.stim);
    var article = getArticleItem(stim.item);
   //  console.log(stim.item);
   //  console.log(stim.label);
	var contextsentence = "How typical is this object for "+article+"<strong>"+stim.item+"</strong>?";
	//var contextsentence = "How typical is this for "+stim.basiclevel+"?";
	//var objimagehtml = '<img src="images/'+stim.basiclevel+'/'+stim.item+'.jpg" style="height:190px;">';
	var objimagehtml = '<img src="images/'+stim.label+'.png" style="height:190px;">';

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
          "slide_number_in_experiment" : exp.phase,
          "utterance": this.stim.item,
          "object": this.stim.label,
          "rt" : Date.now() - _s.trial_start,
	      "response" : exp.sliderPost
        });
    }
 //     $(".contbutton").click(function() {
	//   var ok_to_go_on = true;
	//   console.log($("#objectlabel").val());
	//   if ($("#objectlabel").val().length < 2) {
	//   	ok_to_go_on = false;
	//   }
 //      if (ok_to_go_on) {
	// $(".contbutton").unbind("click");      	
	// stim.objectlabel = $("#objectlabel").val();         	
 //        exp.data_trials.push({
     //      "basiclevel" : stim.basiclevel,
     //      "slide_number_in_experiment" : exp.phase,
     //      "item": stim.item,
     //        "rt" : Date.now() - _s.trial_start,
	    // "response" : stim.objectlabel
 //        });
 //          $(".err").hide();
 //          _stream.apply(_s); 
 //      } else {
 //        $(".err").show();
 //      }
	// });
	  
    //  },
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

var items_target = _.shuffle([

{
"label": "avocado_black",
"item": ["black avocado", "green avocado", "red avocado"]
},
{
"label": "avocado_green",
"item": ["black avocado", "green avocado", "red avocado"]
},
{
"label": "avocado_red",
"item": ["black avocado", "green avocado", "red avocado"]
},
{
"label": "apple_blue",
"item": ["blue apple", "red apple", "green apple"]
},
{
"label": "apple_red",
"item": ["blue apple", "red apple", "green apple"]
},
{
"label": "apple_green",
"item": ["blue apple", "red apple", "green apple"]
},
{
"label": "banana_blue",
"item": ["blue banana", "brown banana", " yellow banana"]
},
{
"label": "banana_brown",
"item": ["blue banana", "brown banana", " yellow banana"]
},
{
"label": "banana_yellow",
"item": ["blue banana", "brown banana", " yellow banana"]
},
{
"label": "carrot_orange",
"item": ["orange carrot", "pink carrot", "brown carrot"]
},
{
"label": "carrot_pink",
"item": ["orange carrot", "pink carrot", "brown carrot"]
},
{
"label": "carrot_brown",
"item": ["orange carrot", "pink carrot", "brown carrot"]
},
{
"label": "pear_green",
"item": ["green pear", "orange pear", "yellow pear"]
},
{
"label": "pear_orange",
"item": ["green pear", "orange pear", "yellow pear"]
},
{
"label": "pear_yellow",
"item": ["green pear", "orange pear", "yellow pear"]
},
{
"label": "pepper_green",
"item": ["green pepper", "black pepper", "orange pepper", "red pepper"]
},
{
"label": "pepper_black",
"item": ["green pepper", "black pepper", "orange pepper", "red pepper"]
},
{
"label": "pepper_orange",
"item": ["green pepper", "black pepper", "orange pepper", "red pepper"]
},
{
"label": "pepper_red",
"item": ["green pepper", "black pepper", "orange pepper", "red pepper"]
},
{
"label": "tomato_green",
"item": ["green tomato", "pink tomato", "red tomato"]
},
{
"label": "tomato_pink",
"item": ["green tomato", "pink tomato", "red tomato"]
},
{
"label": "tomato_red",
"item": ["green tomato", "pink tomato", "red tomato"]
}
]);









var items_target_2 = _.shuffle([
{
"label": "avocado_black",
"item": ["blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "avocado_green",
"item": ["blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "avocado_red",
"item": ["blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "apple_blue",
"item": ["black avocado", "red avocado", "green avocado", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "apple_red",
"item": ["black avocado", "red avocado", "green avocado", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "apple_green",
"item": ["black avocado", "red avocado", "green avocado", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "banana_blue",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "banana_brown",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "banana_yellow",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "carrot_orange",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "carrot_pink",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "carrot_brown",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "pear_green",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "pear_orange",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "pear_yellow",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pepper", "red pepper", "orange pepper", "black pepper", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "pepper_green",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "pepper_black",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "pepper_orange",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "pepper_red",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "red tomato", "pink tomato", "green tomato"]
},
{
"label": "tomato_green",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper"]
},
{
"label": "tomato_pink",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper"]
},
{
"label": "tomato_red",
"item": ["black avocado", "red avocado", "green avocado", "blue apple", "red apple", "green apple", "blue banana", "brown banana", "yellow banana", "orange carrot", "brown carrot", "pink carrot", "green pear", "yellow pear", "orange pear", "green pepper", "red pepper", "orange pepper", "black pepper"]
}
  ]);
	


  function makeTargetStim(i,j) {
    //get item
    var item = items_target[i];
    var item_id = item.item[j];
    var object_label = item.label;
      
      return {
	  "item": item_id,
    "label": object_label
    }
  }
  
  function makeTargetStim2(l,k) {
    //get item
    var item = items_target_2[l];
    var item_id = item.item[k];
    var object_label = item.label;
      
      return {
    "item": item_id,
    "label": object_label
    }
  }

  exp.all_stims = [];

  for (var i=0; i<items_target.length; i++) {
    items_target[i].item = _.shuffle(items_target[i].item);
    for (var j=0; j<3; j++) {
      exp.all_stims.push(makeTargetStim(i,j));
    }
  }

  for (var l=0; l<items_target_2.length; l++) {
    items_target_2[l].item = _.shuffle(items_target_2[l].item);
    for (var k=0; k<2; k++) {
      exp.all_stims.push(makeTargetStim2(l,k));
    }
  }

  exp.all_stims = _.shuffle(exp.all_stims);

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
