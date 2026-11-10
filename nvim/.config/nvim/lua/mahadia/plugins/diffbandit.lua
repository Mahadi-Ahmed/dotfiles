local ok, diffbandit = pcall(require, "diffbandit")
if not ok then
  return
end

-- Defaults for now; press g? inside any diffbandit window to see live mappings.
diffbandit.setup({})
