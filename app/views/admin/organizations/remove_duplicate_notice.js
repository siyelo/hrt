var element = $("#replace_organization");
var form = element.parents('form')
var duplicate_id = $("#duplicate_organization_id").val();
HrtOrganizations.removeOrganizationFromLists(duplicate_id, 'duplicate');
HrtOrganizations.displayFlashForReplaceOrganization('notice', '<%= j(message) %>');
