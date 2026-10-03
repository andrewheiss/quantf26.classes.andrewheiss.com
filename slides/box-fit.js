// .box-clr-* boxes (see slides.scss) are inline-block, so when their text
// wraps, the box stretches to the full available width instead of hugging
// the widest wrapped line (a CSS shrink-to-fit limitation, not something
// fixable with CSS alone). Measure the actual rendered line widths here and
// set an explicit width on each box to match.
(function () {
  function fitBox(box) {
    const range = document.createRange();
    range.selectNodeContents(box);
    const rects = Array.from(range.getClientRects()).filter((r) => r.width > 0);
    if (rects.length === 0) return;
    // getClientRects() returns one rect per text/element fragment, not per
    // line, so a line mixing plain and <strong>/<em> text comes back as
    // several rects. Group fragments into lines by vertical overlap and
    // measure each line from its leftmost to rightmost edge.
    const lines = [];
    rects.forEach((r) => {
      const mid = (r.top + r.bottom) / 2;
      const line = lines.find((l) => mid >= l.top && mid <= l.bottom);
      if (line) {
        line.left = Math.min(line.left, r.left);
        line.right = Math.max(line.right, r.right);
        line.top = Math.min(line.top, r.top);
        line.bottom = Math.max(line.bottom, r.bottom);
      } else {
        lines.push({ left: r.left, right: r.right, top: r.top, bottom: r.bottom });
      }
    });
    const scale = window.Reveal && Reveal.getScale ? Reveal.getScale() : 1;
    const maxWidth = Math.max(...lines.map((l) => l.right - l.left)) / scale;
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
