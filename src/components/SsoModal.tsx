import React, { useState } from 'react';

interface SsoModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (email: string) => void;
}

export const SsoModal: React.FC<SsoModalProps> = ({ isOpen, onClose, onSuccess }) => {
  const [matricId, setMatricId] = useState('A22EC0123');
  const [password, setPassword] = useState('••••••••••••');
  const [isSubmitting, setIsSubmitting] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      onSuccess('keanshen@graduate.utm.my');
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div 
        className="relative w-full max-w-md bg-surface-container-lowest rounded-2xl overflow-hidden shadow-2xl flex flex-col"
        role="dialog"
        aria-modal="true"
      >
        {/* UTM Maroon / Tertiary Bar */}
        <div className="bg-[#5d1725] text-white p-5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center font-bold text-sm tracking-widest text-[#f5c518] ring-1 ring-white/20">
              UTM
            </div>
            <div>
              <h3 className="font-semibold text-base leading-tight">UTM Access Gateway</h3>
              <p className="text-xs text-white/80">CIDOS Single Sign-On (ACID System)</p>
            </div>
          </div>
          <button 
            onClick={onClose}
            className="p-1 rounded-full text-white/80 hover:text-white hover:bg-white/10 transition-colors"
            aria-label="Close"
          >
            <span className="material-symbols-outlined text-[20px]">close</span>
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 flex flex-col gap-4">
          <div className="bg-amber-50 border border-amber-200/80 rounded-xl p-3 flex items-start gap-2.5 text-xs text-amber-900">
            <span className="material-symbols-outlined text-[18px] text-amber-600 shrink-0 mt-0.5">verified_user</span>
            <p>
              You are logging into FinWise via official UTM Student credentials. Single Sign-On validates your scholarship & active semester status automatically.
            </p>
          </div>

          <div className="flex flex-col gap-1.5">
            <label className="font-label-md text-label-md text-text-muted">ACID Username / Student Matric ID</label>
            <div className="relative bg-surface-container-low rounded-xl flex items-center px-3 py-2.5 shadow-sm border border-outline-variant/40">
              <span className="material-symbols-outlined text-[20px] text-text-muted mr-2">badge</span>
              <input 
                type="text" 
                value={matricId} 
                onChange={(e) => setMatricId(e.target.value)}
                placeholder="e.g. A22EC0123" 
                className="w-full bg-transparent font-body-md text-text-primary outline-none"
                required
              />
            </div>
          </div>

          <div className="flex flex-col gap-1.5">
            <label className="font-label-md text-label-md text-text-muted">MyUTM / ACID Password</label>
            <div className="relative bg-surface-container-low rounded-xl flex items-center px-3 py-2.5 shadow-sm border border-outline-variant/40">
              <span className="material-symbols-outlined text-[20px] text-text-muted mr-2">lock</span>
              <input 
                type="password" 
                value={password} 
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••" 
                className="w-full bg-transparent font-body-md text-text-primary outline-none"
                required
              />
            </div>
          </div>

          <div className="flex items-center justify-between text-xs text-text-muted pt-1">
            <span>Server: cidosp.utm.my</span>
            <span className="text-secondary font-medium flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-secondary"></span> Online
            </span>
          </div>

          <div className="flex flex-col gap-2 pt-2">
            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full py-3 bg-[#5d1725] hover:bg-[#4a121d] text-white font-label-lg text-label-lg rounded-xl flex items-center justify-center gap-2 shadow-md transition-all active:scale-[0.99] disabled:opacity-70"
            >
              {isSubmitting ? (
                <>
                  <span className="material-symbols-outlined text-[18px] animate-spin">sync</span>
                  <span>Verifying UTM Directory...</span>
                </>
              ) : (
                <>
                  <span>Authenticate with CIDOS</span>
                  <span className="material-symbols-outlined text-[18px]">login</span>
                </>
              )}
            </button>
            <button
              type="button"
              onClick={onClose}
              className="w-full py-2.5 font-label-md text-label-md text-text-muted hover:text-text-primary rounded-xl transition-colors"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
