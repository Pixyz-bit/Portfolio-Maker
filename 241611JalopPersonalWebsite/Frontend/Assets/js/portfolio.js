function exportPortfolioToPdf() {
            var originalTitle = document.title;
            var headerNameEl = document.querySelector('.header-name');
            var personName = headerNameEl ? headerNameEl.innerText.trim() : '';
            if (!personName) {
                personName = document.title.replace(/\|.*/, '').trim() || 'Portfolio';
            }

            document.title = personName + " - Portfolio";
            window.print();

            setTimeout(function () {
                document.title = originalTitle;
            }, 1000);
        }

        function copyPortfolioLink() {
            var btn = document.getElementById("btnShareLink");
            var url = (btn && btn.getAttribute("data-share-url")) ? btn.getAttribute("data-share-url") : window.location.href;

            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(url).then(function () {
                    showCopiedFeedback();
                }).catch(function () {
                    fallbackCopy(url);
                });
            } else {
                fallbackCopy(url);
            }
        }

        function fallbackCopy(text) {
            var textArea = document.createElement("textarea");
            textArea.value = text;
            textArea.style.position = "fixed";
            textArea.style.left = "-9999px";
            textArea.style.top = "0";
            textArea.style.opacity = "0";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            try {
                var successful = document.execCommand('copy');
                if (successful) {
                    showCopiedFeedback();
                } else {
                    prompt("Copy this portfolio link:", text);
                }
            } catch (err) {
                prompt("Copy this portfolio link:", text);
            }
            document.body.removeChild(textArea);
        }

        function showCopiedFeedback() {
            var span = document.getElementById("btnShareText");
            if (span) {
                var oldText = span.innerText;
                span.innerText = "Link Copied!";
                setTimeout(function () { span.innerText = oldText; }, 2500);
            }
        }

        // Sync browser address bar with canonical share URL if userId param was not already present
        (function () {
            var shareUrl = "<%= ShareUrl %>";
            if (shareUrl && window.history && window.history.replaceState) {
                try {
                    var current = new URL(window.location.href);
                    if (!current.searchParams.has("userId")) {
                        window.history.replaceState(null, document.title, shareUrl);
                    }
                } catch (e) { }
            }
        })();