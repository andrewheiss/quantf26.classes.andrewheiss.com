// .box-clr-* boxes (see slides.scss) are inline-block, so when their text
// wraps, the box stretches to the full available width instead of hugging
// the widest wrapped line (a CSS shrink-to-fit limitation, not something
// fixable with CSS alone). Measure the actual rendered line widths here and
// set an explicit width on each box to match.
(function () {
  function fitBox(box) {
    const range = document.createRange();
    range.selectNodeContents(box);
    const rects = Array.from(range.getClientRects());
    if (rects.length === 0) return;
    const scale = window.Reveal && Reveal.getScale ? Reveal.getScale() : 1;
    const maxWidth = Math.max(...rects.map((r) => r.width)) / scale;
    const style = getComputedStyle(box);
    // box-sizing here is content-box (reveal.js's own CSS, not the page's
    // default), so "width" must NOT include padding
    const paddingX =
      style.boxSizing === "border-box"
        ? parseFloat(style.paddingLeft) + parseFloat(style.paddingRight)
        : 0;
    box.style.width = Math.ceil(maxWidth + paddingX) + "px";
  }

  function fitAllBoxes() {
    document.querySelectorAll('[class*="box-clr-"]').forEach(fitBox);
  }

  // Not Reveal.on("ready", ...): Reveal.initialize() already ran earlier in
  // the page by the time this script executes, so that event may fire (and
  // be missed) before we can listen for it. All slides are laid out (not
  // display:none) regardless of which one is current, so window "load" is
  // late enough to measure every box correctly.
  window.addEventListener("load", fitAllBoxes);
})();
