import React, { useState } from 'react';

interface ForgotPasswordModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (email: string) => void;
}

export const ForgotPasswordModal: React.FC<ForgotPasswordModalProps> = ({ isOpen, onClose, onSubmit }) => {
  const [email, setEmail] = useState('yeoh.k@graduate.utm.my');
  const [isSent, setIsSent] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSent(true);
    setTimeout(() => {
      onSubmit(email);
      setIsSent(false);
      onClose();
    }, 1500);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div 
        className="relative w-full max-w-sm bg-surface-container-lowest rounded-2xl p-6 shadow-2xl flex flex-col"
        role="dialog"
        aria-modal="true"
      >
        <button 
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 text-text-muted hover:text-text-primary rounded-full hover:bg-surface-container transition-colors"
          aria-label="Close"
        >
          <span className="material-symbols-outlined text-[20px]">close</span>
        </button>

        <div className="w-12 h-12 rounded-2xl bg-primary-fixed flex items-center justify-center text-primary mb-3">
          <span className="material-symbols-outlined text-[26px]">lock_reset</span>
        </div>

        <h3 className="font-headline-sm text-headline-sm text-on-surface mb-1">
          Reset Student Password
        </h3>
        <p className="font-body-sm text-body-sm text-text-muted mb-4">
          Enter your registered UTM student email. We will send a secure password reset link and verification code.
        </p>

        {isSent ? (
          <div className="p-4 bg-growth-mint-subtle rounded-xl text-center flex flex-col items-center gap-2">
            <span className="material-symbols-outlined text-secondary text-[32px]">mark_email_read</span>
            <p className="font-label-md text-label-md text-secondary font-semibold">Magic Link Dispatched!</p>
            <p className="font-body-sm text-xs text-secondary/80">
              Check your UTM student inbox at <strong>{email}</strong>
            </p>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="flex flex-col gap-3">
            <div className="flex flex-col gap-1.5">
              <label className="font-label-md text-label-md text-text-muted">Student Email</label>
              <div className="relative bg-surface-container rounded-xl flex items-center px-3 py-2.5 shadow-sm">
                <span className="material-symbols-outlined text-[20px] text-text-muted mr-2">email</span>
                <input 
                  type="email" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="student@graduate.utm.my" 
                  className="w-full bg-transparent font-body-md text-text-primary outline-none"
                  required
                />
              </div>
            </div>

            <div className="flex flex-col gap-2 pt-2">
              <button
                type="submit"
                className="w-full py-3 bg-primary hover:bg-primary-container text-on-primary font-label-lg text-label-lg rounded-xl flex items-center justify-center gap-2 shadow-md transition-all active:scale-[0.99]"
              >
                <span>Send Reset Link</span>
                <span className="material-symbols-outlined text-[18px]">send</span>
              </button>
              <button
                type="button"
                onClick={onClose}
                className="w-full py-2 font-label-md text-label-md text-text-muted hover:text-text-primary rounded-xl transition-colors"
              >
                Back to Login
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
};
