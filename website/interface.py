from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

@app.route('/info/networkStats', methods = ['POST'])
def index2():
    try:
        genre = request.get_json()['title']
        print(genre)
    except:
        print("fail")
    finally:
        return jsonify({'title':4, 'id':5})

@app.route('/')
def index():
    print("index")
    return render_template('index.html')

if __name__ == "__main__":
    
    app.run(host='0.0.0.0', port=80, debug=True)