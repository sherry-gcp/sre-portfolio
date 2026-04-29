async function loadProjects() {
    const container = document.getElementById('projects-list');
    const template = document.getElementById('project-template');
    if (!container || !template) return;

    try {
        const response = await fetch('/api/projects');
        const projects = await response.json();

        container.innerHTML = "";

        projects.forEach(project => {
            const clone = template.content.cloneNode(true);

            // Fill text
            clone.querySelector('.project-name').textContent = project.name;
            clone.querySelector('.project-statement').textContent = project.statement;

            // Fill tags
            const tagsContainer = clone.querySelector('.project-tags');
            project.stack.forEach(tech => {
                const span = document.createElement('span');
                span.className = "bg-surface-variant text-on-surface px-3 py-1 rounded-full text-xs font-label uppercase tracking-wider";
                span.textContent = tech;
                tagsContainer.appendChild(span);
            });

            // Fill links
            const linksContainer = clone.querySelector('.project-links');
            addLink(linksContainer, project.github_url, "GitHub", "code");
            addLink(linksContainer, project.live_demo_url, project.live_demo_label || "Live Demo", "visibility");
            addLink(linksContainer, project.documentation_url, project.documentation_label || "Documentation", "description");

            container.appendChild(clone);
        });
    } catch (error) {
        console.error("API Error:", error);
    }
}

function addLink(container, url, text, icon) {
    if (!url) return;
    
    // Map Material Icons to SVG paths
    const iconPaths = {
        'code': '<path d="M9.4 16.6L4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z"/>',
        'visibility': '<path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>',
        'description': '<path d="M14 2H6c-1.1 0-1.99.89-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.89 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/>'
    };

    const svgIcon = iconPaths[icon] || '';
    const a = document.createElement('a');
    a.href = url;
    a.target = "_blank";
    a.className = "group bg-primary text-on-primary pl-6 pr-4 py-2.5 rounded-lg font-body font-medium transition-all duration-300 flex items-center justify-between w-full md:min-w-[240px] relative overflow-hidden";
    a.innerHTML = `
        <span class="flex items-center gap-2">
            <svg class="w-5 h-5 fill-current" viewBox="0 0 24 24" aria-hidden="true">
                ${svgIcon}
            </svg>
            ${text}
        </span>
        <svg class="w-6 h-6 fill-none stroke-current stroke-2 flex-shrink-0 opacity-0 -translate-x-4 group-hover:translate-x-0 group-hover:opacity-100 transition-all duration-700 ease-in-out" viewBox="0 0 24 24" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
        </svg>
    `;
    container.appendChild(a);
}

async function loadAssets() {
    try {
        const response = await fetch('/api/assets');
        const assets = await response.json();

        const portrait = document.getElementById('portrait-img');
        const resume = document.getElementById('resume-link');
        const resumeFooter = document.getElementById('resume-footer-link');

        if (portrait && assets.portrait) {
            portrait.src = assets.portrait;
            // Reveal the image once the URL is set
            portrait.classList.remove('opacity-0');
        }
        if (resume && assets.resume) {
            resume.href = assets.resume;
        }
        if (resumeFooter && assets.resume) {
            resumeFooter.href = assets.resume;
        }
    } catch (error) {
        console.error("Asset Error:", error);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    loadProjects();
    loadAssets();
});
