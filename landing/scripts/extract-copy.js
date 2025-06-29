#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read the copy file
const copyPath = path.join(__dirname, '../lib/copy.ts');
const copyContent = fs.readFileSync(copyPath, 'utf8');

// Extract the copy object (simple regex, could be improved)
const copyMatch = copyContent.match(/export const copy = ({[\s\S]*}) as const/);
if (!copyMatch) {
  console.error('Could not find copy object');
  process.exit(1);
}

// Parse the object (using eval for simplicity - in production use a proper parser)
const copyObj = eval('(' + copyMatch[1] + ')');

// Flatten the object to key-value pairs
function flattenObject(obj, prefix = '') {
  const result = [];
  
  for (const [key, value] of Object.entries(obj)) {
    const newKey = prefix ? `${prefix}.${key}` : key;
    
    if (typeof value === 'string') {
      result.push({
        key: newKey,
        value: value.replace(/"/g, '""'), // Escape quotes for CSV
        type: 'text'
      });
    } else if (Array.isArray(value)) {
      value.forEach((item, index) => {
        if (typeof item === 'string') {
          result.push({
            key: `${newKey}[${index}]`,
            value: item.replace(/"/g, '""'),
            type: 'array-item'
          });
        } else {
          result.push(...flattenObject(item, `${newKey}[${index}]`));
        }
      });
    } else if (typeof value === 'object' && value !== null) {
      result.push(...flattenObject(value, newKey));
    }
  }
  
  return result;
}

const flatCopy = flattenObject(copyObj);

// Generate CSV
const csv = [
  'Key,Current Value,New Value,Notes',
  ...flatCopy.map(item => `"${item.key}","${item.value}","",""`)
].join('\n');

// Write CSV file
const outputPath = path.join(__dirname, '../copy-export.csv');
fs.writeFileSync(outputPath, csv);

console.log(`✅ Copy exported to: ${outputPath}`);
console.log(`📊 Total strings: ${flatCopy.length}`);
console.log('\n📝 Edit the "New Value" column in Excel/Google Sheets');
console.log('💡 Leave blank to keep current value');
console.log('🔄 Run "npm run import-copy" to apply changes'); 