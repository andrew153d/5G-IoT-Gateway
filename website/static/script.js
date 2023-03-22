

function getNetwork() {
    color = document.getElementById("networkStats").style.backgroundColor;
    document.getElementById("networkStats").style.backgroundColor = "#454040";
    const response = fetch('/info/networkStats', {

        method: 'POST',

        body: JSON.stringify({

            'status':1

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
