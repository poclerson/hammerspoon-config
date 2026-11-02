const http = require('http');
const vscode = require('vscode');

const PORT = 38621;
const HOST = '127.0.0.1';

let server;

function tabs() {
  const items = [];
  const activeGroup = vscode.window.tabGroups.activeTabGroup;

  for (const group of vscode.window.tabGroups.all) {
    for (const tab of group.tabs) {
      if (!(tab.input instanceof vscode.TabInputText)) continue;

      items.push({
        id: `${group.viewColumn}|${tab.input.uri.toString()}`,
        title: tab.label,
        active: group === activeGroup && tab.isActive,
      });
    }
  }

  return items;
}

async function focus(id) {
  const separator = id.indexOf('|');
  if (separator < 0) return false;

  const viewColumn = Number(id.slice(0, separator));
  const uri = vscode.Uri.parse(id.slice(separator + 1));

  await vscode.window.showTextDocument(uri, {
    viewColumn,
    preview: false,
    preserveFocus: false,
  });

  return true;
}

function json(response, status, value) {
  const body = JSON.stringify(value);

  response.writeHead(status, {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body),
  });
  response.end(body);
}

function handle(request, response) {
  const url = new URL(request.url, `http://${HOST}:${PORT}`);

  if (request.method === 'GET' && url.pathname === '/tabs') {
    json(response, 200, tabs());
    return;
  }

  if (request.method === 'GET' && url.pathname === '/focus') {
    focus(url.searchParams.get('id') || '').then(
      () => json(response, 200, { ok: true }),
      (error) => json(response, 500, { ok: false, error: String(error) })
    );
    return;
  }

  json(response, 404, { ok: false, error: 'not found' });
}

function activate(context) {
  server = http.createServer((request, response) => {
    try {
      handle(request, response);
    } catch (error) {
      json(response, 500, { ok: false, error: String(error) });
    }
  });

  server.on('error', (error) => console.error('TabSwitcher bridge:', error));
  server.listen(PORT, HOST);

  context.subscriptions.push({
    dispose() {
      if (server) server.close();
    },
  });
}

function deactivate() {
  if (server) {
    server.close();
    server = undefined;
  }
}

module.exports = { activate, deactivate };
