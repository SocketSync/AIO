<?php
session_start();
require_once __DIR__ . '/php/auth.php';

$message = '';
$messageType = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $fullName = isset($_POST['full_name']) ? $_POST['full_name'] : '';
    $email = isset($_POST['email']) ? $_POST['email'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';

    $result = StudentAuth::register($fullName, $email, $password);
    $message = $result['message'];
    $messageType = $result['success'] ? 'success' : 'error';
    if ($result['success']) {
        header("refresh:2;url=login.php");
    }
}
?>
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  <meta name="shell-type" content="mobile_stack">
  <title>FinWise - Student Registration</title>
  
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
            "on-secondary-fixed": "#002113",
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
        <a aria-label="Go to login" href="login.php" class="min-w-[44px] min-h-[44px] -ml-space-xs flex items-center justify-center rounded-full text-on-surface hover:bg-surface-container-high transition-colors">
          <span class="material-symbols-outlined text-[24px]">arrow_back</span>
        </a>
        <h1 class="font-semibold text-lg text-on-surface tracking-tight text-center truncate px-space-xs flex-1">Register</h1>
        <div class="w-8 h-8 rounded-full bg-primary flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-on-primary text-[18px]">person</span>
        </div>
      </div>
    </header>

    <main class="flex-1 flex flex-col relative w-full bg-surface pt-14 pb-safe">
      <div class="flex flex-col w-full pb-space-xl">
        
        <?php if (!empty($message)): ?>
          <div class="px-margin mt-space-sm p-3 rounded-xl text-xs font-semibold flex items-center gap-2 <?php echo $messageType === 'success' ? 'bg-growth-mint-subtle text-secondary' : 'bg-red-100 text-red-700'; ?>">
            <span class="material-symbols-outlined text-[18px]"><?php echo $messageType === 'success' ? 'check_circle' : 'error'; ?></span>
            <span><?php echo htmlspecialchars($message); ?></span>
          </div>
        <?php endif; ?>

        <!-- Progress Header & Context Banner -->
        <div class="px-margin pt-space-md pb-space-sm flex flex-col gap-space-sm">
          <div class="flex items-center justify-between">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-secondary-fixed text-on-secondary-fixed text-xs font-semibold uppercase tracking-wider shadow-sm">
              <span class="material-symbols-outlined text-[14px]">school</span>
              Student Onboarding
            </span>
            <span class="text-xs text-text-muted font-medium">Step 1 of 2</span>
          </div>

          <div class="w-full h-1.5 bg-surface-container-high rounded-full overflow-hidden">
            <div class="h-full bg-secondary w-1/2 rounded-full transition-all duration-300"></div>
          </div>

          <div class="mt-space-xs">
            <p class="text-sm text-on-surface-variant leading-relaxed">
              Join thousands of UTM students building smarter saving habits and budgeting with AI.
            </p>
          </div>
        </div>

        <!-- UTM Perk Delight Banner -->
        <div class="px-margin mb-space-md">
          <div class="relative overflow-hidden bg-gradient-to-r from-primary-container to-primary text-on-primary rounded-xl p-space-md shadow-md">
            <div class="flex items-start gap-3 relative z-10">
              <div class="w-10 h-10 rounded-xl bg-white/15 flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-secondary-fixed text-[24px]">verified</span>
              </div>
              <div class="flex flex-col gap-0.5">
                <span class="text-sm font-semibold text-secondary-fixed">UTM Student Benefit</span>
                <p class="text-xs text-white/90 leading-tight">
                  Register with your student ID to unlock <strong class="text-white font-semibold">FinWise Pro &amp; AI Assistant</strong> free throughout this academic year.
                </p>
              </div>
            </div>
            <div class="absolute -right-4 -bottom-6 w-24 h-24 rounded-full bg-secondary-fixed/10 pointer-events-none blur-lg"></div>
          </div>
        </div>

        <!-- Registration Form -->
        <form class="px-margin flex flex-col gap-space-md" method="POST" action="register.php">
          
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-medium text-text-muted flex items-center justify-between">
              <span>Campus / Institution</span>
              <span class="text-secondary font-semibold text-xs">Verified Partner</span>
            </label>
            <div class="relative bg-surface-container-lowest rounded-xl p-space-sm flex items-center gap-3 shadow-sm border border-slate-200">
              <div class="w-9 h-9 rounded-lg bg-surface-container-low flex items-center justify-center shrink-0 text-primary">
                <span class="material-symbols-outlined text-[20px]">account_balance</span>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-semibold text-text-primary truncate">Universiti Teknologi Malaysia (UTM)</p>
                <p class="text-xs text-text-muted truncate">Skudai &amp; Kuala Lumpur Campuses</p>
              </div>
              <span class="material-symbols-outlined text-secondary text-[20px]">check_circle</span>
            </div>
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-medium text-text-muted" for="fullName">Full Name (as per Student ID)</label>
            <div class="relative bg-surface-container-lowest rounded-xl flex items-center shadow-sm border border-slate-200">
              <div class="pl-space-md pr-space-xs text-text-muted flex items-center pointer-events-none">
                <span class="material-symbols-outlined text-[20px]">person</span>
              </div>
              <input class="w-full py-3.5 pr-space-md bg-transparent text-sm text-text-primary placeholder:text-outline focus:outline-none" id="fullName" name="full_name" placeholder="e.g. Yeoh Kean Shen" type="text" value="Yeoh Kean Shen" required>
            </div>
          </div>

          <div class="flex flex-col gap-1.5">
            <div class="flex items-center justify-between">
              <label class="text-xs font-medium text-text-muted" for="email">University / Student Email</label>
              <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-secondary bg-growth-mint-subtle px-2 py-0.5 rounded-full">
                <span class="material-symbols-outlined text-[12px]">bolt</span> Instant Perks
              </span>
            </div>
            <div class="relative bg-surface-container-lowest rounded-xl flex items-center shadow-sm border border-slate-200">
              <div class="pl-space-md pr-space-xs text-text-muted flex items-center pointer-events-none">
                <span class="material-symbols-outlined text-[20px]">school</span>
              </div>
              <input class="w-full py-3.5 pr-space-md bg-transparent text-sm text-text-primary placeholder:text-outline focus:outline-none" id="email" name="email" placeholder="keanshen@graduate.utm.my" type="email" value="keanshen@graduate.utm.my" required>
            </div>
            <p class="text-xs text-text-muted flex items-center gap-1 pl-1">
              <span class="material-symbols-outlined text-[14px] text-secondary">info</span>
              Use @utm.my or @graduate.utm.my for instant student status validation.
            </p>
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-medium text-text-muted" for="password">Create Password</label>
            <div class="relative bg-surface-container-lowest rounded-xl flex items-center shadow-sm border border-slate-200">
              <div class="pl-space-md pr-space-xs text-text-muted flex items-center pointer-events-none">
                <span class="material-symbols-outlined text-[20px]">lock</span>
              </div>
              <input class="w-full py-3.5 pr-10 bg-transparent text-sm text-text-primary placeholder:text-outline focus:outline-none tracking-wider" id="password" name="password" type="password" value="UtmFin2025!" required>
              <button aria-label="Toggle password visibility" class="absolute right-3 text-text-muted hover:text-text-primary flex items-center justify-center p-1" id="togglePassword" onclick="togglePasswordVisibility()" type="button">
                <span class="material-symbols-outlined text-[20px]" id="eyeIcon">visibility_off</span>
              </button>
            </div>

            <div class="bg-surface-container-low rounded-xl p-space-sm flex flex-col gap-2 mt-1">
              <div class="flex items-center justify-between">
                <span class="text-xs text-text-muted">Security Strength</span>
                <span class="text-xs text-secondary font-semibold" id="strengthText">Strong Password</span>
              </div>
              <div class="grid grid-cols-3 gap-1.5">
                <div class="h-1.5 rounded-full bg-secondary" id="bar1"></div>
                <div class="h-1.5 rounded-full bg-secondary" id="bar2"></div>
                <div class="h-1.5 rounded-full bg-secondary" id="bar3"></div>
              </div>
              <div class="flex flex-wrap items-center gap-2 pt-1">
                <span class="inline-flex items-center gap-1 text-[11px] text-secondary font-medium">
                  <span class="material-symbols-outlined text-[14px]">check</span> 8+ Characters
                </span>
                <span class="inline-flex items-center gap-1 text-[11px] text-secondary font-medium">
                  <span class="material-symbols-outlined text-[14px]">check</span> Contains Number
                </span>
                <span class="inline-flex items-center gap-1 text-[11px] text-secondary font-medium">
                  <span class="material-symbols-outlined text-[14px]">check</span> Special Symbol
                </span>
              </div>
            </div>
          </div>

          <div class="flex items-start gap-3 mt-1">
            <label class="relative flex items-center cursor-pointer pt-0.5">
              <input checked class="peer sr-only" id="termsCheck" name="terms" type="checkbox" required>
              <div class="w-5 h-5 bg-surface-container-high rounded peer-checked:bg-primary flex items-center justify-center transition-colors">
                <span class="material-symbols-outlined text-white text-[16px] peer-checked:opacity-100 opacity-0 transition-opacity">check</span>
              </div>
            </label>
            <label class="text-xs text-text-muted cursor-pointer select-none" for="termsCheck">
              I agree to the <a class="text-primary font-semibold hover:underline" href="#">Terms of Service</a>, <a class="text-primary font-semibold hover:underline" href="#">Privacy Policy</a>, and consent to student verification.
            </label>
          </div>

          <button type="submit" class="w-full mt-space-sm h-12 bg-primary hover:bg-primary-container text-white text-sm font-semibold rounded-xl flex items-center justify-center gap-2 shadow-md active:scale-[0.99] transition-transform cursor-pointer">
            <span>Continue to Setup Goals</span>
            <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
          </button>
        </form>

        <div class="px-margin my-space-lg flex items-center gap-3">
          <div class="flex-1 h-px bg-surface-container-high"></div>
          <span class="text-xs text-text-muted uppercase tracking-wider">Fast Student Sign-In</span>
          <div class="flex-1 h-px bg-surface-container-high"></div>
        </div>

        <div class="px-margin flex flex-col gap-space-sm">
          <a href="login.php" class="w-full h-12 bg-surface-container-lowest hover:bg-surface-container-low text-text-primary rounded-xl flex items-center justify-between px-space-md shadow-sm active:scale-[0.99] transition-transform border border-slate-200">
            <div class="flex items-center gap-3">
              <div class="w-7 h-7 rounded-full bg-amber-900/10 flex items-center justify-center text-amber-900 font-bold text-xs">
                UTM
              </div>
              <span class="text-sm font-semibold">Sign in via UTM SSO (ID Access)</span>
            </div>
            <span class="material-symbols-outlined text-text-muted text-[18px]">open_in_new</span>
          </a>

          <a href="login.php" class="w-full h-12 bg-surface-container-lowest hover:bg-surface-container-low text-text-primary rounded-xl flex items-center justify-center gap-3 px-space-md shadow-sm active:scale-[0.99] transition-transform border border-slate-200">
            <svg class="w-5 h-5 shrink-0" viewBox="0 0 24 24">
              <path d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.15z" fill="#4285F4"></path>
              <path d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.34 24 12 24z" fill="#34A853"></path>
              <path d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 10.03 0 12s.45 3.82 1.25 5.42l4.03-3.15z" fill="#FBBC05"></path>
              <path d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.34 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z" fill="#EA4335"></path>
            </svg>
            <span class="text-sm font-semibold">Continue with Google</span>
          </a>
        </div>

        <div class="px-margin mt-space-lg">
          <div class="bg-surface-container-low rounded-xl p-space-sm flex items-center justify-between border border-slate-200">
            <div class="flex items-center gap-2">
              <div class="flex -space-x-2">
                <div class="w-7 h-7 rounded-full bg-primary text-white font-bold text-[10px] flex items-center justify-center ring-2 ring-surface">
                  NR
                </div>
                <div class="w-7 h-7 rounded-full bg-secondary text-white font-bold text-[10px] flex items-center justify-center ring-2 ring-surface">
                  AF
                </div>
                <div class="w-7 h-7 rounded-full bg-primary-container text-white font-bold text-[10px] flex items-center justify-center ring-2 ring-surface">
                  CL
                </div>
              </div>
              <p class="text-xs text-text-muted">
                <strong class="text-text-primary font-medium">3,420+</strong> UTM students registered
              </p>
            </div>
            <span class="inline-flex items-center gap-1 text-xs text-secondary font-semibold">
              <span class="material-symbols-outlined text-[14px]">shield</span> Secure
            </span>
          </div>
        </div>

        <div class="px-margin mt-space-lg text-center">
          <p class="text-sm text-text-muted">
            Already have an account? 
            <a class="text-primary font-semibold hover:underline ml-1" href="login.php">Log In</a>
          </p>
        </div>

      </div>
    </main>
  </div>

  <script>
    function togglePasswordVisibility() {
      const pwd = document.getElementById('password');
      const icon = document.getElementById('eyeIcon');
      if (pwd.type === 'password') {
        pwd.type = 'text';
        icon.textContent = 'visibility';
      } else {
        pwd.type = 'password';
        icon.textContent = 'visibility_off';
      }
    }
  </script>
</body>
</html>
