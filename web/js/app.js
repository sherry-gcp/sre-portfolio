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
    const a = document.createElement('a');
    a.href = url;
    a.target = "_blank";
    a.className = "bg-primary text-on-primary px-6 py-2.5 rounded-lg font-body font-medium hover:opacity-90 transition-opacity flex items-center justify-between min-w-[160px]";
    a.innerHTML = `
        <span class="flex items-center gap-2">
            <span class="material-symbols-outlined text-[20px]">${icon}</span>
            ${text}
        </span>
        <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
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
