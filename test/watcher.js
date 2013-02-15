require('coffee-script')
global.glob = {}
glob.config = require('../server/config')
compile = require('../server/compiler')

spawn = require('child_process').spawn

start = function () {
  compile(function() {
    mocha = spawn(__dirname+'/../node_modules/mocha/bin/mocha',[__dirname+'/run.js', '-Gw','-R','spec','-s','20','--timeout','6000'], {customFds: [0,1,2]})
    mocha.on('exit',function() {
      start()
    });
  });
};

start()
