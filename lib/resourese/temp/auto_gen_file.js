const fs = require('fs');
const path = require('path');

// Đường dẫn gốc (thư mục chứa repositories)
const baseFolder = path.resolve(__dirname, '../');

const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

readline.question('Enter your repository name (e.g. auth, user, product): ', name => {
    const newFolderPath = path.join(baseFolder, name);
    fs.mkdirSync(newFolderPath, { recursive: true });

    onReadAndCreateRepositoryFiles(name, newFolderPath);

    console.log('✅ Repository created successfully in', newFolderPath);
    readline.close();
});

// ─── Main ──────────────────────────────────────────────────────
function onReadAndCreateRepositoryFiles(name, outputDir) {
    const className = getClassNameFromFile(name); // e.g. "auth" → "Auth"

    createRepositoryFile(className, name, outputDir);
    createIRepositoryFile(className, name, outputDir);
}

// ─── Tạo auth_repository.dart ─────────────────────────────────
function createRepositoryFile(className, name, outputDir) {
    const templatePath = path.join(__dirname, '_repository.dart');
    let content = fs.readFileSync(templatePath).toString();

    content = content.replaceAll('TName', className);
    content = content.replaceAll('itname', `i${name}`);

    const filePath = path.join(outputDir, `${name}_repository.dart`);
    fs.writeFileSync(filePath, content);
    console.log('  📄 Created:', path.basename(filePath));
}

// ─── Tạo iauth_repository.dart ────────────────────────────────
function createIRepositoryFile(className, name, outputDir) {
    const templatePath = path.join(__dirname, '_irepository.dart');
    let content = fs.readFileSync(templatePath).toString();

    content = content.replaceAll('TName', className);

    const filePath = path.join(outputDir, `i${name}_repository.dart`);
    fs.writeFileSync(filePath, content);
    console.log('  📄 Created:', path.basename(filePath));
}

// ─── Util: snake_case → PascalCase ────────────────────────────
function getClassNameFromFile(name) {
    const split = name.split('_');
    const newName = split.reduce((pre, cur) => {
        return pre + cur[0].toUpperCase() + cur.slice(1);
    }, '');
    return newName[0].toUpperCase() + newName.slice(1);
}