import React, { useState } from 'react';
import { ScreenType } from './types';
import { LoginView } from './views/LoginView';
import { RegisterView } from './views/RegisterView';

export const App: React.FC = () => {
  const [screen, setScreen] = useState<ScreenType>('login');

  return (
    <div className="w-full min-h-screen bg-slate-900 flex justify-center items-start">
      {/* Pure Mobile App Container */}
      <div className="w-full max-w-[430px] min-h-screen bg-surface shadow-2xl relative flex flex-col">
        {screen === 'login' ? (
          <LoginView onNavigateToRegister={() => setScreen('register')} />
        ) : (
          <RegisterView onNavigateToLogin={() => setScreen('login')} />
        )}
      </div>
    </div>
  );
};
