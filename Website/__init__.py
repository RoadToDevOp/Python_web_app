from flask import Flask
from dotenv import dotenv_values

env_vars = dotenv_values(".env")

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = env_vars.get("FLASK_KEY")
    
    from .views import views
    from .auth import auth
    
    app.register_blueprint(views, url_prefix='/')
    app.register_blueprint(auth, url_prefix='/' )
    
    return app 