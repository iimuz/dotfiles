(function () {
  'use strict';

  const STORAGE_KEY = 'vivify-theme';
  const isLight = sessionStorage.getItem(STORAGE_KEY) === 'light';

  // client.mjs は読み込み時の matchMedia でだけ Mermaid のテーマを決めるため、
  // それより先に dark の問い合わせの結果を固定する。
  const originalMatchMedia = window.matchMedia.bind(window);
  window.matchMedia = function (query) {
    if (query.replace(/\s/g, '') === '(prefers-color-scheme:dark)') {
      return originalMatchMedia(isLight ? 'not all' : 'all');
    }
    return originalMatchMedia(query);
  };

  // colors.css は light の値を media rule で上書きしているので、その条件を固定する。
  let lightRuleCount = 0;
  for (const sheet of document.styleSheets) {
    let rules;
    try {
      rules = sheet.cssRules;
    } catch (e) {
      continue;
    }
    for (const rule of rules) {
      if (
        rule instanceof CSSMediaRule &&
        /prefers-color-scheme\s*:\s*light/.test(rule.media.mediaText)
      ) {
        rule.media.mediaText = isLight ? 'all' : 'not all';
        lightRuleCount += 1;
      }
    }
  }
  if (lightRuleCount === 0) {
    console.warn('theme-toggle: light color rule not found; body colors unchanged');
  }

  // Mermaid のテーマは読み込み時にしか決まらないので、切り替えはページごと読み込み直す。
  document.addEventListener('keydown', function (event) {
    const target = event.target;
    if (
      event.key !== 't' ||
      event.ctrlKey ||
      event.altKey ||
      event.metaKey ||
      target.isContentEditable ||
      /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName)
    ) {
      return;
    }
    sessionStorage.setItem(STORAGE_KEY, isLight ? 'dark' : 'light');
    location.reload();
  });
})();
