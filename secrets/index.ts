import fs from "fs";
import yaml from "js-yaml";
import { spawnSync, execSync } from "child_process";


type SecretsData = { [key: string]: SecretsData } | string | null | undefined;

// Constants for the application
const appName = "thesisCloudCompare";
const vltCommand = "vlt";
const shellScriptPath = ".envrc";

/**
 * Updates Vault secrets based on the given YAML file paths.
 * 
 * @param filePaths The paths to the YAML files containing the secrets.
 */
async function updateVaultSecrets(filePaths: string[]): Promise<void> {
    for (const filePath of filePaths) {
        const yamlData = loadSecretsFromYaml(filePath);
        await processYaml(yamlData, "");
    }
}

/**
 * Loads and parses a YAML file into a SecretsData object.
 * 
 * @param filePath The path to the YAML file.
 * @returns A SecretsData object containing the parsed data.
 */
function loadSecretsFromYaml(filePath: string): SecretsData {
    if (!fs.existsSync(filePath)) {
        console.error(`File ${filePath} does not exist.`);
        process.exit(1);
    }

    const data = fs.readFileSync(filePath, "utf8");
    return yaml.load(data) as SecretsData;
}

/**
 * Recursively processes YAML data to update or add secrets in Vault.
 * 
 * @param yamlData The YAML data to process.
 * @param path The path used for nested objects within the YAML data.
 */
async function processYaml(yamlData: SecretsData, path: string): Promise<void> {
    if (!yamlData) {
        console.log(`Skipping ${path} as it has no entries.`);
        return;
    }

    if (typeof yamlData === "object") {
        const promises = Object.keys(yamlData).map(entryName => {
            const nextPath = path ? `${path}_${entryName}` : entryName;
            return processYaml(yamlData[entryName], nextPath);
        });

        await Promise.all(promises);
    } else {
        await updateOrAddSecrets(path.toUpperCase(), String(yamlData));
    }
}

/**
 * Checks for the existence of a secret in Vault and updates or creates it as necessary.
 * 
 * @param secretName The name of the secret to update or create.
 * @param secretValue The value of the secret.
 */
async function updateOrAddSecrets(secretName: string, secretValue: string): Promise<void> {
    const checkResult = executeVltCommand(["secrets", "get", "--app-name", appName, secretName]);

    if (checkResult.status !== 0 && checkResult.stderr) {
        console.error(`Error checking secret ${secretName}: ${checkResult.stderr}`);
        return;
    }

    const action = checkResult.status === 0 ? "update" : "create";
    const result = executeVltCommand(["secrets", action, "--app-name", appName, secretName, secretValue]);

    if (result.status !== 0 && result.stderr) {
        console.error(`Error ${action}ing secret ${secretName}: ${result.stderr}`);
        return;
    }

    console.log(`${action.charAt(0).toUpperCase() + action.slice(1)}d secret ${secretName}`);
}

/**
 * Generate shell commands to set local environment from secrets YAML.
 */
function generateShellCommands(yamlData: SecretsData, path: string): string[] {
    let commands: string[] = [];

    if (typeof yamlData === "object") {
        for (const entryName in yamlData) {
            const currentPath = path ? `${path}_${entryName}` : entryName;
            if (yamlData[entryName] !== null) {
                if (typeof yamlData[entryName] === "object") {
                    // If the value is an object, recursively generate shell commands
                    commands = commands.concat(generateShellCommands(yamlData[entryName], currentPath));
                } else {
                    // If the value is not an object, generate a single shell command
                    commands.push(`export ${currentPath.toUpperCase()}="${yamlData[entryName]}"`);
                }
            }
        }
    } else if (yamlData !== null) {
        // If yamlData is not an object and not null, generate a single shell command
        commands.push(`export ${path.toUpperCase()}="${yamlData}"`);
    }

    return commands;
}

/**
 * Create a shell script to set environment variables from specified secrets YAML files.
 */
function setLocalEnvironment(filePaths: string[]) {
    let allCommands: string[] = []; // Explicitly define the type as string[]

    filePaths.forEach(filePath => {
        const yamlData = loadSecretsFromYaml(filePath);
        allCommands = allCommands.concat(generateShellCommands(yamlData, ""));
    });

    // Sort the commands alphabetically
    allCommands.sort();

    const shellScriptContent = "#!/bin/bash\n\n# Auto-generated script to set environment variables from YAML files\n\n" + allCommands.join('\n');

    fs.writeFileSync(shellScriptPath, shellScriptContent, "utf8");
    console.log(
        `Environment script saved to ${shellScriptPath}. Execute with 'source ${shellScriptPath}'.`
    );
}

/**
 * Delete a secret from Vault.
 */
function removeSecretFromVault(secretName: string): void {
    const deleteResult = executeVltCommand(["secrets", "delete", "--app-name", appName, secretName]);

    if (deleteResult.status !== 0 && deleteResult.stderr) {
        console.error(`Error deleting secret ${secretName}: ${deleteResult.stderr}`);
        return;
    }

    console.log(`Deleted secret ${secretName}`);
}

/**
 * Recursively process the YAML and delete secrets from Vault.
 */
function deleteSecrets(yamlData: SecretsData, path: string): void {
    if (!yamlData) {
        console.log(`Skipping ${path} no entries`);
        return;
    }

    if (typeof yamlData === "object") {
        Object.keys(yamlData).forEach((entryName) => {
            const nextPath = path ? `${path}_${entryName}` : entryName;
            deleteSecrets(yamlData[entryName], nextPath);
        });
    } else {
        removeSecretFromVault(path.toUpperCase());
    }
}

function executeVltCommand(args: string[]): { stdout: string; stderr: string; status: number } {
    const result = spawnSync(vltCommand, args, { encoding: "utf8" });
    const { stdout = "", stderr = "" } = result;

    if (result.status === null) {
        console.error(`Command failed with no exit status. Error: ${stderr}`);
        return { stdout, stderr, status: -1 }; // Use -1 or any other value as a default
    }

    return { stdout, stderr, status: result.status };
}


/**
 * Delete all secrets from Vault based on the YAML files provided.
 * 
 * @param filePaths Array of file paths to YAML files containing the secrets to delete.
 */
function deleteAllVaultSecrets(filePaths: string[]): void {
    filePaths.forEach(filePath => {
        const yamlData = loadSecretsFromYaml(filePath);
        deleteSecrets(yamlData, "");
    });
}




// fetch vault secrets and set environment variables
type SecretValues = { [key: string]: string };

/**
 * Fetches secrets from VLT and loads data from YAML files, then generates .envrc file.
 * Prioritizes file-provided secrets over VLT secrets in case of duplicates.
 * 
 * @param filePaths Array of file paths to YAML files.
 */
async function fetchAndGenerateEnv(filePaths: string[]): Promise<void> {
    // Load YAML data first
    let fileProvidedSecrets: SecretValues = {};
    for (const filePath of filePaths) {
        const data = loadSecretsFromYaml(filePath);
        if (typeof data === 'object' && data !== null) {
            const flattenedData = flattenObject(data); // Flatten nested objects
            fileProvidedSecrets = { ...fileProvidedSecrets, ...flattenedData };
        }
    }

    // Fetch secrets from VLT
    const vltSecrets = await fetchVltSecrets(fileProvidedSecrets);

    // Delete existing .envrc file if it exists
    if (fs.existsSync(shellScriptPath)) {
        fs.unlinkSync(shellScriptPath);
    }

    // Merge and sort the secrets
    const allSecrets: SecretValues = { ...vltSecrets, ...fileProvidedSecrets };
    const sortedKeys = Object.keys(allSecrets).sort();

    // Generate .envrc file content
    const envContent = sortedKeys.map(key => `export ${key.toUpperCase()}="${allSecrets[key]}"`).join('\n');
    fs.writeFileSync(shellScriptPath, envContent, "utf8");
    console.log(`.envrc file generated at ${shellScriptPath}`);
}

function flattenObject(obj: Record<string, any>, prefix = ''): SecretValues {
    return Object.keys(obj).reduce((acc, k) => {
        const pre = prefix.length ? prefix + '_' : '';
        if (obj[k] === null || obj[k] === undefined || (typeof obj[k] === 'object' && Object.keys(obj[k]).length === 0)) {
            // Skip null, undefined, or empty objects
            return acc;
        } else if (typeof obj[k] === 'object') {
            Object.assign(acc, flattenObject(obj[k], pre + k));
        } else {
            acc[pre + k] = obj[k];
        }
        return acc;
    }, {} as SecretValues);
}



/**
 * Executes a shell command and returns the output as a string.
 * 
 * @param command The command to execute.
 * @returns The output of the command.
 */
function executeCommand(command: string): string {
    try {
        const output = execSync(command, { encoding: 'utf8' });
        return output;
    } catch (error) {
        console.error(`Error executing command: ${command}`, error);
        return '';
    }
}

// Function to recursively extract keys from a nested object
function extractKeys(obj: any, prefix: string = ''): string[] {
    return Object.entries(obj).flatMap(([key, value]) => {
        const newKey = prefix ? `${prefix}_${key}` : key;
        return value && typeof value === 'object' && !Array.isArray(value)
            ? extractKeys(value, newKey)
            : newKey;
    });
}

/**
 * Fetches secrets from VLT, skipping those already provided by files.
 * 
 * @param fileSecrets Secrets already provided by files.
 * @returns An object containing the secrets with their names as keys.
 */
async function fetchVltSecrets(fileSecrets: SecretValues): Promise<SecretValues> {
    const secretsListCmd = 'vlt secrets --format json';
    const secretsListOutput = executeCommand(secretsListCmd);
    const secrets = JSON.parse(secretsListOutput);
    let secretsValues: SecretValues = {};

    // Create an array of lowercase secret names from file-provided secrets
    const fileSecretKeys = extractKeys(fileSecrets);
    const fileSecretNamesLower = fileSecretKeys.map(key => key.toLowerCase());

    let skippedSecrets: string[] = [];

    for (const secret of secrets) {
        const secretNameLower = secret.name.toLowerCase();

        if (fileSecretNamesLower.includes(secretNameLower)) {
            skippedSecrets.push(secret.name);
        } else {
            const secretValueCmd = `vlt secrets get --plaintext ${secret.name}`;
            const secretValue = executeCommand(secretValueCmd).trim();
            secretsValues[secret.name] = secretValue;
            console.log(`Fetched secret: ${secret.name}`);
        }
    }

    if (skippedSecrets.length > 0) {
        console.log(`Skipped secrets (already file provided): ${skippedSecrets.join(', ')}`);
    }

    return secretsValues;
}


/**
 * Main script execution.
 * Determines the action to perform based on command-line arguments.
 */
(async () => {
    const [, , command, ...filePaths] = process.argv;
    try {
        switch (command) {
            case "updateVault":
                if (filePaths.length === 0) {
                    console.error('No file paths provided for updateVault.');
                    process.exit(1);
                }
                await updateVaultSecrets(filePaths);
                break;
            case "setEnvLocal":
                setLocalEnvironment(filePaths);
                break;
            case "deleteVaultSecrets":
                deleteAllVaultSecrets(filePaths);
                break;
            case "fetchAndGenerateEnv":
                fetchAndGenerateEnv(filePaths);
                break;
            default:
                console.error("Invalid command.");
                process.exit(1);
        }
    } catch (error) {
        console.error("An error occurred:", error);
    }
})();
