-- The .qmd file uses a title like "Syllabus" and that gets used in the typst
-- title block. However, I want it to show the course title and number instead.
-- This rewrites the document metadata so that it uses the values from the
-- pdf-title and pdf-subtitle keys instead
function Meta(meta)
  if quarto.doc.is_format("typst") then
    if meta['pdf-title'] then
      meta.title = meta['pdf-title']
    end
    if meta['pdf-subtitle'] then
      meta.subtitle = meta['pdf-subtitle']
    end
  end
  return meta
end
