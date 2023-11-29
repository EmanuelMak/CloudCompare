# Stage 1: Build the TypeScript Lambda function
FROM --platform=linux/amd64 node:14 as builder

WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the code
COPY . .

# Build TypeScript to JavaScript
RUN npm run build

# Stage 2: Setup the runtime environment
FROM public.ecr.aws/lambda/nodejs:14

# Copy function code and runtime dependencies from builder
COPY --from=builder /usr/src/app/dist ${LAMBDA_TASK_ROOT}
COPY --from=builder /usr/src/app/node_modules ${LAMBDA_TASK_ROOT}/node_modules

# Set the CMD to your handler
CMD ["createTable.handler"]
