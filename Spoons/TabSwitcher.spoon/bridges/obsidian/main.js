const http = require('http');
const { Plugin, TFile } = require('obsidian');

const PORT = 38622;
const HOST = '127.0.0.1';
const RECENT_LIMIT = 10;

module.exports = class TabSwitcherBridge extends Plugin {
  onload() {
    this.leafIds = new WeakMap();
    this.nextLeafId = 1;
    this.server = http.createServer((request, response) => {
      this.handle(request, response).catch((error) => {
        this.json(response, 500, { ok: false, error: String(error) });
      });
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

  isMainLeaf(leaf) {
    if (typeof leaf.getRoot !== 'function') return false;

    const workspace = this.app.workspace;
    const root = leaf.getRoot();

    return root === workspace.rootSplit
      || (workspace.floatingSplit != null && root === workspace.floatingSplit);
  }

  activeMainLeaf() {
    const active = this.app.workspace.activeLeaf;
    if (active && this.isMainLeaf(active)) return active;

    return this.app.workspace.getMostRecentLeaf(this.app.workspace.rootSplit) || null;
  }

  leaves() {
    const leaves = [];

    this.app.workspace.iterateAllLeaves((leaf) => {
      if (this.isMainLeaf(leaf)) leaves.push(leaf);
    });

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

  pathFor(leaf) {
    if (typeof leaf.getViewState !== 'function') return null;

    const state = leaf.getViewState();
    const path = state && state.state && state.state.file;

    return typeof path === 'string' && path !== '' ? path : null;
  }

  leafId(leaf) {
    const path = this.pathFor(leaf);

    return path ? `file:${path}` : `leaf:${this.idFor(leaf)}`;
  }

  fileFor(path) {
    const file = this.app.vault.getAbstractFileByPath(path);

    return file instanceof TFile ? file : null;
  }

  tabs() {
    const active = this.activeMainLeaf();
    const openPaths = new Set();
    const items = [];

    for (const leaf of this.leaves()) {
      const title = leaf.getDisplayText ? leaf.getDisplayText() : '';
      if (!title) continue;

      const path = this.pathFor(leaf);
      if (path) openPaths.add(path);

      items.push({
        id: this.leafId(leaf),
        title,
        active: leaf === active,
      });
    }

    const recent = typeof this.app.workspace.getLastOpenFiles === 'function'
      ? this.app.workspace.getLastOpenFiles()
      : [];

    for (const path of recent.slice(0, RECENT_LIMIT)) {
      if (openPaths.has(path)) continue;

      const file = this.fileFor(path);
      if (!file) continue;

      openPaths.add(path);
      items.push({
        id: `file:${path}`,
        title: file.basename || file.name || path,
        active: false,
        context: '[Recent]',
      });
    }

    return items;
  }

  reveal(leaf) {
    this.app.workspace.setActiveLeaf(leaf, { focus: true });

    try {
      this.app.workspace.revealLeaf(leaf);
    } catch (error) {
      console.error('TabSwitcher bridge:', error);
    }
  }

  async openPath(path) {
    const file = this.fileFor(path);
    if (!file) return false;

    const leaf = this.app.workspace.getLeaf('tab');
    await leaf.openFile(file, { active: true });
    this.reveal(leaf);

    return true;
  }

  async focus(id) {
    if (id.startsWith('file:')) {
      const path = id.slice(5);
      const leaf = this.leaves().find((candidate) => this.pathFor(candidate) === path);

      if (leaf) {
        this.reveal(leaf);
        return true;
      }

      return this.openPath(path);
    }

    const leafId = id.startsWith('leaf:') ? id.slice(5) : id;
    const leaf = this.leaves().find((candidate) => this.idFor(candidate) === leafId);
    if (!leaf) return false;

    this.reveal(leaf);
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

  async handle(request, response) {
    const url = new URL(request.url, `http://${HOST}:${PORT}`);

    if (request.method === 'GET' && url.pathname === '/tabs') {
      this.json(response, 200, this.tabs());
      return;
    }

    if (request.method === 'GET' && url.pathname === '/focus') {
      const focused = await this.focus(url.searchParams.get('id') || '');
      this.json(response, focused ? 200 : 404, { ok: focused });
      return;
    }

    this.json(response, 404, { ok: false, error: 'not found' });
  }
};
