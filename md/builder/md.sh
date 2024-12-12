#!/bin/bash

# Function to initialize a new Markdown/Mermaid project
md_create_project() {
    local project_name=$1
    if [[ -z "$project_name" ]]; then
        echo "Usage: md_create_project <project_name>"
        return 1
    fi

    mkdir "$project_name" && cd "$project_name" || return 1

    # Initialize npm and create basic files
    npm init -y
    echo "Initializing project '$project_name'..."

    # Create an HTML template
    cat > index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Markdown & Mermaid Viewer</title>
</head>
<body>
    <h1>Markdown & Mermaid Viewer</h1>
    <textarea id="markdownInput" placeholder="Enter Markdown here..."></textarea>
    <div id="output"></div>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <script>
        document.getElementById("markdownInput").addEventListener("input", (e) => {
            const markdown = e.target.value;
            const output = document.getElementById("output");
            output.innerHTML = marked.parse(markdown);

            const mermaidBlocks = output.querySelectorAll("code.language-mermaid");
            mermaidBlocks.forEach((block) => {
                const div = document.createElement("div");
                div.className = "mermaid";
                div.textContent = block.textContent;
                block.replaceWith(div);
                mermaid.init(undefined, div);
            });
        });
    </script>
</body>
</html>
EOL

    # Create a basic server file
    cat > server.js <<EOL
const http = require("http");
const fs = require("fs");
const path = require("path");

const HOST = process.env.HOST || "127.0.0.1";
const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
    const filePath = path.join(__dirname, "index.html");
    fs.readFile(filePath, (err, data) => {
        if (err) {
            res.writeHead(500);
            res.end("Error loading file");
        } else {
            res.writeHead(200, { "Content-Type": "text/html" });
            res.end(data);
        }
    });
});

server.listen(PORT, HOST, () => {
    console.log(\`Server running at http://\${HOST}:\${PORT}/\`);
});
EOL

    echo "Project '$project_name' created. Next steps:"
    echo "1. Run 'cd $project_name'"
    echo "2. Run 'npm install http-server'"
    echo "3. Run 'md_start_server'"
}

# Function to install required packages
md_install_packages() {
    npm install marked mermaid
    echo "Required packages installed: marked, mermaid"
}

# Function to start the server
md_start_server() {
    if [[ -z "$HOST" ]]; then
        export HOST="127.0.0.1"
    fi

    if [[ -z "$PORT" ]]; then
        export PORT="3000"
    fi

    echo "Starting server on http://$HOST:$PORT"
    node server.js
}
