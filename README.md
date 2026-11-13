# 💰 FinWise

> **Smart Personal Financial Management & Real-Time Budget Tracking System**  
> Cloud-Synced Web & Mobile Financial Application (`finwise-app.xyz`)

---

## 👥 Project Team & Architecture Roles

| Role | Primary Module |
| :--- | :--- |
| **Project Lead & Backend Architect** | Authentication, CIA Triad Security & Supabase Cloud Sync |
| **Frontend & Analytics Lead** | Real-Time Expense Tracker & Spending Insights |
| **Simulation & Modelling Lead** | What-If Financial Simulator & Runway Forecasting |
| **Quality Assurance & UI/UX Lead** | Responsive UI, Dark Mode & End-to-End Testing |

---

## 📖 Project Overview

**FinWise** is an integrated financial literacy and budget management system designed for modern personal finance and real-time multi-device budget tracking. FinWise provides a unified platform to track daily cash flow, receive automated spending insights, and simulate future financial scenarios before making major purchasing decisions.

---

## ✨ Key Features

1. **Secure Authentication & Session Management (Confidentiality)**
   - Supabase Auth (Email/Password + Google OAuth) with strict Row Level Security (`auth.uid() = user_id`), strong password complexity enforcement (`>= 8` chars), and full session scrubbing on logout.
2. **Real-Time Multi-Device Expense Tracker (Integrity & Availability)**
   - Real-time calculation of total income, expenses, remaining balance, and category-level budget progress bars (Food, Transport, Housing, Entertainment, Utilities) backed by PostgreSQL `CHECK` constraints and XSS input sanitization.
3. **Automated Spending Insights**
   - Pattern recognition and anomaly alerts (dining out frequency warnings, weekend spending spikes, and subscription cost tracking).
4. **What-If Financial Simulator**
   - Compound savings projection and emergency fund runway calculator allowing users to test how adjusting daily habits impacts long-term goals.
5. **Dual-Theme Glassmorphic UI**
   - Clean, responsive interface supporting both Light and Dark modes across web and mobile.

---

## 🏗️ System Architecture (CIA Triad Hardened)

```text
FinWise/
├── public/                          # Production Web Application (Vercel + Supabase Realtime)
│   ├── login.html                   # Auth, Google OAuth, Demo Account & Dual-Login Setup
│   ├── register.html                # User Registration & Google Sign-Up
│   ├── dashboard.html               # Real-Time Financial Overview & Quick Expense Entry
│   ├── transactions.html            # Full CRUD Ledger with Search, Filter & CSV Export
│   ├── summary.html                 # Interactive Category & Monthly Cashflow Analytics
│   └── profile.html                 # Account Settings, Password Setup & Budget Controls
│
├── api/                             # Serverless API Endpoints
│   ├── config.js                    # Public Environment Config (Supabase URL & Anon Key)
│   ├── accounts.js                  # Sanitized Demo Account Metadata (No Password Hashes)
│   ├── login.js                     # Fallback Demo Auth Verification
│   └── transactions.js              # Seed Fallback Endpoint
│
├── database/                        # Supabase PostgreSQL Schema & Security Policies
│   ├── schema.sql                   # Core Tables, Triggers & RLS Policies
│   ├── reset_and_seed_demo.sql      # Clean Database Reset & Demo User Initialization
│   ├── fix_transactions_and_seed_demo.sql # Transaction UUID & RLS Fix + Linked Demo Data
│   └── security_hardening_cia.sql   # CIA Triad Hardening (RLS, CHECK Constraints, Sanitization)
│
├── lib/                             # Cross-Platform Flutter Application
│   ├── models/                      # TransactionModel, CategoryModel
│   ├── services/                    # SupabaseService, AuthService, DatabaseService, AiService
│   └── screens/                     # Dashboard, Transactions, Analytics, Profile
│
└── docs/                            # Comprehensive Project Documentation
    ├── ANDROID_SETUP_GUIDE.md       # Mobile installation & APK build guide
    ├── BACKEND_DEPLOYMENT.md        # Cloud & local backend setup guide
    └── TESTING_REPORT.md            # Comprehensive authentication, CRUD & security test report
```

---

## 🚀 Quick Start Guide

### 1. Environment Configuration
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Configure `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env` (only the public `anon` key should be used in client configurations; never expose `service_role` keys).

### 2. Supabase Database Setup
1. Open the **Supabase SQL Editor** for your project.
2. Run `database/schema.sql` followed by `database/security_hardening_cia.sql` to enable Row Level Security (RLS), enforce database integrity `CHECK` constraints, and seed the public demo account (`demo@finwise-app.xyz`).

### 3. Running Web & Mobile
- **Web Server**: Run `python server.py 3000 public` or deploy directly to Vercel (`https://www.finwise-app.xyz`).
- **Flutter App**: Run `flutter pub get && flutter test` or `flutter run`.
