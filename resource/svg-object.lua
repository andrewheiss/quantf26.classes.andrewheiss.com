-- Replace <img src="foo.svg"> with <object data="foo.svg" type="image/svg+xml">
-- so text inside SVG figures stays selectable, while keeping Quarto's normal
-- figure pipeline (captions, cross-refs, fig-align, out-width) intact.
--
-- Must run at post-finalize: that's the last user-filter entry point before
-- pandoc's own HTML writer runs, and it's the only point where the Image
-- already carries the classes Quarto's own render_html_fixups filter adds
-- (quarto-figure, quarto-figure-<align>, img-fluid). The width="X%" -> CSS
-- `style="width:X%"` conversion itself happens inside pandoc's HTML writer,
-- which no filter can see, so we reproduce that one conversion ourselves.

local function is_svg(src)
  return src:match("%.svg$") ~= nil
end

local function attrs_to_html(attr)
  local parts = {}
  if attr.identifier and attr.identifier ~= "" then
    table.insert(parts, string.format('id="%s"', attr.identifier))
  end
  -- pandoc's own writer normally adds "figure-img" to a lone image inside a
  -- figure; since we're bypassing that writer with raw HTML, add it back
  local classes = attr.classes:clone()
  classes:insert("figure-img")
  table.insert(parts, string.format('class="%s"', table.concat(classes, " ")))
  for key, val in pairs(attr.attributes) do
    if key ~= "width" and key ~= "height" then
      table.insert(parts, string.format('%s="%s"', key, val))
    end
  end
  local style = {}
  if attr.attributes.width then
    table.insert(style, "width:" .. attr.attributes.width)
  end
  if attr.attributes.height then
    table.insert(style, "height:" .. attr.attributes.height)
  end
  if #style > 0 then
    table.insert(parts, string.format('style="%s"', table.concat(style, ";")))
  end
  return table.concat(parts, " ")
end

function Image(el)
  if not is_svg(el.src) then
    return el
  end

  local html = string.format(
    '<object data="%s" type="image/svg+xml" %s></object>',
    el.src, attrs_to_html(el.attr)
  )
  return pandoc.RawInline("html", html)
end
