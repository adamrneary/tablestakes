// Generated by CoffeeScript 1.4.0
var table;

table = null;

describe("Table: ", function() {
  it('window.tablestakes is function', function(done) {
    assert(window.TablesStakes);
    assert(typeof window.TablesStakes === 'function');
    return done();
  });
  return it('constructor', function(done) {
    table = new window.TablesStakes;
    assert(table);
    return done();
  });
});
