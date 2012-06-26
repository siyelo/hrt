var element = $("#replace_organization");
var form = element.parents('form')
var duplicate_id = $("#duplicate_organization_id").val();
HrtOrganizations.displayFlashForReplaceOrganization('error', '<%= j(message) %>');
