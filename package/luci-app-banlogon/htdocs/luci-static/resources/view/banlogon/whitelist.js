'use strict';
'require view';
'require fs';
'require ui';

return view.extend({
	load: function() {
		return L.resolveDefault(fs.read('/etc/banlogon/whitelist.list'), '');
	},

	handleSave: function(ev) {
		var value = (document.querySelector('textarea').value || '').trim().replace(/\r\n/g, '\n') + '\n';

		return fs.write('/etc/banlogon/whitelist.list', value).then(function(rc) {
			document.querySelector('textarea').value = value;
			ui.addNotification(null, E('p', _('Contents have been saved.')), 'info');
		}).catch(function(e) {
			ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
		});
	},

	render: function(fwuser) {
		return E([
			E('h2', _('Custom release list')),
			E('p', {}, _('这里允许您修改 "/etc/banlogon/whitelist.list" 的内容。<br>一行一个地址(支持IPv4与IPv6地址。)')),
			E('p', {}, E('textarea', { 'style': 'width:100%', 'rows': '30%' }, [ fwuser != null ? fwuser : '' ]))
		]);
	},

	handleSaveApply: null,
	handleReset: null
});
