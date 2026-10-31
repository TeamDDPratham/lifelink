import os
import sys
from urllib.parse import parse_qs

# Add project root directory to python path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app


class VercelPathMiddleware:
    def __init__(self, wsgi_app):
        self.wsgi_app = wsgi_app

    def __call__(self, environ, start_response):
        # Extract the real path passed via query parameter from vercel.json rewrite
        qs = environ.get("QUERY_STRING", "")
        if qs:
            params = parse_qs(qs)
            if "__vercel_path" in params:
                target_path = params["__vercel_path"][0]
                if not target_path.startswith("/"):
                    target_path = "/" + target_path
                # Clean multiple leading slashes
                while target_path.startswith("//"):
                    target_path = target_path[1:]
                environ["PATH_INFO"] = target_path

        elif environ.get("PATH_INFO") == "/api/index":
            environ["PATH_INFO"] = "/"

        return self.wsgi_app(environ, start_response)


app.wsgi_app = VercelPathMiddleware(app.wsgi_app)
