from flask import Flask, render_template, request, jsonify
from tcp_latency import measure_latency
import speedtest 
import csv

app = Flask(__name__)

def extract_entry_num(csv_file_path):
    with open(csv_file_path, 'r') as csv_file:
        csv_reader = csv.reader(csv_file)
        last_line = None
        for line in csv_reader:
            last_line = line
        return last_line[0]

def measureNetwork():
    print("evaluating Network")
    servers = []
    s = speedtest.Speedtest()
    s.get_servers(servers)
    s.get_best_server()
    s.download(threads = 2)
    s.upload(threads = 2)
    s.results.share()
    return s.results.dict()

@app.route('/info/log', methods = ['POST'])
def log():
    action = request.get_json()['status']
    
    if(action == 0):
        # log data
        try:
            with open('MeasuredData.csv', newline='') as csvfile:
                reader = csv.reader(csvfile)
                file_length = len(list(reader))
            
        except:
            print("no file found")
            file_length = 0
        
        results_dict = measureNetwork()

        lastEntry = extract_entry_num('MeasuredData.csv')
        if(lastEntry == 'Point'):
            newEntry = 0
        else:
            newEntry = int(lastEntry)+1

        with open('MeasuredData.csv', 'a') as file:
            writer = csv.writer(file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            if(file_length == 0):
                writer.writerow(['Point', 'Latency', 'Upload', 'Download'])  
            
            writer.writerow([newEntry, round(results_dict['ping']), round(results_dict['upload']/100000), round(results_dict['download']/100000)])    
            print("writing")
        
        
        
        return jsonify({'latency':round(results_dict['ping']), 'UL':round(results_dict['upload']/100000), 'DL':round(results_dict['download']/100000)})
    elif(action == 1):
        # reset data
        with open('MeasuredData.csv', mode = 'w') as file:
            writer = csv.writer(file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            writer.writerow(['Point', 'Latency', 'Upload', 'Download'])      
            print("clearing")
    elif(action == 2):
        # email data
        print(action)

    return jsonify({'empty': 1})

    
    

@app.route('/info/networkStats', methods = ['POST'])
def index2():
    
    try:
        status = request.get_json()['status']
    except:
        print("fail")
    finally:
        results_dict = measureNetwork()
        return jsonify({'latency':round(results_dict['ping']), 'UL':round(results_dict['upload']/100000), 'DL':round(results_dict['download']/100000)})

@app.route('/')
def index():
    print("index")
    return render_template('index.html')

if __name__ == "__main__":
    
    app.run(host='0.0.0.0', port=5000, debug=True)