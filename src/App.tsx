import React, { useState } from 'react';
import { ScreenType, ToastMessage } from './types';
import { RegisterView } from './views/RegisterView';
import { LoginView } from './views/LoginView';
import { SetupGoalsView } from './views/SetupGoalsView';
import { DashboardView } from './views/DashboardView';
import { BiometricModal } from './components/BiometricModal';
import { SsoModal } from './components/SsoModal';
import { GoogleSsoModal } from './components/GoogleSsoModal';
import { ForgotPasswordModal } from './components/ForgotPasswordModal';
import { Toast } from './components/Toast';

export const App: React.FC = () => {
  const [currentScreen, setCurrentScreen] = useState<ScreenType>('login');
  const [userEmail, setUserEmail] = useState('yeoh.k@graduate.utm.my');
  const [isMobileFrame, setIsMobileFrame] = useState(true);

  // Modals state
  const [showBiometric, setShowBiometric] = useState(false);
  const [showUtmSso, setShowUtmSso] = useState(false);
  const [showGoogleSso, setShowGoogleSso] = useState(false);
  const [showForgotPassword, setShowForgotPassword] = useState(false);

  // Toasts
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  const addToast = (title: string, description?: string, type: 'success' | 'info' | 'warning' | 'error' = 'info') => {
    const id = Math.random().toString(36).substring(2, 9);
    setToasts((prev) => [...prev, { id, title, description, type }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 3800);
  };

  const removeToast = (id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  const handleLoginSuccess = (email: string) => {
    setUserEmail(email);
    setCurrentScreen('dashboard');
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans">
      {/* Top Universal Control Bar for Devs & Reviewers */}
      <nav className="bg-slate-900/90 border-b border-slate-800 text-xs px-4 py-2.5 flex flex-wrap items-center justify-between gap-3 sticky top-0 z-50 backdrop-blur-md">
        {/* App Title & Badge */}
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-lg bg-[#00236f] flex items-center justify-center text-white font-bold text-[11px]">
            FW
          </div>
          <span className="font-semibold text-white tracking-wide">FinWise Frontend</span>
          <span className="bg-emerald-500/10 text-emerald-400 px-2 py-0.5 rounded-full border border-emerald-500/20 text-[10px] font-medium">
            UTM Student Edition
          </span>
        </div>

        {/* Screen Switcher */}
        <div className="flex items-center gap-1 bg-slate-950/80 p-1 rounded-xl border border-slate-800">
          <button
            onClick={() => setCurrentScreen('login')}
            className={`px-3 py-1.5 rounded-lg transition-all font-medium ${
              currentScreen === 'login'
                ? 'bg-primary text-white shadow-sm'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            Login
          </button>
          <button
            onClick={() => setCurrentScreen('register')}
            className={`px-3 py-1.5 rounded-lg transition-all font-medium ${
              currentScreen === 'register'
                ? 'bg-primary text-white shadow-sm'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            Register (Step 1)
          </button>
          <button
            onClick={() => setCurrentScreen('setup-goals')}
            className={`px-3 py-1.5 rounded-lg transition-all font-medium ${
              currentScreen === 'setup-goals'
                ? 'bg-primary text-white shadow-sm'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            Setup Goals (Step 2)
          </button>
          <button
            onClick={() => setCurrentScreen('dashboard')}
            className={`px-3 py-1.5 rounded-lg transition-all font-medium ${
              currentScreen === 'dashboard'
                ? 'bg-secondary text-white shadow-sm'
                : 'text-slate-400 hover:text-slate-200'
            }`}
          >
            Student Dashboard
          </button>
        </div>

        {/* View Mode Toggle */}
        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsMobileFrame(!isMobileFrame)}
            className="flex items-center gap-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 px-3 py-1.5 rounded-lg border border-slate-700 transition-colors"
          >
            <span className="material-symbols-outlined text-[16px]">
              {isMobileFrame ? 'devices' : 'smartphone'}
            </span>
            <span>{isMobileFrame ? 'Expand Fullscreen' : 'Mobile Frame'}</span>
          </button>
        </div>
      </nav>

      {/* Main Container Area */}
      <div className={`flex-1 flex items-center justify-center ${isMobileFrame ? 'p-3 sm:p-6 lg:p-8 bg-[#0a0f1d]' : 'p-0 bg-surface'}`}>
        {isMobileFrame ? (
          /* Realistic Smartphone Frame Simulator */
          <div className="relative w-full max-w-[420px] bg-black rounded-[48px] p-3 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.8),0_0_0_1px_rgba(255,255,255,0.1)] ring-1 ring-white/10">
            {/* Phone Screen Bezels & Notch */}
            <div className="relative w-full overflow-hidden rounded-[38px] bg-surface flex flex-col min-h-[780px] max-h-[880px]">
              {/* iOS / Mobile Status Bar Mock */}
              <div className="h-10 w-full bg-surface/90 backdrop-blur-md px-6 flex items-center justify-between text-xs font-semibold text-on-surface select-none z-30 shrink-0">
                <span>9:41</span>
                {/* Dynamic Island / Speaker Pill */}
                <div className="w-20 h-4 bg-black rounded-full"></div>
                <div className="flex items-center gap-1 text-[13px]">
                  <span className="material-symbols-outlined text-[14px]">signal_cellular_4_bar</span>
                  <span className="material-symbols-outlined text-[14px]">wifi</span>
                  <span className="material-symbols-outlined text-[14px]">battery_full</span>
                </div>
              </div>

              {/* Scrollable Screen Content */}
              <div className="flex-1 overflow-y-auto overscroll-contain">
                {currentScreen === 'register' && (
                  <RegisterView
                    onNavigate={(screen) => setCurrentScreen(screen)}
                    onOpenUtmSso={() => setShowUtmSso(true)}
                    onOpenGoogleSso={() => setShowGoogleSso(true)}
                    onShowToast={addToast}
                  />
                )}

                {currentScreen === 'login' && (
                  <LoginView
                    onNavigate={(screen) => setCurrentScreen(screen)}
                    onOpenBiometric={() => setShowBiometric(true)}
                    onOpenUtmSso={() => setShowUtmSso(true)}
                    onOpenGoogleSso={() => setShowGoogleSso(true)}
                    onOpenForgotPassword={() => setShowForgotPassword(true)}
                    onShowToast={addToast}
                    onLoginSuccess={handleLoginSuccess}
                  />
                )}

                {currentScreen === 'setup-goals' && (
                  <SetupGoalsView
                    onNavigate={(screen) => setCurrentScreen(screen)}
                    onShowToast={addToast}
                    onComplete={() => setCurrentScreen('dashboard')}
                  />
                )}

                {currentScreen === 'dashboard' && (
                  <DashboardView
                    onNavigate={(screen) => setCurrentScreen(screen)}
                    userEmail={userEmail}
                    onShowToast={addToast}
                  />
                )}
              </div>

              {/* Mobile Home Bar Indicator */}
              <div className="h-5 w-full bg-surface flex items-center justify-center shrink-0">
                <div className="w-32 h-1 bg-on-surface/20 rounded-full"></div>
              </div>
            </div>
          </div>
        ) : (
          /* Full Responsive View */
          <div className="w-full max-w-xl mx-auto min-h-screen bg-surface flex flex-col shadow-xl">
            {currentScreen === 'register' && (
              <RegisterView
                onNavigate={(screen) => setCurrentScreen(screen)}
                onOpenUtmSso={() => setShowUtmSso(true)}
                onOpenGoogleSso={() => setShowGoogleSso(true)}
                onShowToast={addToast}
              />
            )}

            {currentScreen === 'login' && (
              <LoginView
                onNavigate={(screen) => setCurrentScreen(screen)}
                onOpenBiometric={() => setShowBiometric(true)}
                onOpenUtmSso={() => setShowUtmSso(true)}
                onOpenGoogleSso={() => setShowGoogleSso(true)}
                onOpenForgotPassword={() => setShowForgotPassword(true)}
                onShowToast={addToast}
                onLoginSuccess={handleLoginSuccess}
              />
            )}

            {currentScreen === 'setup-goals' && (
              <SetupGoalsView
                onNavigate={(screen) => setCurrentScreen(screen)}
                onShowToast={addToast}
                onComplete={() => setCurrentScreen('dashboard')}
              />
            )}

            {currentScreen === 'dashboard' && (
              <DashboardView
                onNavigate={(screen) => setCurrentScreen(screen)}
                userEmail={userEmail}
                onShowToast={addToast}
              />
            )}
          </div>
        )}
      </div>

      {/* Modals & Dialogs */}
      <BiometricModal
        isOpen={showBiometric}
        onClose={() => setShowBiometric(false)}
        onSuccess={() => {
          setShowBiometric(false);
          addToast('Biometrics Authenticated', 'Touch ID verified via Secure Enclave.', 'success');
          handleLoginSuccess('yeoh.k@graduate.utm.my');
        }}
      />

      <SsoModal
        isOpen={showUtmSso}
        onClose={() => setShowUtmSso(false)}
        onSuccess={(email) => {
          setShowUtmSso(false);
          addToast('UTM CIDOS SSO Verified', `Authenticated as student: ${email}`, 'success');
          handleLoginSuccess(email);
        }}
      />

      <GoogleSsoModal
        isOpen={showGoogleSso}
        onClose={() => setShowGoogleSso(false)}
        onSuccess={(email) => {
          setShowGoogleSso(false);
          addToast('Google Workspace Connected', `Logged in via ${email}`, 'success');
          handleLoginSuccess(email);
        }}
      />

      <ForgotPasswordModal
        isOpen={showForgotPassword}
        onClose={() => setShowForgotPassword(false)}
        onSubmit={(email) => {
          addToast('Password Link Sent', `Recovery magic link delivered to ${email}`, 'success');
        }}
      />

      {/* Toast Notification Container */}
      <Toast toasts={toasts} onDismiss={removeToast} />
    </div>
  );
};
