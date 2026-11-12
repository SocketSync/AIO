# 🧪 FinWise — Security, Authentication & CRUD Testing Report

**Project**: FinWise Smart Financial Management System  
**Status**: All Test Suites Passed

---

## 📋 1. Executive Summary

This report documents verification of the FinWise web and mobile application across Authentication, Real-Time Transaction CRUD, and the **CIA Triad (Confidentiality, Integrity, Availability)** security requirements.

| Category | Total Cases | Passed | Failed | Pass Rate |
| :--- | :---: | :---: | :---: | :---: |
| **Confidentiality (RLS, Secrets & Auth State)** | 5 | 5 | 0 | **100%** |
| **Integrity (Validation, XSS Sanitization & DB Constraints)** | 6 | 6 | 0 | **100%** |
| **Availability (Timeouts, Retries & Error Handling)** | 5 | 5 | 0 | **100%** |
| **Total** | **16** | **16** | **0** | **100%** |

---

## 🔐 2. Detailed Test Cases

### Confidentiality
- **TC-01: Secrets & PII Audit** — Verified zero hardcoded private API keys, `service_role` keys, or personal user records in tracked files; `.env` and `data/*.json` are listed in `.gitignore`.
- **TC-02: Row Level Security (RLS)** — Verified `public.profiles`, `public.transactions`, and `public.categories` enforce `auth.uid() = user_id` / `auth.uid() = id`.
- **TC-03: Password Hash Stripping** — Verified `/api/accounts`, `/api/login`, and `/api/register` never expose `passwordHash` in JSON responses.
- **TC-04: Secure Logout State** — Verified logging out calls `supabase.auth.signOut()` and clears `localStorage` and `sessionStorage` session keys.
- **TC-05: Scoped Queries** — Verified all transaction and profile queries filter strictly by the authenticated user's `user_id`.

### Integrity
- **TC-06: Numeric Amount Validation** — Verified negative, zero, `NaN`, or infinite transaction amounts are rejected by both frontend forms and PostgreSQL `CHECK (amount > 0)` constraints.
- **TC-07: Transaction Type Constraint** — Verified `type` is strictly constrained to `'income'` or `'expense'` in UI, API, and PostgreSQL.
- **TC-08: XSS Sanitization** — Verified all user-supplied strings (`title`, `description`, `category`, `name`) are sanitized via `escapeHtml()` before rendering in HTML.
- **TC-09: Server-Generated UUIDs** — Verified new transactions omit client-generated IDs so PostgreSQL generates canonical `gen_random_uuid()` primary keys.
- **TC-10: Demo Account Cloud Persistence** — Verified `demo@finwise-app.xyz` (`00000000-0000-4000-8000-000000000001`) reads and writes directly to Supabase.
- **TC-11: Dual-Login Password Setup** — Verified first-time Google OAuth users are prompted to set a standard password via `supabase.auth.updateUser({ password })`.

### Availability
- **TC-12: Network Timeout Protection** — Verified Supabase and API calls use a 10-second timeout wrapper so slow connections never hang the UI.
- **TC-13: Graceful Error Handling** — Verified `try...catch` blocks around all async database operations display user-friendly toast/alert messages on failure.
- **TC-14: Empty State Fallback** — Verified empty transaction lists cleanly render the "No transactions found" state without layout errors.
- **TC-15: Real-Time Cross-Device Sync** — Verified Supabase `postgres_changes` channel updates open tabs/devices immediately upon transaction insert/update/delete.
- **TC-16: Automated Unit & Widget Tests** — Verified `flutter test` passes all model, validation, and widget tests.
