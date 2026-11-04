import React from 'react';
import { ScreenType } from '../types';

interface DashboardViewProps {
  onNavigate: (screen: ScreenType) => void;
  userEmail: string;
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'error') => void;
}

export const DashboardView: React.FC<DashboardViewProps> = ({
  onNavigate,
  userEmail,
  onShowToast,
}) => {
  return (
    <div className="bg-surface text-on-surface font-body-md text-body-md antialiased min-h-screen flex flex-col w-full">
      {/* App Header */}
      <header className="sticky top-0 w-full z-40 pt-safe bg-surface/80 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)]">
        <div className="h-14 px-margin flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-on-primary">
              <span className="material-symbols-outlined text-[18px]">account_balance_wallet</span>
            </div>
            <div>
              <h1 className="font-headline-sm text-headline-sm text-primary tracking-tight leading-tight">FinWise</h1>
              <span className="text-[10px] bg-growth-mint-subtle text-secondary px-1.5 py-0.2 rounded-full font-bold uppercase tracking-wider">
                UTM Skudai
              </span>
            </div>
          </div>
          <button
            onClick={() => {
              onShowToast('Session Ended', 'Logged out of campus vault.', 'info');
              onNavigate('login');
            }}
            className="flex items-center gap-1 text-xs font-semibold text-text-muted hover:text-error transition-colors px-2.5 py-1.5 rounded-lg hover:bg-surface-container"
          >
            <span className="material-symbols-outlined text-[16px]">logout</span>
            <span>Sign Out</span>
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 flex flex-col relative w-full bg-surface pb-safe px-margin pt-3">
        {/* Student ID Card Badge */}
        <div className="bg-gradient-to-br from-primary to-primary-container text-white p-5 rounded-2xl shadow-lg relative overflow-hidden">
          <div className="flex items-start justify-between relative z-10">
            <div>
              <span className="text-xs uppercase tracking-wider text-secondary-fixed font-semibold">UTM Student Vault</span>
              <h2 className="text-xl font-bold mt-1">Yeoh Kean Shen</h2>
              <p className="text-xs text-white/70">{userEmail || 'keanshen@graduate.utm.my'}</p>
            </div>
            <div className="w-9 h-9 rounded-xl bg-white/10 flex items-center justify-center text-[#ffdbcb] font-bold text-xs ring-1 ring-white/20">
              UTM
            </div>
          </div>

          <div className="mt-5 pt-3 border-t border-white/10 flex items-baseline justify-between relative z-10">
            <div>
              <p className="text-xs text-white/70">Campus Available Balance</p>
              <h3 className="text-2xl font-bold tracking-tight text-white mt-0.5">RM 1,420.50</h3>
            </div>
            <span className="inline-flex items-center gap-1 text-xs font-semibold bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full border border-emerald-400/30">
              <span className="material-symbols-outlined text-[12px]">trending_up</span> +RM 450 saved
            </span>
          </div>

          <div className="absolute -right-6 -bottom-6 w-32 h-32 rounded-full bg-secondary-fixed/10 pointer-events-none blur-xl"></div>
        </div>

        {/* AI Insight Pill */}
        <div className="mt-space-sm bg-growth-mint-subtle/70 border border-secondary/30 rounded-xl p-3.5 flex items-start gap-3">
          <div className="w-8 h-8 rounded-lg bg-secondary text-white flex items-center justify-center shrink-0 mt-0.5">
            <span className="material-symbols-outlined text-[18px]">smart_toy</span>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5">
              <span className="font-semibold text-xs text-secondary uppercase tracking-wider">AI Financial Advisor</span>
              <span className="text-[10px] text-secondary/70">• Real-time</span>
            </div>
            <p className="text-xs text-on-surface mt-0.5 leading-relaxed">
              You are spending 18% less on campus meals than last semester. At this rate, your <strong>RM 800 Laptop Upgrade</strong> target will be reached by Week 12!
            </p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mt-space-md grid grid-cols-3 gap-2">
          <button
            onClick={() => onShowToast('Quick Add', 'Transaction logging modal ready.', 'info')}
            className="flex flex-col items-center justify-center p-3 rounded-xl bg-surface-container-lowest border border-outline-variant/30 hover:bg-surface-container-low transition-colors shadow-sm"
          >
            <span className="material-symbols-outlined text-primary text-[22px]">add_circle</span>
            <span className="text-xs font-semibold text-text-primary mt-1">Add Spend</span>
          </button>
          <button
            onClick={() => onShowToast('AI Forecast', 'Generating 14-week cash flow projection...', 'info')}
            className="flex flex-col items-center justify-center p-3 rounded-xl bg-surface-container-lowest border border-outline-variant/30 hover:bg-surface-container-low transition-colors shadow-sm"
          >
            <span className="material-symbols-outlined text-secondary text-[22px]">insights</span>
            <span className="text-xs font-semibold text-text-primary mt-1">Forecast</span>
          </button>
          <button
            onClick={() => onShowToast('Budget Limits', 'Weekly budget cap is RM 225.00', 'info')}
            className="flex flex-col items-center justify-center p-3 rounded-xl bg-surface-container-lowest border border-outline-variant/30 hover:bg-surface-container-low transition-colors shadow-sm"
          >
            <span className="material-symbols-outlined text-amber-600 text-[22px]">pie_chart</span>
            <span className="text-xs font-semibold text-text-primary mt-1">Budgets</span>
          </button>
        </div>

        {/* Recent Transactions List */}
        <div className="mt-space-md flex flex-col gap-2">
          <div className="flex items-center justify-between">
            <h4 className="font-semibold text-xs text-text-muted uppercase tracking-wider">Recent Campus Transactions</h4>
            <span className="text-xs text-primary font-medium hover:underline cursor-pointer">View All</span>
          </div>

          {[
            { name: 'Arkid Meranti Cafeteria', cat: 'Campus Food', amt: '- RM 8.50', icon: 'restaurant', color: 'bg-orange-100 text-orange-600' },
            { name: 'UTM PSZ Library Printing', cat: 'Academics', amt: '- RM 3.20', icon: 'print', color: 'bg-blue-100 text-blue-600' },
            { name: 'KPT Higher Ed Allowance', cat: 'Allowance Deposit', amt: '+ RM 600.00', icon: 'account_balance', color: 'bg-emerald-100 text-secondary' },
          ].map((tx, idx) => (
            <div key={idx} className="bg-surface-container-lowest p-3 rounded-xl border border-outline-variant/30 flex items-center justify-between shadow-sm">
              <div className="flex items-center gap-3">
                <div className={`w-8 h-8 rounded-lg flex items-center justify-center ${tx.color}`}>
                  <span className="material-symbols-outlined text-[18px]">{tx.icon}</span>
                </div>
                <div>
                  <p className="font-semibold text-xs text-text-primary">{tx.name}</p>
                  <p className="text-[11px] text-text-muted">{tx.cat}</p>
                </div>
              </div>
              <span className={`text-xs font-bold ${tx.amt.startsWith('+') ? 'text-secondary' : 'text-text-primary'}`}>
                {tx.amt}
              </span>
            </div>
          ))}
        </div>

        {/* Flow Switcher Bar */}
        <div className="mt-space-lg pt-4 border-t border-border-neutral text-center pb-8">
          <p className="text-xs text-text-muted mb-3">Navigation Quick Switch</p>
          <div className="flex items-center justify-center gap-2">
            <button
              onClick={() => onNavigate('login')}
              className="px-3 py-1.5 text-xs bg-surface-container rounded-lg hover:bg-surface-container-high transition-colors font-medium text-text-primary"
            >
              ← Back to Login
            </button>
            <button
              onClick={() => onNavigate('register')}
              className="px-3 py-1.5 text-xs bg-surface-container rounded-lg hover:bg-surface-container-high transition-colors font-medium text-text-primary"
            >
              ← Back to Register
            </button>
          </div>
        </div>
      </main>
    </div>
  );
};
