// dashboard.js — Tab navigation and global UI orchestration

(function () {
  'use strict';

  // ──────────────────────────────────────────────────────────
  // Tab navigation
  // ──────────────────────────────────────────────────────────
  const tabMeta = {
    products: { title: 'Products',     subtitle: 'Manage your product catalog'           },
    releases: { title: 'APK Releases', subtitle: 'Push new versions to shop devices'     },
    config:   { title: 'App Config',   subtitle: 'Settings synced to all shop devices'   },
  };

  document.querySelectorAll('.nav-item[data-tab]').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const tab = link.dataset.tab;
      _switchTab(tab);
    });
  });

  function _switchTab(tab) {
    // Update sidebar active state
    document.querySelectorAll('.nav-item').forEach(l => l.classList.remove('active'));
    document.querySelector(`.nav-item[data-tab="${tab}"]`).classList.add('active');

    // Show/hide content panels
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    const panel = document.getElementById(`tab-${tab}`);
    if (panel) panel.classList.add('active');

    // Update topbar
    const meta = tabMeta[tab];
    if (meta) {
      document.getElementById('topbar-title').textContent    = meta.title;
      document.getElementById('topbar-subtitle').textContent = meta.subtitle;
    }
  }

  // ──────────────────────────────────────────────────────────
  // Firestore connection status indicator
  // ──────────────────────────────────────────────────────────
  document.addEventListener('auth-ready', () => {
    // Ping Firestore with a lightweight read to confirm connectivity
    db.collection('app_config').doc('settings').get({ source: 'server' })
      .then(() => _setStatus('Connected', true))
      .catch(() => _setStatus('Offline', false));
  });

  function _setStatus(text, connected) {
    const statusText = document.getElementById('status-text');
    const statusDot  = document.querySelector('.status-dot');
    if (statusText) statusText.textContent = text;
    if (statusDot) {
      statusDot.style.background = connected ? '#4ade80' : '#f87171';
    }
  }
})();
