from flask import Flask, request
import redis, os

app = Flask(__name__)
redis_host = os.getenv('REDIS_HOST')
redis_client = redis.Redis(host=redis_host, port=6379, db=0, decode_responses=True)

@app.route('/')
def index():
    user_agent = request.headers.get('User-Agent', '')
    # Assuming ALB health check user-agent contains 'ELB-HealthChecker'
    if 'ELB-HealthChecker' not in user_agent:
        count = redis_client.incr('counter')
        return f'This is the {count} visitor dog'
    return 'Health check', 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)