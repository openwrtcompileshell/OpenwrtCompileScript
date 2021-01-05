'use strict';
'require view';
'require poll';
'require rpc';
'require form';

var callzerotierGetStatus;

callzerotierGetStatus = rpc.declare({
	object: 'luci.banlogon',
	method: 'get_status',
	expect: {  }
});

return view.extend({
	load: function() {
		return Promise.all([
			callzerotierGetStatus()
		]);
	},

	poll_status: function(nodes, data) {

		var clients = Array.isArray(data[0].clients) ? data[0].clients : [];

		var rows = clients.map(function(client) {
			var timeout;

			if (client.timeout  <= 0)
				timeout = _('Loading');
			else
				timeout = '%t'.format(client.timeout);
			return [
				client.server,
				client.ipaddrs,
				timeout
			];
		});

		cbi_update_table(nodes.querySelector('#zerotier_status_table'), rows, E('em', _('There is no active interface information')));

		return;
	},

	render: function(data) {

		var m, s, o;

		m = new form.Map('zerotier');

		s = m.section(form.GridSection, '_active_info');

		s.render = L.bind(function(view, section_id) {
			var table = E('div', { 'class': 'table cbi-section-table', 'id': 'zerotier_status_table' }, [
				E('div', { 'class': 'tr table-titles' }, [
					E('div', { 'class': 'th' }, _('阻止服务')),
					E('div', { 'class': 'th' }, _('阻止地址')),
					E('div', { 'class': 'th' }, _('解除计时')),
				])
			]);

			return E('div', { 'class': 'cbi-section cbi-tblsection' }, [
					E('h3', _('被阻止的地址')), table ]);
		}, o, this);

		return m.render().then(L.bind(function(m, nodes) {
			poll.add(L.bind(function() {
				return Promise.all([
					callzerotierGetStatus()
				]).then(L.bind(this.poll_status, this, nodes));
			}, this), 1);
			return nodes;
		}, this, m));
	},
	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
