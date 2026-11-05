
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

# 6. Create a non-root user for security
USER node

# 7. Document the application port
EXPOSE 5000

# 8. Start the backend application
CMD ["npm", "start"]
