function getEl(id) {
    return document.getElementById(id) || document.querySelector('[id$="' + id + '"]') || document.querySelector('[name$="' + id + '"]');
}

// Modal helpers
        function openAddModal() {
            document.getElementById('addModal').classList.add('active');
        }

        function closeAddModal() {
            document.getElementById('addModal').classList.remove('active');
        }

        function openEditModal(userId, firstName, lastName, email, role, isActive) {
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
                descEl.innerHTML = 'Are you sure you want to deactivate the account for <strong>' + fullName + '</strong> (' + email + ')?<br><br><span style="color: #dc2626; font-size: 0.82rem; font-weight: 600;">The user will be immediately barred from signing in until an administrator reactivates their account.</span>';
                iconWrap.style.backgroundColor = '#fee2e2';
                iconDeactivate.style.display = 'block';
                iconActivate.style.display = 'none';
                confirmBtn.className = 'btn btn-danger btn-sm';
                confirmBtn.value = 'Yes, Deactivate';
            } else {
                titleEl.textContent = 'Activate User Account';
                descEl.innerHTML = 'Are you sure you want to activate the account for <strong>' + fullName + '</strong> (' + email + ')?<br><br><span style="color: #16a34a; font-size: 0.82rem; font-weight: 600;">The user will be granted full access to sign in and update their portfolio.</span>';
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
            descEl.innerHTML = 'Are you sure you want to permanently delete the account for <strong>' + fullName + '</strong> (' + email + ')?';
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

        // Instant Automatic Client-Side Filtering for User Management
        function applyClientUserFilters() {
            var searchInput = getEl('txtSearch') || document.getElementById('txtSearch');
            var statusSelect = getEl('ddlStatusFilter') || document.getElementById('ddlStatusFilter');
            var roleSelect = getEl('ddlRoleFilter') || document.getElementById('ddlRoleFilter');
            var noUsersNotice = document.getElementById('clientNoUsers');

            var query = (searchInput ? searchInput.value : '').trim().toLowerCase();
            var statusVal = (statusSelect ? statusSelect.value : '').trim().toLowerCase();
            var roleVal = (roleSelect ? roleSelect.value : '').trim().toLowerCase();

            var rows = document.querySelectorAll('.data-table tbody tr.user-data-row');
            var visibleCount = 0;

            rows.forEach(function (row) {
                var name = row.getAttribute('data-name') || '';
                var email = row.getAttribute('data-email') || '';
                var role = row.getAttribute('data-role') || '';
                var status = row.getAttribute('data-status') || '';

                var matchesQuery = !query || name.indexOf(query) !== -1 || email.indexOf(query) !== -1;
                var matchesStatus = !statusVal || status === statusVal;
                var matchesRole = !roleVal || role === roleVal;

                if (matchesQuery && matchesStatus && matchesRole) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });

            if (noUsersNotice) {
                noUsersNotice.style.display = (visibleCount === 0 && rows.length > 0) ? 'block' : 'none';
            }
        }

        function resetClientUserFilters() {
            var searchInput = getEl('txtSearch') || document.getElementById('txtSearch');
            var statusSelect = getEl('ddlStatusFilter') || document.getElementById('ddlStatusFilter');
            var roleSelect = getEl('ddlRoleFilter') || document.getElementById('ddlRoleFilter');

            if (searchInput) searchInput.value = '';
            if (statusSelect) statusSelect.selectedIndex = 0;
            if (roleSelect) roleSelect.selectedIndex = 0;

            applyClientUserFilters();
        }

        // Auto-dismiss active toasts after 5 seconds and wire up automatic filtering
        window.addEventListener('DOMContentLoaded', function () {
            var activeToasts = document.querySelectorAll('.toast-box');
            activeToasts.forEach(function (t) {
                setTimeout(function () {
                    var btn = t.querySelector('.toast-close-btn');
                    if (btn) dismissToast(btn);
                }, 5000);
            });

            var searchInput = getEl('txtSearch') || document.getElementById('txtSearch');
            var statusSelect = getEl('ddlStatusFilter') || document.getElementById('ddlStatusFilter');
            var roleSelect = getEl('ddlRoleFilter') || document.getElementById('ddlRoleFilter');

            if (searchInput) {
                searchInput.addEventListener('input', applyClientUserFilters);
                searchInput.addEventListener('keydown', function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        applyClientUserFilters();
                        return false;
                    }
                });
            }
            if (statusSelect) {
                statusSelect.addEventListener('change', applyClientUserFilters);
            }
            if (roleSelect) {
                roleSelect.addEventListener('change', applyClientUserFilters);
            }
        });