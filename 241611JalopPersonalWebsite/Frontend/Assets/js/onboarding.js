function getEl(id) {
    return document.getElementById(id) || document.querySelector('[id$="' + id + '"]') || document.querySelector('[name$="' + id + '"]');
}

var currentStep = 1;
        var totalSteps = 5;

        function setStep(step) {
            currentStep = step;
            getEl('hfCurrentStep').value = step;

            // Hide all sections
            for (var i = 1; i <= totalSteps; i++) {
                var sec = document.getElementById('step' + i);
                var ind = document.getElementById('indicator' + i);
                if (sec) sec.classList.remove('active-step');
                if (ind) {
                    ind.classList.remove('active');
                    if (i < step) ind.classList.add('completed');
                    else ind.classList.remove('completed');
                }
            }

            // Show active section
            var activeSec = document.getElementById('step' + step);
            var activeInd = document.getElementById('indicator' + step);
            if (activeSec) activeSec.classList.add('active-step');
            if (activeInd) activeInd.classList.add('active');

            // Update connector lines between bubbles
            for (var j = 1; j < totalSteps; j++) {
                var line = document.getElementById('line' + j);
                if (line) {
                    if (j < step) {
                        line.classList.add('active');
                    } else {
                        line.classList.remove('active');
                    }
                }
            }

            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        function nextStep(current) {
            if (validateStep(current)) {
                if (current < totalSteps) {
                    setStep(current + 1);
                }
            }
        }

        function prevStep(current) {
            if (current > 1) {
                setStep(current - 1);
            }
        }

        function jumpToStep(step) {
            // Allow jumping freely between steps
            setStep(step);
        }

        function escapeToastHtml(str) {
            if (!str) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function showToast(title, message, isError) {
            if (typeof isError === 'undefined') isError = true;
            var container = document.getElementById('toastContainer');
            if (!container) {
                container = document.createElement('div');
                container.id = 'toastContainer';
                container.className = 'toast-container';
                document.body.appendChild(container);
            }

            // Remove previous client toasts to avoid clutter
            var oldToasts = container.querySelectorAll('.client-toast');
            for (var i = 0; i < oldToasts.length; i++) {
                if (oldToasts[i].parentNode) {
                    oldToasts[i].parentNode.removeChild(oldToasts[i]);
                }
            }

            var toast = document.createElement('div');
            toast.setAttribute('role', 'alert');
            toast.className = 'toast-box client-toast ' + (isError ? 'toast-error' : 'toast-success');

            var iconSvg = isError
                ? '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>'
                : '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>';

            toast.innerHTML =
                '<div class="toast-icon">' + iconSvg + '</div>' +
                '<div class="toast-content">' +
                    '<span class="toast-title">' + escapeToastHtml(title || (isError ? 'Validation Error' : 'Notice')) + '</span>' +
                    '<span class="toast-message">' + escapeToastHtml(message) + '</span>' +
                '</div>' +
                '<button type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>';

            container.appendChild(toast);

            // Auto dismiss after 5 seconds
            setTimeout(function () {
                var btn = toast.querySelector('.toast-close-btn');
                if (btn) dismissToast(btn);
            }, 5000);
        }

        function markInvalid(el) {
            if (!el) return;
            el.classList.add('is-invalid');
            el.setAttribute('aria-invalid', 'true');
            el.focus();
            var removeHandler = function () {
                el.classList.remove('is-invalid');
                el.removeAttribute('aria-invalid');
                el.removeEventListener('input', removeHandler);
            };
            el.addEventListener('input', removeHandler);
        }

        function validateStep(step) {
            if (step === 1) {
                var fnEl = getEl('txtFirstName');
                var lnEl = getEl('txtLastName');
                var fn = fnEl ? fnEl.value.trim() : '';
                var ln = lnEl ? lnEl.value.trim() : '';

                if (!fn || !ln) {
                    showToast('Validation Error', 'Please enter your First Name and Last Name to continue.');
                    if (!fn && fnEl) markInvalid(fnEl);
                    else if (!ln && lnEl) markInvalid(lnEl);
                    return false;
                }

                var emailEl = getEl('txtContactEmail');
                var email = emailEl ? emailEl.value.trim() : '';
                if (email) {
                    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailRegex.test(email)) {
                        showToast('Validation Error', 'Please enter a valid Public Contact Email address (e.g. name@example.com).');
                        markInvalid(emailEl);
                        return false;
                    }
                }

                var phoneEl = getEl('txtContactNum');
                var phone = phoneEl ? phoneEl.value.trim() : '';
                if (phone) {
                    var cleanPhone = phone.replace(/\D/g, '');
                    if (cleanPhone.length !== 11) {
                        showToast('Validation Error', 'Contact / Mobile Number must be exactly 11 digits (e.g. 09123456789).');
                        markInvalid(phoneEl);
                        return false;
                    }
                }
            }
            return true;
        }

        function previewAvatar(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    var previewImg = getEl('imgProfilePreview');
                    if (previewImg) previewImg.src = e.target.result;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        // =========================================================================
        // Dynamic List Management (Add, Remove, Reindex, Serialize)
        // =========================================================================
        function escapeHtml(str) {
            if (str === null || str === undefined) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        }

        function removeDynamicCard(btn, containerId, titlePrefix) {
            var card = btn.closest('.item-card');
            if (!card) return;
            var container = document.getElementById(containerId);
            card.remove();
            reindexCards(containerId, titlePrefix);
            serializeDynamicData();
        }

        function reindexCards(containerId, titlePrefix) {
            var container = document.getElementById(containerId);
            if (!container) return;
            var cards = container.querySelectorAll('.item-card');
            cards.forEach(function (c, idx) {
                var badge = c.querySelector('.badge-title');
                if (badge) {
                    badge.textContent = titlePrefix + ' #' + (idx + 1);
                }
            });
        }

        // 1. Education
        function addEducation(data) {
            data = data || {};
            var container = document.getElementById('educationList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var card = document.createElement('div');
            card.className = 'item-card education-item-card';
            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"></path><path d="M6 12v5c3 3 9 3 12 0v-5"></path></svg>' +
                        '<span class="badge-title">Education #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'educationList\', \'Education\');" title="Remove this education record">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Degree / Course Name *</label>' +
                    '<input type="text" class="form-input edu-course" maxlength="150" placeholder="e.g. Bachelor of Science in Information Technology" value="' + escapeHtml(data.courseName || '') + '" />' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">University / Institution *</label>' +
                    '<input type="text" class="form-input edu-univ" maxlength="150" placeholder="e.g. University of Science and Technology of Southern Philippines" value="' + escapeHtml(data.university || '') + '" />' +
                '</div>' +
                '<div class="form-row-dual">' +
                    '<div class="form-group">' +
                        '<label class="form-label">Start Year *</label>' +
                        '<input type="text" class="form-input edu-start" maxlength="10" placeholder="e.g. 2021" value="' + escapeHtml(data.startYear || '') + '" />' +
                    '</div>' +
                    '<div class="form-group">' +
                        '<label class="form-label">End Year (or \'Present\')</label>' +
                        '<input type="text" class="form-input edu-end" maxlength="10" placeholder="e.g. 2025" value="' + escapeHtml(data.endYear || '') + '" />' +
                    '</div>' +
                '</div>';
            container.appendChild(card);
            if (window.PortfolioAccessibility) PortfolioAccessibility.labelFields(card);
        }

        // 2. Skill
        function addSkill(data) {
            data = data || {};
            var container = document.getElementById('skillList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var card = document.createElement('div');
            card.className = 'item-card skill-item-card';
            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg>' +
                        '<span class="badge-title">Skill #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'skillList\', \'Skill\');" title="Remove this skill">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Skill Name *</label>' +
                    '<input type="text" class="form-input skill-name" maxlength="100" placeholder="e.g. C# & ASP.NET Web Forms / MVC" value="' + escapeHtml(data.skillName || '') + '" />' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Description / Proficiency Details</label>' +
                    '<input type="text" class="form-input skill-desc" placeholder="e.g. Backend architecture, ADO.NET, REST APIs, Session state" value="' + escapeHtml(data.skillDescription || '') + '" />' +
                '</div>';
            container.appendChild(card);
            if (window.PortfolioAccessibility) PortfolioAccessibility.labelFields(card);
        }

        // 3. Affiliation
        function addAffiliation(data) {
            data = data || {};
            var container = document.getElementById('affiliationList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var card = document.createElement('div');
            card.className = 'item-card affiliation-item-card';
            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>' +
                        '<span class="badge-title">Affiliation #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'affiliationList\', \'Affiliation\');" title="Remove this affiliation">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-row-dual">' +
                    '<div class="form-group">' +
                        '<label class="form-label">Organization Name *</label>' +
                        '<input type="text" class="form-input affil-org" maxlength="150" placeholder="e.g. Junior Philippine Computer Society" value="' + escapeHtml(data.organizationName || '') + '" />' +
                    '</div>' +
                    '<div class="form-group">' +
                        '<label class="form-label">Position / Role *</label>' +
                        '<input type="text" class="form-input affil-role" maxlength="100" placeholder="e.g. Vice President for Technical Affairs" value="' + escapeHtml(data.position || '') + '" />' +
                    '</div>' +
                '</div>' +
                '<div class="form-row-dual">' +
                    '<div class="form-group">' +
                        '<label class="form-label">Start Year</label>' +
                        '<input type="text" class="form-input affil-start" maxlength="10" placeholder="e.g. 2022" value="' + escapeHtml(data.startYear || '') + '" />' +
                    '</div>' +
                    '<div class="form-group">' +
                        '<label class="form-label">End Year (or \'Present\')</label>' +
                        '<input type="text" class="form-input affil-end" maxlength="10" placeholder="e.g. 2024" value="' + escapeHtml(data.endYear || '') + '" />' +
                    '</div>' +
                '</div>';
            container.appendChild(card);
            if (window.PortfolioAccessibility) PortfolioAccessibility.labelFields(card);
        }

        // 4. Hobby
        function addHobby(data) {
            data = data || {};
            var container = document.getElementById('hobbyList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var card = document.createElement('div');
            card.className = 'item-card hobby-item-card';
            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>' +
                        '<span class="badge-title">Hobby #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'hobbyList\', \'Hobby\');" title="Remove this hobby">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Hobby / Interest Name *</label>' +
                    '<input type="text" class="form-input hobby-name" maxlength="100" placeholder="e.g. Competitive Programming" value="' + escapeHtml(data.hobbyName || '') + '" />' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Description</label>' +
                    '<input type="text" class="form-input hobby-desc" placeholder="e.g. Solving algorithmic challenges on LeetCode & Codeforces" value="' + escapeHtml(data.hobbyDescription || '') + '" />' +
                '</div>';
            container.appendChild(card);
            if (window.PortfolioAccessibility) PortfolioAccessibility.labelFields(card);
        }

        // 5. Social Link
        function addSocialLink(data) {
            data = data || {};
            var container = document.getElementById('socialLinkList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var currentPlatform = (data.socialLinkName || 'GitHub').trim();
            var card = document.createElement('div');
            card.className = 'item-card social-item-card';

            var platforms = ['GitHub', 'LinkedIn', 'Personal Website', 'Twitter / X', 'Instagram', 'Facebook', 'YouTube', 'Discord', 'TikTok', 'Other'];
            var optionsHtml = '';
            var matched = false;
            for (var i = 0; i < platforms.length; i++) {
                var p = platforms[i];
                var isSelected = (p.toLowerCase() === currentPlatform.toLowerCase());
                if (isSelected) matched = true;
                optionsHtml += '<option value="' + escapeHtml(p) + '"' + (isSelected ? ' selected' : '') + '>' + escapeHtml(p) + '</option>';
            }
            if (!matched && currentPlatform) {
                optionsHtml += '<option value="' + escapeHtml(currentPlatform) + '" selected>' + escapeHtml(currentPlatform) + '</option>';
            }

            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>' +
                        '<span class="badge-title">Link #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'socialLinkList\', \'Link\');" title="Remove this social link">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-row-dual">' +
                    '<div class="form-group">' +
                        '<label class="form-label">Platform / Network</label>' +
                        '<select class="form-input social-platform">' +
                            optionsHtml +
                        '</select>' +
                    '</div>' +
                    '<div class="form-group">' +
                        '<label class="form-label">Profile / Portfolio URL *</label>' +
                        '<input type="text" class="form-input social-url" maxlength="500" placeholder="https://..." value="' + escapeHtml(data.link || '') + '" />' +
                    '</div>' +
                '</div>';
            container.appendChild(card);
            if (window.PortfolioAccessibility) PortfolioAccessibility.labelFields(card);
        }

        // =========================================================================
        // Serialization to Hidden Fields
        // =========================================================================
        function serializeDynamicData() {
            // 1. Educations
            var eduCards = document.querySelectorAll('#educationList .item-card');
            var eduData = [];
            eduCards.forEach(function (c) {
                var courseEl = c.querySelector('.edu-course');
                var univEl = c.querySelector('.edu-univ');
                var startEl = c.querySelector('.edu-start');
                var endEl = c.querySelector('.edu-end');
                var course = courseEl ? courseEl.value.trim() : '';
                var univ = univEl ? univEl.value.trim() : '';
                var start = startEl ? startEl.value.trim() : '';
                var end = endEl ? endEl.value.trim() : '';
                if (course || univ) {
                    eduData.push({ CourseName: course, University: univ, StartYear: start, EndYear: end });
                }
            });
            var hfEdu = getEl('hfEducationsJson');
            if (hfEdu) hfEdu.value = JSON.stringify(eduData);

            // 2. Skills
            var skillCards = document.querySelectorAll('#skillList .item-card');
            var skillData = [];
            skillCards.forEach(function (c) {
                var nameEl = c.querySelector('.skill-name');
                var descEl = c.querySelector('.skill-desc');
                var name = nameEl ? nameEl.value.trim() : '';
                var desc = descEl ? descEl.value.trim() : '';
                if (name) {
                    skillData.push({ SkillName: name, SkillDescription: desc });
                }
            });
            var hfSkill = getEl('hfSkillsJson');
            if (hfSkill) hfSkill.value = JSON.stringify(skillData);

            // 3. Affiliations
            var affilCards = document.querySelectorAll('#affiliationList .item-card');
            var affilData = [];
            affilCards.forEach(function (c) {
                var orgEl = c.querySelector('.affil-org');
                var roleEl = c.querySelector('.affil-role');
                var startEl = c.querySelector('.affil-start');
                var endEl = c.querySelector('.affil-end');
                var org = orgEl ? orgEl.value.trim() : '';
                var role = roleEl ? roleEl.value.trim() : '';
                var start = startEl ? startEl.value.trim() : '';
                var end = endEl ? endEl.value.trim() : '';
                if (org || role) {
                    affilData.push({ OrganizationName: org, Position: role, StartYear: start, EndYear: end });
                }
            });
            var hfAffil = getEl('hfAffiliationsJson');
            if (hfAffil) hfAffil.value = JSON.stringify(affilData);

            // 4. Hobbies
            var hobbyCards = document.querySelectorAll('#hobbyList .item-card');
            var hobbyData = [];
            hobbyCards.forEach(function (c) {
                var nameEl = c.querySelector('.hobby-name');
                var descEl = c.querySelector('.hobby-desc');
                var name = nameEl ? nameEl.value.trim() : '';
                var desc = descEl ? descEl.value.trim() : '';
                if (name) {
                    hobbyData.push({ HobbyName: name, HobbyDescription: desc });
                }
            });
            var hfHobby = getEl('hfHobbiesJson');
            if (hfHobby) hfHobby.value = JSON.stringify(hobbyData);

            // 5. Social Links
            var socialCards = document.querySelectorAll('#socialLinkList .item-card');
            var socialData = [];
            socialCards.forEach(function (c) {
                var platEl = c.querySelector('.social-platform');
                var urlEl = c.querySelector('.social-url');
                var plat = platEl ? platEl.value.trim() : 'Other';
                var url = urlEl ? urlEl.value.trim() : '';
                if (url) {
                    socialData.push({ SocialLinkName: plat, Link: url });
                }
            });
            var hfSocial = getEl('hfSocialLinksJson');
            if (hfSocial) hfSocial.value = JSON.stringify(socialData);
        }

        // =========================================================================
        // Initialization
        // =========================================================================
        function initDynamicSections() {
            function parseJsonSafely(id) {
                var el = document.getElementById(id);
                if (!el || !el.value) return [];
                try {
                    return JSON.parse(el.value) || [];
                } catch (e) {
                    return [];
                }
            }

            // Educations
            var educations = parseJsonSafely('hfEducationsJson');
            if (educations.length > 0) {
                educations.forEach(function (item) { addEducation(item); });
            } else {
                addEducation();
            }

            // Skills
            var skills = parseJsonSafely('hfSkillsJson');
            if (skills.length > 0) {
                skills.forEach(function (item) { addSkill(item); });
            } else {
                addSkill();
            }

            // Affiliations
            var affiliations = parseJsonSafely('hfAffiliationsJson');
            if (affiliations.length > 0) {
                affiliations.forEach(function (item) { addAffiliation(item); });
            } else {
                addAffiliation();
            }

            // Hobbies
            var hobbies = parseJsonSafely('hfHobbiesJson');
            if (hobbies.length > 0) {
                hobbies.forEach(function (item) { addHobby(item); });
            } else {
                addHobby();
            }

            // Social Links
            var socialLinks = parseJsonSafely('hfSocialLinksJson');
            if (socialLinks.length > 0) {
                socialLinks.forEach(function (item) { addSocialLink(item); });
            } else {
                addSocialLink();
            }
        }

        function dismissToast(btn) {
            var toast = btn.closest('.toast-box');
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(16px)';
                setTimeout(function () {
                    if (toast.parentNode) {
                        toast.parentNode.removeChild(toast);
                    } else {
                        toast.style.display = 'none';
                    }
                }, 250);
            }
        }

        // Initialize state on load
        window.addEventListener('DOMContentLoaded', function () {
            var hfStep = getEl('hfCurrentStep');
            var initStep = hfStep && hfStep.value ? parseInt(hfStep.value) : 1;
            if (isNaN(initStep) || initStep < 1 || initStep > totalSteps) initStep = 1;
            setStep(initStep);

            // Populate dynamic lists
            initDynamicSections();

            // Hook form submit
            var form = getEl('onboardingForm');
            if (form) {
                form.addEventListener('submit', serializeDynamicData);
            }

            // Auto-dismiss any active toasts after 5 seconds
            var activeToasts = document.querySelectorAll('.toast-box');
            activeToasts.forEach(function (t) {
                setTimeout(function () {
                    var btn = t.querySelector('.toast-close-btn');
                    if (btn) dismissToast(btn);
                }, 5000);
            });
        });