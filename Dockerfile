FROM node:22-slim

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy package files first for layer caching
COPY package.json pnpm-lock.yaml ./

# Recreate pnpm build-script allowlist in the image instead of relying on
# Hostinger's generated Docker context to include pnpm-workspace.yaml.
RUN printf '%s\n' \
  'onlyBuiltDependencies:' \
  '  - esbuild' \
  '  - sharp' \
  '  - workerd' \
  > pnpm-workspace.yaml

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the project
RUN pnpm run build

# Create data directory for persistence
RUN mkdir -p data logs

# Bind to all interfaces inside the container so platform proxies can reach it.
ENV HOST=0.0.0.0

# Expose the default port
EXPOSE 47821

# Run the proxy
CMD ["node", "dist/node.js"]
