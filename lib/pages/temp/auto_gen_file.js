const fs = require('fs');
const path = require('path');

// Đường dẫn đến thư mục pages
const baseFolder = path.resolve(__dirname, '../');

// Các văn bản thay thế
const stateReplaceText = 'TState';
const newStateReplaceText = '';

const statusReplace = 'TStatus';
const newStatusReplace = 'Status';

const controllerReplaceText = 'BController';
const newControllerReplaceText = 'Controller';

const bindingReplaceText = 'BBinding';
const newBindingReplaceText = 'Binding';

const viewReplaceText = 'View';
const pageReplaceText = ' Page';
const newPageReplaceText = 'Page';

const parameterReplace = 'Parameter';

const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});

readline.question('Enter your new folder name: ', name => {
    // Tạo thư mục mới trong thư mục pages
    const newFolderPath = path.join(baseFolder, name);
    fs.mkdirSync(newFolderPath, { recursive: true });
    onReadAndCreateListFile(name, newFolderPath);

    console.log('Create successfully in', newFolderPath);
    readline.close();
});

function onReadAndCreateListFile(name, outputDir) {
    const className = getClassNameFromFile(name);

    // Thay thế văn bản từ tệp mẫu và lưu vào thư mục đầu ra
    replaceAllTextFromFile('_controller.dart', className, name, outputDir);
    replaceAllTextFromFile('_binding.dart', className, name, outputDir);
    replaceAllTextFromFile('_page.dart', className, name, outputDir);
    replaceAllTextFromFile('_parameter.dart', className, name, outputDir);
}

function replaceAllTextFromFile(fileName, className, newFileName, outputDir) {
    // Đọc nội dung từ tệp mẫu
    const templatePath = path.join(__dirname, fileName);
    let content = fs.readFileSync(templatePath).toString();

    // Thay thế các biến trong nội dung
    content = content.replaceAll(stateReplaceText, className + newStateReplaceText);
    content = content.replaceAll(statusReplace, className + newStatusReplace);
    content = content.replaceAll(controllerReplaceText, className + newControllerReplaceText);
    content = content.replaceAll(bindingReplaceText, className + newBindingReplaceText);
    content = content.replaceAll(viewReplaceText, className + viewReplaceText);
    content = content.replaceAll(pageReplaceText, ' ' + className + newPageReplaceText);
    content = content.replaceAll(parameterReplace, className + parameterReplace);

    // Lưu nội dung đã thay thế vào tệp mới trong thư mục đầu ra
    const filePath = path.join(outputDir, `${newFileName}${path.basename(fileName)}`);
    fs.writeFileSync(filePath, content);
}

function getClassNameFromFile(name) {
    const split = name.split('_');
    const newName = split.reduce((pre, cur) => {
        return pre + cur[0].toUpperCase() + cur.slice(1);
    }, '');
    return newName[0].toUpperCase() + newName.slice(1);
}
