document.addEventListener('DOMContentLoaded', () => {
    // 1. Mobile Menu Toggle with Backdrop
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const navLinks = document.querySelector('.nav-links');
    
    // Create backdrop overlay if not present
    let backdrop = document.querySelector('.nav-backdrop');
    if (!backdrop) {
        backdrop = document.createElement('div');
        backdrop.className = 'nav-backdrop';
        document.body.appendChild(backdrop);
    }

    if (mobileMenuBtn && navLinks) {
        const toggleMenu = (open) => {
            const isActive = open !== undefined ? open : !navLinks.classList.contains('active');
            navLinks.classList.toggle('active', isActive);
            backdrop.classList.toggle('active', isActive);
            mobileMenuBtn.innerHTML = isActive ? '&times;' : '&#9776;';
            // Lock body scroll so all scroll events directly target the drawer
            document.body.style.overflow = isActive ? 'hidden' : '';
        };

        mobileMenuBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            toggleMenu();
        });

        backdrop.addEventListener('click', () => toggleMenu(false));

        const drawerCloseBtn = document.querySelector('.drawer-close-btn');
        if (drawerCloseBtn) {
            drawerCloseBtn.addEventListener('click', () => toggleMenu(false));
        }

        // Close when clicking nav links
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => toggleMenu(false));
        });

        // Close when clicking anywhere outside drawer
        document.addEventListener('click', (e) => {
            if (navLinks.classList.contains('active')) {
                if (!navLinks.contains(e.target) && !mobileMenuBtn.contains(e.target)) {
                    toggleMenu(false);
                }
            }
        });

        // Ensure wheel inside nav-links stays inside nav-links
        navLinks.addEventListener('wheel', (e) => {
            e.stopPropagation();
        }, { passive: true });

        // Close on escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && navLinks.classList.contains('active')) {
                toggleMenu(false);
            }
        });
    }

    // 2. Handle Multi-Language Switch
    const langSelect = document.getElementById('langSelect');
    if (langSelect) {
        if (window.location.pathname.includes('-hi.html')) {
            langSelect.value = 'hi';
        } else {
            langSelect.value = 'en';
        }

        langSelect.addEventListener('change', (e) => {
            const lang = e.target.value;
            let currentPath = window.location.pathname;
            let currentFile = currentPath.split('/').pop();
            
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

    // 3. Gallery Filter Logic (For photos.html & photos-hi.html)
    const filterButtons = document.querySelectorAll('.filter-btn');
    const galleryCards = document.querySelectorAll('.gallery-card');

    if (filterButtons.length > 0 && galleryCards.length > 0) {
        filterButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                filterButtons.forEach(b => b.classList.remove('active'));
                btn.classList.add('active');

                const filter = btn.getAttribute('data-filter');
                galleryCards.forEach(card => {
                    if (filter === 'all' || card.getAttribute('data-category') === filter) {
                        card.style.display = 'flex';
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
        });
    }

    // 4. Lightbox Modal Logic (For photos.html & photos-hi.html)
    const lightboxModal = document.getElementById('lightboxModal');
    if (lightboxModal) {
        const lightboxImg = lightboxModal.querySelector('.lightbox-content img');
        const lightboxTitle = lightboxModal.querySelector('.lightbox-title');
        const lightboxDesc = lightboxModal.querySelector('.lightbox-desc');
        const lightboxClose = lightboxModal.querySelector('.lightbox-close');

        galleryCards.forEach(card => {
            card.addEventListener('click', () => {
                const img = card.querySelector('img');
                const title = card.querySelector('h3');
                const desc = card.querySelector('p');

                if (img) lightboxImg.src = img.src;
                if (title && lightboxTitle) lightboxTitle.innerText = title.innerText;
                if (desc && lightboxDesc) lightboxDesc.innerText = desc.innerText;

                lightboxModal.classList.add('active');
                document.body.style.overflow = 'hidden';
            });
        });

        const closeLightbox = () => {
            lightboxModal.classList.remove('active');
            document.body.style.overflow = '';
        };

        if (lightboxClose) lightboxClose.addEventListener('click', closeLightbox);
        lightboxModal.addEventListener('click', (e) => {
            if (e.target === lightboxModal) closeLightbox();
        });
    }

    // 5. Video Notify Form
    const notifyForm = document.getElementById('notifyForm');
    if (notifyForm) {
        notifyForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const btn = notifyForm.querySelector('button');
            const orig = btn.innerText;
            btn.innerText = 'Subscribed! ✓';
            btn.style.background = '#10B981';
            notifyForm.reset();
            setTimeout(() => {
                btn.innerText = orig;
                btn.style.background = '';
            }, 3000);
        });
    }

    // 6. Generic Form Submissions (Newsletter, Contact, etc.)
    const genericForms = document.querySelectorAll('form:not(#notifyForm):not(#consultationForm)');
    genericForms.forEach(form => {
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const btn = form.querySelector('button[type="submit"]');
            if (!btn) return;
            const originalText = btn.innerText;
            btn.innerText = 'Processing...';
            btn.disabled = true;
            
            setTimeout(() => {
                btn.innerText = 'Success! ✓';
                btn.style.background = '#10B981';
                setTimeout(() => {
                    form.reset();
                    btn.innerText = originalText;
                    btn.disabled = false;
                    btn.style.background = '';
                    
                    if (form.closest('.modal')) {
                        form.closest('.modal').style.display = 'none';
                    }
                }, 2000);
            }, 1000);
        });
    });
});
