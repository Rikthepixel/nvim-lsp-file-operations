local log = require("lsp-file-operations.log")
local utils = require("lsp-file-operations.utils")

local M = {}

M.callback = function(data)
	local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
	for _, client in pairs(get_clients()) do
		local did_rename = utils.get_nested_path(client, { "server_capabilities", "workspace", "fileOperations", "didRename" })
		if did_rename ~= nil then
			local filters = did_rename.filters or {}
			if utils.matches_filters(filters, data.old_name) then
				local params = {
					files = {
						{ oldUri = vim.uri_from_fname(data.old_name), newUri = vim.uri_from_fname(data.new_name) },
					},
				}
				client.notify("workspace/didRenameFiles", params)
				log.debug("Sending workspace/didRenameFiles notification", params)
			end
		end
	end
end

return M