(function () {
        const toggleBtn = document.getElementById('btnUserMenuToggle');
        const dropdown = document.getElementById('userMenuDropdown');

        if (toggleBtn && dropdown) {
            toggleBtn.addEventListener('click', function (e) {
                e.stopPropagation();
                dropdown.classList.toggle('active');
            });

            // Automatically restore dropdown open state after visibility toggle postback
            try {
                if (sessionStorage.getItem('openUserMenuAfterPostback') === '1') {
                    sessionStorage.removeItem('openUserMenuAfterPostback');
                    dropdown.classList.add('active');
                }
            } catch (_) {}

            document.addEventListener('click', function (e) {
                if (!dropdown.contains(e.target) && !toggleBtn.contains(e.target)) {
                    dropdown.classList.remove('active');
                }
            });

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    dropdown.classList.remove('active');
                    closeUserAccountModal();
                }
            });
        }

        window.addEventListener('click', function (e) {
            const modal = document.getElementById('userAccountModalOverlay');
            if (e.target === modal) {
                closeUserAccountModal();
            }
        });

        // Initialize Dynamic Visibility Toggle Switch
        initVisibilityToggle();
    })();

    function initVisibilityToggle() {
        const card = document.getElementById('menuVisibilityCard') || document.querySelector('.menu-visibility-card');
        if (!card) return;

        const toggleBtn = card.querySelector('.visibility-toggle-btn');
        const track = card.querySelector('.toggle-track');
        const dot = card.querySelector('.status-indicator-dot');
        const label = card.querySelector('.visibility-status-text');

        if (!toggleBtn) return;

        // Synchronize initial state with server-rendered dot
        const isInitialPublic = dot ? dot.classList.contains('dot-public') : true;
        card.classList.toggle('is-public', isInitialPublic);
        card.classList.toggle('is-private', !isInitialPublic);
        if (track) {
            track.classList.toggle('is-active', isInitialPublic);
        }
        toggleBtn.setAttribute('aria-checked', isInitialPublic ? 'true' : 'false');

        let isSubmitting = false;

        function triggerToggle(e) {
            if (isSubmitting) {
                if (e) e.preventDefault();
                return;
            }
            isSubmitting = true;

            // Keep user menu open when page reloads after server postback
            try {
                sessionStorage.setItem('openUserMenuAfterPostback', '1');
            } catch (_) {}

            // Immediate optimistic UI response with micro-interaction
            const wasActive = dot ? dot.classList.contains('dot-public') : (track && track.classList.contains('is-active'));
            const willBeActive = !wasActive;

            if (track) {
                track.classList.toggle('is-active', willBeActive);
                track.classList.add('is-loading');
            }
            if (card) {
                card.classList.toggle('is-public', willBeActive);
                card.classList.toggle('is-private', !willBeActive);
            }
            if (dot) {
                dot.classList.toggle('dot-public', willBeActive);
                dot.classList.toggle('dot-private', !willBeActive);
            }
            if (label) {
                label.textContent = willBeActive ? 'Public Portfolio' : 'Private Portfolio';
            }
            toggleBtn.setAttribute('aria-checked', willBeActive ? 'true' : 'false');

            // If user clicked the card outside the toggle link button, invoke the link button
            if (e && !toggleBtn.contains(e.target) && e.target !== toggleBtn) {
                e.preventDefault();
                toggleBtn.click();
            }
        }

        // Entire card is clickable for high usability
        card.addEventListener('click', function (e) {
            if (toggleBtn.contains(e.target) || e.target === toggleBtn) {
                return;
            }
            triggerToggle(e);
        });

        // Toggle button click
        toggleBtn.addEventListener('click', function (e) {
            triggerToggle(e);
        });

        // Keyboard accessibility: Space key activates switch
        toggleBtn.addEventListener('keydown', function (e) {
            if (e.key === ' ' || e.key === 'Spacebar') {
                e.preventDefault();
                toggleBtn.click();
            }
        });
    }

    function ensureModalAttachedToForm() {
        const modal = document.getElementById('userAccountModalOverlay');
        const form = document.forms[0] || document.body;
        if (modal && form && modal.parentElement !== form) {
            form.appendChild(modal);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', ensureModalAttachedToForm);
    } else {
        ensureModalAttachedToForm();
    }

    function openUserAccountModal() {
        const dropdown = document.getElementById('userMenuDropdown');
        if (dropdown) dropdown.classList.remove('active');
        ensureModalAttachedToForm();
        const modal = document.getElementById('userAccountModalOverlay');
        if (modal) modal.style.display = 'flex';
    }

    function closeUserAccountModal() {
        const modal = document.getElementById('userAccountModalOverlay');
        if (modal) modal.style.display = 'none';
    }