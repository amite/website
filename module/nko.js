var http = require('http'),
    qs = require('querystring'),
    os = require('os');

module.exports = function ping(code, callback) {
  if (typeof code !== 'string')
    throw Error('Go to http://nodeknockout.com/teams/mine to get your code.');

  var params = {
    hostname: os.hostname(),
    os: os.type(),
    release: os.release()
  },
  options = {
    host: 'nodeknockout.com',
    port: 80,
    path: '/teams/' + qs.escape(code) + '/deploys?' + qs.stringify(params)
  };

  http.get(options)
    .on('response', function (res) { if (callback) callback(null, res); })
    .on('error', function (err) { if (callback) callback(err); });
};
