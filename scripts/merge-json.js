const fs = require('fs');
const [, , targetPath, sourcePath] = process.argv;

function deepMerge(target, source) {
  const result = { ...target };
  for (const key of Object.keys(source)) {
    const tv = target[key], sv = source[key];
    if (sv !== null && typeof sv === 'object' && !Array.isArray(sv) &&
        tv !== null && typeof tv === 'object' && !Array.isArray(tv)) {
      result[key] = deepMerge(tv, sv);
    } else {
      result[key] = sv;
    }
  }
  return result;
}

let existing = {};
try { existing = JSON.parse(fs.readFileSync(targetPath, 'utf8')); } catch (_) {}
const incoming = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
fs.writeFileSync(targetPath, JSON.stringify(deepMerge(existing, incoming), null, 2) + '\n');
