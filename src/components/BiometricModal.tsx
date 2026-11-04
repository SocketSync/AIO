import React, { useState, useEffect } from 'react';

interface BiometricModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export const BiometricModal: React.FC<BiometricModalProps> = ({ isOpen, onClose, onSuccess }) => {
  const [scanState, setScanState] = useState<'idle' | 'scanning' | 'success' | 'failed'>('idle');

  useEffect(() => {
    if (isOpen) {
      setScanState('idle');
      // Auto-start scanning after brief mount
      const timer = setTimeout(() => {
        setScanState('scanning');
        const successTimer = setTimeout(() => {
          setScanState('success');
          const closeTimer = setTimeout(() => {
            onSuccess();
          }, 1000);
          return () => clearTimeout(closeTimer);
        }, 1600);
        return () => clearTimeout(successTimer);
      }, 500);
      return () => clearTimeout(timer);
    }
  }, [isOpen, onSuccess]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div 
        className="relative w-full max-w-sm bg-surface-container-lowest rounded-2xl p-6 shadow-2xl flex flex-col items-center text-center transform transition-all duration-300 scale-100"
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

        {/* Biometric Animation Graphic */}
        <div className="relative my-4 flex items-center justify-center">
          <div className={`w-24 h-24 rounded-full flex items-center justify-center transition-all duration-500 ${
            scanState === 'success' 
              ? 'bg-growth-mint-subtle text-secondary ring-4 ring-secondary/30' 
              : scanState === 'scanning' 
              ? 'bg-secondary/10 text-secondary ring-4 ring-secondary/20 animate-pulse' 
              : 'bg-surface-container text-primary'
          }`}>
            <span className="material-symbols-outlined text-[48px]">
              {scanState === 'success' ? 'check_circle' : 'fingerprint'}
            </span>
          </div>

          {scanState === 'scanning' && (
            <div className="absolute inset-0 border-2 border-secondary rounded-full animate-ping opacity-30"></div>
          )}
        </div>

        <h3 className="font-headline-sm text-headline-sm text-on-surface mb-1">
          {scanState === 'idle' && 'Touch ID / Face ID'}
          {scanState === 'scanning' && 'Authenticating Sensor...'}
          {scanState === 'success' && 'Identity Verified!'}
        </h3>

        <p className="font-body-sm text-body-sm text-text-muted max-w-[260px] mb-6">
          {scanState === 'idle' && 'Confirm your fingerprint or look at the camera to log in.'}
          {scanState === 'scanning' && 'Verifying your UTM student biometric credentials...'}
          {scanState === 'success' && 'Welcome back, Yeoh! Decrypting your campus vault.'}
        </p>

        <div className="w-full flex flex-col gap-2">
          {scanState !== 'success' ? (
            <button
              onClick={onClose}
              className="w-full py-2.5 px-4 rounded-xl font-label-md text-label-md text-text-muted bg-surface-container-high hover:bg-surface-container-highest transition-colors"
            >
              Use Student Password Instead
            </button>
          ) : (
            <div className="w-full py-2.5 px-4 rounded-xl font-label-md text-label-md text-secondary bg-growth-mint-subtle font-medium flex items-center justify-center gap-1.5">
              <span className="material-symbols-outlined text-[16px]">verified_user</span>
              Access Granted
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
