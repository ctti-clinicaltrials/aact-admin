$(function() {
	$("#jsGrid").jsGrid({
		height: "160vh",
		width: "100%",
		filtering: true,
		inserting: false,
		editing: false,
		sorting: true,
		paging: true,
		autoload: true,
		noDataContent: "...Loading...",
		searchButtonTooltip: "Search",
		clearFilterButtonTooltip: "Clear filter",
		pageSize: 40,
		controller: {
			loadData: function(filter) {
				return $.get('/definitions.json?schema=ctgov')
					.then(result => result.filter(row => Object.keys(filter).every(col =>
						filter[col] === undefined ||
						('' + filter[col]).trim() === '' ||
						('' + row[col]).toLowerCase().includes(('' + filter[col]).trim().toLowerCase())
					)))
			}
		},
		fields: [
			{ type: 'control', deleteButton: false, editButton: false },
			{ name: 'nlm doc', width: 38, align: 'center' },
			{ name: 'db schema', type: "text", width: 70 },
			{ name: 'table', type: "text", width: 150 },
			{ name: 'column', type: "text", width: 180 },
			{ name: 'data type', type: "text", width: 70 },
			{ name: 'CTTI note', type: "text", width: 350 },
			{ name: 'enumerations', type: "text", width: 300 },
			{ name: 'source', type: "text", width: 250 },
		]
	});
});
