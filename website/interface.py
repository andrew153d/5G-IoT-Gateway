from flask import Flask, render_template, request, jsonify
from tcp_latency import measure_latency
import speedtest 

app = Flask(__name__)

def calculate_average(lst):
    if len(lst) == 0:
        return 0
    else:
        return sum(lst) / len(lst)

@app.route('/info/networkStats', methods = ['POST'])
def index2():
    
    
    try:
        genre = request.get_json()['status']
    except:
        print("fail")
    finally:
        servers = []
        s = speedtest.Speedtest()
        s.get_servers(servers)
        s.get_best_server()
        s.download(threads = 2)
        s.upload(threads = 2)
        s.results.share()
        results_dict = s.results.dict()
        return jsonify({'latency':round(results_dict['ping']), 'UL':round(results_dict['upload']/100000), 'DL':round(results_dict['download']/100000)})

@app.route('/')
def index():
    print("index")
    return render_template('index.html')

if __name__ == "__main__":
    
    app.run(host='0.0.0.0', port=5000, debug=True)