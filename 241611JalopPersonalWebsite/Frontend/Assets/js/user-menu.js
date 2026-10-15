(function () {
        const toggleBtn = document.getElementById('btnUserMenuToggle');
        const dropdown = document.getElementById('userMenuDropdown');

        if (toggleBtn && dropdown) {
            toggleBtn.addEventListener('click', function (e) {
                e.stopPropagation();
                setUserMenuOpen(!dropdown.classList.contains('active'));
            });

            // Automatically restore dropdown open state after visibility toggle postback
            try {
                if (sessionStorage.getItem('openUserMenuAfterPostback') === '1') {
                    sessionStorage.removeItem('openUserMenuAfterPostback');
                    setUserMenuOpen(true);
                }
            } catch (_) {}

            document.addEventListener('click', function (e) {
                if (!dropdown.contains(e.target) && !toggleBtn.contains(e.target)) {
                    setUserMenuOpen(false);
                }
            });

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    setUserMenuOpen(false, dropdown.classList.contains('active'));
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

    function setUserMenuOpen(open, restoreFocus) {
        const trigger = document.getElementById('btnUserMenuToggle');
        const menu = document.getElementById('userMenuDropdown');
        if (!trigger || !menu) return;
        menu.classList.toggle('active', open);
        menu.setAttribute('aria-hidden', open ? 'false' : 'true');
        if (open) menu.removeAttribute('inert');
        else menu.setAttribute('inert','');
        trigger.setAttribute('aria-expanded', open ? 'true' : 'false');
        if (!open && restoreFocus) trigger.focus();
    }

    function initVisibilityToggle() {
        const card = document.getElementById('menuVisibilityCard') || document.querySelector('.menu-visibility-card');
        if (!card) return;

        const toggleBtn = card.querySelector('.visibility-toggle-btn');
        const track = card.querySelector('.toggle-track');
        const dot = card.querySelector('.status-indicator-dot');

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

            // Keep the confirmed status until the server renders the committed result.
            card.setAttribute('aria-busy', 'true');
            toggleBtn.setAttribute('aria-disabled', 'true');
            if (track) track.classList.add('is-loading');

            // A failed navigation must not permanently disable the control.
            window.setTimeout(function () {
                isSubmitting = false;
                card.removeAttribute('aria-busy');
                toggleBtn.removeAttribute('aria-disabled');
                if (track) track.classList.remove('is-loading');
            }, 10000);
        }

        // Entire card is clickable for high usability
        card.addEventListener('click', function (e) {
            if (toggleBtn.contains(e.target) || e.target === toggleBtn) {
                return;
            }
            e.preventDefault();
            // Only the button handler sets the submission guard; card clicks use
            // exactly the same postback path as direct or keyboard activation.
            toggleBtn.click();
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
        if (dropdown) setUserMenuOpen(false);
        ensureModalAttachedToForm();
        const modal = document.getElementById('userAccountModalOverlay');
        if (modal) modal.style.display = 'flex';
    }

    function closeUserAccountModal() {
        const modal = document.getElementById('userAccountModalOverlay');
        if (modal) modal.style.display = 'none';
    }
