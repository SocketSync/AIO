export type ScreenType = 'login' | 'register' | 'setup-goals' | 'dashboard';

export interface UserProfile {
  fullName: string;
  email: string;
  matricId?: string;
  campus: string;
  isUtmVerified: boolean;
  savedAmount: number;
  monthlyBudget: number;
}

export interface ToastMessage {
  id: string;
  type: 'success' | 'info' | 'warning' | 'error';
  title: string;
  description?: string;
}
