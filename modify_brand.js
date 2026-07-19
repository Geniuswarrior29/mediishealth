const fs = require('fs');
const path = require('path');

const directory = __dirname;
const files = fs.readdirSync(directory).filter(file => file.endsWith('.html'));

files.forEach(file => {
    const filePath = path.join(directory, file);
    const content = fs.readFileSync(filePath, 'utf8');
    let newContent = content;

    // 1. Replace "Mediis Health Ayurveda" -> "Mediis Health and Lab"
    newContent = newContent.replace(/Mediis Health Ayurveda/g, 'Mediis Health and Lab');

    // 2. Replace "Mediis Health" -> "Mediis Health and Lab"
    // Using a regex to replace "Mediis Health" not followed by " and Lab"
    newContent = newContent.replace(/Mediis Health(?!\s+and Lab)/g, 'Mediis Health and Lab');

    // 3. Replace the SVG Logo in the header
    const svgRegex = /<svg width="32" height="32" viewBox="0 0 24 24" fill="var\(--primary\)"><path d="M11 2v4c0 1\.1-\.9 2-2 2H5v4h4c1\.1 0 2 \.9 2 2v4h2v-4c0-1\.1\.9-2 2-2h4v-4h-4c-1\.1 0-2-\.9-2-2V2h-2z"\/><\/svg>/g;
    const imgTag = '<img src="logo.jpg" alt="Mediis Health and Lab Logo" style="height: 40px; margin-right: 10px; vertical-align: middle;">';
    newContent = newContent.replace(svgRegex, imgTag);

    // 4. Update the Footer Logo
    const footerLogoRegex = /(<a[^>]*class="logo"[^>]*>)\s*Mediis Health and Lab\s*<\/a>/g;
    const footerLogoReplacement = '$1\n                        <img src="logo.jpg" alt="Mediis Health and Lab Logo" style="height: 30px; margin-right: 10px; vertical-align: middle;">Mediis Health and Lab</a>';
    newContent = newContent.replace(footerLogoRegex, footerLogoReplacement);

    // 5. Remove accept="image/*" for the file upload
    newContent = newContent.replace(/accept="image\/\*"/g, '');

    if (content !== newContent) {
        fs.writeFileSync(filePath, newContent, 'utf8');
        console.log(`Updated ${file}`);
    }
});
console.log('Done');
