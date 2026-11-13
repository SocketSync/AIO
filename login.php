<?php
session_start();
require_once __DIR__ . '/php/auth.php';

$message = '';
$messageType = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $studentId = isset($_POST['student_id']) ? $_POST['student_id'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';

    $result = StudentAuth::login($studentId, $password);
    $message = $result['message'];
    $messageType = $result['success'] ? 'success' : 'error';
    if ($result['success']) {
        $_SESSION['student_user'] = $result['student'];
    }
}
?>
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  <meta name="shell-type" content="mobile_stack">
  <title>FinWise - Student Login</title>
  
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
  
  <link rel="stylesheet" href="css/style.css">
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            "primary": "#00236f",
            "primary-container": "#1e3a8a",
            "on-primary": "#ffffff",
            "secondary": "#006c49",
            "secondary-fixed": "#6ffbbe",
            "surface": "#faf8ff",
            "surface-container-low": "#f4f3fa",
            "surface-container-lowest": "#ffffff",
            "surface-container-high": "#e9e7ef",
            "surface-container-highest": "#e3e1e9",
            "growth-mint-subtle": "#D1FAE5",
            "outline": "#757682",
            "text-primary": "#0F172A",
            "text-muted": "#64748B",
            "on-surface": "#1a1b21",
            "on-surface-variant": "#444651"
          },
          spacing: {
            "margin": "1rem",
            "space-xs": "0.25rem",
            "space-sm": "0.5rem",
            "space-md": "1rem",
            "space-lg": "1.5rem",
            "space-xl": "2rem"
          }
        }
      }
    };
  </script>
</head>
<body class="bg-slate-900 text-on-surface antialiased min-h-screen flex justify-center">

  <div class="w-full max-w-[430px] min-h-screen flex flex-col bg-surface shadow-2xl relative">
    
    <!-- Header -->
    <header class="fixed top-0 w-full max-w-[430px] z-50 pt-safe bg-surface/80 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)]">
      <div class="h-14 px-margin flex items-center justify-between">
        <div class="w-8 h-8 shrink-0"></div>
        <h1 class="font-semibold text-lg text-on-surface tracking-tight text-center truncate px-space-xs flex-1">Login</h1>
        <div class="w-8 h-8 rounded-full bg-primary flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-on-primary text-[18px]">person</span>
        </div>
      </div>
    </header>

    <main class="flex-1 flex flex-col relative w-full bg-surface pt-14 pb-safe">
      <div class="flex flex-col w-full px-margin pb-space-xl">
        
        <?php if (!empty($message)): ?>
          <div class="mt-space-sm p-3 rounded-xl text-xs font-semibold flex items-center gap-2 <?php echo $messageType === 'success' ? 'bg-growth-mint-subtle text-secondary' : 'bg-red-100 text-red-700'; ?>">
            <span class="material-symbols-outlined text-[18px]"><?php echo $messageType === 'success' ? 'check_circle' : 'error'; ?></span>
            <span><?php echo htmlspecialchars($message); ?></span>
          </div>
        <?php endif; ?>

        <!-- Campus Mascot Card -->
        <div class="relative w-full overflow-hidden rounded-xl bg-surface-container-low p-space-md shadow-sm mb-space-md mt-space-xs border border-slate-200">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-space-sm">
              <div class="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-on-primary shadow-sm">
                <span class="material-symbols-outlined text-[22px]">account_balance_wallet</span>
              </div>
              <div>
                <div class="flex items-center gap-1">
                  <span class="font-bold text-lg text-primary tracking-tight">FinWise</span>
                  <span class="bg-growth-mint-subtle text-secondary text-xs px-1.5 py-0.5 rounded-full font-bold">PRO</span>
                </div>
                <p class="text-xs text-text-muted">Smart Financial Management</p>
              </div>
            </div>
            <div class="flex items-center gap-1 bg-surface-container-highest px-2 py-1 rounded-full text-on-surface-variant text-xs">
              <span class="material-symbols-outlined text-[14px] text-secondary">verified_user</span>
              <span>Cloud Sync</span>
            </div>
          </div>

          <div class="mt-space-md bg-surface-container-lowest p-space-sm rounded-lg flex items-center gap-space-sm shadow-sm">
            <span class="material-symbols-outlined text-secondary text-[20px]">account_balance</span>
            <div class="min-w-0 flex-1">
              <p class="text-xs text-secondary font-semibold uppercase tracking-wider">Smart Budget Forecast</p>
              <p class="text-xs text-on-surface truncate">Monthly budget active • Intelligent AI Insights</p>
            </div>
            <div class="w-2 h-2 rounded-full bg-secondary shrink-0 animate-ping"></div>
          </div>
        </div>

        <div class="mb-space-lg">
          <h2 class="text-2xl font-bold text-on-surface tracking-tight">Welcome back</h2>
          <p class="text-sm text-text-muted mt-0.5">Take control of your personal finances and dynamic budget.</p>
        </div>

        <!-- Login Form -->
        <form class="flex flex-col gap-space-md w-full" method="POST" action="login.php">
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-medium text-text-muted flex items-center justify-between" for="student-id">
              <span>Email Address</span>
              <span class="text-secondary text-xs font-semibold flex items-center gap-0.5">
                <span class="material-symbols-outlined text-[12px]">check_circle</span> Verified Account
              </span>
            </label>
            <div class="relative flex items-center bg-surface-container-lowest rounded-lg shadow-sm border border-slate-200">
              <div class="absolute left-3 flex items-center pointer-events-none text-text-muted">
                <span class="material-symbols-outlined text-[20px]">mail</span>
              </div>
              <input class="w-full bg-transparent pl-10 pr-4 py-3 text-sm text-on-surface outline-none" id="student-id" name="student_id" placeholder="demo@finwise-app.xyz" required type="email" value="demo@finwise-app.xyz">
            </div>
          </div>

          <div class="flex flex-col gap-1.5">
            <div class="flex items-center justify-between">
              <label class="text-xs font-medium text-text-muted" for="password">Password</label>
              <button class="text-xs text-primary font-semibold hover:underline" onclick="window.location.href='forgot_password.html';" type="button">
                Forgot Password?
              </button>
            </div>
            <div class="relative flex items-center bg-surface-container-lowest rounded-lg shadow-sm border border-slate-200">
              <div class="absolute left-3 flex items-center pointer-events-none text-text-muted">
                <span class="material-symbols-outlined text-[20px]">lock</span>
              </div>
              <input class="w-full bg-transparent pl-10 pr-12 py-3 text-sm text-on-surface outline-none tracking-widest" id="password" name="password" placeholder="••••••••••••" required type="password" value="FinWise2026!">
              <button aria-label="Toggle password view" class="absolute right-2 p-1.5 text-text-muted hover:text-on-surface rounded-full transition-colors flex items-center justify-center" id="toggle-password" onclick="togglePasswordVisibility()" type="button">
                <span class="material-symbols-outlined text-[20px]" id="password-icon">visibility</span>
              </button>
            </div>
          </div>

          <div class="flex items-center justify-between pt-0.5">
            <label class="flex items-center gap-2 cursor-pointer select-none">
              <input checked class="w-4 h-4 rounded text-primary accent-primary cursor-pointer" id="remember-me" name="remember_me" type="checkbox">
              <span class="text-xs text-on-surface font-normal">Remember device</span>
            </label>
            <div class="flex items-center gap-1 bg-growth-mint-subtle px-2 py-0.5 rounded-full">
              <span class="material-symbols-outlined text-[13px] text-secondary">shield_lock</span>
              <span class="text-xs text-secondary font-medium">256-bit AES</span>
            </div>
          </div>

          <div class="flex flex-col gap-space-sm pt-space-xs">
            <button class="w-full min-h-[48px] bg-primary text-on-primary rounded-lg text-sm font-semibold flex items-center justify-center gap-2 shadow-md hover:bg-primary-container active:scale-[0.99] transition-all cursor-pointer" id="login-btn" type="submit">
              <span>Log In</span>
              <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
            </button>

            <button class="w-full min-h-[46px] bg-surface-container-high text-primary rounded-lg text-sm font-semibold flex items-center justify-center gap-2 hover:bg-surface-container-highest transition-colors active:scale-[0.99] cursor-pointer" id="biometric-btn" onclick="simulateBiometrics()" type="button">
              <span class="material-symbols-outlined text-[22px] text-secondary">fingerprint</span>
              <span>Log in with Touch ID / Face ID</span>
            </button>
          </div>
        </form>

        <div class="relative my-space-lg flex items-center justify-center">
          <div class="w-full h-px bg-surface-container-highest"></div>
          <span class="absolute bg-surface px-3 text-xs text-text-muted uppercase tracking-wider">
            Or continue with
          </span>
        </div>

        <div class="grid grid-cols-2 gap-space-sm">
          <button class="flex flex-col items-center justify-center p-space-sm bg-surface-container-lowest rounded-lg shadow-sm hover:shadow-md transition-all active:scale-[0.98] text-center gap-1 border border-slate-200 cursor-pointer" onclick="window.location.href='login.html';" type="button">
            <div class="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center text-primary">
              <span class="material-symbols-outlined text-[20px]">account_circle</span>
            </div>
            <span class="text-xs text-on-surface font-semibold mt-1">Web Portal</span>
            <span class="text-[10px] text-text-muted">Interactive App</span>
          </button>

          <button class="flex flex-col items-center justify-center p-space-sm bg-surface-container-lowest rounded-lg shadow-sm hover:shadow-md transition-all active:scale-[0.98] text-center gap-1 border border-slate-200 cursor-pointer" onclick="alert('Redirecting to Google Campus Account Selection...');" type="button">
            <div class="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center">
              <svg class="w-5 h-5" viewBox="0 0 24 24">
                <path d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.15z" fill="#4285F4"></path>
                <path d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.26v3.15C3.25 21.37 7.34 24 12 24z" fill="#34A853"></path>
                <path d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.26C.46 8.16 0 9.94 0 12s.46 3.84 1.26 5.42l4.02-3.15z" fill="#FBBC05"></path>
                <path d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.34 0 3.25 2.63 1.26 6.58l4.02 3.15c.95-2.83 3.6-4.98 6.72-4.98z" fill="#EA4335"></path>
              </svg>
            </div>
            <span class="text-xs text-on-surface font-semibold mt-1">Google</span>
            <span class="text-[10px] text-text-muted">Campus G-Suite</span>
          </button>
        </div>

        <div class="mt-space-lg bg-surface-container-low rounded-xl p-space-sm flex items-center justify-between border border-slate-200 cursor-pointer" onclick="alert('Top 10% saver in Kolej Tuanku Canselor (RM 450 saved this term)!')">
          <div class="flex items-center gap-space-sm min-w-0">
            <div class="w-8 h-8 rounded-full bg-growth-mint-subtle flex items-center justify-center text-secondary shrink-0">
              <span class="material-symbols-outlined text-[16px]">savings</span>
            </div>
            <div class="truncate">
              <p class="text-xs text-on-surface font-semibold truncate">RM 450.00 Saved this term</p>
              <p class="text-[11px] text-text-muted">Top 10% saver in Kolej Tuanku Canselor</p>
            </div>
          </div>
          <span class="material-symbols-outlined text-outline text-[18px]">chevron_right</span>
        </div>

        <div class="mt-space-xl text-center pb-space-sm">
          <p class="text-sm text-text-muted">
            Don't have an account? 
            <a class="text-primary font-bold hover:underline ml-1" href="register.php">Sign Up</a>
          </p>
          <p class="text-xs text-outline mt-2 flex items-center justify-center gap-1">
            <span class="material-symbols-outlined text-[14px]">lock_clock</span> FinWise for Higher Ed v2.4.1
          </p>
        </div>

      </div>
    </main>
  </div>

  <script>
    function togglePasswordVisibility() {
      const pwd = document.getElementById('password');
      const icon = document.getElementById('password-icon');
      if (pwd.type === 'password') {
        pwd.type = 'text';
        icon.textContent = 'visibility_off';
      } else {
        pwd.type = 'password';
        icon.textContent = 'visibility';
      }
    }

    function simulateBiometrics() {
      const btn = document.getElementById('biometric-btn');
      btn.innerHTML = '<span class="material-symbols-outlined text-[20px] animate-spin text-secondary">sync</span><span>Authenticating biometric sensor...</span>';
      setTimeout(() => {
        btn.innerHTML = '<span class="material-symbols-outlined text-[20px] text-secondary">check_circle</span><span>Identity Verified!</span>';
        setTimeout(() => {
          btn.innerHTML = '<span class="material-symbols-outlined text-[22px] text-secondary">fingerprint</span><span>Log in with Touch ID / Face ID</span>';
        }, 1500);
      }, 900);
    }
  </script>
</body>
</html>

