from flask import Flask
import redis, os

app = Flask(__name__)
redis_host = os.getenv('REDIS_HOST')
redis_client = redis.Redis(host=redis_host, port=6379, db=0, decode_responses=True)

@app.route('/')
def index():
    count = redis_client.incr('counter')
    return f'This is the {count} visitor'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)