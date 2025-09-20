import os
from flask import Flask, request, render_template, send_from_directory, send_file
from datetime import datetime
from functools import wraps
from glob import glob
import subprocess
import tempfile
import io

IMAGES_FOLDER = os.path.join(os.path.dirname(
    os.path.abspath(__file__)), 'images')
USERNAME = os.environ["SCREENSHOT_RECEIVER_USERNAME"]
PASSWORD = os.environ["SCREENSHOT_RECEIVER_PASSWORD"]

app = Flask(__name__)
app.jinja_env.auto_reload = True
app.config['TEMPLATES_AUTO_RELOAD'] = True


def check_auth(username, password):
    return username == USERNAME and password == PASSWORD


def login_required(f):
    @wraps(f)
    def wrapped_view(**kwargs):
        auth = request.authorization
        if not (auth and check_auth(auth.username, auth.password)):
            return ('Unauthorized', 401, {'WWW-Authenticate': 'Basic realm="Login Required"'})
        return f(**kwargs)

    return wrapped_view


def save_image(source_file, source_ip, is_preview=False):
    dest_dir = os.path.join(IMAGES_FOLDER, str(source_ip))
    os.makedirs(dest_dir, exist_ok=True)

    if is_preview:
        dest_file = 'preview_new.avif'
    else:
        dest_file = datetime.now().isoformat() + '.jxl'

    dest_path = os.path.join(dest_dir, dest_file)
    print(
        f'Receiving {source_file.filename} from {source_ip} into {dest_path}')
    source_file.save(dest_path)

    if is_preview:
        os.replace(dest_path, os.path.join(dest_dir, 'preview.avif'))
    else:
        os.symlink(dest_file, os.path.join(dest_dir, 'latest_new.jxl'))
        os.replace(os.path.join(dest_dir, 'latest_new.jxl'),
                   os.path.join(dest_dir, 'latest.jxl'))


@app.route('/upload', methods=['POST'])
def receive_image():
    if 'file' not in request.files or 'preview' not in request.files:
        print('No file :(')
        return "", 400

    save_image(request.files['file'], request.remote_addr, is_preview=False)
    save_image(request.files['preview'], request.remote_addr, is_preview=True)
    return "", 200


def get_contestant_ips():
    paths = glob(IMAGES_FOLDER + '/*')
    paths = [os.path.basename(x) for x in paths]
    try:
        return sorted(paths, key=lambda x: tuple(map(int, x.split('.'))))
    except:
        return sorted(paths)


def get_timestamp(ip):
    try:
        return str(int(os.path.getmtime(os.path.join(IMAGES_FOLDER, ip, 'preview.avif'))))
    except:
        return "0"


@app.route('/', methods=['GET'])
@login_required
def home():
    data = [{"ip": ip, "ts": get_timestamp(ip)} for ip in get_contestant_ips()]
    return render_template('index.html', data=data)


@app.route('/static/<file>', methods=['GET'])
@login_required
def static_file(file):
    return send_from_directory('./static', file)


@app.route('/images/<path:path>', methods=['GET'])
@login_required
def send_image(path):
    return send_from_directory('images', path)


@app.route('/timestamp/<ip>', methods=['GET'])
@login_required
def send_preview_timestamp(ip):
    return get_timestamp(ip)


@app.route('/latest', methods=['GET'])
@login_required
def show_latest():
    ip = request.args['ip']
    return render_template('detail.html', ip=ip, ts=get_timestamp(ip))


@app.route('/images/<ip>/latest', methods=['GET'])
@login_required
def send_latest_screenshot(ip):
    source_file = os.path.join(IMAGES_FOLDER, ip, 'latest.jxl')
    with tempfile.NamedTemporaryFile(suffix='.png') as tmpfile:
        subprocess.run(['convert', source_file, tmpfile.name])

        with open(tmpfile.name, 'rb') as fin:
            data = fin.read()

    return send_file(
        io.BytesIO(data),
        download_name='screenshot.png',
        mimetype='image/png'
    )
