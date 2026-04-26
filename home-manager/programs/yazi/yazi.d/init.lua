-- function Linemode:size()
--   if self._file.cha.is_dir then
--     return ""
--   end
--   local size = self._file:size()
--   if not size then
--     return ""
--   end
--   return ui.Line(ya.readable_size(size))
-- end

require("git"):setup()
