// config.js — App Config tab: reads/writes Firestore app_config/settings doc

(function () {
  'use strict';

  document.addEventListener('auth-ready', () => {
    ConfigModule.init();
  });

  const SETTINGS_DOC = 'app_config/settings';

  const ConfigModule = {
    init() {
      this._loadConfig();
      document.getElementById('save-config-btn').addEventListener('click', () => this._saveConfig());
    },

    async _loadConfig() {
      try {
        const doc = await db.doc(SETTINGS_DOC).get();
        if (doc.exists) {
          const data = doc.data();
          const appNameEl  = document.getElementById('cfg-app-name');
          const forceEl    = document.getElementById('cfg-force-update');
          const maintEl    = document.getElementById('cfg-maintenance-msg');
          if (appNameEl && data.app_name)        appNameEl.value    = data.app_name;
          if (forceEl   && data.force_update)    forceEl.checked    = !!data.force_update;
          if (maintEl   && data.maintenance_msg) maintEl.value      = data.maintenance_msg;
        }
      } catch (err) {
        this._showAlert('config-alert', 'error', `Failed to load config: ${err.message}`);
      }
    },

    async _saveConfig() {
      this._hideAlert('config-alert');
      const btn = document.getElementById('save-config-btn');
      btn.disabled = true;
      btn.textContent = 'Saving...';

      const data = {
        app_name:        document.getElementById('cfg-app-name').value.trim(),
        force_update:    document.getElementById('cfg-force-update').checked,
        maintenance_msg: document.getElementById('cfg-maintenance-msg').value.trim(),
        updated_at:      firebase.firestore.FieldValue.serverTimestamp(),
      };

      try {
        await db.doc(SETTINGS_DOC).set(data, { merge: true });
        this._showAlert('config-alert', 'success', 'Configuration saved successfully.');
      } catch (err) {
        this._showAlert('config-alert', 'error', `Failed to save: ${err.message}`);
      } finally {
        btn.disabled = false;
        btn.textContent = 'Save Config';
      }
    },

    _showAlert(id, type, message) {
      const el = document.getElementById(id);
      if (!el) return;
      el.className = `alert alert-${type}`;
      el.textContent = message;
      el.classList.remove('hidden');
      if (type === 'success') setTimeout(() => el.classList.add('hidden'), 4000);
    },

    _hideAlert(id) {
      const el = document.getElementById(id);
      if (el) el.classList.add('hidden');
    },
  };
})();
