const http = require('http');
const { Plugin } = require('obsidian');

const PORT = 38622;
const HOST = '127.0.0.1';

module.exports = class TabSwitcherBridge extends Plugin {
  onload() {
    this.leafIds = new WeakMap();
    this.nextLeafId = 1;
    this.server = http.createServer((request, response) => {
      try {
        this.handle(request, response);
      } catch (error) {
        this.json(response, 500, { ok: false, error: String(error) });
      }
    });

    this.server.on('error', (error) => console.error('TabSwitcher bridge:', error));
    this.server.listen(PORT, HOST);
    this.register(() => this.close());
  }

  onunload() {
    this.close();
  }

  close() {
    if (!this.server) return;

    this.server.close();
    this.server = undefined;
  }

  leaves() {
    const leaves = [];

    this.app.workspace.iterateAllLeaves((leaf) => leaves.push(leaf));

    return leaves;
  }

  idFor(leaf) {
    let id = this.leafIds.get(leaf);

    if (!id) {
      id = String(this.nextLeafId++);
      this.leafIds.set(leaf, id);
    }

    return id;
  }

  tabs() {
    return this.leaves()
      .map((leaf) => ({
        id: this.idFor(leaf),
        title: leaf.getDisplayText ? leaf.getDisplayText() : '',
        active: leaf === this.app.workspace.activeLeaf,
      }))
      .filter((item) => item.title);
  }

  focus(id) {
    const leaf = this.leaves().find((candidate) => this.idFor(candidate) === id);
    if (!leaf) return false;

    this.app.workspace.setActiveLeaf(leaf, { focus: true });

    try {
      this.app.workspace.revealLeaf(leaf);
    } catch (error) {
      console.error('TabSwitcher bridge:', error);
    }

    return true;
  }

  json(response, status, value) {
    const body = JSON.stringify(value);

    response.writeHead(status, {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
    });
    response.end(body);
  }

  handle(request, response) {
    const url = new URL(request.url, `http://${HOST}:${PORT}`);

    if (request.method === 'GET' && url.pathname === '/tabs') {
      this.json(response, 200, this.tabs());
      return;
    }

    if (request.method === 'GET' && url.pathname === '/focus') {
      const focused = this.focus(url.searchParams.get('id') || '');
      this.json(response, focused ? 200 : 404, { ok: focused });
      return;
    }

    this.json(response, 404, { ok: false, error: 'not found' });
  }
};
