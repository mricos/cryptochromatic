
document.addEventListener('DOMContentLoaded', () => {
    let currentPaletteIndex = 0;

    const animateColors = () => {
        const nestedDivs = document.querySelectorAll(".nested-div");
        nestedDivs.forEach((div, index) => {
            const nextColor = palette[(currentPaletteIndex + index) % palette.length];
            div.style.transition = "background-color 1s ease-in-out";
            div.style.backgroundColor = nextColor;
        });

        currentPaletteIndex = (currentPaletteIndex + 1) % palette.length;
    };

    setInterval(animateColors, 2000); // Update colors every 2 seconds
});
