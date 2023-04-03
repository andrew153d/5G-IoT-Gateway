document.getElementById("oldName").onchange = changeListener;

function changeListener() {
    var value = this.value
    console.log(value);
    
    const response = fetch('/settings/get', {

        method: 'POST',

        body: JSON.stringify({

            'title': value

        }),

        headers: {
            'Content-Type': 'application/json',
        }

    })
        .then(response => response.json())

        .then(jsonResponse => {

            console.log(jsonResponse)
            document.getElementById("newName").value = jsonResponse.name;
            document.getElementById("freq").value = jsonResponse.frequency;
            document.getElementById("rate").value = jsonResponse.rate;
            document.getElementById("gain").value = jsonResponse.gain;
            document.getElementById("samples").value = jsonResponse.samples;
        })
}



function changeBandSettings() {
    // get form data as FormData object
    const formData = new FormData(document.getElementById("bandForm"));

    // convert FormData object to JSON string
    const json = JSON.stringify(Object.fromEntries(formData));

    const response = fetch('/settings/set', {

        method: 'POST',

        body: json,

        headers: {
            'Content-Type': 'application/json',
        }

    })
        .then(response => response.json())

        .then(jsonResponse => {



        })
}


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
