const http = require('http');
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, 'build', 'web');
const port = Number(process.env.PORT || 7358);

const contentTypes = {
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.ico': 'image/x-icon',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
};

http
  .createServer((request, response) => {
    const requestPath = decodeURIComponent(request.url.split('?')[0]);
    const relativePath = requestPath === '/' ? 'index.html' : requestPath.slice(1);
    let filePath = path.resolve(root, relativePath);

    if (!filePath.startsWith(path.resolve(root))) {
      response.writeHead(403);
      response.end('Forbidden');
      return;
    }

    if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
      filePath = path.join(root, 'index.html');
    }

    response.writeHead(200, {
      'Content-Type':
        contentTypes[path.extname(filePath).toLowerCase()] ||
        'application/octet-stream',
      'Cache-Control': 'no-store, no-cache, must-revalidate',
    });
    fs.createReadStream(filePath).pipe(response);
  })
  .listen(port, '127.0.0.1', () => {
    console.log(`Admissions Compass: http://127.0.0.1:${port}`);
  });
