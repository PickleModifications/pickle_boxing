let knockoutInterval = null;
let knockoutTimer = 0;
let knockoutClicks = 0;
let knockoutRecover = 0;

function KnockoutStart(seconds, recover) {
    if (knockoutInterval) {
        clearInterval(knockoutInterval)
        knockoutInterval = null;
    }
    knockoutTimer = seconds;
    knockoutRecover = recover;
    knockoutClicks = 0;
    let format = `
        <div>KNOCKED OUT</div>
        <div>
            <div>E</div>
            <div id="ak-background"></div>
        </div>
        <div>
            MASH THE 
            <div class="control">
                <div>E</div>
            </div> 
            BUTTON TO GET BACK UP
        </div>
        <div>
            <div id="ak-timer"></div> second(s) remaining.
        </div>
    `
    $("#knockout-container").html(format);
    $("#ak-background").css("margin-top", "100%");
    $("#ak-timer").html(seconds);
    $("#app-knockout").fadeIn(1000);
    knockoutInterval = setInterval(function() {
        knockoutTimer = knockoutTimer - 1;
        if (knockoutTimer <= 0) {
            clearInterval(knockoutInterval)
            knockoutTimer = 0;
            knockoutInterval = null;
        }
        $("#ak-timer").html(knockoutTimer);
    }, 1000);
}

function KnockoutStop() {
    $("#app-knockout").fadeOut(1000, function() {
        $("#ak-background").css("margin-top", "100%");
        if (knockoutInterval) {
            clearInterval(knockoutInterval)
            knockoutInterval = null;
        }
        knockoutTimer = 0;
        knockoutRecover = 0;
        knockoutClicks = 0;
    });
}

function KnockoutKeypress() {
    knockoutClicks = knockoutClicks + 1;
    $("#ak-background").css("margin-top", (100 - Percent(knockoutClicks, knockoutRecover)) + "%");
}