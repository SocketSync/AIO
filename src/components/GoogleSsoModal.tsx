import React, { useState } from 'react';

interface GoogleSsoModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (email: string) => void;
}

export const GoogleSsoModal: React.FC<GoogleSsoModalProps> = ({ isOpen, onClose, onSuccess }) => {
  const [selectedEmail, setSelectedEmail] = useState('keanshen@graduate.utm.my');
  const [isLoading, setIsLoading] = useState(false);

  if (!isOpen) return null;

  const handleSelect = (email: string) => {
    setSelectedEmail(email);
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      onSuccess(email);
    }, 1000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div 
        className="relative w-full max-w-sm bg-surface-container-lowest rounded-2xl p-6 shadow-2xl flex flex-col"
        role="dialog"
        aria-modal="true"
      >
        <div className="flex items-center justify-between pb-3 border-b border-border-neutral">
          <div className="flex items-center gap-2">
            <svg className="w-5 h-5 shrink-0" viewBox="0 0 24 24">
              <path d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.15z" fill="#4285F4"></path>
              <path d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.34 24 12 24z" fill="#34A853"></path>
              <path d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 10.03 0 12s.45 3.82 1.25 5.42l4.03-3.15z" fill="#FBBC05"></path>
              <path d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.34 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z" fill="#EA4335"></path>
            </svg>
            <span className="font-label-lg text-label-lg font-semibold text-text-primary">Sign in with Google</span>
          </div>
          <button 
            onClick={onClose}
            className="p-1 text-text-muted hover:text-text-primary rounded-full hover:bg-surface-container transition-colors"
            aria-label="Close"
          >
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>

        <div className="py-4">
          <p className="font-body-sm text-body-sm text-text-muted mb-3">
            Choose a Google Workspace account to continue to <span className="font-semibold text-text-primary">FinWise Campus</span>
          </p>

          <div className="flex flex-col gap-2">
            {/* Account 1 - UTM Graduate */}
            <button
              onClick={() => handleSelect('keanshen@graduate.utm.my')}
              disabled={isLoading}
              className="flex items-center gap-3 p-3 rounded-xl border border-border-neutral hover:bg-surface-container-low transition-all text-left group"
            >
              <div className="w-10 h-10 rounded-full bg-primary text-white flex items-center justify-center font-bold text-sm shrink-0">
                YS
              </div>
              <div className="min-w-0 flex-1">
                <p className="font-label-md text-label-md font-semibold text-text-primary truncate">Yeoh Kean Shen</p>
                <p className="font-body-sm text-xs text-text-muted truncate">keanshen@graduate.utm.my</p>
              </div>
              <span className="material-symbols-outlined text-secondary text-[18px]">verified</span>
            </button>

            {/* Account 2 - UTM Staff/Student Alt */}
            <button
              onClick={() => handleSelect('yeoh.k@utm.my')}
              disabled={isLoading}
              className="flex items-center gap-3 p-3 rounded-xl border border-border-neutral hover:bg-surface-container-low transition-all text-left group"
            >
              <div className="w-10 h-10 rounded-full bg-secondary text-white flex items-center justify-center font-bold text-sm shrink-0">
                YK
              </div>
              <div className="min-w-0 flex-1">
                <p className="font-label-md text-label-md font-semibold text-text-primary truncate">Yeoh Keng Wei</p>
                <p className="font-body-sm text-xs text-text-muted truncate">yeoh.k@utm.my</p>
              </div>
            </button>
          </div>
        </div>

        {isLoading && (
          <div className="flex items-center justify-center gap-2 py-2 text-primary font-label-md text-label-md">
            <span className="material-symbols-outlined text-[18px] animate-spin">sync</span>
            <span>Signing in as {selectedEmail}...</span>
          </div>
        )}

        <div className="pt-2 text-center">
          <button
            onClick={onClose}
            className="text-xs text-text-muted hover:underline"
          >
            Cancel and return
          </button>
        </div>
      </div>
    </div>
  );
};
