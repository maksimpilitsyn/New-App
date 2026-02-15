from flask import Flask, request, jsonify, Response, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from prometheus_client import Counter, generate_latest
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)

# Настройки папок и БД
UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True) # Создаем папку, если её нет
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://pilicyn:pass123@database:5432/twitter_db'
db = SQLAlchemy(app)

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests')

class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.String(280), nullable=False)
    image_url = db.Column(db.String(500), nullable=True)

# Эндпоинт для загрузки файла
@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file"}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    filename = secure_filename(file.filename)
    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    # ВАЖНО: возвращаем URL, по которому фронтенд найдет картинку
    return jsonify({"image_url": f"http://localhost:5000/uploads/{filename}"}), 201

# Раздача картинок из папки uploads
@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/posts', methods=['GET'])
def get_posts():
    posts = Post.query.all()
    return jsonify([{"id": p.id, "content": p.content, "image_url": p.image_url} for p in posts])

@app.route('/posts', methods=['POST'])
def create_post():
    data = request.json
    new_post = Post(content=data['content'], image_url=data.get('image_url'))
    db.session.add(new_post)
    db.session.commit()
    return jsonify({"message": "Created"}), 201

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype="text/plain")

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
