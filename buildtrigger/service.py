from chalice import Chalice

app = Chalice(app_name='buildtrigger')

@app.route('/appinfo')
def appinfo():
    return { 'appname': 'Build Trigger',
             'version': '0.1.0' }
