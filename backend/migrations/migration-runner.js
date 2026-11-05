const fs = require('fs');
const path = require('path');

// PROCESSING: Create migration history table if it does not exist

const createMigrationHistoryTable = async(connection) => {
    await connection.query(`
        CREATE TABLE IF NOT EXISTS schema_migrations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            migration VARCHAR(255) NOT NULL UNIQUE,
            applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB
          DEFAULT CHARSET=utf8mb4
          COLLATE=utf8mb4_unicode_ci
    `);

    console.log('Migration history table is ready.');
};

// PROCESSING: Retrieve previously applied migrations
const getAppliedMigrations = async(connection) => {
    const [rows] = await connection.query(
        'SELECT migration FROM schema_migrations'
    );

    return rows.map(row => row.migration);
};

// PROCESSING: Discover available SQL migration files
const getMigrationFiles = () => {
    const files = fs.readdirSync(__dirname);

    return files
        .filter(file => file.endsWith('.sql'))
        .sort();
};

// PROCESSING: Execute migrations that have not been applied
const runPendingMigrations = async(connection) => {
    const appliedMigrations = await getAppliedMigrations(connection);

    const migrationFiles = getMigrationFiles();

    for (const file of migrationFiles) {

        // RULE: Skip migrations already recorded in the database
        if (appliedMigrations.includes(file)) {
            console.log(`Skipping already applied migration: ${file}`);
            continue;
        }

        console.log(`Running migration: ${file}`);

        // 1. Read the SQL migration file
        const migrationPath = path.join(__dirname, file);

        const sql = fs.readFileSync(migrationPath, 'utf8');

        // 2. Split SQL into individual statements
        const statements = sql
            .split(';')
            .map(statement => statement.trim())
            .filter(statement => statement.length > 0);

        // 3. Execute each SQL statement
        for (const statement of statements) {
            await connection.query(statement);
        }

        // 4. Record migration only after successful execution
        await connection.query(
            'INSERT INTO schema_migrations (migration) VALUES (?)', [file]
        );

        console.log(`Migration completed successfully: ${file}`);
    }

    console.log('All database migrations have been processed.');
};

// OUTPUT: Make migration functions available to other modules
module.exports = {
    createMigrationHistoryTable,
    runPendingMigrations,
};