#!/usr/bin/env python3
"""
FinWise Real-Time Multi-Device Sync Server
Serves static web files and provides cross-device real-time synchronization for:
- /api/accounts (GET, POST)
- /api/register (POST)
- /api/login (POST)
- /api/transactions (GET, POST)
- /api/transactions/version (GET)
- /api/events (SSE - Server-Sent Events for instant push updates across phones)
"""

import sys
import os
import json
import time
import urllib.parse
from http.server import HTTPServer, SimpleHTTPRequestHandler
import threading

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
WEB_DIR = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")
DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")

os.makedirs(DATA_DIR, exist_ok=True)
ACCOUNTS_FILE = os.path.join(DATA_DIR, "accounts.json")
SHARED_TX_FILE = os.path.join(DATA_DIR, "transactions_shared.json")

DEFAULT_PASSWORD_HASH = "989a2c9493e8051c86a809ae60c025b6fff7a79de475aa91ebac2e2b562fb322"

# Global real-time version tracking
TX_VERSION_LOCK = threading.Lock()
GLOBAL_TX_VERSION = 1
GLOBAL_LAST_UPDATED = time.time()

# Active SSE client connections
SSE_CLIENTS = []
SSE_LOCK = threading.Lock()

def get_current_date_str():
    return time.strftime("%Y-%m-%d")

def get_seed_transactions():
    today = get_current_date_str()
    # Timestamps relative to today
    d1 = time.strftime("%Y-%m-%d", time.localtime(time.time() - 86400 * 1))
    d2 = time.strftime("%Y-%m-%d", time.localtime(time.time() - 86400 * 2))
    d3 = time.strftime("%Y-%m-%d", time.localtime(time.time() - 86400 * 4))
    d4 = time.strftime("%Y-%m-%d", time.localtime(time.time() - 86400 * 5))

    return [
        {
            "id": "tx_seed_001",
            "title": "Monthly Tech Salary",
            "description": "Monthly Tech Salary",
            "amount": 4800.00,
            "type": "income",
            "category": "Salary",
            "category_id": "salary",
            "date": today,
            "created_at": today + "T08:00:00Z"
        },
        {
            "id": "tx_seed_002",
            "title": "Village Grocer Weekly",
            "description": "Village Grocer Weekly",
            "amount": 142.50,
            "type": "expense",
            "category": "Groceries",
            "category_id": "groceries",
            "date": today,
            "created_at": today + "T10:30:00Z"
        },
        {
            "id": "tx_seed_003",
            "title": "Coffee & Bistro Lunch",
            "description": "Coffee & Bistro Lunch",
            "amount": 28.00,
            "type": "expense",
            "category": "Food & Dining",
            "category_id": "food_dining",
            "date": d1,
            "created_at": d1 + "T12:15:00Z"
        },
        {
            "id": "tx_seed_004",
            "title": "Electricity & Water Utilities",
            "description": "Electricity & Water Utilities",
            "amount": 115.80,
            "type": "expense",
            "category": "Bills & Utilities",
            "category_id": "bills_utilities",
            "date": d2,
            "created_at": d2 + "T09:00:00Z"
        },
        {
            "id": "tx_seed_005",
            "title": "Freelance Mobile Consulting",
            "description": "Freelance Mobile Consulting",
            "amount": 750.00,
            "type": "income",
            "category": "Freelance",
            "category_id": "freelance",
            "date": d3,
            "created_at": d3 + "T15:45:00Z"
        },
        {
            "id": "tx_seed_006",
            "title": "Touch N Go / Transit Reload",
            "description": "Touch N Go / Transit Reload",
            "amount": 50.00,
            "type": "expense",
            "category": "Transportation",
            "category_id": "transportation",
            "date": d4,
            "created_at": d4 + "T08:30:00Z"
        }
    ]

def load_accounts():
    if not os.path.exists(ACCOUNTS_FILE):
        seed_accounts = {
            "demo@finwise-app.xyz": {
                "id": "00000000-0000-4000-8000-000000000001",
                "name": "Demo Finwise",
                "email": "demo@finwise-app.xyz",
                "phone": "",
                "occupation": "",
                "currency": "RM",
                "monthlyBudget": 2500.0,
                "passwordHash": DEFAULT_PASSWORD_HASH,
                "avatar": "D"
            }
        }
        save_accounts(seed_accounts)
        return seed_accounts
    try:
        with open(ACCOUNTS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}

def save_accounts(accounts):
    try:
        with open(ACCOUNTS_FILE, "w", encoding="utf-8") as f:
            json.dump(accounts, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"[FinWise Server] Error saving accounts: {e}")

def load_shared_transactions():
    if not os.path.exists(SHARED_TX_FILE):
        seeds = get_seed_transactions()
        save_shared_transactions(seeds, broadcast=False)
        return seeds
    try:
        with open(SHARED_TX_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data if isinstance(data, list) else []
    except Exception:
        return []

def save_shared_transactions(tx_list, broadcast=True):
    global GLOBAL_TX_VERSION, GLOBAL_LAST_UPDATED
    try:
        with open(SHARED_TX_FILE, "w", encoding="utf-8") as f:
            json.dump(tx_list, f, indent=2, ensure_ascii=False)
        with TX_VERSION_LOCK:
            GLOBAL_TX_VERSION += 1
            GLOBAL_LAST_UPDATED = time.time()
        if broadcast:
            broadcast_sse_event({"event": "tx_updated", "version": GLOBAL_TX_VERSION, "count": len(tx_list)})
    except Exception as e:
        print(f"[FinWise Server] Error saving shared transactions: {e}")

def broadcast_sse_event(data):
    payload = f"data: {json.dumps(data)}\n\n".encode("utf-8")
    with SSE_LOCK:
        dead = []
        for client in SSE_CLIENTS:
            try:
                client.wfile.write(payload)
                client.wfile.flush()
            except Exception:
                dead.append(client)
        for d in dead:
            if d in SSE_CLIENTS:
                SSE_CLIENTS.remove(d)

class FinWiseHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, DELETE")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, Bypass-Tunnel-Reminder")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200, "ok")
        self.end_headers()

    def _send_json(self, status_code, data):
        body = json.dumps(data).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        # 1. Accounts list for multi-device sync
        if path == "/api/accounts":
            accounts = load_accounts()
            safe_accounts = {}
            for email, acc in accounts.items():
                safe_accounts[email] = {
                    "id": acc.get("id"),
                    "name": acc.get("name"),
                    "email": acc.get("email"),
                    "phone": acc.get("phone", ""),
                    "occupation": acc.get("occupation", ""),
                    "currency": acc.get("currency", "RM"),
                    "monthlyBudget": acc.get("monthlyBudget", 2500.0),
                    "avatar": acc.get("avatar", ""),
                    "passwordHash": acc.get("passwordHash", "")
                }
            self._send_json(200, {"success": True, "accounts": safe_accounts})
            return

        # 2. Real-time version check for lightweight polling (2ms response time)
        if path in ("/api/transactions/version", "/api/version", "/api/sync/version"):
            tx_list = load_shared_transactions()
            self._send_json(200, {
                "success": True,
                "version": GLOBAL_TX_VERSION,
                "lastUpdated": GLOBAL_LAST_UPDATED,
                "count": len(tx_list)
            })
            return

        # 3. Synchronized transactions endpoint (Unified across all phones)
        if path == "/api/transactions":
            query = urllib.parse.parse_qs(parsed.query)
            email = (query.get("email", [""])[0] or "").lower().strip()

            # Always return the unified shared transactions ledger
            tx_data = load_shared_transactions()

            # If user has an explicit custom list in their user file, load it;
            # if user list is empty, initialize it with the shared ledger
            if email:
                safe_name = "".join(c for c in email if c.isalnum() or c in "_-")
                user_file = os.path.join(DATA_DIR, f"transactions_{safe_name}.json")
                if os.path.exists(user_file):
                    try:
                        with open(user_file, "r", encoding="utf-8") as f:
                            custom_data = json.load(f)
                            if isinstance(custom_data, list) and len(custom_data) > 0:
                                tx_data = custom_data
                    except Exception:
                        pass
                else:
                    # Automatically sync the user file with shared ledger so all devices have data
                    try:
                        with open(user_file, "w", encoding="utf-8") as f:
                            json.dump(tx_data, f, indent=2, ensure_ascii=False)
                    except Exception:
                        pass

            self._send_json(200, {
                "success": True,
                "version": GLOBAL_TX_VERSION,
                "lastUpdated": GLOBAL_LAST_UPDATED,
                "transactions": tx_data
            })
            return

        # 4. Server-Sent Events (SSE) for Real-Time Push Updates
        if path == "/api/events":
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Connection", "keep-alive")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()

            # Initial handshake event
            init_msg = f"data: {json.dumps({'event': 'connected', 'version': GLOBAL_TX_VERSION})}\n\n".encode("utf-8")
            self.wfile.write(init_msg)
            self.wfile.flush()

            with SSE_LOCK:
                SSE_CLIENTS.append(self)

            try:
                while True:
                    time.sleep(15)
                    # Keep-alive heartbeat
                    heartbeat = f": heartbeat {time.time()}\n\n".encode("utf-8")
                    self.wfile.write(heartbeat)
                    self.wfile.flush()
            except Exception:
                pass
            finally:
                with SSE_LOCK:
                    if self in SSE_CLIENTS:
                        SSE_CLIENTS.remove(self)
            return

        super().do_GET()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else "{}"
        try:
            payload = json.loads(body)
        except Exception:
            payload = {}

        if path in ("/api/register", "/api/accounts"):
            email = (payload.get("email") or "").lower().strip()
            name = (payload.get("name") or "").strip()
            password_hash = payload.get("passwordHash") or ""
            user_id = payload.get("id") or ""
            avatar = payload.get("avatar") or ""
            phone = payload.get("phone") or ""
            occupation = payload.get("occupation") or ""
            currency = payload.get("currency") or "RM"
            monthly_budget = payload.get("monthlyBudget", 2500.0)

            if not email:
                self._send_json(400, {"success": False, "message": "Email is required."})
                return

            if not user_id:
                h = abs(sum((ord(c) * (31 ** i)) for i, c in enumerate(email)))
                user_id = f"00000000-0000-4000-8000-{h:012x}"[-36:]

            accounts = load_accounts()
            accounts[email] = {
                "id": user_id,
                "name": name or email.split("@")[0],
                "email": email,
                "passwordHash": password_hash or DEFAULT_PASSWORD_HASH,
                "avatar": avatar,
                "phone": phone,
                "occupation": occupation,
                "currency": currency,
                "monthlyBudget": monthly_budget
            }
            save_accounts(accounts)
            print(f"[FinWise Server] Registered/Updated account across devices: {email} ({name})")
            self._send_json(200, {"success": True, "message": "Account registered successfully", "account": accounts[email]})
            return

        if path == "/api/login":
            email = (payload.get("email") or "").lower().strip()
            password_hash = payload.get("passwordHash") or ""

            if not email:
                self._send_json(400, {"success": False, "message": "Email is required."})
                return

            accounts = load_accounts()
            if email not in accounts:
                self._send_json(404, {"success": False, "message": "No account found with this email. Please register first."})
                return

            acc = accounts[email]
            if password_hash and acc.get("passwordHash") and acc["passwordHash"] != password_hash:
                self._send_json(401, {"success": False, "message": "Incorrect password. Please try again."})
                return

            self._send_json(200, {"success": True, "message": "Login successful", "account": acc})
            return

        # Save or modify synchronized transactions (Live Multi-Device Push)
        if path == "/api/transactions":
            email = (payload.get("email") or "").lower().strip()
            tx_data = payload.get("transactions")

            # Case A: Full transaction list update
            if isinstance(tx_data, list):
                # Save to shared unified ledger
                save_shared_transactions(tx_data, broadcast=True)

                # Also save to user specific partition
                if email:
                    safe_name = "".join(c for c in email if c.isalnum() or c in "_-")
                    user_file = os.path.join(DATA_DIR, f"transactions_{safe_name}.json")
                    try:
                        with open(user_file, "w", encoding="utf-8") as f:
                            json.dump(tx_data, f, indent=2, ensure_ascii=False)
                    except Exception:
                        pass

                print(f"[FinWise Server] Synced {len(tx_data)} transactions across all devices. Version: {GLOBAL_TX_VERSION}")
                self._send_json(200, {
                    "success": True,
                    "message": "Transactions synchronized across devices",
                    "version": GLOBAL_TX_VERSION
                })
                return

            # Case B: Single transaction upsert
            single_tx = payload.get("transaction")
            if isinstance(single_tx, dict) and single_tx.get("id"):
                existing = load_shared_transactions()
                found = False
                for idx, item in enumerate(existing):
                    if item.get("id") == single_tx.get("id"):
                        existing[idx] = single_tx
                        found = True
                        break
                if not found:
                    existing.insert(0, single_tx)

                save_shared_transactions(existing, broadcast=True)

                if email:
                    safe_name = "".join(c for c in email if c.isalnum() or c in "_-")
                    user_file = os.path.join(DATA_DIR, f"transactions_{safe_name}.json")
                    try:
                        with open(user_file, "w", encoding="utf-8") as f:
                            json.dump(existing, f, indent=2, ensure_ascii=False)
                    except Exception:
                        pass

                print(f"[FinWise Server] Realtime upsert transaction: {single_tx.get('id')}. Version: {GLOBAL_TX_VERSION}")
                self._send_json(200, {
                    "success": True,
                    "message": "Transaction upserted and synchronized",
                    "version": GLOBAL_TX_VERSION
                })
                return

            # Case C: Delete transaction
            delete_id = payload.get("delete_id")
            if delete_id:
                existing = load_shared_transactions()
                existing = [t for t in existing if t.get("id") != delete_id]
                save_shared_transactions(existing, broadcast=True)

                if email:
                    safe_name = "".join(c for c in email if c.isalnum() or c in "_-")
                    user_file = os.path.join(DATA_DIR, f"transactions_{safe_name}.json")
                    try:
                        with open(user_file, "w", encoding="utf-8") as f:
                            json.dump(existing, f, indent=2, ensure_ascii=False)
                    except Exception:
                        pass

                print(f"[FinWise Server] Realtime deleted transaction: {delete_id}. Version: {GLOBAL_TX_VERSION}")
                self._send_json(200, {
                    "success": True,
                    "message": "Transaction deleted and synchronized",
                    "version": GLOBAL_TX_VERSION
                })
                return

            self._send_json(400, {"success": False, "message": "Invalid transaction payload"})
            return

        self._send_json(404, {"success": False, "message": "Endpoint not found"})

def run():
    load_accounts()
    load_shared_transactions()
    server_address = ("0.0.0.0", PORT)
    try:
        from http.server import ThreadingHTTPServer
        httpd = ThreadingHTTPServer(server_address, FinWiseHandler)
    except Exception:
        httpd = HTTPServer(server_address, FinWiseHandler)

    print(f"[FinWise Server] Running on http://0.0.0.0:{PORT} serving '{WEB_DIR}'")
    print(f"[FinWise Server] Real-Time Sync API active at /api/transactions, /api/events, /api/transactions/version")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[FinWise Server] Stopped.")
        httpd.server_close()

if __name__ == "__main__":
    run()
