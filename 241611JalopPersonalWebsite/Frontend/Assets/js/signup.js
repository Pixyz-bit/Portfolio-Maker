function togglePasswordVisibility(inputId, button) {
            var input = document.getElementById(inputId);
            if (!input) return;

            if (input.type === "password") {
                input.type = "text";
                button.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>';
            } else {
                input.type = "password";
                button.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>';
            }
        }

        function showLoadingScreen(title, desc) {
            var overlay = document.getElementById('loadingOverlay');
            if (title) document.getElementById('loadingTitle').textContent = title;
            if (desc) document.getElementById('loadingDesc').textContent = desc;
            if (overlay) overlay.style.display = 'flex';
        }

        function hideLoadingScreen() {
            var overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.style.display = 'none';
        }

        function dismissToast(btn) {
            var toast = btn.closest('.toast-box');
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(16px)';
                setTimeout(function () { toast.style.display = 'none'; }, 250);
            }
        }

        function handleSignupError() {
            showLoadingScreen('Validating Registration...', 'Checking account availability...');
            setTimeout(function () {
                hideLoadingScreen();
                var errToast = document.querySelector('.toast-box.toast-error');
                if (errToast) {
                    setTimeout(function () {
                        var btn = errToast.querySelector('.toast-close-btn');
                        if (btn) dismissToast(btn);
                    }, 5000);
                }
            }, 650);
        }

        function handleSignupSuccess() {
            showLoadingScreen('Account Created!', 'Redirecting you to sign in...');
            setTimeout(function () {
                hideLoadingScreen();
            }, 1000);
        }