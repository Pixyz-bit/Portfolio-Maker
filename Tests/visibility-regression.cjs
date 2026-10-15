// Exercise actual production handlers with a small event-bubbling DOM, including
// the nested card -> anchor click which caused the original double-guard failure.
const fs = require('fs'), vm = require('vm'), assert = require('assert/strict');
const source = fs.readFileSync('241611JalopPersonalWebsite/Frontend/Assets/js/user-menu.js', 'utf8');
function fixture(isPublic) {
  const timers = []; let submissions = 0;
  function element(classes = []) {
    const values = new Set(classes), listeners = {}, attributes = {};
    return { parent: null, attributes, textContent: '',
      classList: { contains: x => values.has(x), add: x => values.add(x), remove: x => values.delete(x),
        toggle(x, on = !values.has(x)) { if (on) values.add(x); else values.delete(x); } },
      addEventListener(type, fn) { (listeners[type] ||= []).push(fn); },
      setAttribute(key, value) { attributes[key] = value; }, removeAttribute(key) { delete attributes[key]; },
      contains(node) { return node === this || (!!node.parent && this.contains(node.parent)); },
      dispatch(type, target = this, key) {
        const event = { target, key, defaultPrevented: false, preventDefault() { this.defaultPrevented = true; } };
        for (let node = this; node; node = node.parent) for (const fn of node.listeners?.[type] || []) fn(event);
        return event;
      }, listeners,
      click() { const event = this.dispatch('click'); if (this === button && !event.defaultPrevented) submissions++; }
    };
  }
  const card = element(), button = element(), track = element(), dot = element(isPublic ? ['dot-public'] : ['dot-private']), label = element();
  label.textContent = isPublic ? 'Public Portfolio' : 'Private Portfolio';
  button.parent = card;
  card.querySelector = selector => ({ '.visibility-toggle-btn': button, '.toggle-track': track, '.status-indicator-dot': dot, '.visibility-status-text': label })[selector];
  const document = { readyState: 'loading', getElementById: id => id === 'menuVisibilityCard' ? card : null,
    querySelector: () => null, addEventListener() {} };
  vm.runInNewContext(source, { document, window: { addEventListener() {}, setTimeout(fn) { timers.push(fn); } }, sessionStorage: { setItem() {} } });
  return { card, button, label, timers, submissions: () => submissions };
}
let passed = 0;
for (const initial of [true, false]) {
  for (const action of ['card', 'button', 'space']) {
    const f = fixture(initial), label = f.label.textContent;
    if (action === 'space') f.button.dispatch('keydown', f.button, ' ');
    else f[action].click();
    assert.equal(f.submissions(), 1, `${action} submits exactly once`);
    assert.equal(f.label.textContent, label, 'status stays confirmed until server response');
    assert.equal(f.button.attributes['aria-checked'], String(initial));
    assert.equal(f.card.attributes['aria-busy'], 'true');
    f.button.click(); assert.equal(f.submissions(), 1, 'double submission blocked');
    f.timers[0](); f.button.click(); assert.equal(f.submissions(), 2, 'failed navigation permits retry');
    passed += 6;
  }
}
console.log(`PASS: ${passed} visibility interaction assertions.`);
