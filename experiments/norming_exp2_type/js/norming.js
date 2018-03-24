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
preload(["images/apple_blue.png","images/apple_green.png","images/apple_red.png","images/apple_yellow.png","images/avocado_black.png","images/avocado_green.png","images/avocado_red.png","images/banana_blue.png","images/banana_brown.png","images/banana_yellow.png","images/carrot_orange.png","images/carrot_pink.png","images/carrot_purple.png","images/cup_black.png","images/cup_blue.png","images/cup_brown.png","images/cup_green.png","images/cup_orange.png","images/cup_pink.png","images/cup_purple.png","images/cup_red.png","images/cup_yellow.png","images/pear_green.png","images/pear_orange.png","images/pear_yellow.png","images/pepper_green.png","images/pepper_orange.png","images/pepper_red.png","images/strawberry_blue.png","images/strawberry_red.png","images/tomato_green.png","images/tomato_pink.png","images/tomato_red.png","images/tomato_yellow.png"],
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

/*	var items_target = _.shuffle([

{
"label": "avocado_black",
"item": ["avocado"]
},
{
"label": "avocado_green",
"item": ["avocado"]
},
{
"label": "avocado_red",
"item": ["avocado"]
},
{
"label": "apple_blue",
"item": ["apple"]
},
{
"label": "apple_red",
"item": ["apple"]
},
{
"label": "apple_green",
"item": ["apple"]
},
{
"label": "banana_blue",
"item": ["banana"]
},
{
"label": "banana_brown",
"item": ["banana"]
},
{
"label": "banana_yellow",
"item": ["banana"]
},
{
"label": "carrot_orange",
"item": ["carrot"]
},
{
"label": "carrot_pink",
"item": ["carrot"]
},
{
"label": "carrot_purple",
"item": ["carrot"]
},
{
"label": "cup_black",
"item": ["cup"]
},
{
"label": "cup_blue",
"item": ["cup"]
},
{
"label": "cup_brown",
"item": ["cup"]
},
{
"label": "cup_green",
"item": ["cup"]
},
{
"label": "cup_orange",
"item": ["cup"]
},
{
"label": "cup_pink",
"item": ["cup"]
},
{
"label": "cup_purple",
"item": ["cup"]
},
{
"label": "cup_red",
"item": ["cup"]
},
{
"label": "cup_yellow",
"item": ["cup"]
},
{
"label": "pear_green",
"item": ["pear"]
},
{
"label": "pear_orange",
"item": ["pear"]
},
{
"label": "pear_yellow",
"item": ["pear"]
},
{
"label": "pepper_green",
"item": ["pepper"]
},
{
"label": "pepper_orange",
"item": ["pepper"]
},
{
"label": "pepper_red",
"item": ["pepper"]
},
{
"label": "tomato_green",
"item": ["tomato"]
},
{
"label": "tomato_pink",
"item": ["tomato"]
},
{
"label": "tomato_red",
"item": ["tomato"]
},


{
"label": "avocado_black",
"item": ["apple", "banana"]
},
{
"label": "avocado_green",
"item": ["apple", "banana"]
},
{
"label": "avocado_red",
"item": ["apple", "banana"]
},
{
"label": "apple_blue",
"item": ["avocado", "banana"]
},
{
"label": "apple_red",
"item": ["avocado", "banana"]
},
{
"label": "apple_green",
"item": ["avocado", "banana"]
},
{
"label": "banana_blue",
"item": ["avocado", "apple"]
},
{
"label": "banana_brown",
"item": ["avocado", "apple"]
},
{
"label": "banana_yellow",
"item": ["avocado", "apple"]
},
{
"label": "carrot_orange",
"item": ["avocado", "apple"]
},
{
"label": "carrot_pink",
"item": ["avocado", "apple"]
},
{
"label": "carrot_purple",
"item": ["avocado", "apple"]
},
{
"label": "cup_black",
"item": ["avocado", "apple"]
},
{
"label": "cup_blue",
"item": ["avocado", "apple"]
},
{
"label": "cup_brown",
"item": ["avocado", "apple"]
},
{
"label": "cup_green",
"item": ["avocado", "apple"]
},
{
"label": "cup_orange",
"item": ["avocado", "apple"]
},
{
"label": "cup_pink",
"item": ["avocado", "apple"]
},
{
"label": "cup_purple",
"item": ["avocado", "apple"]
},
{
"label": "cup_red",
"item": ["avocado", "apple"]
},
{
"label": "cup_yellow",
"item": ["avocado", "apple"]
},
{
"label": "pear_green",
"item": ["avocado", "apple"]
},
{
"label": "pear_orange",
"item": ["avocado", "apple"]
},
{
"label": "pear_yellow",
"item": ["avocado", "apple"]
},
{
"label": "pepper_green",
"item": ["avocado", "apple"]
},
{
"label": "pepper_orange",
"item": ["avocado", "apple"]
},
{
"label": "pepper_red",
"item": ["avocado", "apple"]
},
{
"label": "tomato_green",
"item": ["avocado", "apple"]
},
{
"label": "tomato_pink",
"item": ["avocado", "apple"]
},
{
"label": "tomato_red",
"item": ["avocado", "apple"]
},


{
"label": "avocado_black",
"item": ["carrot", "pear"]
},
{
"label": "avocado_green",
"item": ["carrot", "pear"]
},
{
"label": "avocado_red",
"item": ["carrot", "pear"]
},
{
"label": "apple_blue",
"item": ["carrot", "pear"]
},
{
"label": "apple_red",
"item": ["carrot", "pear"]
},
{
"label": "apple_green",
"item": ["carrot", "pear"]
},
{
"label": "banana_blue",
"item": ["carrot", "pear"]
},
{
"label": "banana_brown",
"item": ["carrot", "pear"]
},
{
"label": "banana_yellow",
"item": ["carrot", "pear"]
},
{
"label": "carrot_orange",
"item": ["banana", "pear"]
},
{
"label": "carrot_pink",
"item": ["banana", "pear"]
},
{
"label": "carrot_purple",
"item": ["banana", "pear"]
},
{
"label": "cup_black",
"item": ["banana", "pear"]
},
{
"label": "cup_blue",
"item": ["banana", "pear"]
},
{
"label": "cup_brown",
"item": ["banana", "pear"]
},
{
"label": "cup_green",
"item": ["banana", "pear"]
},
{
"label": "cup_orange",
"item": ["banana", "pear"]
},
{
"label": "cup_pink",
"item": ["banana", "pear"]
},
{
"label": "cup_purple",
"item": ["banana", "pear"]
},
{
"label": "cup_red",
"item": ["banana", "pear"]
},
{
"label": "cup_yellow",
"item": ["banana", "pear"]
},
{
"label": "pear_green",
"item": ["banana", "carrot"]
},
{
"label": "pear_orange",
"item": ["banana", "carrot"]
},
{
"label": "pear_yellow",
"item": ["banana", "carrot"]
},
{
"label": "pepper_green",
"item": ["banana", "carrot"]
},
{
"label": "pepper_orange",
"item": ["banana", "carrot"]
},
{
"label": "pepper_red",
"item": ["banana", "carrot"]
},
{
"label": "tomato_green",
"item": ["banana", "carrot"]
},
{
"label": "tomato_pink",
"item": ["banana", "carrot"]
},
{
"label": "tomato_red",
"item": ["banana", "carrot"]
},


{
"label": "avocado_black",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "avocado_green",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "avocado_red",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "apple_blue",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "apple_red",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "apple_green",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "banana_blue",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "banana_brown",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "banana_yellow",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "carrot_orange",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "carrot_pink",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "carrot_purple",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "cup_black",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "cup_blue",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "cup_brown",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "cup_green",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "cup_orange",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "cup_pink",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "cup_purple",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "cup_red",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "cup_yellow",
"item": ["pepper", "tomato", "carrot"]
},
{
"label": "pear_green",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "pear_orange",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "pear_yellow",
"item": ["pepper", "tomato", "cup"]
},
{
"label": "pepper_green",
"item": ["pear", "tomato", "cup"]
},
{
"label": "pepper_orange",
"item": ["pear", "tomato", "cup"]
},
{
"label": "pepper_red",
"item": ["pear", "tomato", "cup"]
},
{
"label": "tomato_green",
"item": ["pear", "pepper", "cup"]
},
{
"label": "tomato_pink",
"item": ["pear", "pepper", "cup"]
},
{
"label": "tomato_red",
"item": ["pear", "pepper", "cup"]
}
	]).slice(0,200)*/

  var items_target = _.shuffle([

{
"label": "avocado_black",
"item": ["avocado"]
},
{
"label": "avocado_green",
"item": ["avocado"]
},
{
"label": "avocado_red",
"item": ["avocado"]
},
{
"label": "apple_blue",
"item": ["apple"]
},
{
"label": "apple_red",
"item": ["apple"]
},
{
"label": "apple_green",
"item": ["apple"]
},
{
"label": "banana_blue",
"item": ["banana"]
},
{
"label": "banana_brown",
"item": ["banana"]
},
{
"label": "banana_yellow",
"item": ["banana"]
},
{
"label": "carrot_orange",
"item": ["carrot"]
},
{
"label": "carrot_pink",
"item": ["carrot"]
},
{
"label": "carrot_purple",
"item": ["carrot"]
},
{
"label": "cup_black",
"item": ["cup"]
},
{
"label": "cup_blue",
"item": ["cup"]
},
{
"label": "cup_brown",
"item": ["cup"]
},
{
"label": "cup_green",
"item": ["cup"]
},
{
"label": "cup_orange",
"item": ["cup"]
},
{
"label": "cup_pink",
"item": ["cup"]
},
{
"label": "cup_purple",
"item": ["cup"]
},
{
"label": "cup_red",
"item": ["cup"]
},
{
"label": "cup_yellow",
"item": ["cup"]
},
{
"label": "pear_green",
"item": ["pear"]
},
{
"label": "pear_orange",
"item": ["pear"]
},
{
"label": "pear_yellow",
"item": ["pear"]
},
{
"label": "pepper_green",
"item": ["pepper"]
},
{
"label": "pepper_orange",
"item": ["pepper"]
},
{
"label": "pepper_red",
"item": ["pepper"]
},
{
"label": "tomato_green",
"item": ["tomato"]
},
{
"label": "tomato_pink",
"item": ["tomato"]
},
{
"label": "tomato_red",
"item": ["tomato"]
}
]);









var items_target_2 = _.shuffle([
{
"label": "avocado_black",
"item": ["apple", "banana", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "avocado_green",
"item": ["apple", "banana", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "avocado_red",
"item": ["apple", "banana", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "apple_blue",
"item": ["avocado", "banana", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "apple_red",
"item": ["avocado", "banana", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "apple_green",
"item": ["avocado", "banana", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "banana_blue",
"item": ["avocado", "apple", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "banana_brown",
"item": ["avocado", "apple", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "banana_yellow",
"item": ["avocado", "apple", "carrot", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "carrot_orange",
"item": ["avocado", "apple", "banana", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "carrot_pink",
"item": ["avocado", "apple", "banana", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "carrot_purple",
"item": ["avocado", "apple", "banana", "pear", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "cup_black",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "cup_blue",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "cup_brown",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "cup_green",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "cup_orange",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "cup_pink",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "cup_purple",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "cup_red",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "cup_yellow",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "tomato", "fruit", "vegetable"]
},
{
"label": "pear_green",
"item": ["avocado", "apple", "banana", "carrot", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "pear_orange",
"item": ["avocado", "apple", "banana", "carrot", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "pear_yellow",
"item": ["avocado", "apple", "banana", "carrot", "pepper", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "pepper_green",
"item": ["avocado", "apple", "banana", "carrot", "pear", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "pepper_orange",
"item": ["avocado", "apple", "banana", "carrot", "pear", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "pepper_red",
"item": ["avocado", "apple", "banana", "carrot", "pear", "tomato", "cup", "fruit", "vegetable"]
},
{
"label": "tomato_green",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "cup", "fruit", "vegetable"]
},
{
"label": "tomato_pink",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "cup", "fruit", "vegetable"]
},
{
"label": "tomato_red",
"item": ["avocado", "apple", "banana", "carrot", "pear", "pepper", "cup", "fruit", "vegetable"]
}
  ]);
	


  function makeTargetStim(i) {
    //get item
    var item = items_target[i];
    var item_id = item.item[0];
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
    exp.all_stims.push(makeTargetStim(i));
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
