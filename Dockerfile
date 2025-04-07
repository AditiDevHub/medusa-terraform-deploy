# Use Node.js 20 as the base image
FROM node:20

# Set working directory
WORKDIR /app

# Copy project files to container
COPY . .

# Install dependencies
RUN yarn install

# Expose the Medusa backend default port
EXPOSE 9000

# Start the Medusa server
CMD ["yarn", "start"]

