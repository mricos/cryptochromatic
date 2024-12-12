document.addEventListener('DOMContentLoaded', () => {
    const cssVariables = {
        "--container-size": "500px",
        "--block-width": "250px",
        "--block-height": "250px",
        "--padding": "10px",
        "--margin": "5px",
        "--border": "1px solid rgba(0, 0, 0, 0.2)",
        "--body-bg-color": "#f4f4f4",
        "--font-family": "Arial, sans-serif",
        "--button-bg-color": "#444",
        "--button-text-color": "white",
        "--button-hover-bg-color": "#555"
    };

    const palette = [
        "#FF6464", "#64FF64", "#6464FF", "#FFFF64",
        "#FF64FF", "#64FFFF", "#C8C8C8", "#963264"
    ];

    const applyStyles = () => {
        Object.entries(cssVariables).forEach(([key, value]) => {
            document.documentElement.style.setProperty(key, value);
        });

        const nestedDivs = document.querySelectorAll(".nested-div");
        nestedDivs.forEach((div, index) => {
            div.style.backgroundColor = palette[index % palette.length];
        });
    };

    const renderDebugPanel = () => {
        const cssEditor = document.getElementById("css-editor");
        const paletteEditor = document.getElementById("palette-editor");
        cssEditor.innerHTML = "";
        paletteEditor.innerHTML = "";

        Object.entries(cssVariables).forEach(([key, value]) => {
            const row = document.createElement("div");
            row.innerHTML = `
                <label for="${key}">${key.replace("--", "")}:</label>
                <input type="text" id="${key}" value="${value}">
            `;
            cssEditor.appendChild(row);

            const input = row.querySelector(`#${key}`);
            input.addEventListener("input", () => {
                cssVariables[key] = input.value;
                applyStyles();
            });
        });

        palette.forEach((color, index) => {
            const row = document.createElement("div");
            row.innerHTML = `
                <label for="color-${index}">Color ${index + 1}:</label>
                <input type="color" id="color-${index}" value="${color}">
            `;
            paletteEditor.appendChild(row);

            const colorInput = row.querySelector(`#color-${index}`);
            colorInput.addEventListener("input", () => {
                palette[index] = colorInput.value;
                applyStyles();
            });
        });
    };

    const resetPalette = () => {
        const defaultPalette = [
            "#FF6464", "#64FF64", "#6464FF", "#FFFF64",
            "#FF64FF", "#64FFFF", "#C8C8C8", "#963264"
        ];
        palette.splice(0, palette.length, ...defaultPalette);
        renderDebugPanel();
        applyStyles();
    };

    const debugPopup = document.getElementById("debug-popup");

    document.body.addEventListener("dblclick", (event) => {
        if (event.shiftKey) {
            debugPopup.style.display = debugPopup.style.display === "none" ? "block" : "none";
        }
    });

    debugPopup.addEventListener("mousedown", (e) => {
        const offsetX = e.clientX - debugPopup.offsetLeft;
        const offsetY = e.clientY - debugPopup.offsetTop;

        const mouseMoveHandler = (event) => {
            debugPopup.style.left = `${event.clientX - offsetX}px`;
            debugPopup.style.top = `${event.clientY - offsetY}px`;
        };

        document.addEventListener("mousemove", mouseMoveHandler);
        document.addEventListener("mouseup", () => {
            document.removeEventListener("mousemove", mouseMoveHandler);
        }, { once: true });
    });

    document.getElementById("reset-palette").addEventListener("click", resetPalette);

    renderDebugPanel();
    applyStyles();
});
