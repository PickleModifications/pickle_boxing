function ShowFighterStats(data) {
    let format = `
        <div>
            <div style="background-image: url(${data.image})"></div>
        </div>
        <div>
            <div>
                <div>${data.name.toUpperCase()}</div>
            </div>
            <div>
                <div>
                    <div>RECORD</div>
                    <div>${data.record.wins} - ${data.record.losses} - ${data.record.ties}</div>
                </div>
                <div>
                    <div>AGE</div>
                    <div>${data.age}</div>
                </div>
                <div>
                    <div>WEIGHT</div>
                    <div>${data.weight} LBS</div>
                </div>
                <div>
                    <div>HEIGHT</div>
                    <div>${data.height}</div>
                </div>
            </div>
        </div>
    `
    $("#fighterstats-container").html(format);
    $("#app-fighterstats").fadeIn(1000);
}

function HideFighterStats() {
    $("#app-fighterstats").fadeOut(1000, function() {
        $("#fighterstats-container").html("");
    });
}