function escapeDialogText(value) { return String(value || '').replace(/[&<>"']/g, function(c) { return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]); }); }
function getEl(id) {
    return document.getElementById(id) || document.querySelector('[id$="' + id + '"]') || document.querySelector('[name$="' + id + '"]');
}

// Modal helpers
        function openAddModal() {
            clearAccountFormErrors('addModal');
            document.getElementById('addModal').classList.add('active');
        }

        function closeAddModal() {
            document.getElementById('addModal').classList.remove('active');
        }

        function openEditModal(userId, firstName, lastName, email, role, isActive) {
            clearAccountFormErrors('editModal');
            getEl('hfEditUserId').value = userId;
            getEl('txtEditFirstName').value = firstName;
            getEl('txtEditLastName').value = lastName;
            getEl('txtEditEmail').value = email;
            getEl('ddlEditRole').value = role;
            getEl('chkEditIsActive').checked = (isActive === true || isActive === 'true');
            getEl('txtEditNewPassword').value = '';
            getEl('txtEditConfirmPassword').value = '';
            document.getElementById('editModal').classList.add('active');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.remove('active');
        }

        function openEditFromSummary() {
            var userId = getEl('hfSummaryUserId').value;
            var firstName = getEl('hfSummaryFirstName').value;
            var lastName = getEl('hfSummaryLastName').value;
            var email = getEl('hfSummaryEmailRaw').value;
            var role = getEl('hfSummaryRoleRaw').value;
            var isActive = getEl('hfSummaryCurrentStatus').value;
            openEditModal(userId, firstName, lastName, email, role, isActive);
        }

        // Proper Status Modal handlers
        function openStatusModal(userId, fullName, email, isActive) {
            getEl('hfStatusUserId').value = userId;
            const isCurrentlyActive = (isActive === true || isActive === 'true');
            const targetNewState = !isCurrentlyActive;
            getEl('hfStatusNewState').value = targetNewState ? 'true' : 'false';

            const titleEl = document.getElementById('statusModalTitle');
            const descEl = document.getElementById('statusModalDesc');
            const iconDeactivate = document.getElementById('statusModalIconDeactivate');
            const iconActivate = document.getElementById('statusModalIconActivate');
            const iconWrap = document.getElementById('statusModalIconWrap');
            const confirmBtn = getEl('btnConfirmStatusAction');

            if (isCurrentlyActive) {
                titleEl.textContent = 'Deactivate User Account';
                descEl.innerHTML = 'Are you sure you want to deactivate the account for <strong>' + escapeDialogText(fullName) + '</strong> (' + escapeDialogText(email) + ')?<br><br><span style="color: #dc2626; font-size: 0.82rem; font-weight: 600;">The user will be immediately barred from signing in until an administrator reactivates their account.</span>';
                iconWrap.style.backgroundColor = '#fee2e2';
                iconDeactivate.style.display = 'block';
                iconActivate.style.display = 'none';
                confirmBtn.className = 'btn btn-danger btn-sm';
                confirmBtn.value = 'Yes, Deactivate';
            } else {
                titleEl.textContent = 'Activate User Account';
                descEl.innerHTML = 'Are you sure you want to activate the account for <strong>' + escapeDialogText(fullName) + '</strong> (' + escapeDialogText(email) + ')?<br><br><span style="color: #16a34a; font-size: 0.82rem; font-weight: 600;">The user will be granted full access to sign in and update their portfolio.</span>';
                iconWrap.style.backgroundColor = '#dcfce7';
                iconDeactivate.style.display = 'none';
                iconActivate.style.display = 'block';
                confirmBtn.className = 'btn btn-success btn-sm';
                confirmBtn.value = 'Yes, Activate';
            }

            document.getElementById('statusModal').classList.add('active');
        }

        function closeStatusModal() {
            document.getElementById('statusModal').classList.remove('active');
        }

        function openStatusModalFromSummary() {
            const userId = getEl('hfSummaryUserId').value;
            const firstName = getEl('hfSummaryFirstName').value;
            const lastName = getEl('hfSummaryLastName').value;
            const fullName = (firstName + ' ' + lastName).trim();
            const email = getEl('hfSummaryEmailRaw').value;
            const isActive = getEl('hfSummaryCurrentStatus').value;
            openStatusModal(userId, fullName, email, isActive);
        }

        // Proper Delete Modal handlers
        function openDeleteModal(userId, fullName, email) {
            getEl('hfDeleteUserId').value = userId;
            const descEl = document.getElementById('deleteModalDesc');
            descEl.innerHTML = 'Are you sure you want to permanently delete the account for <strong>' + escapeDialogText(fullName) + '</strong> (' + escapeDialogText(email) + ')?';
            document.getElementById('deleteModal').classList.add('active');
        }

        function closeDeleteModal() {
            document.getElementById('deleteModal').classList.remove('active');
        }

        function openDeleteModalFromSummary() {
            const userId = getEl('hfSummaryUserId').value;
            const firstName = getEl('hfSummaryFirstName').value;
            const lastName = getEl('hfSummaryLastName').value;
            const fullName = (firstName + ' ' + lastName).trim();
            const email = getEl('hfSummaryEmailRaw').value;
            openDeleteModal(userId, fullName, email);
        }

        // Close on escape key
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                closeAddModal();
                closeEditModal();
                closeStatusModal();
                closeDeleteModal();
            }
        });

        // Close modals on clicking overlay background
        window.addEventListener('click', function (e) {
            const addModal = document.getElementById('addModal');
            const editModal = document.getElementById('editModal');
            const statusModal = document.getElementById('statusModal');
            const deleteModal = document.getElementById('deleteModal');
            if (e.target === addModal) closeAddModal();
            if (e.target === editModal) closeEditModal();
            if (e.target === statusModal) closeStatusModal();
            if (e.target === deleteModal) closeDeleteModal();
        });

        function dismissToast(btn) {
            var toast = btn.closest('.toast-box');
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(16px)';
                setTimeout(function () { toast.style.display = 'none'; }, 250);
            }
        }

        // Filters run on the server across the entire paginated directory.
        window.addEventListener('DOMContentLoaded', function () {
            var search = getEl('txtSearch');
            if (search) search.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') { event.preventDefault(); getEl('btnSearchUsers').click(); }
            });
        });

function clearAccountFormErrors(id) {
    var form = document.getElementById(id);
    form.querySelectorAll('[aria-invalid]').forEach(function (field) { field.removeAttribute('aria-invalid'); field.removeAttribute('aria-describedby'); });
    form.querySelectorAll('.form-error').forEach(function (error) { error.style.display = 'none'; });
}
