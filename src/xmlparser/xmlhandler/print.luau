local write = print

---@module Handler to generate a simple event trace which
--outputs messages to the terminal during the XML
--parsing, usually for debugging purposes.
local print = {}

---Parses a start tag.
-- @param tag a {name, attrs} table
-- where name is the name of the tag and attrs
-- is a table containing the atributtes of the tag
-- @param s position where the tag starts
-- @param e position where the tag ends
function print:starttag(tag, _, _)
	write("Start:", tag.name)
	if tag.attrs then
		for k, v in pairs(tag.attrs) do
			write(string.format(" + %s='%s'\n", k, v))
		end
	end
end

---Parses an end tag.
-- @param tag a {name, attrs} table
-- where name is the name of the tag and attrs
-- is a table containing the atributtes of the tag
-- @param s position where the tag starts
-- @param e position where the tag ends
function print:endtag(tag, _, _)
	write("End:", tag.name)
end

---Parses a tag content.
-- @param text text to process
-- @param s position where the tag starts
-- @param e position where the tag ends
function print:text(text, _, _)
	write("Text:", text)
end

---Parses CDATA tag content.
-- @param text CDATA content to be processed
-- @param s position where the tag starts
-- @param e position where the tag ends
function print:cdata(text, _, _)
	write("CDATA:", text)
end

---Parses a comment tag.
-- @param text comment text
-- @param s position where the tag starts
-- @param e position where the tag ends
function print:comment(text, _, _)
	write("Comment:", text)
end

---Parses a DTD tag.
-- @param tag a {name, attrs} table
-- where name is the name of the tag and attrs
-- is a table containing the atributtes of the tag
-- @param s position where the tag starts
-- @param e position where the tag ends
function print:dtd(tag, _, _)
	write("DTD:", tag.name)
	if tag.attrs then
		for k, v in pairs(tag.attrs) do
			write(string.format(" + %s='%s'\n", k, v))
		end
	end
end

--- Parse a XML processing instructions (PI) tag.
-- @param tag a {name, attrs} table
-- where name is the name of the tag and attrs
-- is a table containing the atributtes of the tag
-- @param s position where the tag starts
-- @param e position where the tag ends
function print:pi(tag, _, _)
	write("PI:", tag.name)
	if tag.attrs then
		for k, v in pairs(tag.attrs) do
			write(string.format(" + %s='%s'\n", k, v))
		end
	end
end

---Parse the XML declaration line (the line that indicates the XML version).
-- @param tag a {name, attrs} table
-- where name is the name of the tag and attrs
-- is a table containing the atributtes of the tag
-- @param s position where the tag starts
-- @param e position where the tag ends
function print:decl(tag, _, _)
	write("XML Decl:", tag.name)
	if tag.attrs then
		for k, v in pairs(tag.attrs) do
			write(string.format(" + %s='%s'\n", k, v))
		end
	end
end

return print
