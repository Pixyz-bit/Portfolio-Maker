(function () {
    'use strict';
    var nextLabel = 0;
    var openDialogs = [];
    var previousFocus = new WeakMap();
    var selector = '.modal-overlay, .user-account-modal-overlay, .login-modal-overlay';
    function visible(element) { return element.getClientRects().length > 0 && getComputedStyle(element).visibility !== 'hidden'; }
    function focusable(dialog) {
        return Array.from(dialog.querySelectorAll('a[href],button,input:not([type="hidden"]),select,textarea,[tabindex]'))
            .filter(function (el) { return !el.disabled && el.tabIndex >= 0 && visible(el); });
    }
    function labelFields(root) {
        root.querySelectorAll('.form-group, .user-account-form-group').forEach(function (group) {
            var label = group.querySelector('label');
            var field = group.querySelector('input:not([type="hidden"]),select,textarea');
            if (!label || !field) return;
            if (!label.htmlFor) {
                if (!field.id) field.id = 'portfolioField' + (++nextLabel);
                label.htmlFor = field.id;
            }
            if (label.textContent.indexOf('*') >= 0) field.setAttribute('aria-required', 'true');
        });
    }
    function syncDialogs() {
        document.querySelectorAll(selector).forEach(function (dialog) {
            var isOpen = visible(dialog);
            var index = openDialogs.indexOf(dialog);
            dialog.setAttribute('role', 'dialog');
            dialog.setAttribute('aria-modal', 'true');
            dialog.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
            var title = dialog.querySelector('h2,h3,h4');
            if (title) {
                if (!title.id) title.id = 'portfolioDialogTitle' + (++nextLabel);
                dialog.setAttribute('aria-labelledby', title.id);
            }
            if (isOpen && index < 0) {
                previousFocus.set(dialog, document.activeElement);
                openDialogs.push(dialog);
                var field = dialog.querySelector('input:not([type="hidden"]):not([type="submit"]),select,textarea');
                var target = field && visible(field) ? field : focusable(dialog)[0];
                if (!target) { dialog.tabIndex = -1; target = dialog; }
                target.focus();
            } else if (!isOpen && index >= 0) {
                openDialogs.splice(index, 1);
                var previous = previousFocus.get(dialog);
                if (previous && previous.isConnected && visible(previous)) previous.focus();
            }
        });
    }
    document.addEventListener('keydown', function (event) {
        var dialog = openDialogs[openDialogs.length - 1];
        if (!dialog || !visible(dialog)) return;
        if (event.key === 'Escape') {
            if (dialog.classList.contains('user-account-modal-overlay') && window.closeUserAccountModal) window.closeUserAccountModal();
            else { dialog.classList.remove('active'); dialog.style.display = 'none'; }
            // Class-controlled dialogs must remain eligible to reopen.
            if (dialog.classList.contains('modal-overlay')) dialog.style.removeProperty('display');
            syncDialogs();
            event.preventDefault();
        }
        if (event.key === 'Tab') {
            var fields = focusable(dialog);
            if (!fields.length) { event.preventDefault(); dialog.focus(); return; }
            var first = fields[0], last = fields[fields.length - 1];
            if (!dialog.contains(document.activeElement) || (event.shiftKey && document.activeElement === first)) {
                event.preventDefault(); (event.shiftKey ? last : first).focus();
            } else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
        }
    }, true);
    document.addEventListener('focusin', function (event) {
        var dialog = openDialogs[openDialogs.length - 1];
        if (dialog && visible(dialog) && !dialog.contains(event.target)) {
            var fields = focusable(dialog); if (fields.length) fields[0].focus();
        }
    });
    document.addEventListener('DOMContentLoaded', function () {
        labelFields(document);
        syncDialogs();
        new MutationObserver(syncDialogs).observe(document.body, { subtree: true, attributes: true, attributeFilter: ['style', 'class'] });
    });
    window.PortfolioAccessibility = { labelFields: labelFields };
})();
