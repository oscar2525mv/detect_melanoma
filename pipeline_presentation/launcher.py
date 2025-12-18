import http.server
import socketserver
import subprocess
import os
import json
import threading

PORT = 8000
DIRECTORY = "."

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/launch':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            # Run commands in a separate thread to not block the server
            threading.Thread(target=self.launch_app).start()
            
            response = {"status": "success", "message": "Commandes lancées !"}
            self.wfile.write(json.dumps(response).encode())
        else:
            super().do_POST()

    def launch_app(self):
        print("🔹 Réception de la demande de lancement...")
        try:
            # Step 1: Launch Emulator
            print("🚀 Lancement de l'émulateur...")
            subprocess.Popen(
                ["flutter", "emulators", "--launch", "Medium_Phone_API_36.1"],
                cwd="..",  # Go up one level to project root
                shell=True
            )
            
            # Step 2: Run App (Wait a bit or run immediately, flutter run waits for device usually)
            print("📱 Lancement de l'application...")
            subprocess.Popen(
                ["flutter", "run"],
                cwd="..", # Go up one level to project root
                shell=True
            )
            print("✅ Commandes envoyées.")
        except Exception as e:
            print(f"❌ Erreur lors du lancement : {e}")

print(f"🌍 Serveur démarré sur http://localhost:{PORT}")
print("📂 Dossier servi :", os.path.abspath(DIRECTORY))

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.serve_forever()
