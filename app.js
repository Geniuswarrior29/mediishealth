document.addEventListener('DOMContentLoaded', () => {
    // Mobile Menu Toggle
    // Handle multi-language switch
    const langSelect = document.getElementById('langSelect');
    if (langSelect) {
        // Set initial value based on URL
        if (window.location.pathname.includes('-hi.html')) {
            langSelect.value = 'hi';
        } else {
            langSelect.value = 'en';
        }

        langSelect.addEventListener('change', (e) => {
            const lang = e.target.value;
            let currentPath = window.location.pathname;
            let currentFile = currentPath.split('/').pop();
            
            // Default to index.html if no file specified in URL
            if (!currentFile || currentFile === '') {
                currentFile = 'index.html';
            }
            
            if (lang === 'hi') {
                if (!currentFile.includes('-hi.html')) {
                    window.location.href = currentFile.replace('.html', '-hi.html');
                }
            } else {
                if (currentFile.includes('-hi.html')) {
                    window.location.href = currentFile.replace('-hi.html', '.html');
                }
            }
        });
    }

    // Modal logic for Login/Signup
    const loginBtn = document.getElementById('loginBtn');
    const loginModal = document.getElementById('loginModal');
    const closeModals = document.querySelectorAll('.close-modal');

    if(loginBtn && loginModal) {
        loginBtn.addEventListener('click', (e) => {
            e.preventDefault();
            loginModal.style.display = 'flex';
        });
    }

    closeModals.forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.modal').forEach(m => m.style.display = 'none');
        });
    });

    // Close modal on outside click
    window.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal')) {
            e.target.style.display = 'none';
        }
    });

    // Dummy form submissions
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const btn = form.querySelector('button[type="submit"]');
            const originalText = btn.innerText;
            btn.innerText = 'Processing...';
            btn.disabled = true;
            
            setTimeout(() => {
                btn.innerText = 'Success!';
                btn.style.background = '#10B981'; // Green
                setTimeout(() => {
                    form.reset();
                    btn.innerText = originalText;
                    btn.disabled = false;
                    btn.style.background = '';
                    
                    // Close modal if inside modal
                    if(form.closest('.modal')) {
                        form.closest('.modal').style.display = 'none';
                    }
                }, 2000);
            }, 1500);
        });
    });
});
