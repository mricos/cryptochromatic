// Get references to the DOM elements
const markdownInput = document.getElementById("markdownInput");
const renderButton = document.getElementById("renderMarkdown");
const outputDiv = document.getElementById("output");

// Function to render Markdown with Mermaid support
function renderMarkdown() {
    const markdown = markdownInput.value;

    // Convert Markdown to HTML
    const renderedHTML = marked.parse(markdown);
    outputDiv.innerHTML = renderedHTML;

    // Find Mermaid code blocks and render them
    const mermaidBlocks = outputDiv.querySelectorAll("code.language-mermaid");
    mermaidBlocks.forEach((block) => {
        const diagramContainer = document.createElement("div");
        diagramContainer.className = "mermaid";
        diagramContainer.textContent = block.textContent; // Preserve Mermaid syntax
        block.replaceWith(diagramContainer);

        try {
            mermaid.init(undefined, diagramContainer);
        } catch (error) {
            console.error("Mermaid rendering error:", error);
        }
    });
}

// Attach event listener to the Render button
renderButton.addEventListener("click", renderMarkdown);
