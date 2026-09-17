-- link-to-footnote.lua
--
-- Converts hyperlinks to footnotes while keeping the link live in the text,
-- for formats that lack Pandoc's LaTeX-only `links-as-notes` option (Typst, docx).
--
-- [here's a link](https://example.com)
-- becomes
-- [here's a link](https://example.com)^[<https://example.com>]
--
-- Usage: add to your Quarto doc/project YAML:
--   filters:
--     - link-to-footnote.lua

-- Only run for formats that don't already have native links-as-notes support
local target_formats = { typst = true, docx = true }

if not target_formats[FORMAT] then
  return {}
end

-- Only convert "real" external links: must contain "://".
-- This skips internal cross-references (#sec-intro), relative paths (other.qmd),
-- and mailto: links
local function is_external_link(url)
  return url:match("://") ~= nil
end

local function Link(el)
  local url = el.target

  if not is_external_link(url) then
    return el
  end

  -- Skip bare-URL autolinks (text already is the URL) to avoid duplicating it
  local link_text = pandoc.utils.stringify(el.content)
  if link_text == url then
    return el
  end

  local note_content = { pandoc.Para({ pandoc.Link({ pandoc.Str(url) }, url) }) }
  local note = pandoc.Note(note_content)

  return { el, note }
end

return {
  {
    traverse = "topdown",
    -- Don't add footnotes inside headers
    Header = function(el)
      return el, false
    end,
    -- Don't re-footnote links that already live inside a footnote
    Note = function(el)
      return el, false
    end,
    Link = Link,
  },
}
