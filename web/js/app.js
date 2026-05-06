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

async function updateStatus() {
    const statusDot = document.getElementById('status-dot');
    const statusText = document.getElementById('status-text');
    const statusLink = document.getElementById('status-indicator');
    
    if (!statusDot || !statusText) return;


    try {
        statusLink.href = "https://sherrym.cronitorstatus.com";

        statusDot.className = "w-2 h-2 rounded-full bg-[#10b981] shadow-status-glow";
        statusText.textContent = "Operational";
        
    } catch (error) {
        console.error("Status check failed:", error);
        statusDot.className = "w-2 h-2 rounded-full bg-amber-500";
        statusText.textContent = "Status Unknown";
    }
}

document.addEventListener('DOMContentLoaded', () => {
    updateStatus();
    // loadAssets(); // Disabled: Assets hardcoded directly to GCS bucket for speed.
});
