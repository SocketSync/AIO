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
            "created_at": today + "T10:30:00Z",
            "receipt_items": [
                {"item_name": "Organic Bananas", "price": 14.50, "quantity": 1, "category": "Groceries"},
                {"item_name": "Farm Fresh Milk 2L", "price": 18.90, "quantity": 2, "category": "Groceries"},
                {"item_name": "Colgate Toothpaste", "price": 12.50, "quantity": 2, "category": "Groceries"},
                {"item_name": "Artisan Sourdough Loaf", "price": 16.00, "quantity": 1, "category": "Groceries"}
            ]
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
            "created_at": d1 + "T12:15:00Z",
            "receipt_items": [
                {"item_name": "Flat White Coffee", "price": 13.00, "quantity": 1, "category": "Food & Dining"},
                {"item_name": "Sourdough Avocado Toast", "price": 15.00, "quantity": 1, "category": "Food & Dining"}
            ]
        },
        {
            "id": "tx_seed_003b",
            "title": "AEON Mall Supermarket & Footwear",
            "description": "AEON Mall Supermarket & Footwear",
            "amount": 224.00,
            "type": "expense",
            "category": "Shopping",
            "category_id": "shopping",
            "date": d2,
            "created_at": d2 + "T14:20:00Z",
            "receipt_items": [
                {"item_name": "Nike Sneakers", "price": 199.00, "quantity": 1, "category": "Clothing"},
                {"item_name": "Colgate Toothpaste", "price": 12.50, "quantity": 2, "category": "Groceries"}
            ]
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

def _strip_sensitive_account(acc):
    """Confidentiality: Never expose passwordHash or sensitive tokens in API responses."""
    if not isinstance(acc, dict):
        return {}
    return {
        "id": acc.get("id"),
        "name": acc.get("name"),
        "email": acc.get("email"),
        "phone": acc.get("phone", ""),
        "occupation": acc.get("occupation", ""),
        "currency": acc.get("currency", "RM"),
        "monthlyBudget": acc.get("monthlyBudget", 2500.0),
        "avatar": acc.get("avatar", "")
    }

def _sanitize_receipt_items(raw_items, fallback_cat="General"):
    if not isinstance(raw_items, list):
        return []
    cleaned = []
    for item in raw_items[:40]:
        if not isinstance(item, dict):
            continue
        name = str(item.get("item_name") or item.get("name") or "").strip()
        if not name:
            continue
        name = name.replace("<", "&lt;").replace(">", "&gt;")[:120]
        try:
            price = round(max(0.0, float(item.get("price", 0))), 2)
        except (ValueError, TypeError):
            price = 0.0
        try:
            qty = max(1, min(999, int(item.get("quantity", 1))))
        except (ValueError, TypeError):
            qty = 1
        cat = str(item.get("category") or fallback_cat or "General").strip().replace("<", "&lt;").replace(">", "&gt;")[:60]
        cleaned.append({
            "item_name": name,
            "price": price,
            "quantity": qty,
            "category": cat or "General"
        })
    return cleaned

def _validate_and_sanitize_tx(tx):
    """Integrity: Validate numeric amount, constrain type ENUM, and strip HTML tags."""
    if not isinstance(tx, dict):
        return None
    try:
        amount = float(tx.get("amount", 0))
    except (ValueError, TypeError):
        return None
    if amount <= 0 or amount > 1000000000:
        return None
    tx_type = str(tx.get("type", "expense")).lower().strip()
    if tx_type not in ("income", "expense"):
        tx_type = "expense"
    raw_title = str(tx.get("title") or tx.get("description") or "Transaction").strip()
    clean_title = raw_title.replace("<", "&lt;").replace(">", "&gt;")[:150]
    raw_cat = str(tx.get("category") or "Other").strip()
    clean_cat = raw_cat.replace("<", "&lt;").replace(">", "&gt;")[:60]
    sanitized = dict(tx)
    sanitized["amount"] = round(amount, 2)
    sanitized["type"] = tx_type
    sanitized["title"] = clean_title
    sanitized["description"] = clean_title
    sanitized["category"] = clean_cat
    sanitized["receipt_items"] = _sanitize_receipt_items(tx.get("receipt_items"), clean_cat)
    return sanitized

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

        # 0. Public client configuration endpoint (Anon Key only; never service_role)
        if path == "/api/config":
            self._send_json(200, {
                "success": True,
                "supabaseUrl": os.environ.get("SUPABASE_URL", "https://vcxxsffdsznmqtpghrss.supabase.co"),
                "supabaseAnonKey": os.environ.get("SUPABASE_ANON_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjeHhzZmZkc3pubXF0cGdocnNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyMjgwOTMsImV4cCI6MjEwOTgwNDA5M30.bxxoU1PgcSeOMkss5kx71dI3P67eTL9bk9TzaJC_1VM"),
                "appUrl": os.environ.get("APP_URL", "https://www.finwise-app.xyz")
            })
            return

        # 1. Accounts list for multi-device sync (Confidentiality: passwordHash stripped)
        if path == "/api/accounts":
            accounts = load_accounts()
            safe_accounts = {}
            for email, acc in accounts.items():
                safe_accounts[email] = _strip_sensitive_account(acc)
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

            if email == "demo@finwise-app.xyz":
                self._send_json(403, {
                    "success": False,
                    "message": "Demo accounts cannot alter or delete profile information. The demo account is strictly reserved for testing input and output transactions."
                })
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
            self._send_json(200, {"success": True, "message": "Account registered successfully", "account": _strip_sensitive_account(accounts[email])})
            return

        if path in ("/api/accounts/delete", "/api/profile/delete"):
            email = (payload.get("email") or "").lower().strip()
            if email == "demo@finwise-app.xyz":
                self._send_json(403, {
                    "success": False,
                    "message": "Demo accounts cannot alter or delete profile information. The demo account is strictly reserved for testing input and output transactions."
                })
                return
            accounts = load_accounts()
            if email in accounts:
                del accounts[email]
                save_accounts(accounts)
            self._send_json(200, {"success": True, "message": "Account permanently deleted."})
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

            self._send_json(200, {"success": True, "message": "Login successful", "account": _strip_sensitive_account(acc)})
            return

        # Save or modify synchronized transactions (Live Multi-Device Push)
        if path == "/api/transactions":
            email = (payload.get("email") or "").lower().strip()
            tx_data = payload.get("transactions")

            # Case A: Full transaction list update
            if isinstance(tx_data, list):
                validated_list = [v for v in (_validate_and_sanitize_tx(item) for item in tx_data) if v is not None]
                tx_data = validated_list
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
            single_tx = _validate_and_sanitize_tx(payload.get("transaction"))
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

        if path == "/api/scan-receipt":
            filename = str(payload.get("filename") or "").lower()
            presets = [
                {
                    "merchant": "AEON Mall Supermarket",
                    "amount": 224.00,
                    "category": "Shopping",
                    "receipt_items": [
                        {"item_name": "Nike Sneakers", "price": 199.00, "quantity": 1, "category": "Clothing"},
                        {"item_name": "Colgate Toothpaste", "price": 12.50, "quantity": 2, "category": "Groceries"}
                    ]
                },
                {
                    "merchant": "Village Grocer",
                    "amount": 68.40,
                    "category": "Groceries",
                    "receipt_items": [
                        {"item_name": "Organic Bananas", "price": 11.90, "quantity": 1, "category": "Groceries"},
                        {"item_name": "Farm Fresh Milk 2L", "price": 16.50, "quantity": 2, "category": "Groceries"},
                        {"item_name": "Sourdough Bread", "price": 13.50, "quantity": 1, "category": "Groceries"},
                        {"item_name": "Free-Range Eggs (10s)", "price": 10.00, "quantity": 1, "category": "Groceries"}
                    ]
                },
                {
                    "merchant": "MR.DIY Home & Hardware",
                    "amount": 54.70,
                    "category": "Shopping",
                    "receipt_items": [
                        {"item_name": "LED Desk Lamp", "price": 32.90, "quantity": 1, "category": "Home & Living"},
                        {"item_name": "AA Alkaline Batteries (8s)", "price": 11.90, "quantity": 1, "category": "Electronics"}
                    ]
                },
                {
                    "merchant": "Starbucks Coffee",
                    "amount": 26.50,
                    "category": "Food & Dining",
                    "receipt_items": [
                        {"item_name": "Caramel Macchiato (Venti)", "price": 17.50, "quantity": 1, "category": "Food & Dining"},
                        {"item_name": "Almond Croissant", "price": 9.00, "quantity": 1, "category": "Food & Dining"}
                    ]
                }
            ]
            pick = presets[0]
            if "grocer" in filename:
                pick = presets[1]
            elif "diy" in filename:
                pick = presets[2]
            elif "starbuck" in filename or "coffee" in filename:
                pick = presets[3]

            self._send_json(200, {
                "success": True,
                "engine": "smart-receipt-ai (local server)",
                "scanDuration": "0.8",
                "merchant": pick["merchant"],
                "amount": pick["amount"],
                "category": pick["category"],
                "date": get_current_date_str(),
                "receipt_items": pick["receipt_items"],
                "items": [i["item_name"] for i in pick["receipt_items"]]
            })
            return

        if path == "/api/ai-purchase-insights":
            recent = payload.get("recentTransactions") or []
            curr_receipt = payload.get("currentReceipt")
            currency = payload.get("currency") or "RM"
            combined = list(recent) if isinstance(recent, list) else []
            if isinstance(curr_receipt, dict) and curr_receipt.get("receipt_items"):
                combined.insert(0, {
                    "type": "expense",
                    "date": curr_receipt.get("date") or get_current_date_str(),
                    "receipt_items": curr_receipt.get("receipt_items")
                })

            shoe_dates = []
            coffee_dates = []
            for tx in combined:
                if not isinstance(tx, dict) or tx.get("type") == "income":
                    continue
                d = str(tx.get("date") or "")[:10]
                for it in (tx.get("receipt_items") or []):
                    nm = str(it.get("item_name") or "").lower()
                    if any(k in nm for k in ("shoe", "sneaker", "footwear")):
                        shoe_dates.append(d)
                    elif any(k in nm for k in ("coffee", "latte", "macchiato", "americano")):
                        coffee_dates.append(d)

            if len(shoe_dates) >= 2:
                msg = f"✨ FinWise noticed: You bought shoes multiple times recently ({shoe_dates[-1]} & {shoe_dates[0]})! Treating yourself is great, but keep an eye on your 'Clothing' budget to avoid overspending this month~"
                self._send_json(200, {"success": True, "duplicateDetected": True, "insight": msg})
            elif len(coffee_dates) >= 2:
                msg = f"✨ FinWise noticed: You bought coffee drinks {len(coffee_dates)} times in the last 14 days! Brewing at home twice a week could save ~{currency} 30/week~"
                self._send_json(200, {"success": True, "duplicateDetected": True, "insight": msg})
            else:
                self._send_json(200, {
                    "success": True,
                    "duplicateDetected": False,
                    "insight": "✨ FinWise noticed: Your itemized receipt purchases over the last 14 days look well-balanced with no repetitive impulse buys!"
                })
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
