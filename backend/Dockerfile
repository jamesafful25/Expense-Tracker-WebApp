
# 1. Use a lightweight Node.js base image
FROM node:22-alpine

# 2. Set the application working directory
WORKDIR /app

# 3. Copy dependency definitions first
COPY package*.json ./

# 4. Install production dependencies only
RUN npm ci --omit=dev

# 5. Copy application source code
COPY . .

# 6. Create reports directory and grant write access to node user
RUN mkdir -p /app/utils/reports \
    && chown -R node:node /app/utils/reports
# 7. Run application as non-root user
USER node

# 8. Document the application port
EXPOSE 5000

# 9. Start the backend application
CMD ["npm", "start"]