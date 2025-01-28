var started = false;
var rgbStart = [139,195,74]
var rgbEnd = [183,28,28]

var currentState = 2

$(function(){
	window.addEventListener('message', function(event) {
		if (event.data.action == "setValue"){
			if (event.data.key == "job"){
				if (event.data.icon.includes("unemployed")){
					hideJob2()
				}else{
					showJob2()
					setJobIcon(event.data.icon)
				}
			}
			if (event.data.key == "job2"){
				setJob2Icon(event.data.icon)
			}
			setValue(event.data.key, event.data.value)

		}else if (event.data.action == "updateStatus"){
			updateStatus(event.data.status);
		}else if (event.data.action == "setTalking"){
			setTalking(event.data.value)
		}else if (event.data.action == "setProximity"){
			setProximity(event.data.value)
		}else if (event.data.action == "toggle"){
			if (event.data.show){
				$('#ui').fadeIn();
			} else{
				$('#ui').fadeOut();
			}
		} else if (event.data.action == "toggleCar"){
			if (event.data.show){
				//$('.carStats').show();
			} else{
				//$('.carStats').hide();
			}
		}else if (event.data.action == "updateCarStatus"){
			updateCarStatus(event.data.status)
		/*}else if (event.data.action == "updateWeight"){
			updateWeight(event.data.weight)*/
		}
		else if (event.data.action == "startUI") {
			if (started === false) {
				started = true;
				setTimeout(() => {
					$('#ui').fadeIn();
				}, 2000);
			}
		}
		else if (event.data.action == "setId") {
			$('#playerid').html(event.data.value);
		}
		else if (event.data.action == "voiceChange") {
			$('#voicebg').css('background', event.data.setcolor)
			$('#voicebg').css('width', event.data.value+'%')
			var randomNumber = Math.floor(Math.random() * 150000)
			currentState = randomNumber
			var myState = randomNumber
			setTimeout(function () {
				if(myState == currentState) {
					$('#voicebg').css('background', '#fff')
				}
			}, 5000);
		}
	});

});

function updateWeight(weight){


	var bgcolor = colourGradient(weight/100, rgbEnd, rgbStart)
	$('#weight .bg').css('height', weight+'%')
	$('#weight .bg').css('background-color', 'rgb(' + bgcolor[0] +','+ bgcolor[1] +','+ bgcolor[2] +')')
}

function updateCarStatus(status){
	var gas = status[0]
	$('#gas .bg').css('height', gas.percent+'%')
	var bgcolor = colourGradient(gas.percent/100, rgbStart, rgbEnd)
	//var bgcolor = colourGradient(0.1, rgbStart, rgbEnd)
	//$('#gas .bg').css('height', '10%')
	$('#gas .bg').css('background-color', 'rgb(' + bgcolor[0] +','+ bgcolor[1] +','+ bgcolor[2] +')')
}

function setValue(key, value){
	$('#'+key+' span').html(value)
}

function setValueSociety(key, value){
	var element = $('#'+key+' span');
	if (element.style.display === "none") {
		element.style.display = "block";
	  }
	  element.html(value);

}

function setJobIcon(value){
	$('#job img').attr('src', 'img/jobs/'+value+'.png')
}

function setJob2Icon(value){
	$('#job2 img').attr('src', 'img/jobs/'+value+'.png')
}

function showJob2(){
	$('#job').show()
}

function showJob3(){
	$('#job3').show()
}

function hideJob2(){
	$('#job').hide()
}

function hideJob3(){
	$('#job2').hide()
}

function updateStatus(status){
	var hunger = status[1] || 0;
	var thirst = status[2] || 0;
	var drunk = status[0] || 0;
	status.forEach(element => {
		if(element.name === "drunk") {
			drunk = element;
		}
		else if (element.name === "thirst") {
			thirst = element;
		} else if (element.name === "hunger") {
			hunger = element;
		}
	});
	$('#hunger .bg').css('width', hunger.percent+'%')
	$('#water .bg').css('width', thirst.percent+'%')
	//$('#playerid').html(hunger.percent);
	if(hunger.percent < 30) {
		if(hunger.percent < 20) {
			$('#hungerbg').css('background', '#FF0000')
		}
		else {
			$('#hungerbg').css('background', '#FFFF00')
		}
	}
	else {
		$('#hungerbg').css('background', '#fff')
	}
	if(thirst.percent < 30) {
		if(thirst.percent < 20) {
			$('#waterbg').css('background', '#FF0000')
		}
		else {
			$('#waterbg').css('background', '#FFFF00')
		}
	}
	else {
		$('#waterbg').css('background', '#fff')
	}
	$('#drunk .bg').css('width', drunk.percent+'%');
	if (drunk.percent > 5){
		$('#drunk').show();
	}else{
		$('#drunk').hide();
	}

}

function setProximity(value){
	var color;
	var speaker;
	if (value == "whisper"){
		color = "#FFEB3B";
		speaker = 1;
	}else if (value == "normal"){
		color = "#039BE5";
		speaker = 2;
    }else if (value == "loud") {
        color = "#81C784";
		speaker = 3;
    }
    else if (value == "shout"){
		color = "#e53935";
		speaker = 3;
	}
	$('#voice .bg').css('background-color', color);
	$('#voice img').attr('src', 'img/speaker'+speaker+'.png');
}	

function setTalking(value){
	if (value){
		//#64B5F6
		$('#voice div').css('background-color', '#03A9F4')
	}else{
		//#81C784
		$('#voice div').css('background-color', '#fff')
	}
}

//API Shit
function colourGradient(p, rgb_beginning, rgb_end){
    var w = p * 2 - 1;

    var w1 = (w + 1) / 2.0;
    var w2 = 1 - w1;

    var rgb = [parseInt(rgb_beginning[0] * w1 + rgb_end[0] * w2),
        parseInt(rgb_beginning[1] * w1 + rgb_end[1] * w2),
            parseInt(rgb_beginning[2] * w1 + rgb_end[2] * w2)];
    return rgb;
};