FROM node:22-slim

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy package files first for layer caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the project
RUN pnpm run build

# Create data directory for persistence
RUN mkdir -p data logs

# Expose the default port
EXPOSE 47821

# Run the proxy
CMD ["node", "dist/node.js"]
