'use strict';
'require fs';
'require view';
'require rpc';
'require form';
'require tools.widgets as widgets';

function getbanlogon() {
	return fs.exec('/usr/bin/pgrep', ['-f', 'banlogon']).then(function (res) {
		if (res.code === 0) {
			return res.stdout.trim();
		} else {
			return "";
		}
	});
}

function banlogonServiceStatus() {
	return Promise.all([
		getbanlogon(),
		L.resolveDefault(fs.exec('/usr/bin/pgrep', ['-f', 'banlogon']), null)
	]);
}

function banlogonRenderStatus(res) {
	var renderHTML = "";
	var isRunning = res[0];

	if (isRunning) {
		renderHTML += "<span style=\"color:green;font-weight:bold\">" + _("RUNNING") + ' PID:' + res[1].stdout.trim() + "</span>";
		return renderHTML;
	} else {
		renderHTML += "<span style=\"color:red;font-weight:bold\">" + _("NOT RUNNING") + "</span>";
		return renderHTML;
	}
}

return view.extend({
	callHostHints: rpc.declare({
		object: 'luci-rpc',
		method: 'getHostHints',
		expect: { '': {} }
	}),

	load: function() {
		return Promise.all([
			this.callHostHints()
		]);
	},

	render: function(data) {
		var hosts = data[0],
		    m, s, o;

		m = new form.Map('banlogon', _('错误登录访问限制'), 
		_('这是一个通过监听日志将OPENWRT标配WEB服务与远程终端服务登录错误的IP地址作出限制的机制(防止密码穷举暴力破解)'));

		s = m.section(form.NamedSection, '');
		s.anonymous = true;

		s.render = function () {
			L.Poll.add(function () {
				return L.resolveDefault(banlogonServiceStatus()).then(function (res) {
					var view = document.getElementById("service_status");
					view.innerHTML = banlogonRenderStatus(res);
				});
			});

			return E('div', { class: 'cbi-section' }, [
					E('div', { id: 'service_status' },
						_('Collecting data ...'))
				])
			}

		s = m.section(form.TypedSection, 'basic', _('Basic settings'));
		s.anonymous = true;

		o = s.option(form.Flag, 'enabled', _('Enable'), _('同时限制IPv4与IPv6'));
		o.rmempty = false;
		o.editable = true;

		o = s.option(form.Flag, 'uhttpd', _('监听uhttpd日志'),
		_('监听uhttpd登录错误日志记录(WEB)'));
		o.rmempty = false;
		o.default = o.enabled;
		o.editable = true;

		o = s.option(form.Flag, 'dropbear', _('监听dropbear日志'),
		_('监听dropbear登录错误日志记录(SSH)'));
		o.rmempty = false;
		o.default = o.enabled;
		o.editable = true;

		o = s.option(form.Value, 'Refreshinterval', _('刷新间隔'),
		_('监听脚本刷新时间(值越小CPU占用越高 1s秒 1m分 1h时 1d天)'));
		o.default = '3s';
		o.rmempty = false;

		o = s.option(form.Value, 'Errorcount', _('错误计数'),
		_('当错误计数大于等于该值时执行动作(默认只允许错3次)'));
		o.default = '3';
		o.rmempty = false;

		o = s.option(form.ListValue, 'Actionmethod', _('动作方式'),
		_('指定动作方式'));
		o.value('0', _('重启前永久'));
		o.value('1', _('佛系式解封'));
		o.rmempty = false;

		o = s.option(form.Value, 'Actiontime', _('动作时间'),
		_('倒计时结束后解除动作(单位：秒) 0 与永久一样') + '<br>' + _('该功能不可用，已去掉语句除非解决</font><a style=\"cursor:pointer;color: #1E90FF;\" onclick=\"window.open(\'https://www.right.com.cn/forum/thread-570103-1-1.html\')\">链接</a>的问题') + '<br>' + _('目前只能待日志消退后解封的佛系方式') );
		o.default = '60';
		o.depends('Actionmethod', '1');
		o.rmempty = false;

		return m.render();
	}
});
