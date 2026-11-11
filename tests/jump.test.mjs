import assert from 'node:assert/strict';
import { test } from 'node:test';
import { jump } from '../mods/omarchy-tabs/jump.js';

const items = (...statuses) => statuses.map((status, i) => ({ id: i, status, cur: false }));
const at = (list, i) => { list[i].cur = true; return list; };
const isCur = x => x.cur;

test('skips to the next running or blocked item, wrapping', () => {
  const list = at(items('working', null, 'idle', 'blocked', null), 3);
  assert.equal(jump(list, isCur, 1).id, 0);
  assert.equal(jump(list, isCur, -1).id, 0);
});

test('done and idle do not count as running', () => {
  const list = at(items(null, 'done', 'idle', 'working'), 0);
  assert.equal(jump(list, isCur, 1).id, 3);
});

test('falls back to every item when no other one is running', () => {
  const list = at(items(null, 'working', null), 1);
  assert.equal(jump(list, isCur, 1).id, 2);
  assert.equal(jump(list, isCur, -1).id, 0);
});

test('starts from the edge when nothing is current', () => {
  const list = items(null, 'working', 'blocked');
  assert.equal(jump(list, isCur, 1).id, 1);
  assert.equal(jump(list, isCur, -1).id, 2);
});

test('returns null for an empty list', () => {
  assert.equal(jump([], isCur, 1), null);
});
