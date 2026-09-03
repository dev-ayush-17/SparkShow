// products.js — Firestore CRUD for the Products tab

(function () {
  'use strict';

  // Wait for Firebase auth to be confirmed
  document.addEventListener('auth-ready', () => {
    ProductsModule.init();
  });

  const COLLECTION = 'products';

  const ProductsModule = {
    _allProducts: [],
    _editingId: null,   // null = add mode, string = edit mode (original ID)

    // ──────────────────────────────────────────────────────────
    // Init
    // ──────────────────────────────────────────────────────────
    init() {
      this._bindEvents();
      this._loadProducts();
    },

    _bindEvents() {
      // Search & filter
      document.getElementById('product-search').addEventListener('input', () => this._renderTable());
      document.getElementById('category-filter').addEventListener('change', () => this._renderTable());

      // Add button
      document.getElementById('add-product-btn').addEventListener('click', () => this._openModal(null));

      // Modal buttons
      document.getElementById('modal-close-btn').addEventListener('click', () => this._closeModal());
      document.getElementById('modal-cancel-btn').addEventListener('click', () => this._closeModal());
      document.getElementById('modal-save-btn').addEventListener('click', () => this._saveProduct());

      // Close modal on overlay click
      document.getElementById('product-modal-overlay').addEventListener('click', (e) => {
        if (e.target.id === 'product-modal-overlay') this._closeModal();
      });

      // Delete modal
      document.getElementById('delete-modal-close').addEventListener('click', () => this._closeDeleteModal());
      document.getElementById('delete-cancel-btn').addEventListener('click', () => this._closeDeleteModal());
      document.getElementById('delete-confirm-btn').addEventListener('click', () => this._confirmDelete());

      document.getElementById('delete-modal-overlay').addEventListener('click', (e) => {
        if (e.target.id === 'delete-modal-overlay') this._closeDeleteModal();
      });
    },

    // ──────────────────────────────────────────────────────────
    // Load products from Firestore
    // ──────────────────────────────────────────────────────────
    async _loadProducts() {
      try {
        const snap = await db.collection(COLLECTION).get();
        this._allProducts = snap.docs.map(doc => ({ ...doc.data() }));
        this._allProducts.sort((a, b) => String(a.id).localeCompare(String(b.id)));
        this._renderTable();

        // Update stats
        const productCount = this._allProducts.length;
        const categoryCount = new Set(this._allProducts.map(p => p.category)).size;
        const statProducts   = document.getElementById('stat-products');
        const statCategories = document.getElementById('stat-categories');
        if (statProducts)   statProducts.textContent   = productCount;
        if (statCategories) statCategories.textContent = categoryCount;
      } catch (err) {
        this._showAlert('products-alert', 'error', `Failed to load products: ${err.message}`);
      }
    },

    // ──────────────────────────────────────────────────────────
    // Render table with search + category filter
    // ──────────────────────────────────────────────────────────
    _renderTable() {
      const query    = (document.getElementById('product-search').value || '').toLowerCase();
      const category = document.getElementById('category-filter').value;
      const tbody    = document.getElementById('products-tbody');

      let filtered = this._allProducts;

      if (category) {
        filtered = filtered.filter(p => p.category === category);
      }
      if (query) {
        filtered = filtered.filter(p =>
          (p.title       || '').toLowerCase().includes(query) ||
          (p.category    || '').toLowerCase().includes(query) ||
          (p.description || '').toLowerCase().includes(query) ||
          (p.keywords    || []).some(k => k.toLowerCase().includes(query))
        );
      }

      if (filtered.length === 0) {
        tbody.innerHTML = `
          <tr>
            <td colspan="6" class="empty-cell">
              <span class="empty-icon">📭</span>
              <span>${this._allProducts.length === 0 ? 'No products yet. Add your first one!' : 'No products match your filter.'}</span>
            </td>
          </tr>`;
        return;
      }

      tbody.innerHTML = filtered.map(p => `
        <tr>
          <td><span class="id-badge">${this._esc(p.id)}</span></td>
          <td class="fw-medium">${this._esc(p.title)}</td>
          <td><span class="cat-badge cat-${(p.category||'').toLowerCase()}">${this._esc(p.category)}</span></td>
          <td class="keywords-cell">${(p.keywords||[]).map(k => `<span class="keyword-tag">${this._esc(k)}</span>`).join('')}</td>
          <td class="desc-cell">${this._esc(p.description)}</td>
          <td>
            <div class="action-btns">
              <button class="btn-icon btn-edit" title="Edit" data-id="${this._esc(p.id)}">✏️</button>
              <button class="btn-icon btn-delete" title="Delete" data-id="${this._esc(p.id)}" data-title="${this._esc(p.title)}">🗑️</button>
            </div>
          </td>
        </tr>
      `).join('');

      // Attach row event listeners
      tbody.querySelectorAll('.btn-edit').forEach(btn => {
        btn.addEventListener('click', () => {
          const product = this._allProducts.find(p => p.id === btn.dataset.id);
          if (product) this._openModal(product);
        });
      });

      tbody.querySelectorAll('.btn-delete').forEach(btn => {
        btn.addEventListener('click', () => {
          this._openDeleteModal(btn.dataset.id, btn.dataset.title);
        });
      });
    },

    // ──────────────────────────────────────────────────────────
    // Add / Edit Modal
    // ──────────────────────────────────────────────────────────
    _openModal(product) {
      this._editingId = product ? product.id : null;
      document.getElementById('modal-title').textContent = product ? 'Edit Product' : 'Add Product';
      document.getElementById('modal-save-text').textContent = product ? 'Save Changes' : 'Add Product';
      document.getElementById('modal-product-id').value = product?.id ?? '';

      // Populate fields
      document.getElementById('modal-id').value          = product?.id          ?? '';
      document.getElementById('modal-title-input').value = product?.title       ?? '';
      document.getElementById('modal-category').value    = product?.category    ?? '';
      document.getElementById('modal-description').value = product?.description ?? '';
      document.getElementById('modal-keywords').value    = (product?.keywords   ?? []).join(', ');
      document.getElementById('modal-video').value       = product?.video       ?? '';
      document.getElementById('modal-thumbnail').value   = product?.thumbnail   ?? '';

      // Disable ID field in edit mode (ID is the doc key, shouldn't change)
      document.getElementById('modal-id').disabled = !!product;

      this._hideAlert('modal-alert');
      document.getElementById('product-modal-overlay').classList.remove('hidden');
    },

    _closeModal() {
      document.getElementById('product-modal-overlay').classList.add('hidden');
    },

    async _saveProduct() {
      this._hideAlert('modal-alert');

      const id          = document.getElementById('modal-id').value.trim();
      const title       = document.getElementById('modal-title-input').value.trim();
      const category    = document.getElementById('modal-category').value;
      const description = document.getElementById('modal-description').value.trim();
      const keywordsRaw = document.getElementById('modal-keywords').value;
      const video       = document.getElementById('modal-video').value.trim();
      const thumbnail   = document.getElementById('modal-thumbnail').value.trim();

      // Validation
      if (!id || !title || !category || !video || !thumbnail) {
        this._showAlert('modal-alert', 'error', 'Please fill in all required fields (*).');
        return;
      }

      const keywords = keywordsRaw
        .split(',')
        .map(k => k.trim())
        .filter(Boolean);

      const product = { id, title, category, description, keywords, video, thumbnail };

      const saveText    = document.getElementById('modal-save-text');
      const saveSpinner = document.getElementById('modal-save-spinner');
      saveText.classList.add('hidden');
      saveSpinner.classList.remove('hidden');

      try {
        await db.collection(COLLECTION).doc(id).set(product);

        // Update local cache
        const existingIndex = this._allProducts.findIndex(p => p.id === id);
        if (existingIndex >= 0) {
          this._allProducts[existingIndex] = product;
        } else {
          this._allProducts.push(product);
          this._allProducts.sort((a, b) => String(a.id).localeCompare(String(b.id)));
        }

        this._renderTable();
        this._closeModal();
        this._showAlert('products-alert', 'success', `Product "${title}" saved successfully.`);
      } catch (err) {
        this._showAlert('modal-alert', 'error', `Failed to save: ${err.message}`);
      } finally {
        saveText.classList.remove('hidden');
        saveSpinner.classList.add('hidden');
      }
    },

    // ──────────────────────────────────────────────────────────
    // Delete
    // ──────────────────────────────────────────────────────────
    _deleteTargetId: null,

    _openDeleteModal(id, title) {
      this._deleteTargetId = id;
      document.getElementById('delete-product-name').textContent = title;
      document.getElementById('delete-modal-overlay').classList.remove('hidden');
    },

    _closeDeleteModal() {
      this._deleteTargetId = null;
      document.getElementById('delete-modal-overlay').classList.add('hidden');
    },

    async _confirmDelete() {
      if (!this._deleteTargetId) return;

      const deleteText    = document.getElementById('delete-btn-text');
      const deleteSpinner = document.getElementById('delete-spinner');
      deleteText.classList.add('hidden');
      deleteSpinner.classList.remove('hidden');

      try {
        await db.collection(COLLECTION).doc(this._deleteTargetId).delete();
        this._allProducts = this._allProducts.filter(p => p.id !== this._deleteTargetId);
        this._renderTable();
        this._closeDeleteModal();
        this._showAlert('products-alert', 'success', 'Product deleted successfully.');
      } catch (err) {
        this._closeDeleteModal();
        this._showAlert('products-alert', 'error', `Failed to delete: ${err.message}`);
      } finally {
        deleteText.classList.remove('hidden');
        deleteSpinner.classList.add('hidden');
      }
    },

    // ──────────────────────────────────────────────────────────
    // Alert helpers
    // ──────────────────────────────────────────────────────────
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

    // HTML escape
    _esc(str) {
      return String(str ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    },
  };

  // Expose for other modules that need the product list
  window.ProductsModule = ProductsModule;
})();
