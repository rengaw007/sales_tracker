# Use an official Node.js runtime as a parent image
FROM node:18-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the package.json file and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application files
COPY . .

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Define the command to run the app
CMD [ "npm", "start" ]
