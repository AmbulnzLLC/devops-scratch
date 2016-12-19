from chalice import Chalice

app = Chalice(app_name='buildtrigger')


@app.route('/')
def index():
    return {'hello': 'world'}


@app.route('/appinfo')
def appinfo():
    return {'appname': 'Build Trigger',
            'version': '0.1.0'}

@app.route('/job/{id}')
def jobstatus(id):
    return {'job-id': id}

@app.route('/commit', methods=['PUT'])
def commit():
    return {'echo-body': app.current_request.json_body}

@app.route('/buildstep', methods=['PUT'])
def commit():
    return {'echo-body': app.current_request.json_body}
