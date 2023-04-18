function sendCommand(event) {
    event.preventDefault(); // prevent form submission
    // get form data as FormData object
    const formData = new FormData(document.getElementById("commandForm"));

    // convert FormData object to JSON string
    const json = JSON.stringify(Object.fromEntries(formData));
    document.getElementById("commandForm")
    const response = fetch('/execShell', {

        method: 'POST',

        body: json,

        headers: {
            'Content-Type': 'application/json',
        }
    })
        .then(response => response.json())

        .then(jsonResponse => {
            document.getElementById("output").innerHTML += '<br>' + jsonResponse.user + ' ' + jsonResponse.dir + ' ' + jsonResponse.command + ' ' + jsonResponse.output;
            document.getElementById("command").value = ''; // clear the input field
            console.log(jsonResponse);
        })

}

function loadDir() {
    const response = fetch('/dir', {

        method: 'POST',

        body: JSON.stringify({

            'status': 0

        }),

        headers: {
            'Content-Type': 'application/json',
        }
    })
        .then(response => response.json())

        .then(jsonResponse => {
            document.getElementById("output").innerHTML += jsonResponse.dir;
            document.getElementById("command").value = ''; // clear the input field
        })
}

document.onload += loadDir();