from flask import Flask, render_template, request, jsonify, send_file
from tcp_latency import measure_latency
import speedtest
import pandas as pd
import csv
import sys
import threading
import time
import json

sys.path.append("../")
from measure_power.bladeRF_signal_power import *
app = Flask(__name__)

# get the first entry of the last line of the file
def extract_entry_num(csv_file_path):
    with open(csv_file_path, "r") as csv_file:
        csv_reader = csv.reader(csv_file)
        last_line = None
        for line in csv_reader:
            last_line = line
        return last_line[0]

s = speedtest.Speedtest()

def TestUL():
    s.upload()
    return

def TestDL():
    s.download()
    return

def measureNetwork():
    print("Testing Network Speed")
    servers = []
    
    DLThread = threading.Thread(target = TestDL)
    ULThread = threading.Thread(target = TestUL)
    s.get_servers(servers)
    s.get_best_server()
    start = time.time()
    DLThread.start()
    ULThread.start()
    DLThread.join()
    ULThread.join()
    s.results.share()
    results = s.results.dict()
    end = time.time()
    print('Execution Time: {}'.format(end-start))
    return s.results.dict()


# button coming from log section of website
@app.route("/info/log", methods=["POST"])
def log():
    action = request.get_json()["status"]
    # action 0: Log data button
    # action 1: Reset Log
    # action 2: Email Log button
    if action == 0:
        # get the file length
        try:
            with open("MeasuredData.csv", newline="") as csvfile:
                reader = csv.reader(csvfile)
                file_length = len(list(reader))

        except:
            print("no file found")
            file_length = 0

        # measure the latency, UL, DL
        results_dict = measureNetwork()

        # get the last entry number from the file
        lastEntry = extract_entry_num("MeasuredData.csv")
        if lastEntry == "Point":
            newEntry = 0
        else:
            newEntry = int(lastEntry) + 1

        # Write the next row, write header also if the file is empty
        with open("MeasuredData.csv", "a") as file:
            writer = csv.writer(
                file, delimiter=",", quotechar='"', quoting=csv.QUOTE_MINIMAL
            )
            if file_length == 0:
                writer.writerow(["Point", "Latency", "Upload", "Download"])

            writer.writerow(
                [
                    newEntry,
                    round(results_dict["ping"], 2),
                    round(results_dict["upload"] / 1000000, 2),
                    round(results_dict["download"] / 1000000, 2),
                ]
            )

        # return json data to frontend
        return jsonify(
            {
                "latency": round(results_dict["ping"], 2),
                "UL": round(results_dict["upload"] / 1000000, 2),
                "DL": round(results_dict["download"] / 1000000, 2),
            }
        )
    elif action == 1:
        # reset data
        with open("MeasuredData.csv", mode="w") as file:
            writer = csv.writer(
                file, delimiter=",", quotechar='"', quoting=csv.QUOTE_MINIMAL
            )
            writer.writerow(["Point", "Latency", "Upload", "Download"])
    elif action == 2:
        # email data
        print(action)

    return jsonify({"empty": 1})


# Button press from top section
# Measure the network info and return json to frontend
@app.route("/info/networkStats", methods=["POST"])
def netStats():
    try:
        status = request.get_json()["status"]
    except:
        print("fail")
    finally:
        results_dict = measureNetwork()
        return jsonify(
            {
                "latency": round(results_dict["ping"], 2),
                "UL": round(results_dict["upload"] / 1000000, 2),
                "DL": round(results_dict["download"] / 1000000, 2),
            }
        )


# Button press from band section
# Measure the network info and return json to frontend
@app.route("/info/bandPower", methods=["POST"])
def bandPower():
    print("measuring")
    with open('SDRconfig.json', 'r') as f:
        data = json.load(f)
    for band in data['bands']:
        print(f"Name: {band['name']}")
        print(f"Bandwidth: {band['bandwidth']}")
        print(f"Frequency: {band['frequency']}")
        print()
    try:
        bandNum = request.get_json()["bandNum"]
    except:
        print("fail")

    if bandNum == 1:
        power = measure_power(freq=680000000, rate=35000000, gain=1, num_samples=200000)
    elif bandNum == 2:
        power = measure_power(freq=3700000000, rate=35000000, gain=1, num_samples=2000)
    elif bandNum == 3:
        power = measure_power(freq=3500000000, rate=35000000, gain=1, num_samples=2000)
    elif bandNum == 4:
        power = measure_power(freq=4700000000, rate=35000000, gain=1, num_samples=2000)
    else:
        power = 0

    return jsonify({"power": round(power, 3)})


def rebootPi():
    time.sleep(1)
    os.system("sudo reboot")


def shutdownPython():
    time.sleep(1)
    os._exit(0)


rebootThread = threading.Thread(target=rebootPi)
restartThread = threading.Thread(target=shutdownPython)


@app.route("/reboot")
def reboot():
    # I know this wont work
    rebootThread.start()
    return render_template("reboot.html")


@app.route("/shutdown")
def restart():
    # This wont return the page, I need to find a solution to this
    restartThread.start()
    return render_template("reboot.html")


@app.route("/settings")
def settings():
    return render_template("settings.html")


@app.route("/show_data")
def showData():
    # Uploaded File Path
    data_file_path = "MeasuredData.csv"
    # read csv
    uploaded_df = pd.read_csv(data_file_path, encoding="unicode_escape")
    # Converting to html Table
    uploaded_df_html = uploaded_df.to_html()
    return render_template("show_csv.html", data_var=uploaded_df_html)


@app.route("/download")
def downloadFile():
    # For windows you need to use drive name [ex: F:/Example.pdf]
    path = "MeasuredData.csv"
    return send_file(path, as_attachment=True)


@app.route("/")
def index():
    return render_template("index.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
