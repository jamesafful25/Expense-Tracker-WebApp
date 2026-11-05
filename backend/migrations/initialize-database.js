const mysql = require('mysql2/promise');
const crypto = require('crypto');

const {
    SecretsManagerClient,
    DescribeSecretCommand,
    GetSecretValueCommand,
    PutSecretValueCommand,
} = require('@aws-sdk/client-secrets-manager');

// INPUT: Migration functions
const {
    createMigrationHistoryTable,
    runPendingMigrations,
} = require('./migration-runner');
// INPUT: Configuration supplied securely by ECS
const requiredVariables = [
    'DB_HOST',
    'DB_PORT',
    'DB_NAME',
    'DB_MASTER_USERNAME',
    'DB_MASTER_PASSWORD',
    'DB_APP_SECRET_ARN',
    'AWS_REGION',
];

for (const variable of requiredVariables) {
    if (!process.env[variable]) {
        throw new Error(`Missing required environment variable: ${variable}`);
    }
}

const dbConfig = {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_MASTER_USERNAME,
    password: process.env.DB_MASTER_PASSWORD,
    database: process.env.DB_NAME,
    connectTimeout: 30000,
};

const secretsClient = new SecretsManagerClient({
    region: process.env.AWS_REGION,
});

// PROCESSING: Retrieve existing application credentials or create them once
const getApplicationCredentials = async() => {
    const secretDetails = await secretsClient.send(
        new DescribeSecretCommand({
            SecretId: process.env.DB_APP_SECRET_ARN,
        })
    );

    const secretVersions = Object.keys(
        secretDetails.VersionIdsToStages || {}
    );

    // RULE: Reuse credentials if the secret already has a version
    if (secretVersions.length > 0) {
        const secretResponse = await secretsClient.send(
            new GetSecretValueCommand({
                SecretId: process.env.DB_APP_SECRET_ARN,
                VersionStage: 'AWSCURRENT',
            })
        );

        const credentials = JSON.parse(secretResponse.SecretString);

        if (
            typeof credentials.username !== 'string' ||
            typeof credentials.password !== 'string' ||
            !credentials.username ||
            !credentials.password
        ) {
            throw new Error('Application database credentials are invalid.');
        }

        console.log('Existing application credentials retrieved.');

        return credentials;
    }

    // TRANSFORM: Generate credentials only when no secret version exists
    const credentials = {
        username: 'expense_app',
        password: crypto.randomBytes(32).toString('base64url'),
    };

    // OUTPUT: Save credentials before applying them to MySQL
    await secretsClient.send(
        new PutSecretValueCommand({
            SecretId: process.env.DB_APP_SECRET_ARN,
            SecretString: JSON.stringify(credentials),
        })
    );

    console.log('New application credentials saved securely.');

    return credentials;
};

// PROCESSING: Ensure the MySQL application user matches Secrets Manager
const configureApplicationUser = async(connection, credentials) => {
    const escapedPassword = connection.escape(credentials.password);

    const escapedUsername = connection.escape(credentials.username);

    const databaseIdentifier = connection.escapeId(process.env.DB_NAME);

    // RULE: Create the user if it does not already exist
    await connection.query(
        `CREATE USER IF NOT EXISTS ${escapedUsername}@'%' IDENTIFIED BY ${escapedPassword}`
    );

    // RULE: Synchronize the MySQL password with the stored credential
    await connection.query(
        `ALTER USER ${escapedUsername}@'%' IDENTIFIED BY ${escapedPassword}`
    );

    // RULE: Grant only the permissions required by the application
    await connection.query(
        `GRANT SELECT, INSERT, UPDATE, DELETE ON ${databaseIdentifier}.* TO ${escapedUsername}@'%'`
    );

    console.log('Application database user configured successfully.');
};

// PROCESSING: Initialize database and execute pending migrations
const initializeDatabase = async() => {
    let connection;

    try {
        // 1. Connect to AWS RDS using master credentials
        connection = await mysql.createConnection(dbConfig);

        console.log('Connected to the database.');

        // 2. Retrieve or generate stable application credentials
        const credentials = await getApplicationCredentials();

        // 3. Configure the restricted MySQL application user
        await configureApplicationUser(connection, credentials);

        // 4. Create the migration history table
        await createMigrationHistoryTable(connection);

        // 5. Execute all migrations that have not yet been applied
        await runPendingMigrations(connection);

        console.log('Database initialization completed successfully.');

    } catch (error) {
        console.error('Database initialization failed:', error.message);
        process.exitCode = 1;

    } finally {
        if (connection) {
            await connection.end();
            console.log('Database connection closed.');
        }

        secretsClient.destroy();
    }
};

// OUTPUT: Start database initialization
initializeDatabase();