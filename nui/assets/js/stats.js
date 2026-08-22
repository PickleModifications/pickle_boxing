function ShowStats(data) {
    let records = [
        data.fighters[0].record.wins + " - " + data.fighters[0].record.losses + " - " + data.fighters[0].record.ties,
        data.fighters[1].record.wins + " - " + data.fighters[1].record.losses + " - " + data.fighters[1].record.ties,
    ]
    let format = `
        <div>
            <img src="assets/images/logo.png"/>
            <div>${data.event.toUpperCase()}</div>
        </div>
        <div>
            <div class="sc-fighter">
                <div style="background-image: url(${data.fighters[0].image})"></div>
                <div>
                    <div>${data.fighters[0].name}</div>
                </div>
            </div>
            <div class="sc-stats">
                <div>
                    <div>${data.fighters[0].age}</div>
                    <div>AGE</div>
                    <div>${data.fighters[1].age}</div>
                </div>
                <div>
                    <div>${records[0]}</div>
                    <div>RECORD</div>
                    <div>${records[1]}</div>
                </div>
                <div>
                    <div>${data.fighters[0].height}</div>
                    <div>HEIGHT</div>
                    <div>${data.fighters[1].height}</div>
                </div>
                <div>
                    <div>${data.fighters[0].weight}</div>
                    <div>WEIGHT</div>
                    <div>${data.fighters[1].weight}</div>
                </div>
            </div>
            <div class="sc-fighter">
                <div style="background-image: url(${data.fighters[1].image})"></div>
                <div>
                    <div>${data.fighters[1].name}</div>
                </div>
            </div>
        </div>
    `
    $("#stats-container").html(format);
    $("#app-stats").fadeIn(1000);
}

function HideStats() {
    $("#app-stats").fadeOut(1000, function() {
        $("#stats-container").html("");
    });
}