const sharp = require('sharp');
const fs = require('fs');

async function convert() {
    try {
        await sharp('test/jadeE.svg')
            .png()
            .toFile('assets/images/logo.png');
        console.log('Successfully converted SVG to PNG');
    } catch (err) {
        console.error('Error:', err);
    }
}

convert();
