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

-- End typst blocks correctly
local function endTypstBlock(blocks)
    local lastBlock = blocks[#blocks]
    if lastBlock.t == "Para" or lastBlock.t == "Plain" then
        lastBlock.content:insert(pandoc.RawInline('typst', '\n]'))
        return blocks
    else
        blocks:insert(pandoc.RawBlock('typst', ']\n'))
        return blocks
    end
end

-- Quarto/pandoc strips out custom classes from fenced ::: {.div} elements in
-- typst output, so there's no way to carry over something like :::
-- {.course-details} into typst. This checks for a few specific classes and
-- makes named typst blocks that can be targeted and styled
function Div(el)
    if el.classes:includes('course-details') then
        local blocks = pandoc.List({
            pandoc.RawBlock('typst', '#course-details[')
        })
        blocks:extend(el.content)
        return endTypstBlock(blocks)
    end

    -- I use Bootstrap CSS grid to create columns, so this looks for the
    -- .g-col-12 class to identify columns
    if el.classes:includes('g-col-12') then
        -- Change all H3s in the course-details div to h6 so that they're easily
        -- targetable/stylable
        el.content = el.content:walk({
            Header = function(h)
                if h.level == 3 then
                    h.level = 7
                end
                return h
            end
        })

        local blocks = pandoc.List({
            pandoc.RawBlock('typst', '#grid-col[')
        })
        blocks:extend(el.content)
        return endTypstBlock(blocks)
    end

    if el.classes:includes('centered-table') then
        local blocks = pandoc.List({
            pandoc.RawBlock('typst', '#centered-table[')
        })
        blocks:extend(el.content)
        return endTypstBlock(blocks)
    end

    if el.classes:includes('schedule-table') then
        local blocks = pandoc.List({
            pandoc.RawBlock('typst', '#schedule-table[')
        })
        blocks:extend(el.content)
        return endTypstBlock(blocks)
    end
end
