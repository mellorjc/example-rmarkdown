Pandoc = function (doc)
  local meta = doc.meta
  local body = {}
  for i, block in pairs(doc.blocks) do -- first loop through all the blocks
      --[[ weirdly it seems that without looping through all the keys of each
           block then the information in the Div block is not completed
           (don't understand this), so this is the way we do it
        ]]
      for j, el in pairs(block) do
        if j == 'content' and block.t == 'Div' then -- Now we only care about Div blocks with contents
            for k, subel in pairs(el) do
              if subel.t == 'Para' then 
                 --[[ if the subelement of this Div is a Para then
                      we want to change the text to remove the reference tag
                 ]]
                 for m, el4 in pairs(subel.content) do
                   if el4 and el4.t == 'Str' then
                     el4.text = string.gsub(el4.text, "%(#(.*)%)", "")
                   end
                 end
              end
            end
        else
        end
      end

  end

  return doc
end

function CodeBlock (el)
  attr = el.attr
  text = el.text
  if FORMAT == "latex" then
    newtext = text
    newtext, count = string.gsub(text, '\\\\@ref%((.*)%)', '\\@ref(%1)')
    newtext, count = string.gsub(newtext, '%(#(.*)%)', '( #%1)')
  else
    newtext = text
  end
  return pandoc.CodeBlock(newtext, attr)
end

function RawBlock (el)
  str = el.text
  format = el.format
  --print(format)
  if format == 'latex' then
    text = str
    text, count = string.gsub(str, 'Table \\@ref%(.*%)','')
    text, count = string.gsub(text, 'ref','')
    text, count = string.gsub(text, '%(#([^%)]*)%)','\\label{%1}')
  elseif format == 'openxml' then
    text = str
  else
    text = str
  end
  return pandoc.RawBlock(format, text)
end



