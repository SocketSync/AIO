import React, { useState, useId } from 'react';
import { ScreenType } from '../types';

interface RegisterViewProps {
  onNavigate: (screen: ScreenType) => void;
  onOpenUtmSso: () => void;
  onOpenGoogleSso: () => void;
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'error') => void;
}

export const RegisterView: React.FC<RegisterViewProps> = ({
  onNavigate,
  onOpenUtmSso,
  onOpenGoogleSso,
  onShowToast,
}) => {
  const [fullName, setFullName] = useState('Yeoh Kean Shen');
  const [email, setEmail] = useState('keanshen@graduate.utm.my');
  const [password, setPassword] = useState('UtmFin2025!');
  const [showPassword, setShowPassword] = useState(false);
  const [termsAgreed, setTermsAgreed] = useState(true);
  const fullNameInputId = useId();
  const emailInputId = useId();
  const passwordInputId = useId();
  const termsInputId = useId();

  // Real-time password strength calculation
  const hasMinLength = password.length >= 8;
  const hasNumber = /\d/.test(password);
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

  const criteriaMetCount = [hasMinLength, hasNumber, hasSpecialChar].filter(Boolean).length;
  
  const strengthLabel = 
    password.length === 0 ? 'Enter Password' :
    criteriaMetCount === 3 ? 'Strong Password' :
    criteriaMetCount === 2 ? 'Medium Strength' : 'Weak Password';

  const isUtmDomain = email.toLowerCase().endsWith('@graduate.utm.my') || email.toLowerCase().endsWith('@utm.my');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!termsAgreed) {
      onShowToast('Action Required', 'Please accept terms and conditions to proceed.', 'error');
      return;
    }
    if (!hasMinLength) {
      onShowToast('Password too short', 'Password must have at least 8 characters.', 'error');
      return;
    }

    onShowToast('Student Profile Created!', 'Proceeding to Step 2: Goal Setup...', 'success');
    onNavigate('setup-goals');
  };

  return (
    <div className="bg-surface text-on-surface font-body-md text-body-md antialiased min-h-screen flex flex-col w-full">
      {/* Fixed Header */}
      <header className="sticky top-0 w-full z-40 pt-safe bg-surface/80 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)]">
        <div className="h-14 px-margin flex items-center justify-between">
          <button
            aria-label="Go back to login"
            onClick={() => onNavigate('login')}
            className="min-w-[44px] min-h-[44px] -ml-space-xs flex items-center justify-center rounded-full text-on-surface hover:bg-surface-container-high transition-colors"
          >
            <span className="material-symbols-outlined text-[24px]">arrow_back</span>
          </button>
          <h1 className="font-headline-sm text-headline-sm text-on-surface tracking-tight text-center truncate px-space-xs flex-1">
            Register
          </h1>
          <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center shrink-0">
            <span className="material-symbols-outlined text-on-primary text-[18px]">person</span>
          </div>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 flex flex-col relative w-full bg-surface pb-safe">
        <div className="flex flex-col w-full pb-space-xl">
          {/* Progress Header & Context Banner */}
          <div className="px-margin pt-space-md pb-space-sm flex flex-col gap-space-sm">
            <div className="flex items-center justify-between">
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-secondary-fixed text-on-secondary-fixed font-label-sm text-label-sm uppercase tracking-wider shadow-sm">
                <span className="material-symbols-outlined text-[14px]">school</span>
                Student Onboarding
              </span>
              <span className="font-label-md text-label-md text-text-muted">Step 1 of 2</span>
            </div>

            {/* Step Progress Bar */}
            <div className="w-full h-1.5 bg-surface-container-high rounded-full overflow-hidden">
              <div className="h-full bg-secondary w-1/2 rounded-full transition-all duration-300"></div>
            </div>

            {/* Intro Text */}
            <div className="mt-space-xs">
              <p className="font-body-md text-body-md text-on-surface-variant leading-relaxed">
                Join thousands of UTM students building smarter saving habits and budgeting with AI.
              </p>
            </div>
          </div>

          {/* UTM Perk Delight Banner */}
          <div className="px-margin mb-space-md">
            <div className="relative overflow-hidden bg-gradient-to-r from-primary-container to-primary text-on-primary rounded-xl p-space-md shadow-md">
              <div className="flex items-start gap-3 relative z-10">
                <div className="w-10 h-10 rounded-xl bg-on-primary/15 flex items-center justify-center shrink-0">
                  <span className="material-symbols-outlined text-secondary-fixed text-[24px]">verified</span>
                </div>
                <div className="flex flex-col gap-0.5">
                  <span className="font-label-lg text-label-lg text-secondary-fixed">UTM Student Benefit</span>
                  <p className="font-body-sm text-body-sm text-on-primary-container leading-tight">
                    Register with your student ID to unlock <strong className="text-on-primary font-semibold">FinWise Pro &amp; AI Assistant</strong> free throughout this academic year.
                  </p>
                </div>
              </div>
              <div className="absolute -right-4 -bottom-6 w-24 h-24 rounded-full bg-secondary-fixed/10 pointer-events-none blur-lg"></div>
            </div>
          </div>

          {/* Registration Form */}
          <form className="px-margin flex flex-col gap-space-md" onSubmit={handleSubmit}>
            {/* Campus Picker (Defaults to UTM) */}
            <div className="flex flex-col gap-1.5">
              <div className="font-label-md text-label-md text-text-muted flex items-center justify-between">
                <span>Campus / Institution</span>
                <span className="text-secondary font-medium text-label-sm">Verified Partner</span>
              </div>
              <div className="relative bg-surface-container-lowest rounded-xl p-space-sm flex items-center gap-3 shadow-sm border border-outline-variant/30">
                <div className="w-9 h-9 rounded-lg bg-surface-container flex items-center justify-center shrink-0 text-primary">
                  <span className="material-symbols-outlined text-[20px]">account_balance</span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-label-lg text-label-lg text-text-primary truncate">Universiti Teknologi Malaysia (UTM)</p>
                  <p className="font-body-sm text-body-sm text-text-muted truncate">Skudai &amp; Kuala Lumpur Campuses</p>
                </div>
                <span className="material-symbols-outlined text-secondary text-[20px]">check_circle</span>
              </div>
            </div>

            {/* Full Name Input */}
            <div className="flex flex-col gap-1.5">
              <label className="font-label-md text-label-md text-text-muted" htmlFor={fullNameInputId}>
                Full Name (as per Student ID)
              </label>
              <div className="relative bg-surface-container-lowest rounded-xl flex items-center shadow-sm focus-within:shadow-md transition-shadow border border-outline-variant/30">
                <div className="pl-space-md pr-space-xs text-text-muted flex items-center pointer-events-none">
                  <span className="material-symbols-outlined text-[20px]">person</span>
                </div>
                <input
                  id={fullNameInputId}
                  className="w-full py-3.5 pr-space-md bg-transparent font-body-md text-body-md text-text-primary placeholder:text-outline focus:outline-none"
                  placeholder="e.g. Yeoh Kean Shen"
                  type="text"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  required
                />
              </div>
            </div>

            {/* Student Email Input */}
            <div className="flex flex-col gap-1.5">
              <div className="flex items-center justify-between">
                <label className="font-label-md text-label-md text-text-muted" htmlFor={emailInputId}>
                  University / Student Email
                </label>
                {isUtmDomain && (
                  <span className="inline-flex items-center gap-1 font-label-sm text-label-sm text-secondary bg-growth-mint-subtle px-2 py-0.5 rounded-full animate-fade-in">
                    <span className="material-symbols-outlined text-[12px]">bolt</span> Instant Perks
                  </span>
                )}
              </div>
              <div className="relative bg-surface-container-lowest rounded-xl flex items-center shadow-sm focus-within:shadow-md transition-shadow border border-outline-variant/30">
                <div className="pl-space-md pr-space-xs text-text-muted flex items-center pointer-events-none">
                  <span className="material-symbols-outlined text-[20px]">school</span>
                </div>
                <input
                  id={emailInputId}
                  className="w-full py-3.5 pr-space-md bg-transparent font-body-md text-body-md text-text-primary placeholder:text-outline focus:outline-none"
                  placeholder="keanshen@graduate.utm.my"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              <p className="font-body-sm text-body-sm text-text-muted flex items-center gap-1 pl-1">
                <span className="material-symbols-outlined text-[14px] text-secondary">info</span>
                Use @utm.my or @graduate.utm.my for instant student status validation.
              </p>
            </div>

            {/* Password Input with Live Interactive Visual Meter */}
            <div className="flex flex-col gap-1.5">
              <label className="font-label-md text-label-md text-text-muted" htmlFor={passwordInputId}>
                Create Password
              </label>
              <div className="relative bg-surface-container-lowest rounded-xl flex items-center shadow-sm focus-within:shadow-md transition-shadow border border-outline-variant/30">
                <div className="pl-space-md pr-space-xs text-text-muted flex items-center pointer-events-none">
                  <span className="material-symbols-outlined text-[20px]">lock</span>
                </div>
                <input
                  id={passwordInputId}
                  className="w-full py-3.5 pr-10 bg-transparent font-body-md text-body-md text-text-primary placeholder:text-outline focus:outline-none tracking-wider"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
                <button
                  type="button"
                  aria-label="Toggle password visibility"
                  className="absolute right-3 text-text-muted hover:text-text-primary flex items-center justify-center p-1"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  <span className="material-symbols-outlined text-[20px]">
                    {showPassword ? 'visibility' : 'visibility_off'}
                  </span>
                </button>
              </div>

              {/* Password Strength Indicator Card */}
              <div className="bg-surface-container-low rounded-xl p-space-sm flex flex-col gap-2 mt-1">
                <div className="flex items-center justify-between">
                  <span className="font-label-sm text-label-sm text-text-muted">Security Strength</span>
                  <span className={`font-label-sm text-label-sm font-semibold ${
                    criteriaMetCount === 3 ? 'text-secondary' : criteriaMetCount === 2 ? 'text-amber-600' : 'text-error'
                  }`}>
                    {strengthLabel}
                  </span>
                </div>
                {/* 3 Segment Bar */}
                <div className="grid grid-cols-3 gap-1.5">
                  <div className={`h-1.5 rounded-full transition-colors ${
                    criteriaMetCount >= 1 
                      ? criteriaMetCount === 1 ? 'bg-error' : criteriaMetCount === 2 ? 'bg-amber-500' : 'bg-secondary'
                      : 'bg-surface-container-high'
                  }`}></div>
                  <div className={`h-1.5 rounded-full transition-colors ${
                    criteriaMetCount >= 2 
                      ? criteriaMetCount === 2 ? 'bg-amber-500' : 'bg-secondary'
                      : 'bg-surface-container-high'
                  }`}></div>
                  <div className={`h-1.5 rounded-full transition-colors ${
                    criteriaMetCount === 3 ? 'bg-secondary' : 'bg-surface-container-high'
                  }`}></div>
                </div>
                {/* Criteria Pills */}
                <div className="flex flex-wrap items-center gap-2 pt-1">
                  <span className={`inline-flex items-center gap-1 font-label-sm text-label-sm transition-colors ${
                    hasMinLength ? 'text-secondary' : 'text-text-muted'
                  }`}>
                    <span className="material-symbols-outlined text-[14px]">
                      {hasMinLength ? 'check' : 'radio_button_unchecked'}
                    </span>
                    8+ Characters
                  </span>
                  <span className={`inline-flex items-center gap-1 font-label-sm text-label-sm transition-colors ${
                    hasNumber ? 'text-secondary' : 'text-text-muted'
                  }`}>
                    <span className="material-symbols-outlined text-[14px]">
                      {hasNumber ? 'check' : 'radio_button_unchecked'}
                    </span>
                    Contains Number
                  </span>
                  <span className={`inline-flex items-center gap-1 font-label-sm text-label-sm transition-colors ${
                    hasSpecialChar ? 'text-secondary' : 'text-text-muted'
                  }`}>
                    <span className="material-symbols-outlined text-[14px]">
                      {hasSpecialChar ? 'check' : 'radio_button_unchecked'}
                    </span>
                    Special Symbol
                  </span>
                </div>
              </div>
            </div>

            {/* Terms Checkbox */}
            <div className="flex items-start gap-3 mt-1">
              <label className="relative flex items-center cursor-pointer pt-0.5" htmlFor={termsInputId}>
                <input
                  id={termsInputId}
                  type="checkbox"
                  checked={termsAgreed}
                  onChange={(e) => setTermsAgreed(e.target.checked)}
                  className="peer sr-only"
                />
                <div className="w-5 h-5 bg-surface-container-high rounded peer-checked:bg-primary flex items-center justify-center transition-colors">
                  <span className={`material-symbols-outlined text-on-primary text-[16px] transition-opacity ${termsAgreed ? 'opacity-100' : 'opacity-0'}`}>
                    check
                  </span>
                </div>
              </label>
              <label htmlFor={termsInputId} className="font-body-sm text-body-sm text-text-muted cursor-pointer select-none">
                I agree to the <a className="text-primary font-semibold hover:underline" href="#terms" onClick={(e) => { e.preventDefault(); onShowToast('UTM Terms of Service', 'FinWise operates under student data privacy guidelines.'); }}>Terms of Service</a>, <a className="text-primary font-semibold hover:underline" href="#privacy" onClick={(e) => { e.preventDefault(); onShowToast('UTM Privacy Policy', 'Financial data is protected with 256-bit encryption.'); }}>Privacy Policy</a>, and consent to student verification.
              </label>
            </div>

            {/* Primary Action Button */}
            <button
              type="submit"
              className="w-full mt-space-sm h-12 bg-primary hover:bg-primary-container text-on-primary font-label-lg text-label-lg rounded-xl flex items-center justify-center gap-2 shadow-md active:scale-[0.99] transition-all cursor-pointer"
            >
              <span>Continue to Setup Goals</span>
              <span className="material-symbols-outlined text-[18px]">arrow_forward</span>
            </button>
          </form>

          {/* Divider */}
          <div className="px-margin my-space-lg flex items-center gap-3">
            <div className="flex-1 h-px bg-surface-container-high"></div>
            <span className="font-label-sm text-label-sm text-text-muted uppercase tracking-wider">Fast Student Sign-In</span>
            <div className="flex-1 h-px bg-surface-container-high"></div>
          </div>

          {/* Fast SSO Options */}
          <div className="px-margin flex flex-col gap-space-sm">
            {/* UTM SSO Instant Connect Button */}
            <button
              type="button"
              onClick={onOpenUtmSso}
              className="w-full h-12 bg-surface-container-lowest hover:bg-surface-container-low text-text-primary rounded-xl flex items-center justify-between px-space-md shadow-sm active:scale-[0.99] transition-transform border border-outline-variant/30 cursor-pointer text-left"
            >
              <div className="flex items-center gap-3">
                <div className="w-7 h-7 rounded-full bg-tertiary-container/10 flex items-center justify-center text-tertiary font-bold font-headline-sm text-xs">
                  UTM
                </div>
                <span className="font-label-lg text-label-lg">Sign in via UTM SSO (ID Access)</span>
              </div>
              <span className="material-symbols-outlined text-text-muted text-[18px]">open_in_new</span>
            </button>

            {/* Google Button */}
            <button
              type="button"
              onClick={onOpenGoogleSso}
              className="w-full h-12 bg-surface-container-lowest hover:bg-surface-container-low text-text-primary rounded-xl flex items-center justify-center gap-3 px-space-md shadow-sm active:scale-[0.99] transition-transform border border-outline-variant/30 cursor-pointer"
            >
              <svg className="w-5 h-5 shrink-0" viewBox="0 0 24 24">
                <path d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.15z" fill="#4285F4"></path>
                <path d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.34 24 12 24z" fill="#34A853"></path>
                <path d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 10.03 0 12s.45 3.82 1.25 5.42l4.03-3.15z" fill="#FBBC05"></path>
                <path d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.34 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z" fill="#EA4335"></path>
              </svg>
              <span className="font-label-lg text-label-lg">Continue with Google</span>
            </button>
          </div>

          {/* Community Micro Social Proof */}
          <div className="px-margin mt-space-lg">
            <div className="bg-surface-container-low rounded-xl p-space-sm flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="flex -space-x-2">
                  <div className="w-7 h-7 rounded-full bg-primary text-on-primary font-bold text-[10px] flex items-center justify-center ring-2 ring-surface">
                    NR
                  </div>
                  <div className="w-7 h-7 rounded-full bg-secondary text-on-secondary font-bold text-[10px] flex items-center justify-center ring-2 ring-surface">
                    AF
                  </div>
                  <div className="w-7 h-7 rounded-full bg-primary-container text-on-primary font-bold text-[10px] flex items-center justify-center ring-2 ring-surface">
                    CL
                  </div>
                </div>
                <p className="font-body-sm text-body-sm text-text-muted">
                  <strong className="text-text-primary font-medium">3,420+</strong> UTM students registered
                </p>
              </div>
              <span className="inline-flex items-center gap-1 font-label-sm text-label-sm text-secondary font-semibold">
                <span className="material-symbols-outlined text-[14px]">shield</span> Secure
              </span>
            </div>
          </div>

          {/* Footer Navigation */}
          <div className="px-margin mt-space-lg text-center">
            <p className="font-body-md text-body-md text-text-muted">
              Already have an account?{' '}
              <button
                type="button"
                onClick={() => onNavigate('login')}
                className="text-primary font-semibold hover:underline cursor-pointer"
              >
                Log In
              </button>
            </p>
          </div>
        </div>
      </main>
    </div>
  );
};
