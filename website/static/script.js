
//0: log data, 1: reset data, 2: email data
function logData(type) {
    color = document.getElementById("dataRow").style.backgroundColor;
    document.getElementById("dataRow").style.backgroundColor = "#454040";
    const response = fetch('/info/log', {

        method: 'POST',

        body: JSON.stringify({

            'status': type

        }),

        headers: {
            'Content-Type': 'application/json',
        }

    })
        .then(response => response.json())

        .then(jsonResponse => {
            if (type == 0) {
                document.getElementById("latency").innerHTML = "Latency: " + jsonResponse.latency + " ms";
                document.getElementById("UL").innerHTML = "Upload: " + jsonResponse.UL + " Mbps";
                document.getElementById("DL").innerHTML = "Download: " + jsonResponse.DL + " Mbps";
            }

            document.getElementById("dataRow").style.backgroundColor = color;
        })
}


function getNetwork() {
    color = document.getElementById("networkStats").style.backgroundColor;
    document.getElementById("networkStats").style.backgroundColor = "#454040";
    const response = fetch('/info/networkStats', {

        method: 'POST',

        body: JSON.stringify({

            'status': 1

        }),

        headers: {
            'Content-Type': 'application/json',
        }

    })
        .then(response => response.json())

        .then(jsonResponse => {
            document.getElementById("latency").innerHTML = "Latency: " + jsonResponse.latency + " ms";
            document.getElementById("UL").innerHTML = "Upload: " + jsonResponse.UL + " Mbps";
            document.getElementById("DL").innerHTML = "Download: " + jsonResponse.DL + " Mbps";
            document.getElementById("networkStats").style.backgroundColor = color;

        })

}

function shutdownServer() {
    ocument.getElementsByTagName("html")[0].innerHTML
}

function loadPage() {
    fetch('another-page.html')
        .then(response => response.text())
        .then(html => {
            document.open();
            document.write(html);
            document.close();
        });
}

function getBandPower(button) {
    callerID = button.id;
    color = document.getElementById("bandBox").style.backgroundColor;
    document.getElementById("bandBox").style.backgroundColor = "#454040";

    const response = fetch('/info/bandPower', {

        method: 'POST',

        body: JSON.stringify({

            'bandNum': callerID

        }),

        headers: {
            'Content-Type': 'application/json',
        }

    })
        .then(response => response.json())

        .then(jsonResponse => {
            document.getElementById(jsonResponse.name).innerHTML = jsonResponse.name + ": " + jsonResponse.power + " dBm";
            document.getElementById("bandBox").style.backgroundColor = color;
        })

}
