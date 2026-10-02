// auth.js — Firebase Auth logic for both login page and dashboard

(function () {
  'use strict';

  const isLoginPage    = document.body.classList.contains('login-body');
  const isDashboard    = document.body.classList.contains('dashboard-body');

  // ──────────────────────────────────────────────────────────
  // LOGIN PAGE
  // ──────────────────────────────────────────────────────────
  if (isLoginPage) {
    const form       = document.getElementById('login-form');
    const emailInput = document.getElementById('email');
    const passInput  = document.getElementById('password');
    const errorBox   = document.getElementById('login-error');
    const btnText    = document.getElementById('login-btn-text');
    const spinner    = document.getElementById('login-spinner');

    // If already logged in, go straight to dashboard
    auth.onAuthStateChanged((user) => {
      if (user) window.location.href = 'dashboard.html';
    });

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      errorBox.classList.add('hidden');
      btnText.textContent = 'Signing in...';
      spinner.classList.remove('hidden');

      try {
        await auth.signInWithEmailAndPassword(
          emailInput.value.trim(),
          passInput.value
        );
        // onAuthStateChanged above will redirect
      } catch (err) {
        btnText.textContent = 'Sign In';
        spinner.classList.add('hidden');
        errorBox.textContent = _friendlyAuthError(err.code);
        errorBox.classList.remove('hidden');
      }
    });
  }

  // ──────────────────────────────────────────────────────────
  // DASHBOARD PAGE — auth guard
  // ──────────────────────────────────────────────────────────
  if (isDashboard) {
    const guard      = document.getElementById('auth-guard');
    const userEmail  = document.getElementById('user-email');
    const userAvatar = document.getElementById('user-avatar');
    const logoutBtn  = document.getElementById('logout-btn');

    auth.onAuthStateChanged((user) => {
      if (!user) {
        // Not logged in — redirect to login
        window.location.href = 'index.html';
        return;
      }

      // Authenticated: show dashboard, hide guard
      if (userEmail) userEmail.textContent = user.email;
      if (userAvatar) userAvatar.textContent = (user.email || 'A')[0].toUpperCase();
      if (guard) guard.style.display = 'none';

      // Fire custom event so other scripts know auth is ready
      document.dispatchEvent(new CustomEvent('auth-ready', { detail: { user } }));
    });

    if (logoutBtn) {
      logoutBtn.addEventListener('click', async () => {
        await auth.signOut();
        window.location.href = 'index.html';
      });
    }
  }

  // ──────────────────────────────────────────────────────────
  // Helper
  // ──────────────────────────────────────────────────────────
  function _friendlyAuthError(code) {
    const map = {
      'auth/wrong-password':       'Incorrect password. Please try again.',
      'auth/user-not-found':       'No account found with this email.',
      'auth/invalid-email':        'Please enter a valid email address.',
      'auth/too-many-requests':    'Too many failed attempts. Try again later.',
      'auth/network-request-failed': 'Network error. Check your internet connection.',
      'auth/invalid-credential':   'Invalid email or password.',
    };
    return map[code] || `Sign-in failed: ${code}`;
  }
})();
