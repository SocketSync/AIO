import React, { useState } from 'react';
import { ScreenType } from '../types';

interface LoginViewProps {
  onNavigate: (screen: ScreenType) => void;
  onOpenBiometric: () => void;
  onOpenUtmSso: () => void;
  onOpenGoogleSso: () => void;
  onOpenForgotPassword: () => void;
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'error') => void;
  onLoginSuccess: (email: string) => void;
}

export const LoginView: React.FC<LoginViewProps> = ({
  onNavigate,
  onOpenBiometric,
  onOpenUtmSso,
  onOpenGoogleSso,
  onOpenForgotPassword,
  onShowToast,
  onLoginSuccess,
}) => {
  const [studentId, setStudentId] = useState('yeoh.k@graduate.utm.my');
  const [password, setPassword] = useState('SecretStudentPass99');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [loginSuccess, setLoginSuccess] = useState(false);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    if (!studentId || !password) {
      onShowToast('Missing Fields', 'Please enter your student credentials.', 'error');
      return;
    }

    setIsLoggingIn(true);
    setTimeout(() => {
      setLoginSuccess(true);
      onShowToast('Authentication Successful', 'Opening campus financial vault...', 'success');
      setTimeout(() => {
        setIsLoggingIn(false);
        setLoginSuccess(false);
        onLoginSuccess(studentId);
      }, 1000);
    }, 1000);
  };

  return (
    <div className="bg-surface text-on-surface font-body-md text-body-md antialiased min-h-screen flex flex-col w-full">
      {/* Header */}
      <header className="sticky top-0 w-full z-40 pt-safe bg-surface/80 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)]">
        <div className="h-14 px-margin flex items-center justify-between">
          <button
            aria-label="Go back"
            className="min-w-[44px] min-h-[44px] -ml-space-xs flex items-center justify-center rounded-full text-on-surface hover:bg-surface-container-high transition-colors"
            onClick={() => onNavigate('register')}
            type="button"
          >
            <span className="material-symbols-outlined text-[24px]">arrow_back</span>
          </button>
          <h1 className="font-headline-sm text-headline-sm text-on-surface tracking-tight text-center truncate px-space-xs flex-1">
            Login
          </h1>
          <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center shrink-0">
            <span className="material-symbols-outlined text-on-primary text-[18px]">person</span>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="flex-1 flex flex-col relative w-full bg-surface pb-safe">
        <div className="flex flex-col w-full px-margin pb-space-xl">
          {/* Ambient Glow & Student Context Mascot/Card */}
          <div className="relative w-full overflow-hidden rounded-xl bg-surface-container-low p-space-md shadow-sm mb-space-md mt-space-xs border border-outline-variant/30">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-space-sm">
                <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-on-primary shadow-sm">
                  <span className="material-symbols-outlined text-[22px]" style={{ fontVariationSettings: "'FILL' 1" }}>
                    account_balance_wallet
                  </span>
                </div>
                <div>
                  <div className="flex items-center gap-1">
                    <span className="font-headline-sm text-headline-sm text-primary tracking-tight">FinWise</span>
                    <span className="bg-growth-mint-subtle text-secondary font-label-sm text-label-sm px-1.5 py-0.5 rounded-full font-bold">
                      CAMPUS
                    </span>
                  </div>
                  <p className="font-label-md text-label-md text-text-muted">Student Smart Banking</p>
                </div>
              </div>
              <div className="flex items-center gap-1 bg-surface-container-highest px-2 py-1 rounded-full text-on-surface-variant font-label-sm text-label-sm">
                <span className="material-symbols-outlined text-[14px] text-secondary">verified_user</span>
                <span>UTM Portal Sync</span>
              </div>
            </div>

            {/* Motivational Campus Snippet */}
            <div className="mt-space-md bg-surface-container-lowest p-space-sm rounded-lg flex items-center gap-space-sm shadow-sm border border-outline-variant/20">
              <span className="material-symbols-outlined text-secondary text-[20px]">school</span>
              <div className="min-w-0 flex-1">
                <p className="font-label-sm text-label-sm text-secondary font-semibold uppercase tracking-wider">
                  Semester Allowance Forecast
                </p>
                <p className="font-body-sm text-body-sm text-on-surface truncate">
                  Sem 2 budget active • UTM Skudai Campus
                </p>
              </div>
              <div className="w-2 h-2 rounded-full bg-secondary shrink-0 animate-ping"></div>
            </div>
          </div>

          {/* Hero Titles */}
          <div className="mb-space-lg">
            <h2 className="font-headline-md text-headline-md text-on-surface tracking-tight">Welcome back</h2>
            <p className="font-body-md text-body-md text-text-muted mt-0.5">
              Take control of your campus finances and dynamic budget.
            </p>
          </div>

          {/* Form Container */}
          <form className="flex flex-col gap-space-md w-full" onSubmit={handleLogin}>
            {/* Student Email / Matric ID Input Field */}
            <div className="flex flex-col gap-1.5">
              <label className="font-label-md text-label-md text-text-muted flex items-center justify-between" htmlFor="student-id-input">
                <span>Student Email or Matric ID</span>
                <span className="text-secondary font-label-sm text-label-sm flex items-center gap-0.5">
                  <span className="material-symbols-outlined text-[12px]">check_circle</span> UTM Verified
                </span>
              </label>
              <div className="relative flex items-center bg-surface-container-lowest rounded-lg shadow-sm focus-within:shadow-md transition-shadow border border-outline-variant/30">
                <div className="absolute left-3 flex items-center pointer-events-none text-text-muted">
                  <span className="material-symbols-outlined text-[20px]">badge</span>
                </div>
                <input
                  className="w-full bg-transparent pl-10 pr-4 py-3 font-body-md text-body-md text-on-surface placeholder:text-outline outline-none"
                  id="student-id-input"
                  placeholder="yeoh.k@graduate.utm.my"
                  required
                  type="text"
                  value={studentId}
                  onChange={(e) => setStudentId(e.target.value)}
                />
              </div>
            </div>

            {/* Password Input Field */}
            <div className="flex flex-col gap-1.5">
              <div className="flex items-center justify-between">
                <label className="font-label-md text-label-md text-text-muted" htmlFor="password-input">Password</label>
                <button
                  className="font-label-md text-label-md text-primary font-semibold hover:underline"
                  onClick={onOpenForgotPassword}
                  type="button"
                >
                  Forgot Password?
                </button>
              </div>
              <div className="relative flex items-center bg-surface-container-lowest rounded-lg shadow-sm focus-within:shadow-md transition-shadow border border-outline-variant/30">
                <div className="absolute left-3 flex items-center pointer-events-none text-text-muted">
                  <span className="material-symbols-outlined text-[20px]">lock</span>
                </div>
                <input
                  className="w-full bg-transparent pl-10 pr-12 py-3 font-body-md text-body-md text-on-surface placeholder:text-outline outline-none tracking-widest"
                  id="password-input"
                  placeholder="••••••••••••"
                  required
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
                <button
                  aria-label="Toggle password view"
                  className="absolute right-2 p-1.5 text-text-muted hover:text-on-surface rounded-full transition-colors flex items-center justify-center"
                  id="toggle-password-btn"
                  onClick={() => setShowPassword(!showPassword)}
                  type="button"
                >
                  <span className="material-symbols-outlined text-[20px]" id="password-visibility-icon">
                    {showPassword ? 'visibility_off' : 'visibility'}
                  </span>
                </button>
              </div>
            </div>

            {/* Security & Remember Me Row */}
            <div className="flex items-center justify-between pt-0.5">
              <label className="flex items-center gap-2 cursor-pointer select-none">
                <input
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="w-4 h-4 rounded text-primary-container accent-primary cursor-pointer"
                  id="remember-me-checkbox"
                  type="checkbox"
                />
                <span className="font-label-md text-label-md text-on-surface font-normal">Remember device</span>
              </label>
              <div className="flex items-center gap-1 bg-growth-mint-subtle px-2 py-0.5 rounded-full">
                <span className="material-symbols-outlined text-[13px] text-secondary">shield_lock</span>
                <span className="font-label-sm text-label-sm text-secondary font-medium">256-bit AES</span>
              </div>
            </div>

            {/* Primary Action CTA */}
            <div className="flex flex-col gap-space-sm pt-space-xs">
              <button
                className="w-full min-h-[48px] bg-primary text-on-primary rounded-lg font-label-lg text-label-lg flex items-center justify-center gap-2 shadow-md hover:bg-primary-container active:scale-[0.99] transition-all cursor-pointer disabled:opacity-80"
                id="login-btn"
                type="submit"
                disabled={isLoggingIn}
              >
                {isLoggingIn ? (
                  loginSuccess ? (
                    <>
                      <span className="material-symbols-outlined text-[18px]">check</span>
                      <span>Welcome, Yeoh!</span>
                    </>
                  ) : (
                    <>
                      <span className="material-symbols-outlined text-[18px] animate-spin">refresh</span>
                      <span>Opening Campus Vault...</span>
                    </>
                  )
                ) : (
                  <>
                    <span>Log In</span>
                    <span className="material-symbols-outlined text-[18px]">arrow_forward</span>
                  </>
                )}
              </button>

              {/* Biometric Fast Pass */}
              <button
                className="w-full min-h-[46px] bg-surface-container-high text-primary rounded-lg font-label-lg text-label-lg flex items-center justify-center gap-2 hover:bg-surface-container-highest transition-colors active:scale-[0.99] cursor-pointer border border-outline-variant/30"
                id="biometric-btn"
                onClick={onOpenBiometric}
                type="button"
              >
                <span className="material-symbols-outlined text-[22px] text-secondary">fingerprint</span>
                <span>Log in with Touch ID / Face ID</span>
              </button>
            </div>
          </form>

          {/* Or Continue With Divider */}
          <div className="relative my-space-lg flex items-center justify-center">
            <div className="w-full h-px bg-surface-container-highest"></div>
            <span className="absolute bg-surface px-3 font-label-sm text-label-sm text-text-muted uppercase tracking-wider">
              Or continue with
            </span>
          </div>

          {/* SSO & Campus Login Grid */}
          <div className="grid grid-cols-2 gap-space-sm">
            {/* UTM Student SSO Option */}
            <button
              className="flex flex-col items-center justify-center p-space-sm bg-surface-container-lowest rounded-lg shadow-sm hover:shadow-md transition-all active:scale-[0.98] text-center gap-1 group border border-outline-variant/30 cursor-pointer"
              onClick={onOpenUtmSso}
              type="button"
            >
              <div className="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center text-primary group-hover:bg-primary-fixed transition-colors">
                <span className="material-symbols-outlined text-[20px]" style={{ fontVariationSettings: "'FILL' 1" }}>
                  domain
                </span>
              </div>
              <span className="font-label-md text-label-md text-on-surface font-semibold mt-1">UTM CIDOS SSO</span>
              <span className="font-label-sm text-label-sm text-text-muted">Direct Student Auth</span>
            </button>

            {/* Google Account Fast SSO */}
            <button
              className="flex flex-col items-center justify-center p-space-sm bg-surface-container-lowest rounded-lg shadow-sm hover:shadow-md transition-all active:scale-[0.98] text-center gap-1 group border border-outline-variant/30 cursor-pointer"
              onClick={onOpenGoogleSso}
              type="button"
            >
              <div className="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center group-hover:bg-surface-container transition-colors">
                <svg className="w-5 h-5" viewBox="0 0 24 24">
                  <path d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.15z" fill="#4285F4"></path>
                  <path d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.26v3.15C3.25 21.37 7.34 24 12 24z" fill="#34A853"></path>
                  <path d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.26C.46 8.16 0 9.94 0 12s.46 3.84 1.26 5.42l4.02-3.15z" fill="#FBBC05"></path>
                  <path d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.34 0 3.25 2.63 1.26 6.58l4.02 3.15c.95-2.83 3.6-4.98 6.72-4.98z" fill="#EA4335"></path>
                </svg>
              </div>
              <span className="font-label-md text-label-md text-on-surface font-semibold mt-1">Google</span>
              <span className="font-label-sm text-label-sm text-text-muted">Campus G-Suite</span>
            </button>
          </div>

          {/* Recent Campus Activity Pill (Delight/Engagement) */}
          <div 
            onClick={() => onShowToast('UTM Saver Leaderboard', 'Yeoh is currently in the 90th percentile of savers at KTC!', 'info')}
            className="mt-space-lg bg-surface-container-low rounded-xl p-space-sm flex items-center justify-between cursor-pointer hover:bg-surface-container transition-colors border border-outline-variant/30"
          >
            <div className="flex items-center gap-space-sm min-w-0">
              <div className="w-8 h-8 rounded-full bg-growth-mint-subtle flex items-center justify-center text-secondary shrink-0">
                <span className="material-symbols-outlined text-[16px]">savings</span>
              </div>
              <div className="truncate">
                <p className="font-label-md text-label-md text-on-surface font-semibold truncate">RM 450.00 Saved this term</p>
                <p className="font-label-sm text-label-sm text-text-muted">Top 10% saver in Kolej Tuanku Canselor</p>
              </div>
            </div>
            <span className="material-symbols-outlined text-outline text-[18px]">chevron_right</span>
          </div>

          {/* Sign-Up Prompt Footer */}
          <div className="mt-space-xl text-center pb-space-sm">
            <p className="font-body-md text-body-md text-text-muted">
              Don't have an account?{' '}
              <button
                className="text-primary font-label-lg text-label-lg font-bold hover:underline ml-1 cursor-pointer"
                onClick={() => onNavigate('register')}
                type="button"
              >
                Sign Up
              </button>
            </p>
            <p className="font-label-sm text-label-sm text-outline mt-2 flex items-center justify-center gap-1">
              <span className="material-symbols-outlined text-[14px]">lock_clock</span> FinWise for Higher Ed v2.4.1
            </p>
          </div>
        </div>
      </main>
    </div>
  );
};
