-- Render explicitly typed publication records; a missing URL never hides a record.
local function str(x) return x and pandoc.utils.stringify(x) or "" end
local function esc(x)
  return str(x):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
end
function Pandoc(doc)
  local groups = {
    {"report", "Policy reports & research papers", "policy-reports"},
    {"manuscript", "Submitted manuscripts", "submitted-manuscripts"},
    {"working", "Working papers", "working-papers"},
    {"dissertation", "Dissertation", "dissertation"}
  }
  local blocks = pandoc.List()
  for _, group in ipairs(groups) do
    blocks:insert(pandoc.Header(2, group[2], pandoc.Attr(group[3])))
    for _, p in ipairs(doc.meta.publications or {}) do
      if str(p.type) == group[1] then
        local html = '<article class="publication" id="pub-' .. esc(p.id) .. '">'
        html = html .. '<h3>' .. esc(p.title) .. '</h3>'
        html = html .. '<p class="pub-authors">' .. esc(p.authors) .. ' <span class="pub-year">(' .. esc(p.year) .. ')</span></p><p class="pub-venue">' .. esc(p.venue) .. '</p>'
        if p.status then html = html .. '<p class="pub-status">' .. esc(p.status) .. '</p>' end
        if p.summary then html = html .. '<p class="pub-summary">' .. esc(p.summary) .. '</p>' end
        html = html .. '<div class="pub-links">'
        for _, link in ipairs({{"url", "Read paper"}, {"website", "Research materials"}, {"project", "Project overview"}}) do
          if p[link[1]] then html = html .. '<a href="' .. esc(p[link[1]]) .. '">' .. link[2] .. '<span class="visually-hidden">: ' .. esc(p.title) .. '</span> →</a>' end
        end
        blocks:insert(pandoc.RawBlock('html', html .. '</div></article>'))
      end
    end
  end
  return doc:walk({Div = function(el) if el.identifier == 'publication-list' then return blocks end end})
end
