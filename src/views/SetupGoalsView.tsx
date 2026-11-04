import React, { useState } from 'react';
import { ScreenType } from '../types';

interface SetupGoalsViewProps {
  onNavigate: (screen: ScreenType) => void;
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'error') => void;
  onComplete: () => void;
}

export const SetupGoalsView: React.FC<SetupGoalsViewProps> = ({
  onNavigate,
  onShowToast,
  onComplete,
}) => {
  const [allowance, setAllowance] = useState<number>(900);
  const [foodPct, setFoodPct] = useState<number>(45);
  const [studyPct, setStudyPct] = useState<number>(25);
  const [savingsTarget, setSavingsTarget] = useState<number>(200);
  const [selectedGoal, setSelectedGoal] = useState('Emergency Fund');

  const foodAmount = Math.round((allowance * foodPct) / 100);
  const studyAmount = Math.round((allowance * studyPct) / 100);
  const remainingAllowance = allowance - foodAmount - studyAmount;

  const handleFinish = (e: React.FormEvent) => {
    e.preventDefault();
    onShowToast('Goals Configured!', 'Welcome to FinWise Campus. Your AI Assistant is active!', 'success');
    onComplete();
  };

  return (
    <div className="bg-surface text-on-surface font-body-md text-body-md antialiased min-h-screen flex flex-col w-full">
      {/* Header */}
      <header className="sticky top-0 w-full z-40 pt-safe bg-surface/80 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)]">
        <div className="h-14 px-margin flex items-center justify-between">
          <button
            aria-label="Go back to register"
            onClick={() => onNavigate('register')}
            className="min-w-[44px] min-h-[44px] -ml-space-xs flex items-center justify-center rounded-full text-on-surface hover:bg-surface-container-high transition-colors"
          >
            <span className="material-symbols-outlined text-[24px]">arrow_back</span>
          </button>
          <h1 className="font-headline-sm text-headline-sm text-on-surface tracking-tight text-center truncate px-space-xs flex-1">
            Setup Goals
          </h1>
          <div className="w-8 h-8 rounded-full bg-secondary flex items-center justify-center shrink-0 text-white font-bold text-xs">
            2/2
          </div>
        </div>
      </header>

      {/* Main Form */}
      <main className="flex-1 flex flex-col relative w-full bg-surface pb-safe">
        <form onSubmit={handleFinish} className="flex flex-col w-full pb-space-xl px-margin">
          {/* Progress Header */}
          <div className="pt-space-md pb-space-sm flex flex-col gap-space-sm">
            <div className="flex items-center justify-between">
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-growth-mint-subtle text-secondary font-label-sm text-label-sm uppercase tracking-wider font-semibold">
                <span className="material-symbols-outlined text-[14px]">flag</span>
                Goal Setting
              </span>
              <span className="font-label-md text-label-md text-secondary font-semibold">Step 2 of 2</span>
            </div>

            {/* Step Progress Bar - 100% */}
            <div className="w-full h-1.5 bg-surface-container-high rounded-full overflow-hidden">
              <div className="h-full bg-secondary w-full rounded-full transition-all duration-300"></div>
            </div>

            <p className="font-body-md text-body-md text-on-surface-variant leading-relaxed mt-space-xs">
              Tell us your expected monthly allowance so our AI budget engine can tailor spending limits for UTM campus life.
            </p>
          </div>

          {/* Monthly Allowance Selector */}
          <div className="mt-space-sm bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/30 shadow-sm flex flex-col gap-3">
            <label className="font-label-lg text-label-lg text-text-primary flex items-center justify-between">
              <span>Estimated Monthly Allowance</span>
              <span className="text-primary font-bold text-lg">RM {allowance}</span>
            </label>

            <div className="grid grid-cols-4 gap-2">
              {[500, 750, 900, 1200].map((amt) => (
                <button
                  key={amt}
                  type="button"
                  onClick={() => setAllowance(amt)}
                  className={`py-2 px-1 rounded-lg text-xs font-semibold transition-all ${
                    allowance === amt
                      ? 'bg-primary text-white shadow-sm'
                      : 'bg-surface-container hover:bg-surface-container-high text-text-primary'
                  }`}
                >
                  RM {amt}
                </button>
              ))}
            </div>

            <input
              type="range"
              min="300"
              max="2500"
              step="50"
              value={allowance}
              onChange={(e) => setAllowance(Number(e.target.value))}
              className="w-full accent-primary mt-1"
            />
          </div>

          {/* AI Category Allocations */}
          <div className="mt-space-md flex flex-col gap-3">
            <div className="flex items-center justify-between">
              <span className="font-label-md text-label-md text-text-muted">AI Campus Budget Allocation</span>
              <span className="text-secondary font-label-sm text-label-sm flex items-center gap-1">
                <span className="material-symbols-outlined text-[14px]">auto_awesome</span> Smart Preset
              </span>
            </div>

            {/* Category 1: Food & Arkid */}
            <div className="bg-surface-container-lowest p-3 rounded-xl border border-outline-variant/30 flex items-center justify-between shadow-sm">
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-lg bg-orange-100 text-orange-600 flex items-center justify-center">
                  <span className="material-symbols-outlined text-[20px]">restaurant</span>
                </div>
                <div>
                  <p className="font-label-md text-label-md font-semibold text-text-primary">Campus Food & Cafeteria</p>
                  <p className="font-body-sm text-xs text-text-muted">Arkid Meranti, KTC Cafe ({foodPct}%)</p>
                </div>
              </div>
              <span className="font-bold text-sm text-text-primary">RM {foodAmount}</span>
            </div>

            {/* Category 2: Academic & Books */}
            <div className="bg-surface-container-lowest p-3 rounded-xl border border-outline-variant/30 flex items-center justify-between shadow-sm">
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center">
                  <span className="material-symbols-outlined text-[20px]">menu_book</span>
                </div>
                <div>
                  <p className="font-label-md text-label-md font-semibold text-text-primary">Study Materials & Tech</p>
                  <p className="font-body-sm text-xs text-text-muted">Printing, labs, software ({studyPct}%)</p>
                </div>
              </div>
              <span className="font-bold text-sm text-text-primary">RM {studyAmount}</span>
            </div>

            {/* Category 3: Flex / Savings */}
            <div className="bg-surface-container-lowest p-3 rounded-xl border border-outline-variant/30 flex items-center justify-between shadow-sm">
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-lg bg-emerald-100 text-secondary flex items-center justify-center">
                  <span className="material-symbols-outlined text-[20px]">savings</span>
                </div>
                <div>
                  <p className="font-label-md text-label-md font-semibold text-text-primary">Discretionary & Savings</p>
                  <p className="font-body-sm text-xs text-text-muted">Residual buffer</p>
                </div>
              </div>
              <span className="font-bold text-sm text-secondary">RM {remainingAllowance}</span>
            </div>
          </div>

          {/* Primary Savings Goal */}
          <div className="mt-space-md bg-surface-container-low rounded-xl p-space-md border border-outline-variant/30 flex flex-col gap-2.5">
            <label className="font-label-md text-label-md text-text-muted">Choose Your First Savings Milestone</label>
            <div className="grid grid-cols-3 gap-2">
              {['Emergency Fund', 'Laptop Upgrade', 'Sem Break Trip'].map((goal) => (
                <button
                  key={goal}
                  type="button"
                  onClick={() => setSelectedGoal(goal)}
                  className={`p-2.5 rounded-xl text-xs font-medium text-center transition-all ${
                    selectedGoal === goal
                      ? 'bg-secondary text-white shadow-sm ring-2 ring-secondary/20'
                      : 'bg-surface-container-lowest hover:bg-surface-container text-text-primary border border-outline-variant/30'
                  }`}
                >
                  {goal}
                </button>
              ))}
            </div>

            <div className="flex items-center justify-between text-xs text-text-muted pt-1">
              <span>Target monthly contribution:</span>
              <span className="font-semibold text-secondary">RM {savingsTarget} / month</span>
            </div>
          </div>

          {/* Submit Action */}
          <div className="mt-space-lg flex flex-col gap-2">
            <button
              type="submit"
              className="w-full h-12 bg-primary hover:bg-primary-container text-on-primary font-label-lg text-label-lg rounded-xl flex items-center justify-center gap-2 shadow-md active:scale-[0.99] transition-transform cursor-pointer"
            >
              <span>Complete Setup & Launch FinWise</span>
              <span className="material-symbols-outlined text-[18px]">rocket_launch</span>
            </button>
            <button
              type="button"
              onClick={() => onNavigate('login')}
              className="w-full py-2.5 text-center font-label-md text-label-md text-text-muted hover:text-text-primary transition-colors"
            >
              Skip setup for now
            </button>
          </div>
        </form>
      </main>
    </div>
  );
};
