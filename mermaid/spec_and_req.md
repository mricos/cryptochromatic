# Pixeljam Arcade's Communications Protocol Specification and Requirements

## Table of Contents

1. [Introduction](#introduction)
2. [System Overview](#system-overview)
3. [Communication Protocols](#communication-protocols)
   - [HOST-CLIENT Communication](#host-client-communication)
   - [CLIENT-SERVER Communication](#client-server-communication)
   - [GAME-CLIENT Communication](#game-client-communication)
4. [Data Formats and Conventions](#data-formats-and-conventions)
   - [Message Headers](#message-headers)
   - [Timestamps](#timestamps)
   - [Payload Structure](#payload-structure)
5. [Game States](#game-states)
6. [Client Wrapper Specification](#client-wrapper-specification)
   - [Boilerplate Code for Game Developers](#boilerplate-code-for-game-developers)
7. [Security Considerations](#security-considerations)
8. [API Specification](#api-specification)
   - [Minimal OpenAPI Specification](#minimal-openapi-specification)
9. [Conclusion](#conclusion)
10. [Appendix](#appendix)

---

## Introduction

This document outlines the communication protocols and requirements for the **Pixeljam Arcade (PJA)** system, which involves interactions between the HOST, CLIENT, SERVER, and GAME components. The goal is to facilitate seamless multiplayer gaming experiences, exemplified by a sample application called **Pong Circle**—a multiplayer version of Pong played on a circle.

## System Overview

The PJA system consists of four primary components:

- **HOST**: An HTML/CSS/JS web page running the `pjaGameSdk`, serving as the primary interface for users.
- **CLIENT**: An embedded iframe within the HOST, running a game client (e.g., GameMaker, Unity, HTML5).
- **GAME**: The actual game application running within the CLIENT.
- **SERVER**: A Node.js application providing HTTPS API endpoints and WebSocket connections for real-time state communication.

### System Architecture Diagram

```mermaid
graph TD
    subgraph HOST
        A[HOST<br>(Web Page with pjaGameSdk)]
    end
    subgraph CLIENT
        B[CLIENT<br>(Iframe)]
        subgraph GAME
            C[GAME<br>(GameMaker/Unity/HTML5)]
        end
    end
    D[SERVER<br>(Node.js Application)]

    A -- postMessage API --> B
    B -- postMessage API --> A
    B -- Internal API --> C
    C -- Internal API --> B
    B -- HTTPS/WebSocket --> D
    D -- HTTPS/WebSocket --> B
```

## Communication Protocols

### HOST-CLIENT Communication

Communication between the HOST and CLIENT occurs via the `postMessage` API and is facilitated by the `pjaGameSdk`. This allows for secure cross-origin communication between the parent window and the iframe.

- **Mechanism**: `window.postMessage(message, targetOrigin)`
- **Data Exchange**: JSON-formatted messages
- **Security**: Messages are only accepted from trusted origins

### CLIENT-SERVER Communication

The CLIENT communicates with the SERVER through:

- **HTTPS API Endpoints**: For standard HTTP requests (e.g., fetching game configurations, leaderboards).
- **WebSockets**: For real-time data exchange (e.g., game state updates, multiplayer synchronization).

### GAME-CLIENT Communication

The GAME communicates with the CLIENT via an internal API provided by the CLIENT wrapper. This API abstracts the communication details, allowing the GAME to interact with the HOST and SERVER indirectly.

## Data Formats and Conventions

### Message Headers

All messages exchanged should include the following headers:

- **messageType**: Identifier for the type of message (e.g., `GAME_STATE_UPDATE`, `SCORE_SUBMISSION`)
- **sender**: Origin of the message (`HOST`, `CLIENT`, `SERVER`, `GAME`)
- **recipient**: Intended recipient
- **universalPixeljamID**: A unique identifier for the user/session

### Timestamps

Timestamps should be included in all messages to ensure synchronization and for debugging purposes.

- **Format**: ISO 8601 (e.g., `2023-10-05T14:48:00.000Z`)

### Payload Structure

Payloads should be JSON objects containing relevant data for the message type.

```json
{
  "header": {
    "messageType": "GAME_STATE_UPDATE",
    "sender": "GAME",
    "recipient": "HOST",
    "timestamp": "2023-10-05T14:48:00.000Z",
    "universalPixeljamID": "USER12345"
  },
  "payload": {
    "state": "PLAYING",
    "score": 1500,
    "credits": 3
  }
}
```

## Game States

The GAME can be in one of several states, which should be communicated to the HOST:

- **IDLE**: The game is loaded but not actively playing.
- **PLAYING**: The game is in progress.
- **PAUSED**: The game is paused.
- **DONE**: The game session has ended.
- **SCORE**: The player's score at any point.
- **CREDITS**: The number of credits or lives the player has.
- **UNIVERSAL_PIXELJAM_ID**: A unique identifier for the player, used across the PJA platform.

## Client Wrapper Specification

To facilitate integration, game developers should implement a CLIENT wrapper that handles communication between the GAME and the CLIENT, and by extension, the HOST and SERVER.

### Boilerplate Code for Game Developers

Below is a sample implementation for a JavaScript-based GAME.

#### Initialization

```javascript
// Initialize the PJA Game SDK
const pjaGameSdk = window.parent.pjaGameSdk;

// Verify that the SDK is available
if (!pjaGameSdk) {
  console.error('PJA Game SDK is not available.');
}

// Set up message listener
window.addEventListener('message', (event) => {
  if (event.origin !== 'https://trusted.host.origin') return; // Replace with actual HOST origin

  const message = event.data;

  // Handle incoming messages
  switch (message.header.messageType) {
    case 'HOST_COMMAND':
      handleHostCommand(message.payload);
      break;
    // Add more cases as needed
  }
});

// Function to handle commands from the HOST
function handleHostCommand(payload) {
  // Implement command handling logic
}
```

#### Sending Messages to HOST

```javascript
function sendMessageToHost(messageType, payload) {
  const message = {
    header: {
      messageType: messageType,
      sender: 'GAME',
      recipient: 'HOST',
      timestamp: new Date().toISOString(),
      universalPixeljamID: 'USER12345', // Retrieve dynamically as needed
    },
    payload: payload,
  };

  window.parent.postMessage(message, 'https://trusted.host.origin'); // Replace with actual HOST origin
}

// Example usage
sendMessageToHost('GAME_STATE_UPDATE', {
  state: 'PLAYING',
  score: 1500,
  credits: 3,
});
```

#### WebSocket Connection to SERVER

```javascript
// Establish WebSocket connection
const socket = new WebSocket('wss://server.pixeljam.com/game');

socket.addEventListener('open', () => {
  console.log('Connected to the server via WebSocket');
  
  // Send initial handshake or authentication if necessary
});

socket.addEventListener('message', (event) => {
  const message = JSON.parse(event.data);

  // Handle messages from the SERVER
  switch (message.header.messageType) {
    case 'SERVER_UPDATE':
      handleServerUpdate(message.payload);
      break;
    // Add more cases as needed
  }
});

function handleServerUpdate(payload) {
  // Implement server update handling logic
}
```

## Security Considerations

- **Origin Checks**: Always validate the `event.origin` in `postMessage` handlers to ensure messages are from trusted sources.
- **Authentication**: Use secure tokens or session identifiers when communicating with the SERVER.
- **Data Validation**: Validate all incoming data to prevent injection attacks.

## API Specification

To ground our language and prepare for adding more features and endpoints, we start with a minimal OpenAPI specification that includes only the bare necessities.

### Minimal OpenAPI Specification

```yaml
openapi: 3.0.0
info:
  title: Pixeljam Arcade API
  version: 0.1.0
  description: Minimal API for Pixeljam Arcade gaming platform
servers:
  - url: https://api.pixeljamarcade.com/v1

paths:
  /users:
    post:
      tags:
        - Users
      summary: Create a new user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          description: Bad request
    get:
      tags:
        - Users
      summary: Get current user profile
      responses:
        '200':
          description: User profile retrieved successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '401':
          description: Unauthorized

components:
  schemas:
    User:
      type: object
      required:
        - email
        - password
        - monogram
      properties:
        id:
          type: string
          description: Unique identifier for the user.
        email:
          type: string
          format: email
          description: Email address of the user.
        password:
          type: string
          description: Password for the user account.
        monogram:
          type: string
          description: Three-character monogram.
    Game:
      type: object
      required:
        - name
        - slug
      properties:
        id:
          type: string
          description: Unique identifier for the game.
        name:
          type: string
          description: Name of the game.
        slug:
          type: string
          description: Slug for the game.
  responses:
    Error:
      description: Error response
      content:
        application/json:
          schema:
            type: object
            properties:
              message:
                type: string
```

This minimal specification includes:

- **User Registration and Retrieval**: Allows for creating a new user and retrieving the current user's profile.
- **Schemas**: Defines the `User` and `Game` schemas with essential properties.
- **Error Handling**: Includes a generic error response.

By starting with this minimal API specification, we establish a foundation upon which we can incrementally add more features and endpoints, ensuring clarity and manageability.

## Conclusion

This specification provides a comprehensive guide for implementing communication protocols within the Pixeljam Arcade system. By starting with a minimal API specification, we ground our language and can methodically add features and endpoints as needed. Adhering to these guidelines will ensure seamless integration and a consistent user experience across the platform.

## Appendix

- **pjaGameSdk Documentation**: [Link to SDK Docs](#)
- **Sample Applications**: [GitHub Repository](#)
- **Contact Information**: For support, email [support@pixeljam.com](mailto:support@pixeljam.com)

---

*Note: Replace placeholder URLs and email addresses with actual resources.*
