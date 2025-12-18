document.addEventListener('DOMContentLoaded', () => {
    initMarkdown();
    initScrollSpy();
    initCircuitAnimation();

    // Load content dynamically
    if (window.markdownFiles) {
        Object.keys(window.markdownFiles).forEach(targetId => {
            const filename = window.markdownFiles[targetId];
            loadMarkdownFile(filename, targetId);
        });
    }

    // Resize observer for SVG updates
    window.addEventListener('resize', debounce(initCircuitAnimation, 200));
});

/* Markdown Handling */
function initMarkdown() {
    marked.setOptions({
        gfm: true,
        breaks: true,
        headerIds: false
    });
}

function loadMarkdownFile(filename, targetId) {
    const element = document.getElementById(targetId);
    if (!element) return;

    fetch(filename)
        .then(response => {
            if (!response.ok) throw new Error("HTTP " + response.status);
            return response.text();
        })
        .then(text => {
            // Save content for modal usage
            element.dataset.fullContent = text;

            // Render a preview (first 200 chars or summary)
            const preview = text.substring(0, 300) + "...";
            element.innerHTML = marked.parse(text); // Render all for now in the preview box

            // Remove placeholder styling
            const placeholder = element.querySelector('.placeholder-text');
            if (placeholder) placeholder.remove();

        })
        .catch(err => {
            console.error('Error loading ' + filename, err);
            element.innerHTML = `<div class="placeholder-text error">
                Erreur: Impossible de charger ${filename}.<br>
                <small>Si vous êtes en local, utilisez un serveur (ex: <code>python -m http.server</code>) ou VS Code Live Server.</small>
            </div>`;
        });
}

/* Modal Logic */
function openModal(targetId) {
    const element = document.getElementById(targetId);
    const modal = document.getElementById('markdown-modal');
    const modalBody = document.getElementById('modal-body');
    const modalTitle = document.getElementById('modal-title-text');

    if (!element || !modal) return;

    // Get content from dataset if loaded, or innerHTML
    const content = element.dataset.fullContent || element.innerText; // Fallback

    // Set Title based on the card title
    const cardTitle = element.closest('.card').querySelector('.card-title').textContent;
    modalTitle.textContent = cardTitle;

    modalBody.innerHTML = marked.parse(content);

    modal.classList.add('open');
    modal.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden'; // Prevent background scrolling
}

function closeModal(event) {
    // If event is provided, check if clicked specific overlay
    if (event && !event.target.classList.contains('modal-overlay')) {
        return;
    }

    const modal = document.getElementById('markdown-modal');
    modal.classList.remove('open');
    modal.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
}

/* Escape key to close modal */
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        const modal = document.getElementById('markdown-modal');
        if (modal && modal.classList.contains('open')) {
            closeModal();
        }
    }
});

/* Navigation & ScrollSpy */
function initScrollSpy() {
    const sections = ['prompt', 'tasks', 'plan', 'walkthrough', 'application'];
    const navLinks = document.querySelectorAll('.nav-link');

    window.addEventListener('scroll', () => {
        let current = '';

        sections.forEach(section => {
            const element = document.getElementById(section);
            if (element) {
                const sectionTop = element.offsetTop;
                if (window.scrollY >= (sectionTop - 200)) {
                    current = section;
                }
            }
        });

        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href').includes(current)) {
                link.classList.add('active');
            }
        });
    });
}

/* SVG Circuit Animation Logic */
function initCircuitAnimation() {
    const svg = document.getElementById('circuit-svg');
    const path = document.getElementById('circuit-path');
    const cards = document.querySelectorAll('.card');

    if (cards.length < 2) return;

    const bodyRect = document.body.getBoundingClientRect();
    svg.setAttribute('width', bodyRect.width);
    svg.setAttribute('height', bodyRect.height);

    let d = '';

    cards.forEach((card, index) => {
        const rect = card.getBoundingClientRect();
        const centerX = rect.left + rect.width / 2 + window.scrollX;
        const centerY = rect.top + rect.height / 2 + window.scrollY;

        if (index === 0) {
            d += `M ${centerX} ${centerY} `;
        } else {
            const prevRect = cards[index - 1].getBoundingClientRect();
            const prevX = prevRect.left + prevRect.width / 2 + window.scrollX;
            const prevY = prevRect.top + prevRect.height / 2 + window.scrollY;

            const cp1X = prevX;
            const cp1Y = prevY + (centerY - prevY) / 2;
            const cp2X = centerX;
            const cp2Y = prevY + (centerY - prevY) / 2;

            d += `C ${cp1X} ${cp1Y}, ${cp2X} ${cp2Y}, ${centerX} ${centerY} `;
        }
    });

    path.setAttribute('d', d);
}

/* Protocol Launcher */
function launchAppProtocol() {
    const btn = document.querySelector('.btn-primary');
    const originalText = btn.innerHTML;

    btn.innerHTML = '<span class="btn-icon">⏳</span> Lancement...';
    btn.disabled = true;

    fetch('http://localhost:8000/launch', { method: 'POST' })
        .then(response => response.json())
        .then(data => {
            alert("✅ " + data.message + "\nL'émulateur et l'application vont s'ouvrir.");
        })
        .catch(err => {
            console.error(err);
            alert("❌ Erreur : Impossible de contacter le launcher.\nAssurez-vous d'avoir lancé 'launcher.py'.");
        })
        .finally(() => {
            setTimeout(() => {
                btn.innerHTML = originalText;
                btn.disabled = false;
            }, 3000);
        });
}

/* Utilities */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}
