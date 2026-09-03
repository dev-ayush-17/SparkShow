// releases.js — APK upload to Firebase Storage + version document management

(function () {
  'use strict';

  document.addEventListener('auth-ready', () => {
    ReleasesModule.init();
  });

  const VERSION_DOC  = 'app_config/latest_version';
  const HISTORY_COL  = 'app_config/releases/history';
  const STORAGE_PATH = 'releases/';

  const ReleasesModule = {
    _selectedFile: null,

    // ──────────────────────────────────────────────────────────
    // Init
    // ──────────────────────────────────────────────────────────
    init() {
      this._bindEvents();
      this._loadCurrentVersion();
      this._loadReleaseHistory();
    },

    _bindEvents() {
      // File input
      const fileInput = document.getElementById('apk-file');
      fileInput.addEventListener('change', (e) => {
        if (e.target.files[0]) this._setFile(e.target.files[0]);
      });

      // Drag & drop zone
      const dropZone = document.getElementById('apk-drop-zone');

      dropZone.addEventListener('dragover', (e) => {
        e.preventDefault();
        dropZone.classList.add('drag-over');
      });
      dropZone.addEventListener('dragleave', () => {
        dropZone.classList.remove('drag-over');
      });
      dropZone.addEventListener('drop', (e) => {
        e.preventDefault();
        dropZone.classList.remove('drag-over');
        const file = e.dataTransfer.files[0];
        if (file && file.name.endsWith('.apk')) {
          this._setFile(file);
        } else {
          this._showAlert('release-alert', 'error', 'Please drop a valid .apk file.');
        }
      });

      // Release button
      document.getElementById('release-btn').addEventListener('click', () => {
        this._pushRelease();
      });
    },

    // ──────────────────────────────────────────────────────────
    // File selection
    // ──────────────────────────────────────────────────────────
    _setFile(file) {
      this._selectedFile = file;
      const content = document.getElementById('drop-zone-content');
      const sizeMB  = (file.size / (1024 * 1024)).toFixed(1);
      content.innerHTML = `
        <div class="drop-icon">✅</div>
        <p class="file-selected-name">${this._esc(file.name)}</p>
        <span class="file-hint">${sizeMB} MB — <label for="apk-file" class="file-label">Change file</label></span>
        <input type="file" id="apk-file" accept=".apk" class="hidden" />
      `;
      // Re-bind file input
      document.getElementById('apk-file').addEventListener('change', (e) => {
        if (e.target.files[0]) this._setFile(e.target.files[0]);
      });
    },

    // ──────────────────────────────────────────────────────────
    // Load current live version from Firestore
    // ──────────────────────────────────────────────────────────
    async _loadCurrentVersion() {
      try {
        const doc = await db.doc(VERSION_DOC).get();
        const liveVersionEl = document.getElementById('live-version');
        const liveDateEl    = document.getElementById('live-date');
        const notesEl       = document.getElementById('release-notes-display');
        const statVersion   = document.getElementById('stat-version');

        if (doc.exists) {
          const data = doc.data();
          if (liveVersionEl) liveVersionEl.textContent = `v${data.version || '—'}`;
          if (liveDateEl && data.pushed_at) {
            const date = new Date(data.pushed_at.toDate ? data.pushed_at.toDate() : data.pushed_at);
            liveDateEl.textContent = `Pushed ${date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}`;
          }
          if (notesEl && data.release_notes) {
            notesEl.textContent = data.release_notes;
          }
          if (statVersion) statVersion.textContent = data.version || '—';
        } else {
          if (liveVersionEl) liveVersionEl.textContent = 'No release yet';
          if (statVersion) statVersion.textContent = '—';
        }
      } catch (err) {
        console.error('Failed to load version:', err);
      }
    },

    // ──────────────────────────────────────────────────────────
    // Load release history
    // ──────────────────────────────────────────────────────────
    async _loadReleaseHistory() {
      const tbody = document.getElementById('releases-tbody');
      try {
        const snap = await db.collection(HISTORY_COL).orderBy('pushed_at', 'desc').limit(20).get();

        if (snap.empty) {
          tbody.innerHTML = `<tr><td colspan="4" class="empty-cell"><span class="empty-icon">📋</span><span>No releases yet.</span></td></tr>`;
          return;
        }

        tbody.innerHTML = snap.docs.map(doc => {
          const d    = doc.data();
          const date = d.pushed_at
            ? new Date(d.pushed_at.toDate ? d.pushed_at.toDate() : d.pushed_at)
                .toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
            : '—';
          return `
            <tr>
              <td><span class="version-badge-sm">v${this._esc(d.version)}</span></td>
              <td>${date}</td>
              <td>${this._esc(d.release_notes || '—')}</td>
              <td>${d.download_url ? `<a href="${d.download_url}" target="_blank" class="link-btn">Download APK</a>` : '—'}</td>
            </tr>`;
        }).join('');
      } catch (err) {
        tbody.innerHTML = `<tr><td colspan="4" class="empty-cell">Failed to load history: ${err.message}</td></tr>`;
      }
    },

    // ──────────────────────────────────────────────────────────
    // Push new release
    // ──────────────────────────────────────────────────────────
    async _pushRelease() {
      this._hideAlert('release-alert');

      const version      = document.getElementById('new-version').value.trim();
      const releaseNotes = document.getElementById('release-notes').value.trim();

      if (!version) {
        this._showAlert('release-alert', 'error', 'Please enter the new version number (e.g. 1.2.0).');
        return;
      }
      if (!this._selectedFile) {
        this._showAlert('release-alert', 'error', 'Please select an APK file to upload.');
        return;
      }

      this._setButtonLoading(true);

      try {
        // 1. Upload APK to Firebase Storage
        const fileName  = `sparkshow_v${version}.apk`;
        const storageRef = storage.ref(`${STORAGE_PATH}${fileName}`);
        const uploadTask = storageRef.put(this._selectedFile);

        const downloadUrl = await new Promise((resolve, reject) => {
          uploadTask.on(
            'state_changed',
            (snapshot) => {
              const pct = snapshot.bytesTransferred / snapshot.totalBytes;
              this._updateProgress(pct);
            },
            reject,
            async () => {
              const url = await uploadTask.snapshot.ref.getDownloadURL();
              resolve(url);
            }
          );
        });

        this._updateProgress(1);

        // 2. Update the latest_version Firestore document
        const versionData = {
          version,
          download_url:  downloadUrl,
          release_notes: releaseNotes || null,
          pushed_at:     firebase.firestore.FieldValue.serverTimestamp(),
          force_update:  false,
        };
        await db.doc(VERSION_DOC).set(versionData);

        // 3. Add to release history
        await db.collection(HISTORY_COL).add(versionData);

        // 4. Update UI
        this._showAlert('release-alert', 'success', `✅ Version ${version} pushed! Devices will be notified on next app open.`);
        document.getElementById('new-version').value = '';
        document.getElementById('release-notes').value = '';
        this._selectedFile = null;
        document.getElementById('drop-zone-content').innerHTML = `
          <div class="drop-icon">📁</div>
          <p>Drag & drop APK here or <label for="apk-file" class="file-label">browse</label></p>
          <span class="file-hint">.apk files only</span>
          <input type="file" id="apk-file" accept=".apk" class="hidden" />
        `;
        document.getElementById('apk-file').addEventListener('change', (e) => {
          if (e.target.files[0]) this._setFile(e.target.files[0]);
        });

        this._loadCurrentVersion();
        this._loadReleaseHistory();

      } catch (err) {
        this._showAlert('release-alert', 'error', `Release failed: ${err.message}`);
      } finally {
        this._setButtonLoading(false);
        document.getElementById('upload-progress-container').classList.add('hidden');
      }
    },

    // ──────────────────────────────────────────────────────────
    // Progress UI
    // ──────────────────────────────────────────────────────────
    _updateProgress(value) {
      const container = document.getElementById('upload-progress-container');
      const fill      = document.getElementById('upload-progress-fill');
      const pct       = document.getElementById('upload-progress-pct');
      const label     = document.getElementById('upload-progress-label');

      container.classList.remove('hidden');
      const percent = Math.round(value * 100);
      fill.style.width = `${percent}%`;
      pct.textContent  = `${percent}%`;
      if (percent === 100) label.textContent = 'Finalizing...';
    },

    _setButtonLoading(loading) {
      const btnText   = document.getElementById('release-btn-text');
      const spinner   = document.getElementById('release-spinner');
      const btn       = document.getElementById('release-btn');
      btn.disabled    = loading;
      btnText.classList.toggle('hidden', loading);
      spinner.classList.toggle('hidden', !loading);
    },

    // ──────────────────────────────────────────────────────────
    // Helpers
    // ──────────────────────────────────────────────────────────
    _showAlert(id, type, message) {
      const el = document.getElementById(id);
      if (!el) return;
      el.className = `alert alert-${type}`;
      el.textContent = message;
      el.classList.remove('hidden');
      if (type === 'success') setTimeout(() => el.classList.add('hidden'), 6000);
    },

    _hideAlert(id) {
      const el = document.getElementById(id);
      if (el) el.classList.add('hidden');
    },

    _esc(str) {
      return String(str ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    },
  };
})();
