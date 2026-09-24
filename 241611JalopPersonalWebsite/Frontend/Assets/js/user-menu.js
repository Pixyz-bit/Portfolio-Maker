(function () {
        const toggleBtn = document.getElementById('btnUserMenuToggle');
        const dropdown = document.getElementById('userMenuDropdown');

        if (toggleBtn && dropdown) {
            toggleBtn.addEventListener('click', function (e) {
                e.stopPropagation();
                dropdown.classList.toggle('active');
            });

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
    })();

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