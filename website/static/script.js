

function getNetwork() {
    color = document.getElementById("networkStats").style.backgroundColor;
    document.getElementById("networkStats").style.backgroundColor = "#454040";
    const response = fetch('/info/networkStats', {

        method: 'POST',

        body: JSON.stringify({

            'title': 10,

            'description': 1,

            'yor': 2,

            'publisher': 3,

            'genre': 4

        }),

        headers: {
            'Content-Type': 'application/json',
        }

    })
        .then(response => response.json())

        .then(jsonResponse => {

            document.getElementById("networkStats").style.backgroundColor = color;

        })

}
