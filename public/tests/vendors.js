!function (name, context, definition) {
  if (typeof require === 'function' && typeof exports === 'object' && typeof module === 'object') {
    module.exports = definition();
  } else if (typeof define === 'function' && typeof define.amd  === 'object') {
    define(function () {
      return definition();
    });
  } else {
    context[name] = definition();
  }
}('chai', this, function () {

  function require(p) {
    var path = require.resolve(p)
      , mod = require.modules[path];
    if (!mod) throw new Error('failed to require "' + p + '"');
    if (!mod.exports) {
      mod.exports = {};
      mod.call(mod.exports, mod, mod.exports, require.relative(path));
    }
    return mod.exports;
  }

  require.modules = {};

  require.resolve = function (path) {
    var orig = path
      , reg = path + '.js'
      , index = path + '/index.js';
    return require.modules[reg] && reg
      || require.modules[index] && index
      || orig;
  };

  require.register = function (path, fn) {
    require.modules[path] = fn;
  };

  require.relative = function (parent) {
    return function(p){
      if ('.' != p.charAt(0)) return require(p);

      var path = parent.split('/')
        , segs = p.split('/');
      path.pop();

      for (var i = 0; i < segs.length; i++) {
        var seg = segs[i];
        if ('..' == seg) path.pop();
        else if ('.' != seg) path.push(seg);
      }

      return require(path.join('/'));
    };
  };

  require.alias = function (from, to) {
    var fn = require.modules[from];
    require.modules[to] = fn;
  };


  require.register("chai.js", function(module, exports, require){
    /*!
     * chai
     * Copyright(c) 2011-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    var used = []
      , exports = module.exports = {};

    /*!
     * Chai version
     */

    exports.version = '1.5.0';

    /*!
     * Primary `Assertion` prototype
     */

    exports.Assertion = require('./chai/assertion');

    /*!
     * Assertion Error
     */

    exports.AssertionError = require('./chai/error');

    /*!
     * Utils for plugins (not exported)
     */

    var util = require('./chai/utils');

    /**
     * # .use(function)
     *
     * Provides a way to extend the internals of Chai
     *
     * @param {Function}
     * @returns {this} for chaining
     * @api public
     */

    exports.use = function (fn) {
      if (!~used.indexOf(fn)) {
        fn(this, util);
        used.push(fn);
      }

      return this;
    };

    /*!
     * Core Assertions
     */

    var core = require('./chai/core/assertions');
    exports.use(core);

    /*!
     * Expect interface
     */

    var expect = require('./chai/interface/expect');
    exports.use(expect);

    /*!
     * Should interface
     */

    var should = require('./chai/interface/should');
    exports.use(should);

    /*!
     * Assert interface
     */

    var assert = require('./chai/interface/assert');
    exports.use(assert);

  }); // module: chai.js

  require.register("chai/assertion.js", function(module, exports, require){
    /*!
     * chai
     * http://chaijs.com
     * Copyright(c) 2011-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /*!
     * Module dependencies.
     */

    var AssertionError = require('./error')
      , util = require('./utils')
      , flag = util.flag;

    /*!
     * Module export.
     */

    module.exports = Assertion;


    /*!
     * Assertion Constructor
     *
     * Creates object for chaining.
     *
     * @api private
     */

    function Assertion (obj, msg, stack) {
      flag(this, 'ssfi', stack || arguments.callee);
      flag(this, 'object', obj);
      flag(this, 'message', msg);
    }

    /*!
      * ### Assertion.includeStack
      *
      * User configurable property, influences whether stack trace
      * is included in Assertion error message. Default of false
      * suppresses stack trace in the error message
      *
      *     Assertion.includeStack = true;  // enable stack on error
      *
      * @api public
      */

    Assertion.includeStack = false;

    /*!
     * ### Assertion.showDiff
     *
     * User configurable property, influences whether or not
     * the `showDiff` flag should be included in the thrown
     * AssertionErrors. `false` will always be `false`; `true`
     * will be true when the assertion has requested a diff
     * be shown.
     *
     * @api public
     */

    Assertion.showDiff = true;

    Assertion.addProperty = function (name, fn) {
      util.addProperty(this.prototype, name, fn);
    };

    Assertion.addMethod = function (name, fn) {
      util.addMethod(this.prototype, name, fn);
    };

    Assertion.addChainableMethod = function (name, fn, chainingBehavior) {
      util.addChainableMethod(this.prototype, name, fn, chainingBehavior);
    };

    Assertion.overwriteProperty = function (name, fn) {
      util.overwriteProperty(this.prototype, name, fn);
    };

    Assertion.overwriteMethod = function (name, fn) {
      util.overwriteMethod(this.prototype, name, fn);
    };

    /*!
     * ### .assert(expression, message, negateMessage, expected, actual)
     *
     * Executes an expression and check expectations. Throws AssertionError for reporting if test doesn't pass.
     *
     * @name assert
     * @param {Philosophical} expression to be tested
     * @param {String} message to display if fails
     * @param {String} negatedMessage to display if negated expression fails
     * @param {Mixed} expected value (remember to check for negation)
     * @param {Mixed} actual (optional) will default to `this.obj`
     * @api private
     */

    Assertion.prototype.assert = function (expr, msg, negateMsg, expected, _actual, showDiff) {
      var ok = util.test(this, arguments);
      if (true !== showDiff) showDiff = false;
      if (true !== Assertion.showDiff) showDiff = false;

      if (!ok) {
        var msg = util.getMessage(this, arguments)
          , actual = util.getActual(this, arguments);
        throw new AssertionError({
            message: msg
          , actual: actual
          , expected: expected
          , stackStartFunction: (Assertion.includeStack) ? this.assert : flag(this, 'ssfi')
          , showDiff: showDiff
        });
      }
    };

    /*!
     * ### ._obj
     *
     * Quick reference to stored `actual` value for plugin developers.
     *
     * @api private
     */

    Object.defineProperty(Assertion.prototype, '_obj',
      { get: function () {
          return flag(this, 'object');
        }
      , set: function (val) {
          flag(this, 'object', val);
        }
    });

  }); // module: chai/assertion.js

  require.register("chai/core/assertions.js", function(module, exports, require){
    /*!
     * chai
     * http://chaijs.com
     * Copyright(c) 2011-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    module.exports = function (chai, _) {
      var Assertion = chai.Assertion
        , toString = Object.prototype.toString
        , flag = _.flag;

      /**
       * ### Language Chains
       *
       * The following are provide as chainable getters to
       * improve the readability of your assertions. They
       * do not provide an testing capability unless they
       * have been overwritten by a plugin.
       *
       * **Chains**
       *
       * - to
       * - be
       * - been
       * - is
       * - that
       * - and
       * - have
       * - with
       * - at
       * - of
       *
       * @name language chains
       * @api public
       */

      [ 'to', 'be', 'been'
      , 'is', 'and', 'have'
      , 'with', 'that', 'at'
      , 'of' ].forEach(function (chain) {
        Assertion.addProperty(chain, function () {
          return this;
        });
      });

      /**
       * ### .not
       *
       * Negates any of assertions following in the chain.
       *
       *     expect(foo).to.not.equal('bar');
       *     expect(goodFn).to.not.throw(Error);
       *     expect({ foo: 'baz' }).to.have.property('foo')
       *       .and.not.equal('bar');
       *
       * @name not
       * @api public
       */

      Assertion.addProperty('not', function () {
        flag(this, 'negate', true);
      });

      /**
       * ### .deep
       *
       * Sets the `deep` flag, later used by the `equal` and
       * `property` assertions.
       *
       *     expect(foo).to.deep.equal({ bar: 'baz' });
       *     expect({ foo: { bar: { baz: 'quux' } } })
       *       .to.have.deep.property('foo.bar.baz', 'quux');
       *
       * @name deep
       * @api public
       */

      Assertion.addProperty('deep', function () {
        flag(this, 'deep', true);
      });

      /**
       * ### .a(type)
       *
       * The `a` and `an` assertions are aliases that can be
       * used either as language chains or to assert a value's
       * type.
       *
       *     // typeof
       *     expect('test').to.be.a('string');
       *     expect({ foo: 'bar' }).to.be.an('object');
       *     expect(null).to.be.a('null');
       *     expect(undefined).to.be.an('undefined');
       *
       *     // language chain
       *     expect(foo).to.be.an.instanceof(Foo);
       *
       * @name a
       * @alias an
       * @param {String} type
       * @param {String} message _optional_
       * @api public
       */

      function an (type, msg) {
        if (msg) flag(this, 'message', msg);
        type = type.toLowerCase();
        var obj = flag(this, 'object')
          , article = ~[ 'a', 'e', 'i', 'o', 'u' ].indexOf(type.charAt(0)) ? 'an ' : 'a ';

        this.assert(
            type === _.type(obj)
          , 'expected #{this} to be ' + article + type
          , 'expected #{this} not to be ' + article + type
        );
      }

      Assertion.addChainableMethod('an', an);
      Assertion.addChainableMethod('a', an);

      /**
       * ### .include(value)
       *
       * The `include` and `contain` assertions can be used as either property
       * based language chains or as methods to assert the inclusion of an object
       * in an array or a substring in a string. When used as language chains,
       * they toggle the `contain` flag for the `keys` assertion.
       *
       *     expect([1,2,3]).to.include(2);
       *     expect('foobar').to.contain('foo');
       *     expect({ foo: 'bar', hello: 'universe' }).to.include.keys('foo');
       *
       * @name include
       * @alias contain
       * @param {Object|String|Number} obj
       * @param {String} message _optional_
       * @api public
       */

      function includeChainingBehavior () {
        flag(this, 'contains', true);
      }

      function include (val, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object')
        this.assert(
            ~obj.indexOf(val)
          , 'expected #{this} to include ' + _.inspect(val)
          , 'expected #{this} to not include ' + _.inspect(val));
      }

      Assertion.addChainableMethod('include', include, includeChainingBehavior);
      Assertion.addChainableMethod('contain', include, includeChainingBehavior);

      /**
       * ### .ok
       *
       * Asserts that the target is truthy.
       *
       *     expect('everthing').to.be.ok;
       *     expect(1).to.be.ok;
       *     expect(false).to.not.be.ok;
       *     expect(undefined).to.not.be.ok;
       *     expect(null).to.not.be.ok;
       *
       * @name ok
       * @api public
       */

      Assertion.addProperty('ok', function () {
        this.assert(
            flag(this, 'object')
          , 'expected #{this} to be truthy'
          , 'expected #{this} to be falsy');
      });

      /**
       * ### .true
       *
       * Asserts that the target is `true`.
       *
       *     expect(true).to.be.true;
       *     expect(1).to.not.be.true;
       *
       * @name true
       * @api public
       */

      Assertion.addProperty('true', function () {
        this.assert(
            true === flag(this, 'object')
          , 'expected #{this} to be true'
          , 'expected #{this} to be false'
          , this.negate ? false : true
        );
      });

      /**
       * ### .false
       *
       * Asserts that the target is `false`.
       *
       *     expect(false).to.be.false;
       *     expect(0).to.not.be.false;
       *
       * @name false
       * @api public
       */

      Assertion.addProperty('false', function () {
        this.assert(
            false === flag(this, 'object')
          , 'expected #{this} to be false'
          , 'expected #{this} to be true'
          , this.negate ? true : false
        );
      });

      /**
       * ### .null
       *
       * Asserts that the target is `null`.
       *
       *     expect(null).to.be.null;
       *     expect(undefined).not.to.be.null;
       *
       * @name null
       * @api public
       */

      Assertion.addProperty('null', function () {
        this.assert(
            null === flag(this, 'object')
          , 'expected #{this} to be null'
          , 'expected #{this} not to be null'
        );
      });

      /**
       * ### .undefined
       *
       * Asserts that the target is `undefined`.
       *
       *      expect(undefined).to.be.undefined;
       *      expect(null).to.not.be.undefined;
       *
       * @name undefined
       * @api public
       */

      Assertion.addProperty('undefined', function () {
        this.assert(
            undefined === flag(this, 'object')
          , 'expected #{this} to be undefined'
          , 'expected #{this} not to be undefined'
        );
      });

      /**
       * ### .exist
       *
       * Asserts that the target is neither `null` nor `undefined`.
       *
       *     var foo = 'hi'
       *       , bar = null
       *       , baz;
       *
       *     expect(foo).to.exist;
       *     expect(bar).to.not.exist;
       *     expect(baz).to.not.exist;
       *
       * @name exist
       * @api public
       */

      Assertion.addProperty('exist', function () {
        this.assert(
            null != flag(this, 'object')
          , 'expected #{this} to exist'
          , 'expected #{this} to not exist'
        );
      });


      /**
       * ### .empty
       *
       * Asserts that the target's length is `0`. For arrays, it checks
       * the `length` property. For objects, it gets the count of
       * enumerable keys.
       *
       *     expect([]).to.be.empty;
       *     expect('').to.be.empty;
       *     expect({}).to.be.empty;
       *
       * @name empty
       * @api public
       */

      Assertion.addProperty('empty', function () {
        var obj = flag(this, 'object')
          , expected = obj;

        if (Array.isArray(obj) || 'string' === typeof object) {
          expected = obj.length;
        } else if (typeof obj === 'object') {
          expected = Object.keys(obj).length;
        }

        this.assert(
            !expected
          , 'expected #{this} to be empty'
          , 'expected #{this} not to be empty'
        );
      });

      /**
       * ### .arguments
       *
       * Asserts that the target is an arguments object.
       *
       *     function test () {
       *       expect(arguments).to.be.arguments;
       *     }
       *
       * @name arguments
       * @alias Arguments
       * @api public
       */

      function checkArguments () {
        var obj = flag(this, 'object')
          , type = Object.prototype.toString.call(obj);
        this.assert(
            '[object Arguments]' === type
          , 'expected #{this} to be arguments but got ' + type
          , 'expected #{this} to not be arguments'
        );
      }

      Assertion.addProperty('arguments', checkArguments);
      Assertion.addProperty('Arguments', checkArguments);

      /**
       * ### .equal(value)
       *
       * Asserts that the target is strictly equal (`===`) to `value`.
       * Alternately, if the `deep` flag is set, asserts that
       * the target is deeply equal to `value`.
       *
       *     expect('hello').to.equal('hello');
       *     expect(42).to.equal(42);
       *     expect(1).to.not.equal(true);
       *     expect({ foo: 'bar' }).to.not.equal({ foo: 'bar' });
       *     expect({ foo: 'bar' }).to.deep.equal({ foo: 'bar' });
       *
       * @name equal
       * @alias equals
       * @alias eq
       * @alias deep.equal
       * @param {Mixed} value
       * @param {String} message _optional_
       * @api public
       */

      function assertEqual (val, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        if (flag(this, 'deep')) {
          return this.eql(val);
        } else {
          this.assert(
              val === obj
            , 'expected #{this} to equal #{exp}'
            , 'expected #{this} to not equal #{exp}'
            , val
            , this._obj
            , true
          );
        }
      }

      Assertion.addMethod('equal', assertEqual);
      Assertion.addMethod('equals', assertEqual);
      Assertion.addMethod('eq', assertEqual);

      /**
       * ### .eql(value)
       *
       * Asserts that the target is deeply equal to `value`.
       *
       *     expect({ foo: 'bar' }).to.eql({ foo: 'bar' });
       *     expect([ 1, 2, 3 ]).to.eql([ 1, 2, 3 ]);
       *
       * @name eql
       * @alias eqls
       * @param {Mixed} value
       * @param {String} message _optional_
       * @api public
       */

      function assertEql(obj, msg) {
        if (msg) flag(this, 'message', msg);
        this.assert(
            _.eql(obj, flag(this, 'object'))
          , 'expected #{this} to deeply equal #{exp}'
          , 'expected #{this} to not deeply equal #{exp}'
          , obj
          , this._obj
          , true
        );
      }

      Assertion.addMethod('eql', assertEql);
      Assertion.addMethod('eqls', assertEql);

      /**
       * ### .above(value)
       *
       * Asserts that the target is greater than `value`.
       *
       *     expect(10).to.be.above(5);
       *
       * Can also be used in conjunction with `length` to
       * assert a minimum length. The benefit being a
       * more informative error message than if the length
       * was supplied directly.
       *
       *     expect('foo').to.have.length.above(2);
       *     expect([ 1, 2, 3 ]).to.have.length.above(2);
       *
       * @name above
       * @alias gt
       * @alias greaterThan
       * @param {Number} value
       * @param {String} message _optional_
       * @api public
       */

      function assertAbove (n, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        if (flag(this, 'doLength')) {
          new Assertion(obj, msg).to.have.property('length');
          var len = obj.length;
          this.assert(
              len > n
            , 'expected #{this} to have a length above #{exp} but got #{act}'
            , 'expected #{this} to not have a length above #{exp}'
            , n
            , len
          );
        } else {
          this.assert(
              obj > n
            , 'expected #{this} to be above ' + n
            , 'expected #{this} to be at most ' + n
          );
        }
      }

      Assertion.addMethod('above', assertAbove);
      Assertion.addMethod('gt', assertAbove);
      Assertion.addMethod('greaterThan', assertAbove);

      /**
       * ### .least(value)
       *
       * Asserts that the target is greater than or equal to `value`.
       *
       *     expect(10).to.be.at.least(10);
       *
       * Can also be used in conjunction with `length` to
       * assert a minimum length. The benefit being a
       * more informative error message than if the length
       * was supplied directly.
       *
       *     expect('foo').to.have.length.of.at.least(2);
       *     expect([ 1, 2, 3 ]).to.have.length.of.at.least(3);
       *
       * @name least
       * @alias gte
       * @param {Number} value
       * @param {String} message _optional_
       * @api public
       */

      function assertLeast (n, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        if (flag(this, 'doLength')) {
          new Assertion(obj, msg).to.have.property('length');
          var len = obj.length;
          this.assert(
              len >= n
            , 'expected #{this} to have a length at least #{exp} but got #{act}'
            , 'expected #{this} to have a length below #{exp}'
            , n
            , len
          );
        } else {
          this.assert(
              obj >= n
            , 'expected #{this} to be at least ' + n
            , 'expected #{this} to be below ' + n
          );
        }
      }

      Assertion.addMethod('least', assertLeast);
      Assertion.addMethod('gte', assertLeast);

      /**
       * ### .below(value)
       *
       * Asserts that the target is less than `value`.
       *
       *     expect(5).to.be.below(10);
       *
       * Can also be used in conjunction with `length` to
       * assert a maximum length. The benefit being a
       * more informative error message than if the length
       * was supplied directly.
       *
       *     expect('foo').to.have.length.below(4);
       *     expect([ 1, 2, 3 ]).to.have.length.below(4);
       *
       * @name below
       * @alias lt
       * @alias lessThan
       * @param {Number} value
       * @param {String} message _optional_
       * @api public
       */

      function assertBelow (n, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        if (flag(this, 'doLength')) {
          new Assertion(obj, msg).to.have.property('length');
          var len = obj.length;
          this.assert(
              len < n
            , 'expected #{this} to have a length below #{exp} but got #{act}'
            , 'expected #{this} to not have a length below #{exp}'
            , n
            , len
          );
        } else {
          this.assert(
              obj < n
            , 'expected #{this} to be below ' + n
            , 'expected #{this} to be at least ' + n
          );
        }
      }

      Assertion.addMethod('below', assertBelow);
      Assertion.addMethod('lt', assertBelow);
      Assertion.addMethod('lessThan', assertBelow);

      /**
       * ### .most(value)
       *
       * Asserts that the target is less than or equal to `value`.
       *
       *     expect(5).to.be.at.most(5);
       *
       * Can also be used in conjunction with `length` to
       * assert a maximum length. The benefit being a
       * more informative error message than if the length
       * was supplied directly.
       *
       *     expect('foo').to.have.length.of.at.most(4);
       *     expect([ 1, 2, 3 ]).to.have.length.of.at.most(3);
       *
       * @name most
       * @alias lte
       * @param {Number} value
       * @param {String} message _optional_
       * @api public
       */

      function assertMost (n, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        if (flag(this, 'doLength')) {
          new Assertion(obj, msg).to.have.property('length');
          var len = obj.length;
          this.assert(
              len <= n
            , 'expected #{this} to have a length at most #{exp} but got #{act}'
            , 'expected #{this} to have a length above #{exp}'
            , n
            , len
          );
        } else {
          this.assert(
              obj <= n
            , 'expected #{this} to be at most ' + n
            , 'expected #{this} to be above ' + n
          );
        }
      }

      Assertion.addMethod('most', assertMost);
      Assertion.addMethod('lte', assertMost);

      /**
       * ### .within(start, finish)
       *
       * Asserts that the target is within a range.
       *
       *     expect(7).to.be.within(5,10);
       *
       * Can also be used in conjunction with `length` to
       * assert a length range. The benefit being a
       * more informative error message than if the length
       * was supplied directly.
       *
       *     expect('foo').to.have.length.within(2,4);
       *     expect([ 1, 2, 3 ]).to.have.length.within(2,4);
       *
       * @name within
       * @param {Number} start lowerbound inclusive
       * @param {Number} finish upperbound inclusive
       * @param {String} message _optional_
       * @api public
       */

      Assertion.addMethod('within', function (start, finish, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object')
          , range = start + '..' + finish;
        if (flag(this, 'doLength')) {
          new Assertion(obj, msg).to.have.property('length');
          var len = obj.length;
          this.assert(
              len >= start && len <= finish
            , 'expected #{this} to have a length within ' + range
            , 'expected #{this} to not have a length within ' + range
          );
        } else {
          this.assert(
              obj >= start && obj <= finish
            , 'expected #{this} to be within ' + range
            , 'expected #{this} to not be within ' + range
          );
        }
      });

      /**
       * ### .instanceof(constructor)
       *
       * Asserts that the target is an instance of `constructor`.
       *
       *     var Tea = function (name) { this.name = name; }
       *       , Chai = new Tea('chai');
       *
       *     expect(Chai).to.be.an.instanceof(Tea);
       *     expect([ 1, 2, 3 ]).to.be.instanceof(Array);
       *
       * @name instanceof
       * @param {Constructor} constructor
       * @param {String} message _optional_
       * @alias instanceOf
       * @api public
       */

      function assertInstanceOf (constructor, msg) {
        if (msg) flag(this, 'message', msg);
        var name = _.getName(constructor);
        this.assert(
            flag(this, 'object') instanceof constructor
          , 'expected #{this} to be an instance of ' + name
          , 'expected #{this} to not be an instance of ' + name
        );
      };

      Assertion.addMethod('instanceof', assertInstanceOf);
      Assertion.addMethod('instanceOf', assertInstanceOf);

      /**
       * ### .property(name, [value])
       *
       * Asserts that the target has a property `name`, optionally asserting that
       * the value of that property is strictly equal to  `value`.
       * If the `deep` flag is set, you can use dot- and bracket-notation for deep
       * references into objects and arrays.
       *
       *     // simple referencing
       *     var obj = { foo: 'bar' };
       *     expect(obj).to.have.property('foo');
       *     expect(obj).to.have.property('foo', 'bar');
       *
       *     // deep referencing
       *     var deepObj = {
       *         green: { tea: 'matcha' }
       *       , teas: [ 'chai', 'matcha', { tea: 'konacha' } ]
       *     };

       *     expect(deepObj).to.have.deep.property('green.tea', 'matcha');
       *     expect(deepObj).to.have.deep.property('teas[1]', 'matcha');
       *     expect(deepObj).to.have.deep.property('teas[2].tea', 'konacha');
       *
       * You can also use an array as the starting point of a `deep.property`
       * assertion, or traverse nested arrays.
       *
       *     var arr = [
       *         [ 'chai', 'matcha', 'konacha' ]
       *       , [ { tea: 'chai' }
       *         , { tea: 'matcha' }
       *         , { tea: 'konacha' } ]
       *     ];
       *
       *     expect(arr).to.have.deep.property('[0][1]', 'matcha');
       *     expect(arr).to.have.deep.property('[1][2].tea', 'konacha');
       *
       * Furthermore, `property` changes the subject of the assertion
       * to be the value of that property from the original object. This
       * permits for further chainable assertions on that property.
       *
       *     expect(obj).to.have.property('foo')
       *       .that.is.a('string');
       *     expect(deepObj).to.have.property('green')
       *       .that.is.an('object')
       *       .that.deep.equals({ tea: 'matcha' });
       *     expect(deepObj).to.have.property('teas')
       *       .that.is.an('array')
       *       .with.deep.property('[2]')
       *         .that.deep.equals({ tea: 'konacha' });
       *
       * @name property
       * @alias deep.property
       * @param {String} name
       * @param {Mixed} value (optional)
       * @param {String} message _optional_
       * @returns value of property for chaining
       * @api public
       */

      Assertion.addMethod('property', function (name, val, msg) {
        if (msg) flag(this, 'message', msg);

        var descriptor = flag(this, 'deep') ? 'deep property ' : 'property '
          , negate = flag(this, 'negate')
          , obj = flag(this, 'object')
          , value = flag(this, 'deep')
            ? _.getPathValue(name, obj)
            : obj[name];

        if (negate && undefined !== val) {
          if (undefined === value) {
            msg = (msg != null) ? msg + ': ' : '';
            throw new Error(msg + _.inspect(obj) + ' has no ' + descriptor + _.inspect(name));
          }
        } else {
          this.assert(
              undefined !== value
            , 'expected #{this} to have a ' + descriptor + _.inspect(name)
            , 'expected #{this} to not have ' + descriptor + _.inspect(name));
        }

        if (undefined !== val) {
          this.assert(
              val === value
            , 'expected #{this} to have a ' + descriptor + _.inspect(name) + ' of #{exp}, but got #{act}'
            , 'expected #{this} to not have a ' + descriptor + _.inspect(name) + ' of #{act}'
            , val
            , value
          );
        }

        flag(this, 'object', value);
      });


      /**
       * ### .ownProperty(name)
       *
       * Asserts that the target has an own property `name`.
       *
       *     expect('test').to.have.ownProperty('length');
       *
       * @name ownProperty
       * @alias haveOwnProperty
       * @param {String} name
       * @param {String} message _optional_
       * @api public
       */

      function assertOwnProperty (name, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        this.assert(
            obj.hasOwnProperty(name)
          , 'expected #{this} to have own property ' + _.inspect(name)
          , 'expected #{this} to not have own property ' + _.inspect(name)
        );
      }

      Assertion.addMethod('ownProperty', assertOwnProperty);
      Assertion.addMethod('haveOwnProperty', assertOwnProperty);

      /**
       * ### .length(value)
       *
       * Asserts that the target's `length` property has
       * the expected value.
       *
       *     expect([ 1, 2, 3]).to.have.length(3);
       *     expect('foobar').to.have.length(6);
       *
       * Can also be used as a chain precursor to a value
       * comparison for the length property.
       *
       *     expect('foo').to.have.length.above(2);
       *     expect([ 1, 2, 3 ]).to.have.length.above(2);
       *     expect('foo').to.have.length.below(4);
       *     expect([ 1, 2, 3 ]).to.have.length.below(4);
       *     expect('foo').to.have.length.within(2,4);
       *     expect([ 1, 2, 3 ]).to.have.length.within(2,4);
       *
       * @name length
       * @alias lengthOf
       * @param {Number} length
       * @param {String} message _optional_
       * @api public
       */

      function assertLengthChain () {
        flag(this, 'doLength', true);
      }

      function assertLength (n, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        new Assertion(obj, msg).to.have.property('length');
        var len = obj.length;

        this.assert(
            len == n
          , 'expected #{this} to have a length of #{exp} but got #{act}'
          , 'expected #{this} to not have a length of #{act}'
          , n
          , len
        );
      }

      Assertion.addChainableMethod('length', assertLength, assertLengthChain);
      Assertion.addMethod('lengthOf', assertLength, assertLengthChain);

      /**
       * ### .match(regexp)
       *
       * Asserts that the target matches a regular expression.
       *
       *     expect('foobar').to.match(/^foo/);
       *
       * @name match
       * @param {RegExp} RegularExpression
       * @param {String} message _optional_
       * @api public
       */

      Assertion.addMethod('match', function (re, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        this.assert(
            re.exec(obj)
          , 'expected #{this} to match ' + re
          , 'expected #{this} not to match ' + re
        );
      });

      /**
       * ### .string(string)
       *
       * Asserts that the string target contains another string.
       *
       *     expect('foobar').to.have.string('bar');
       *
       * @name string
       * @param {String} string
       * @param {String} message _optional_
       * @api public
       */

      Assertion.addMethod('string', function (str, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        new Assertion(obj, msg).is.a('string');

        this.assert(
            ~obj.indexOf(str)
          , 'expected #{this} to contain ' + _.inspect(str)
          , 'expected #{this} to not contain ' + _.inspect(str)
        );
      });


      /**
       * ### .keys(key1, [key2], [...])
       *
       * Asserts that the target has exactly the given keys, or
       * asserts the inclusion of some keys when using the
       * `include` or `contain` modifiers.
       *
       *     expect({ foo: 1, bar: 2 }).to.have.keys(['foo', 'bar']);
       *     expect({ foo: 1, bar: 2, baz: 3 }).to.contain.keys('foo', 'bar');
       *
       * @name keys
       * @alias key
       * @param {String...|Array} keys
       * @api public
       */

      function assertKeys (keys) {
        var obj = flag(this, 'object')
          , str
          , ok = true;

        keys = keys instanceof Array
          ? keys
          : Array.prototype.slice.call(arguments);

        if (!keys.length) throw new Error('keys required');

        var actual = Object.keys(obj)
          , len = keys.length;

        // Inclusion
        ok = keys.every(function(key){
          return ~actual.indexOf(key);
        });

        // Strict
        if (!flag(this, 'negate') && !flag(this, 'contains')) {
          ok = ok && keys.length == actual.length;
        }

        // Key string
        if (len > 1) {
          keys = keys.map(function(key){
            return _.inspect(key);
          });
          var last = keys.pop();
          str = keys.join(', ') + ', and ' + last;
        } else {
          str = _.inspect(keys[0]);
        }

        // Form
        str = (len > 1 ? 'keys ' : 'key ') + str;

        // Have / include
        str = (flag(this, 'contains') ? 'contain ' : 'have ') + str;

        // Assertion
        this.assert(
            ok
          , 'expected #{this} to ' + str
          , 'expected #{this} to not ' + str
        );
      }

      Assertion.addMethod('keys', assertKeys);
      Assertion.addMethod('key', assertKeys);

      /**
       * ### .throw(constructor)
       *
       * Asserts that the function target will throw a specific error, or specific type of error
       * (as determined using `instanceof`), optionally with a RegExp or string inclusion test
       * for the error's message.
       *
       *     var err = new ReferenceError('This is a bad function.');
       *     var fn = function () { throw err; }
       *     expect(fn).to.throw(ReferenceError);
       *     expect(fn).to.throw(Error);
       *     expect(fn).to.throw(/bad function/);
       *     expect(fn).to.not.throw('good function');
       *     expect(fn).to.throw(ReferenceError, /bad function/);
       *     expect(fn).to.throw(err);
       *     expect(fn).to.not.throw(new RangeError('Out of range.'));
       *
       * Please note that when a throw expectation is negated, it will check each
       * parameter independently, starting with error constructor type. The appropriate way
       * to check for the existence of a type of error but for a message that does not match
       * is to use `and`.
       *
       *     expect(fn).to.throw(ReferenceError)
       *        .and.not.throw(/good function/);
       *
       * @name throw
       * @alias throws
       * @alias Throw
       * @param {ErrorConstructor} constructor
       * @param {String|RegExp} expected error message
       * @param {String} message _optional_
       * @see https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Error#Error_types
       * @api public
       */

      function assertThrows (constructor, errMsg, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        new Assertion(obj, msg).is.a('function');

        var thrown = false
          , desiredError = null
          , name = null
          , thrownError = null;

        if (arguments.length === 0) {
          errMsg = null;
          constructor = null;
        } else if (constructor && (constructor instanceof RegExp || 'string' === typeof constructor)) {
          errMsg = constructor;
          constructor = null;
        } else if (constructor && constructor instanceof Error) {
          desiredError = constructor;
          constructor = null;
          errMsg = null;
        } else if (typeof constructor === 'function') {
          name = (new constructor()).name;
        } else {
          constructor = null;
        }

        try {
          obj();
        } catch (err) {
          // first, check desired error
          if (desiredError) {
            this.assert(
                err === desiredError
              , 'expected #{this} to throw #{exp} but #{act} was thrown'
              , 'expected #{this} to not throw #{exp}'
              , desiredError
              , err
            );

            return this;
          }
          // next, check constructor
          if (constructor) {
            this.assert(
                err instanceof constructor
              , 'expected #{this} to throw #{exp} but #{act} was thrown'
              , 'expected #{this} to not throw #{exp} but #{act} was thrown'
              , name
              , err
            );

            if (!errMsg) return this;
          }
          // next, check message
          var message = 'object' === _.type(err) && "message" in err
            ? err.message
            : '' + err;

          if ((message != null) && errMsg && errMsg instanceof RegExp) {
            this.assert(
                errMsg.exec(message)
              , 'expected #{this} to throw error matching #{exp} but got #{act}'
              , 'expected #{this} to throw error not matching #{exp}'
              , errMsg
              , message
            );

            return this;
          } else if ((message != null) && errMsg && 'string' === typeof errMsg) {
            this.assert(
                ~message.indexOf(errMsg)
              , 'expected #{this} to throw error including #{exp} but got #{act}'
              , 'expected #{this} to throw error not including #{act}'
              , errMsg
              , message
            );

            return this;
          } else {
            thrown = true;
            thrownError = err;
          }
        }

        var actuallyGot = ''
          , expectedThrown = name !== null
            ? name
            : desiredError
              ? '#{exp}' //_.inspect(desiredError)
              : 'an error';

        if (thrown) {
          actuallyGot = ' but #{act} was thrown'
        }

        this.assert(
            thrown === true
          , 'expected #{this} to throw ' + expectedThrown + actuallyGot
          , 'expected #{this} to not throw ' + expectedThrown + actuallyGot
          , desiredError
          , thrownError
        );
      };

      Assertion.addMethod('throw', assertThrows);
      Assertion.addMethod('throws', assertThrows);
      Assertion.addMethod('Throw', assertThrows);

      /**
       * ### .respondTo(method)
       *
       * Asserts that the object or class target will respond to a method.
       *
       *     Klass.prototype.bar = function(){};
       *     expect(Klass).to.respondTo('bar');
       *     expect(obj).to.respondTo('bar');
       *
       * To check if a constructor will respond to a static function,
       * set the `itself` flag.
       *
       *    Klass.baz = function(){};
       *    expect(Klass).itself.to.respondTo('baz');
       *
       * @name respondTo
       * @param {String} method
       * @param {String} message _optional_
       * @api public
       */

      Assertion.addMethod('respondTo', function (method, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object')
          , itself = flag(this, 'itself')
          , context = ('function' === _.type(obj) && !itself)
            ? obj.prototype[method]
            : obj[method];

        this.assert(
            'function' === typeof context
          , 'expected #{this} to respond to ' + _.inspect(method)
          , 'expected #{this} to not respond to ' + _.inspect(method)
        );
      });

      /**
       * ### .itself
       *
       * Sets the `itself` flag, later used by the `respondTo` assertion.
       *
       *    function Foo() {}
       *    Foo.bar = function() {}
       *    Foo.prototype.baz = function() {}
       *
       *    expect(Foo).itself.to.respondTo('bar');
       *    expect(Foo).itself.not.to.respondTo('baz');
       *
       * @name itself
       * @api public
       */

      Assertion.addProperty('itself', function () {
        flag(this, 'itself', true);
      });

      /**
       * ### .satisfy(method)
       *
       * Asserts that the target passes a given truth test.
       *
       *     expect(1).to.satisfy(function(num) { return num > 0; });
       *
       * @name satisfy
       * @param {Function} matcher
       * @param {String} message _optional_
       * @api public
       */

      Assertion.addMethod('satisfy', function (matcher, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        this.assert(
            matcher(obj)
          , 'expected #{this} to satisfy ' + _.objDisplay(matcher)
          , 'expected #{this} to not satisfy' + _.objDisplay(matcher)
          , this.negate ? false : true
          , matcher(obj)
        );
      });

      /**
       * ### .closeTo(expected, delta)
       *
       * Asserts that the target is equal `expected`, to within a +/- `delta` range.
       *
       *     expect(1.5).to.be.closeTo(1, 0.5);
       *
       * @name closeTo
       * @param {Number} expected
       * @param {Number} delta
       * @param {String} message _optional_
       * @api public
       */

      Assertion.addMethod('closeTo', function (expected, delta, msg) {
        if (msg) flag(this, 'message', msg);
        var obj = flag(this, 'object');
        this.assert(
            Math.abs(obj - expected) <= delta
          , 'expected #{this} to be close to ' + expected + ' +/- ' + delta
          , 'expected #{this} not to be close to ' + expected + ' +/- ' + delta
        );
      });

    };

  }); // module: chai/core/assertions.js

  require.register("chai/error.js", function(module, exports, require){
    /*!
     * chai
     * Copyright(c) 2011-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /*!
     * Main export
     */

    module.exports = AssertionError;

    /**
     * # AssertionError (constructor)
     *
     * Create a new assertion error based on the Javascript
     * `Error` prototype.
     *
     * **Options**
     * - message
     * - actual
     * - expected
     * - operator
     * - startStackFunction
     *
     * @param {Object} options
     * @api public
     */

    function AssertionError (options) {
      options = options || {};
      this.message = options.message;
      this.actual = options.actual;
      this.expected = options.expected;
      this.operator = options.operator;
      this.showDiff = options.showDiff;

      if (options.stackStartFunction && Error.captureStackTrace) {
        var stackStartFunction = options.stackStartFunction;
        Error.captureStackTrace(this, stackStartFunction);
      }
    }

    /*!
     * Inherit from Error
     */

    AssertionError.prototype = Object.create(Error.prototype);
    AssertionError.prototype.name = 'AssertionError';
    AssertionError.prototype.constructor = AssertionError;

    /**
     * # toString()
     *
     * Override default to string method
     */

    AssertionError.prototype.toString = function() {
      return this.message;
    };

  }); // module: chai/error.js

  require.register("chai/interface/assert.js", function(module, exports, require){
    /*!
     * chai
     * Copyright(c) 2011-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */


    module.exports = function (chai, util) {

      /*!
       * Chai dependencies.
       */

      var Assertion = chai.Assertion
        , flag = util.flag;

      /*!
       * Module export.
       */

      /**
       * ### assert(expression, message)
       *
       * Write your own test expressions.
       *
       *     assert('foo' !== 'bar', 'foo is not bar');
       *     assert(Array.isArray([]), 'empty arrays are arrays');
       *
       * @param {Mixed} expression to test for truthiness
       * @param {String} message to display on error
       * @name assert
       * @api public
       */

      var assert = chai.assert = function (express, errmsg) {
        var test = new Assertion(null);
        test.assert(
            express
          , errmsg
          , '[ negation message unavailable ]'
        );
      };

      /**
       * ### .fail(actual, expected, [message], [operator])
       *
       * Throw a failure. Node.js `assert` module-compatible.
       *
       * @name fail
       * @param {Mixed} actual
       * @param {Mixed} expected
       * @param {String} message
       * @param {String} operator
       * @api public
       */

      assert.fail = function (actual, expected, message, operator) {
        throw new chai.AssertionError({
            actual: actual
          , expected: expected
          , message: message
          , operator: operator
          , stackStartFunction: assert.fail
        });
      };

      /**
       * ### .ok(object, [message])
       *
       * Asserts that `object` is truthy.
       *
       *     assert.ok('everything', 'everything is ok');
       *     assert.ok(false, 'this will fail');
       *
       * @name ok
       * @param {Mixed} object to test
       * @param {String} message
       * @api public
       */

      assert.ok = function (val, msg) {
        new Assertion(val, msg).is.ok;
      };

      /**
       * ### .equal(actual, expected, [message])
       *
       * Asserts non-strict equality (`==`) of `actual` and `expected`.
       *
       *     assert.equal(3, '3', '== coerces values to strings');
       *
       * @name equal
       * @param {Mixed} actual
       * @param {Mixed} expected
       * @param {String} message
       * @api public
       */

      assert.equal = function (act, exp, msg) {
        var test = new Assertion(act, msg);

        test.assert(
            exp == flag(test, 'object')
          , 'expected #{this} to equal #{exp}'
          , 'expected #{this} to not equal #{act}'
          , exp
          , act
        );
      };

      /**
       * ### .notEqual(actual, expected, [message])
       *
       * Asserts non-strict inequality (`!=`) of `actual` and `expected`.
       *
       *     assert.notEqual(3, 4, 'these numbers are not equal');
       *
       * @name notEqual
       * @param {Mixed} actual
       * @param {Mixed} expected
       * @param {String} message
       * @api public
       */

      assert.notEqual = function (act, exp, msg) {
        var test = new Assertion(act, msg);

        test.assert(
            exp != flag(test, 'object')
          , 'expected #{this} to not equal #{exp}'
          , 'expected #{this} to equal #{act}'
          , exp
          , act
        );
      };

      /**
       * ### .strictEqual(actual, expected, [message])
       *
       * Asserts strict equality (`===`) of `actual` and `expected`.
       *
       *     assert.strictEqual(true, true, 'these booleans are strictly equal');
       *
       * @name strictEqual
       * @param {Mixed} actual
       * @param {Mixed} expected
       * @param {String} message
       * @api public
       */

      assert.strictEqual = function (act, exp, msg) {
        new Assertion(act, msg).to.equal(exp);
      };

      /**
       * ### .notStrictEqual(actual, expected, [message])
       *
       * Asserts strict inequality (`!==`) of `actual` and `expected`.
       *
       *     assert.notStrictEqual(3, '3', 'no coercion for strict equality');
       *
       * @name notStrictEqual
       * @param {Mixed} actual
       * @param {Mixed} expected
       * @param {String} message
       * @api public
       */

      assert.notStrictEqual = function (act, exp, msg) {
        new Assertion(act, msg).to.not.equal(exp);
      };

      /**
       * ### .deepEqual(actual, expected, [message])
       *
       * Asserts that `actual` is deeply equal to `expected`.
       *
       *     assert.deepEqual({ tea: 'green' }, { tea: 'green' });
       *
       * @name deepEqual
       * @param {Mixed} actual
       * @param {Mixed} expected
       * @param {String} message
       * @api public
       */

      assert.deepEqual = function (act, exp, msg) {
        new Assertion(act, msg).to.eql(exp);
      };

      /**
       * ### .notDeepEqual(actual, expected, [message])
       *
       * Assert that `actual` is not deeply equal to `expected`.
       *
       *     assert.notDeepEqual({ tea: 'green' }, { tea: 'jasmine' });
       *
       * @name notDeepEqual
       * @param {Mixed} actual
       * @param {Mixed} expected
       * @param {String} message
       * @api public
       */

      assert.notDeepEqual = function (act, exp, msg) {
        new Assertion(act, msg).to.not.eql(exp);
      };

      /**
       * ### .isTrue(value, [message])
       *
       * Asserts that `value` is true.
       *
       *     var teaServed = true;
       *     assert.isTrue(teaServed, 'the tea has been served');
       *
       * @name isTrue
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isTrue = function (val, msg) {
        new Assertion(val, msg).is['true'];
      };

      /**
       * ### .isFalse(value, [message])
       *
       * Asserts that `value` is false.
       *
       *     var teaServed = false;
       *     assert.isFalse(teaServed, 'no tea yet? hmm...');
       *
       * @name isFalse
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isFalse = function (val, msg) {
        new Assertion(val, msg).is['false'];
      };

      /**
       * ### .isNull(value, [message])
       *
       * Asserts that `value` is null.
       *
       *     assert.isNull(err, 'there was no error');
       *
       * @name isNull
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isNull = function (val, msg) {
        new Assertion(val, msg).to.equal(null);
      };

      /**
       * ### .isNotNull(value, [message])
       *
       * Asserts that `value` is not null.
       *
       *     var tea = 'tasty chai';
       *     assert.isNotNull(tea, 'great, time for tea!');
       *
       * @name isNotNull
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isNotNull = function (val, msg) {
        new Assertion(val, msg).to.not.equal(null);
      };

      /**
       * ### .isUndefined(value, [message])
       *
       * Asserts that `value` is `undefined`.
       *
       *     var tea;
       *     assert.isUndefined(tea, 'no tea defined');
       *
       * @name isUndefined
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isUndefined = function (val, msg) {
        new Assertion(val, msg).to.equal(undefined);
      };

      /**
       * ### .isDefined(value, [message])
       *
       * Asserts that `value` is not `undefined`.
       *
       *     var tea = 'cup of chai';
       *     assert.isDefined(tea, 'tea has been defined');
       *
       * @name isUndefined
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isDefined = function (val, msg) {
        new Assertion(val, msg).to.not.equal(undefined);
      };

      /**
       * ### .isFunction(value, [message])
       *
       * Asserts that `value` is a function.
       *
       *     function serveTea() { return 'cup of tea'; };
       *     assert.isFunction(serveTea, 'great, we can have tea now');
       *
       * @name isFunction
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isFunction = function (val, msg) {
        new Assertion(val, msg).to.be.a('function');
      };

      /**
       * ### .isNotFunction(value, [message])
       *
       * Asserts that `value` is _not_ a function.
       *
       *     var serveTea = [ 'heat', 'pour', 'sip' ];
       *     assert.isNotFunction(serveTea, 'great, we have listed the steps');
       *
       * @name isNotFunction
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isNotFunction = function (val, msg) {
        new Assertion(val, msg).to.not.be.a('function');
      };

      /**
       * ### .isObject(value, [message])
       *
       * Asserts that `value` is an object (as revealed by
       * `Object.prototype.toString`).
       *
       *     var selection = { name: 'Chai', serve: 'with spices' };
       *     assert.isObject(selection, 'tea selection is an object');
       *
       * @name isObject
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isObject = function (val, msg) {
        new Assertion(val, msg).to.be.a('object');
      };

      /**
       * ### .isNotObject(value, [message])
       *
       * Asserts that `value` is _not_ an object.
       *
       *     var selection = 'chai'
       *     assert.isObject(selection, 'tea selection is not an object');
       *     assert.isObject(null, 'null is not an object');
       *
       * @name isNotObject
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isNotObject = function (val, msg) {
        new Assertion(val, msg).to.not.be.a('object');
      };

      /**
       * ### .isArray(value, [message])
       *
       * Asserts that `value` is an array.
       *
       *     var menu = [ 'green', 'chai', 'oolong' ];
       *     assert.isArray(menu, 'what kind of tea do we want?');
       *
       * @name isArray
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isArray = function (val, msg) {
        new Assertion(val, msg).to.be.an('array');
      };

      /**
       * ### .isNotArray(value, [message])
       *
       * Asserts that `value` is _not_ an array.
       *
       *     var menu = 'green|chai|oolong';
       *     assert.isNotArray(menu, 'what kind of tea do we want?');
       *
       * @name isNotArray
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isNotArray = function (val, msg) {
        new Assertion(val, msg).to.not.be.an('array');
      };

      /**
       * ### .isString(value, [message])
       *
       * Asserts that `value` is a string.
       *
       *     var teaOrder = 'chai';
       *     assert.isString(teaOrder, 'order placed');
       *
       * @name isString
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isString = function (val, msg) {
        new Assertion(val, msg).to.be.a('string');
      };

      /**
       * ### .isNotString(value, [message])
       *
       * Asserts that `value` is _not_ a string.
       *
       *     var teaOrder = 4;
       *     assert.isNotString(teaOrder, 'order placed');
       *
       * @name isNotString
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isNotString = function (val, msg) {
        new Assertion(val, msg).to.not.be.a('string');
      };

      /**
       * ### .isNumber(value, [message])
       *
       * Asserts that `value` is a number.
       *
       *     var cups = 2;
       *     assert.isNumber(cups, 'how many cups');
       *
       * @name isNumber
       * @param {Number} value
       * @param {String} message
       * @api public
       */

      assert.isNumber = function (val, msg) {
        new Assertion(val, msg).to.be.a('number');
      };

      /**
       * ### .isNotNumber(value, [message])
       *
       * Asserts that `value` is _not_ a number.
       *
       *     var cups = '2 cups please';
       *     assert.isNotNumber(cups, 'how many cups');
       *
       * @name isNotNumber
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isNotNumber = function (val, msg) {
        new Assertion(val, msg).to.not.be.a('number');
      };

      /**
       * ### .isBoolean(value, [message])
       *
       * Asserts that `value` is a boolean.
       *
       *     var teaReady = true
       *       , teaServed = false;
       *
       *     assert.isBoolean(teaReady, 'is the tea ready');
       *     assert.isBoolean(teaServed, 'has tea been served');
       *
       * @name isBoolean
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isBoolean = function (val, msg) {
        new Assertion(val, msg).to.be.a('boolean');
      };

      /**
       * ### .isNotBoolean(value, [message])
       *
       * Asserts that `value` is _not_ a boolean.
       *
       *     var teaReady = 'yep'
       *       , teaServed = 'nope';
       *
       *     assert.isNotBoolean(teaReady, 'is the tea ready');
       *     assert.isNotBoolean(teaServed, 'has tea been served');
       *
       * @name isNotBoolean
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.isNotBoolean = function (val, msg) {
        new Assertion(val, msg).to.not.be.a('boolean');
      };

      /**
       * ### .typeOf(value, name, [message])
       *
       * Asserts that `value`'s type is `name`, as determined by
       * `Object.prototype.toString`.
       *
       *     assert.typeOf({ tea: 'chai' }, 'object', 'we have an object');
       *     assert.typeOf(['chai', 'jasmine'], 'array', 'we have an array');
       *     assert.typeOf('tea', 'string', 'we have a string');
       *     assert.typeOf(/tea/, 'regexp', 'we have a regular expression');
       *     assert.typeOf(null, 'null', 'we have a null');
       *     assert.typeOf(undefined, 'undefined', 'we have an undefined');
       *
       * @name typeOf
       * @param {Mixed} value
       * @param {String} name
       * @param {String} message
       * @api public
       */

      assert.typeOf = function (val, type, msg) {
        new Assertion(val, msg).to.be.a(type);
      };

      /**
       * ### .notTypeOf(value, name, [message])
       *
       * Asserts that `value`'s type is _not_ `name`, as determined by
       * `Object.prototype.toString`.
       *
       *     assert.notTypeOf('tea', 'number', 'strings are not numbers');
       *
       * @name notTypeOf
       * @param {Mixed} value
       * @param {String} typeof name
       * @param {String} message
       * @api public
       */

      assert.notTypeOf = function (val, type, msg) {
        new Assertion(val, msg).to.not.be.a(type);
      };

      /**
       * ### .instanceOf(object, constructor, [message])
       *
       * Asserts that `value` is an instance of `constructor`.
       *
       *     var Tea = function (name) { this.name = name; }
       *       , chai = new Tea('chai');
       *
       *     assert.instanceOf(chai, Tea, 'chai is an instance of tea');
       *
       * @name instanceOf
       * @param {Object} object
       * @param {Constructor} constructor
       * @param {String} message
       * @api public
       */

      assert.instanceOf = function (val, type, msg) {
        new Assertion(val, msg).to.be.instanceOf(type);
      };

      /**
       * ### .notInstanceOf(object, constructor, [message])
       *
       * Asserts `value` is not an instance of `constructor`.
       *
       *     var Tea = function (name) { this.name = name; }
       *       , chai = new String('chai');
       *
       *     assert.notInstanceOf(chai, Tea, 'chai is not an instance of tea');
       *
       * @name notInstanceOf
       * @param {Object} object
       * @param {Constructor} constructor
       * @param {String} message
       * @api public
       */

      assert.notInstanceOf = function (val, type, msg) {
        new Assertion(val, msg).to.not.be.instanceOf(type);
      };

      /**
       * ### .include(haystack, needle, [message])
       *
       * Asserts that `haystack` includes `needle`. Works
       * for strings and arrays.
       *
       *     assert.include('foobar', 'bar', 'foobar contains string "bar"');
       *     assert.include([ 1, 2, 3 ], 3, 'array contains value');
       *
       * @name include
       * @param {Array|String} haystack
       * @param {Mixed} needle
       * @param {String} message
       * @api public
       */

      assert.include = function (exp, inc, msg) {
        var obj = new Assertion(exp, msg);

        if (Array.isArray(exp)) {
          obj.to.include(inc);
        } else if ('string' === typeof exp) {
          obj.to.contain.string(inc);
        }
      };

      /**
       * ### .match(value, regexp, [message])
       *
       * Asserts that `value` matches the regular expression `regexp`.
       *
       *     assert.match('foobar', /^foo/, 'regexp matches');
       *
       * @name match
       * @param {Mixed} value
       * @param {RegExp} regexp
       * @param {String} message
       * @api public
       */

      assert.match = function (exp, re, msg) {
        new Assertion(exp, msg).to.match(re);
      };

      /**
       * ### .notMatch(value, regexp, [message])
       *
       * Asserts that `value` does not match the regular expression `regexp`.
       *
       *     assert.notMatch('foobar', /^foo/, 'regexp does not match');
       *
       * @name notMatch
       * @param {Mixed} value
       * @param {RegExp} regexp
       * @param {String} message
       * @api public
       */

      assert.notMatch = function (exp, re, msg) {
        new Assertion(exp, msg).to.not.match(re);
      };

      /**
       * ### .property(object, property, [message])
       *
       * Asserts that `object` has a property named by `property`.
       *
       *     assert.property({ tea: { green: 'matcha' }}, 'tea');
       *
       * @name property
       * @param {Object} object
       * @param {String} property
       * @param {String} message
       * @api public
       */

      assert.property = function (obj, prop, msg) {
        new Assertion(obj, msg).to.have.property(prop);
      };

      /**
       * ### .notProperty(object, property, [message])
       *
       * Asserts that `object` does _not_ have a property named by `property`.
       *
       *     assert.notProperty({ tea: { green: 'matcha' }}, 'coffee');
       *
       * @name notProperty
       * @param {Object} object
       * @param {String} property
       * @param {String} message
       * @api public
       */

      assert.notProperty = function (obj, prop, msg) {
        new Assertion(obj, msg).to.not.have.property(prop);
      };

      /**
       * ### .deepProperty(object, property, [message])
       *
       * Asserts that `object` has a property named by `property`, which can be a
       * string using dot- and bracket-notation for deep reference.
       *
       *     assert.deepProperty({ tea: { green: 'matcha' }}, 'tea.green');
       *
       * @name deepProperty
       * @param {Object} object
       * @param {String} property
       * @param {String} message
       * @api public
       */

      assert.deepProperty = function (obj, prop, msg) {
        new Assertion(obj, msg).to.have.deep.property(prop);
      };

      /**
       * ### .notDeepProperty(object, property, [message])
       *
       * Asserts that `object` does _not_ have a property named by `property`, which
       * can be a string using dot- and bracket-notation for deep reference.
       *
       *     assert.notDeepProperty({ tea: { green: 'matcha' }}, 'tea.oolong');
       *
       * @name notDeepProperty
       * @param {Object} object
       * @param {String} property
       * @param {String} message
       * @api public
       */

      assert.notDeepProperty = function (obj, prop, msg) {
        new Assertion(obj, msg).to.not.have.deep.property(prop);
      };

      /**
       * ### .propertyVal(object, property, value, [message])
       *
       * Asserts that `object` has a property named by `property` with value given
       * by `value`.
       *
       *     assert.propertyVal({ tea: 'is good' }, 'tea', 'is good');
       *
       * @name propertyVal
       * @param {Object} object
       * @param {String} property
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.propertyVal = function (obj, prop, val, msg) {
        new Assertion(obj, msg).to.have.property(prop, val);
      };

      /**
       * ### .propertyNotVal(object, property, value, [message])
       *
       * Asserts that `object` has a property named by `property`, but with a value
       * different from that given by `value`.
       *
       *     assert.propertyNotVal({ tea: 'is good' }, 'tea', 'is bad');
       *
       * @name propertyNotVal
       * @param {Object} object
       * @param {String} property
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.propertyNotVal = function (obj, prop, val, msg) {
        new Assertion(obj, msg).to.not.have.property(prop, val);
      };

      /**
       * ### .deepPropertyVal(object, property, value, [message])
       *
       * Asserts that `object` has a property named by `property` with value given
       * by `value`. `property` can use dot- and bracket-notation for deep
       * reference.
       *
       *     assert.deepPropertyVal({ tea: { green: 'matcha' }}, 'tea.green', 'matcha');
       *
       * @name deepPropertyVal
       * @param {Object} object
       * @param {String} property
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.deepPropertyVal = function (obj, prop, val, msg) {
        new Assertion(obj, msg).to.have.deep.property(prop, val);
      };

      /**
       * ### .deepPropertyNotVal(object, property, value, [message])
       *
       * Asserts that `object` has a property named by `property`, but with a value
       * different from that given by `value`. `property` can use dot- and
       * bracket-notation for deep reference.
       *
       *     assert.deepPropertyNotVal({ tea: { green: 'matcha' }}, 'tea.green', 'konacha');
       *
       * @name deepPropertyNotVal
       * @param {Object} object
       * @param {String} property
       * @param {Mixed} value
       * @param {String} message
       * @api public
       */

      assert.deepPropertyNotVal = function (obj, prop, val, msg) {
        new Assertion(obj, msg).to.not.have.deep.property(prop, val);
      };

      /**
       * ### .lengthOf(object, length, [message])
       *
       * Asserts that `object` has a `length` property with the expected value.
       *
       *     assert.lengthOf([1,2,3], 3, 'array has length of 3');
       *     assert.lengthOf('foobar', 5, 'string has length of 6');
       *
       * @name lengthOf
       * @param {Mixed} object
       * @param {Number} length
       * @param {String} message
       * @api public
       */

      assert.lengthOf = function (exp, len, msg) {
        new Assertion(exp, msg).to.have.length(len);
      };

      /**
       * ### .throws(function, [constructor/string/regexp], [string/regexp], [message])
       *
       * Asserts that `function` will throw an error that is an instance of
       * `constructor`, or alternately that it will throw an error with message
       * matching `regexp`.
       *
       *     assert.throw(fn, 'function throws a reference error');
       *     assert.throw(fn, /function throws a reference error/);
       *     assert.throw(fn, ReferenceError);
       *     assert.throw(fn, ReferenceError, 'function throws a reference error');
       *     assert.throw(fn, ReferenceError, /function throws a reference error/);
       *
       * @name throws
       * @alias throw
       * @alias Throw
       * @param {Function} function
       * @param {ErrorConstructor} constructor
       * @param {RegExp} regexp
       * @param {String} message
       * @see https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Error#Error_types
       * @api public
       */

      assert.Throw = function (fn, errt, errs, msg) {
        if ('string' === typeof errt || errt instanceof RegExp) {
          errs = errt;
          errt = null;
        }

        new Assertion(fn, msg).to.Throw(errt, errs);
      };

      /**
       * ### .doesNotThrow(function, [constructor/regexp], [message])
       *
       * Asserts that `function` will _not_ throw an error that is an instance of
       * `constructor`, or alternately that it will not throw an error with message
       * matching `regexp`.
       *
       *     assert.doesNotThrow(fn, Error, 'function does not throw');
       *
       * @name doesNotThrow
       * @param {Function} function
       * @param {ErrorConstructor} constructor
       * @param {RegExp} regexp
       * @param {String} message
       * @see https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Error#Error_types
       * @api public
       */

      assert.doesNotThrow = function (fn, type, msg) {
        if ('string' === typeof type) {
          msg = type;
          type = null;
        }

        new Assertion(fn, msg).to.not.Throw(type);
      };

      /**
       * ### .operator(val1, operator, val2, [message])
       *
       * Compares two values using `operator`.
       *
       *     assert.operator(1, '<', 2, 'everything is ok');
       *     assert.operator(1, '>', 2, 'this will fail');
       *
       * @name operator
       * @param {Mixed} val1
       * @param {String} operator
       * @param {Mixed} val2
       * @param {String} message
       * @api public
       */

      assert.operator = function (val, operator, val2, msg) {
        if (!~['==', '===', '>', '>=', '<', '<=', '!=', '!=='].indexOf(operator)) {
          throw new Error('Invalid operator "' + operator + '"');
        }
        var test = new Assertion(eval(val + operator + val2), msg);
        test.assert(
            true === flag(test, 'object')
          , 'expected ' + util.inspect(val) + ' to be ' + operator + ' ' + util.inspect(val2)
          , 'expected ' + util.inspect(val) + ' to not be ' + operator + ' ' + util.inspect(val2) );
      };

      /**
       * ### .closeTo(actual, expected, delta, [message])
       *
       * Asserts that the target is equal `expected`, to within a +/- `delta` range.
       *
       *     assert.closeTo(1.5, 1, 0.5, 'numbers are close');
       *
       * @name closeTo
       * @param {Number} actual
       * @param {Number} expected
       * @param {Number} delta
       * @param {String} message
       * @api public
       */

      assert.closeTo = function (act, exp, delta, msg) {
        new Assertion(act, msg).to.be.closeTo(exp, delta);
      };

      /*!
       * Undocumented / untested
       */

      assert.ifError = function (val, msg) {
        new Assertion(val, msg).to.not.be.ok;
      };

      /*!
       * Aliases.
       */

      (function alias(name, as){
        assert[as] = assert[name];
        return alias;
      })
      ('Throw', 'throw')
      ('Throw', 'throws');
    };

  }); // module: chai/interface/assert.js

  require.register("chai/interface/expect.js", function(module, exports, require){
    /*!
     * chai
     * Copyright(c) 2011-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    module.exports = function (chai, util) {
      chai.expect = function (val, message) {
        return new chai.Assertion(val, message);
      };
    };


  }); // module: chai/interface/expect.js

  require.register("chai/interface/should.js", function(module, exports, require){
    /*!
     * chai
     * Copyright(c) 2011-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    module.exports = function (chai, util) {
      var Assertion = chai.Assertion;

      function loadShould () {
        // modify Object.prototype to have `should`
        Object.defineProperty(Object.prototype, 'should',
          {
            set: function (value) {
              // See https://github.com/chaijs/chai/issues/86: this makes
              // `whatever.should = someValue` actually set `someValue`, which is
              // especially useful for `global.should = require('chai').should()`.
              //
              // Note that we have to use [[DefineProperty]] instead of [[Put]]
              // since otherwise we would trigger this very setter!
              Object.defineProperty(this, 'should', {
                value: value,
                enumerable: true,
                configurable: true,
                writable: true
              });
            }
          , get: function(){
              if (this instanceof String || this instanceof Number) {
                return new Assertion(this.constructor(this));
              } else if (this instanceof Boolean) {
                return new Assertion(this == true);
              }
              return new Assertion(this);
            }
          , configurable: true
        });

        var should = {};

        should.equal = function (val1, val2, msg) {
          new Assertion(val1, msg).to.equal(val2);
        };

        should.Throw = function (fn, errt, errs, msg) {
          new Assertion(fn, msg).to.Throw(errt, errs);
        };

        should.exist = function (val, msg) {
          new Assertion(val, msg).to.exist;
        }

        // negation
        should.not = {}

        should.not.equal = function (val1, val2, msg) {
          new Assertion(val1, msg).to.not.equal(val2);
        };

        should.not.Throw = function (fn, errt, errs, msg) {
          new Assertion(fn, msg).to.not.Throw(errt, errs);
        };

        should.not.exist = function (val, msg) {
          new Assertion(val, msg).to.not.exist;
        }

        should['throw'] = should['Throw'];
        should.not['throw'] = should.not['Throw'];

        return should;
      };

      chai.should = loadShould;
      chai.Should = loadShould;
    };

  }); // module: chai/interface/should.js

  require.register("chai/utils/addChainableMethod.js", function(module, exports, require){
    /*!
     * Chai - addChainingMethod utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /*!
     * Module dependencies
     */

    var transferFlags = require('./transferFlags');

    /*!
     * Module variables
     */

    // Check whether `__proto__` is supported
    var hasProtoSupport = '__proto__' in Object;

    // Without `__proto__` support, this module will need to add properties to a function.
    // However, some Function.prototype methods cannot be overwritten,
    // and there seems no easy cross-platform way to detect them (@see chaijs/chai/issues/69).
    var excludeNames = /^(?:length|name|arguments|caller)$/;

    /**
     * ### addChainableMethod (ctx, name, method, chainingBehavior)
     *
     * Adds a method to an object, such that the method can also be chained.
     *
     *     utils.addChainableMethod(chai.Assertion.prototype, 'foo', function (str) {
     *       var obj = utils.flag(this, 'object');
     *       new chai.Assertion(obj).to.be.equal(str);
     *     });
     *
     * Can also be accessed directly from `chai.Assertion`.
     *
     *     chai.Assertion.addChainableMethod('foo', fn, chainingBehavior);
     *
     * The result can then be used as both a method assertion, executing both `method` and
     * `chainingBehavior`, or as a language chain, which only executes `chainingBehavior`.
     *
     *     expect(fooStr).to.be.foo('bar');
     *     expect(fooStr).to.be.foo.equal('foo');
     *
     * @param {Object} ctx object to which the method is added
     * @param {String} name of method to add
     * @param {Function} method function to be used for `name`, when called
     * @param {Function} chainingBehavior function to be called every time the property is accessed
     * @name addChainableMethod
     * @api public
     */

    module.exports = function (ctx, name, method, chainingBehavior) {
      if (typeof chainingBehavior !== 'function')
        chainingBehavior = function () { };

      Object.defineProperty(ctx, name,
        { get: function () {
            chainingBehavior.call(this);

            var assert = function () {
              var result = method.apply(this, arguments);
              return result === undefined ? this : result;
            };

            // Use `__proto__` if available
            if (hasProtoSupport) {
              assert.__proto__ = this;
            }
            // Otherwise, redefine all properties (slow!)
            else {
              var asserterNames = Object.getOwnPropertyNames(ctx);
              asserterNames.forEach(function (asserterName) {
                if (!excludeNames.test(asserterName)) {
                  var pd = Object.getOwnPropertyDescriptor(ctx, asserterName);
                  Object.defineProperty(assert, asserterName, pd);
                }
              });
            }

            transferFlags(this, assert);
            return assert;
          }
        , configurable: true
      });
    };

  }); // module: chai/utils/addChainableMethod.js

  require.register("chai/utils/addMethod.js", function(module, exports, require){
    /*!
     * Chai - addMethod utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * ### .addMethod (ctx, name, method)
     *
     * Adds a method to the prototype of an object.
     *
     *     utils.addMethod(chai.Assertion.prototype, 'foo', function (str) {
     *       var obj = utils.flag(this, 'object');
     *       new chai.Assertion(obj).to.be.equal(str);
     *     });
     *
     * Can also be accessed directly from `chai.Assertion`.
     *
     *     chai.Assertion.addMethod('foo', fn);
     *
     * Then can be used as any other assertion.
     *
     *     expect(fooStr).to.be.foo('bar');
     *
     * @param {Object} ctx object to which the method is added
     * @param {String} name of method to add
     * @param {Function} method function to be used for name
     * @name addMethod
     * @api public
     */

    module.exports = function (ctx, name, method) {
      ctx[name] = function () {
        var result = method.apply(this, arguments);
        return result === undefined ? this : result;
      };
    };

  }); // module: chai/utils/addMethod.js

  require.register("chai/utils/addProperty.js", function(module, exports, require){
    /*!
     * Chai - addProperty utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * ### addProperty (ctx, name, getter)
     *
     * Adds a property to the prototype of an object.
     *
     *     utils.addProperty(chai.Assertion.prototype, 'foo', function () {
     *       var obj = utils.flag(this, 'object');
     *       new chai.Assertion(obj).to.be.instanceof(Foo);
     *     });
     *
     * Can also be accessed directly from `chai.Assertion`.
     *
     *     chai.Assertion.addProperty('foo', fn);
     *
     * Then can be used as any other assertion.
     *
     *     expect(myFoo).to.be.foo;
     *
     * @param {Object} ctx object to which the property is added
     * @param {String} name of property to add
     * @param {Function} getter function to be used for name
     * @name addProperty
     * @api public
     */

    module.exports = function (ctx, name, getter) {
      Object.defineProperty(ctx, name,
        { get: function () {
            var result = getter.call(this);
            return result === undefined ? this : result;
          }
        , configurable: true
      });
    };

  }); // module: chai/utils/addProperty.js

  require.register("chai/utils/eql.js", function(module, exports, require){
    // This is (almost) directly from Node.js assert
    // https://github.com/joyent/node/blob/f8c335d0caf47f16d31413f89aa28eda3878e3aa/lib/assert.js

    module.exports = _deepEqual;

    var getEnumerableProperties = require('./getEnumerableProperties');

    // for the browser
    var Buffer;
    try {
      Buffer = require('buffer').Buffer;
    } catch (ex) {
      Buffer = {
        isBuffer: function () { return false; }
      };
    }

    function _deepEqual(actual, expected, memos) {

      // 7.1. All identical values are equivalent, as determined by ===.
      if (actual === expected) {
        return true;

      } else if (Buffer.isBuffer(actual) && Buffer.isBuffer(expected)) {
        if (actual.length != expected.length) return false;

        for (var i = 0; i < actual.length; i++) {
          if (actual[i] !== expected[i]) return false;
        }

        return true;

      // 7.2. If the expected value is a Date object, the actual value is
      // equivalent if it is also a Date object that refers to the same time.
      } else if (actual instanceof Date && expected instanceof Date) {
        return actual.getTime() === expected.getTime();

      // 7.3. Other pairs that do not both pass typeof value == 'object',
      // equivalence is determined by ==.
      } else if (typeof actual != 'object' && typeof expected != 'object') {
        return actual === expected;

      // 7.4. For all other Object pairs, including Array objects, equivalence is
      // determined by having the same number of owned properties (as verified
      // with Object.prototype.hasOwnProperty.call), the same set of keys
      // (although not necessarily the same order), equivalent values for every
      // corresponding key, and an identical 'prototype' property. Note: this
      // accounts for both named and indexed properties on Arrays.
      } else {
        return objEquiv(actual, expected, memos);
      }
    }

    function isUndefinedOrNull(value) {
      return value === null || value === undefined;
    }

    function isArguments(object) {
      return Object.prototype.toString.call(object) == '[object Arguments]';
    }

    function objEquiv(a, b, memos) {
      if (isUndefinedOrNull(a) || isUndefinedOrNull(b))
        return false;

      // an identical 'prototype' property.
      if (a.prototype !== b.prototype) return false;

      // check if we have already compared a and b
      var i;
      if (memos) {
        for(i = 0; i < memos.length; i++) {
          if ((memos[i][0] === a && memos[i][1] === b) ||
              (memos[i][0] === b && memos[i][1] === a))
            return true;
        }
      } else {
        memos = [];
      }

      //~~~I've managed to break Object.keys through screwy arguments passing.
      //   Converting to array solves the problem.
      if (isArguments(a)) {
        if (!isArguments(b)) {
          return false;
        }
        a = pSlice.call(a);
        b = pSlice.call(b);
        return _deepEqual(a, b, memos);
      }
      try {
        var ka = getEnumerableProperties(a),
            kb = getEnumerableProperties(b),
            key;
      } catch (e) {//happens when one is a string literal and the other isn't
        return false;
      }

      // having the same number of owned properties (keys incorporates
      // hasOwnProperty)
      if (ka.length != kb.length)
        return false;

      //the same set of keys (although not necessarily the same order),
      ka.sort();
      kb.sort();
      //~~~cheap key test
      for (i = ka.length - 1; i >= 0; i--) {
        if (ka[i] != kb[i])
          return false;
      }

      // remember objects we have compared to guard against circular references
      memos.push([ a, b ]);

      //equivalent values for every corresponding key, and
      //~~~possibly expensive deep test
      for (i = ka.length - 1; i >= 0; i--) {
        key = ka[i];
        if (!_deepEqual(a[key], b[key], memos)) return false;
      }

      return true;
    }

  }); // module: chai/utils/eql.js

  require.register("chai/utils/flag.js", function(module, exports, require){
    /*!
     * Chai - flag utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * ### flag(object ,key, [value])
     *
     * Get or set a flag value on an object. If a
     * value is provided it will be set, else it will
     * return the currently set value or `undefined` if
     * the value is not set.
     *
     *     utils.flag(this, 'foo', 'bar'); // setter
     *     utils.flag(this, 'foo'); // getter, returns `bar`
     *
     * @param {Object} object (constructed Assertion
     * @param {String} key
     * @param {Mixed} value (optional)
     * @name flag
     * @api private
     */

    module.exports = function (obj, key, value) {
      var flags = obj.__flags || (obj.__flags = Object.create(null));
      if (arguments.length === 3) {
        flags[key] = value;
      } else {
        return flags[key];
      }
    };

  }); // module: chai/utils/flag.js

  require.register("chai/utils/getActual.js", function(module, exports, require){
    /*!
     * Chai - getActual utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * # getActual(object, [actual])
     *
     * Returns the `actual` value for an Assertion
     *
     * @param {Object} object (constructed Assertion)
     * @param {Arguments} chai.Assertion.prototype.assert arguments
     */

    module.exports = function (obj, args) {
      var actual = args[4];
      return 'undefined' !== typeof actual ? actual : obj._obj;
    };

  }); // module: chai/utils/getActual.js

  require.register("chai/utils/getEnumerableProperties.js", function(module, exports, require){
    /*!
     * Chai - getEnumerableProperties utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * ### .getEnumerableProperties(object)
     *
     * This allows the retrieval of enumerable property names of an object,
     * inherited or not.
     *
     * @param {Object} object
     * @returns {Array}
     * @name getEnumerableProperties
     * @api public
     */

    module.exports = function getEnumerableProperties(object) {
      var result = [];
      for (var name in object) {
        result.push(name);
      }
      return result;
    };

  }); // module: chai/utils/getEnumerableProperties.js

  require.register("chai/utils/getMessage.js", function(module, exports, require){
    /*!
     * Chai - message composition utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /*!
     * Module dependancies
     */

    var flag = require('./flag')
      , getActual = require('./getActual')
      , inspect = require('./inspect')
      , objDisplay = require('./objDisplay');

    /**
     * ### .getMessage(object, message, negateMessage)
     *
     * Construct the error message based on flags
     * and template tags. Template tags will return
     * a stringified inspection of the object referenced.
     *
     * Messsage template tags:
     * - `#{this}` current asserted object
     * - `#{act}` actual value
     * - `#{exp}` expected value
     *
     * @param {Object} object (constructed Assertion)
     * @param {Arguments} chai.Assertion.prototype.assert arguments
     * @name getMessage
     * @api public
     */

    module.exports = function (obj, args) {
      var negate = flag(obj, 'negate')
        , val = flag(obj, 'object')
        , expected = args[3]
        , actual = getActual(obj, args)
        , msg = negate ? args[2] : args[1]
        , flagMsg = flag(obj, 'message');

      msg = msg || '';
      msg = msg
        .replace(/#{this}/g, objDisplay(val))
        .replace(/#{act}/g, objDisplay(actual))
        .replace(/#{exp}/g, objDisplay(expected));

      return flagMsg ? flagMsg + ': ' + msg : msg;
    };

  }); // module: chai/utils/getMessage.js

  require.register("chai/utils/getName.js", function(module, exports, require){
    /*!
     * Chai - getName utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * # getName(func)
     *
     * Gets the name of a function, in a cross-browser way.
     *
     * @param {Function} a function (usually a constructor)
     */

    module.exports = function (func) {
      if (func.name) return func.name;

      var match = /^\s?function ([^(]*)\(/.exec(func);
      return match && match[1] ? match[1] : "";
    };

  }); // module: chai/utils/getName.js

  require.register("chai/utils/getPathValue.js", function(module, exports, require){
    /*!
     * Chai - getPathValue utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * @see https://github.com/logicalparadox/filtr
     * MIT Licensed
     */

    /**
     * ### .getPathValue(path, object)
     *
     * This allows the retrieval of values in an
     * object given a string path.
     *
     *     var obj = {
     *         prop1: {
     *             arr: ['a', 'b', 'c']
     *           , str: 'Hello'
     *         }
     *       , prop2: {
     *             arr: [ { nested: 'Universe' } ]
     *           , str: 'Hello again!'
     *         }
     *     }
     *
     * The following would be the results.
     *
     *     getPathValue('prop1.str', obj); // Hello
     *     getPathValue('prop1.att[2]', obj); // b
     *     getPathValue('prop2.arr[0].nested', obj); // Universe
     *
     * @param {String} path
     * @param {Object} object
     * @returns {Object} value or `undefined`
     * @name getPathValue
     * @api public
     */

    var getPathValue = module.exports = function (path, obj) {
      var parsed = parsePath(path);
      return _getPathValue(parsed, obj);
    };

    /*!
     * ## parsePath(path)
     *
     * Helper function used to parse string object
     * paths. Use in conjunction with `_getPathValue`.
     *
     *      var parsed = parsePath('myobject.property.subprop');
     *
     * ### Paths:
     *
     * * Can be as near infinitely deep and nested
     * * Arrays are also valid using the formal `myobject.document[3].property`.
     *
     * @param {String} path
     * @returns {Object} parsed
     * @api private
     */

    function parsePath (path) {
      var str = path.replace(/\[/g, '.[')
        , parts = str.match(/(\\\.|[^.]+?)+/g);
      return parts.map(function (value) {
        var re = /\[(\d+)\]$/
          , mArr = re.exec(value)
        if (mArr) return { i: parseFloat(mArr[1]) };
        else return { p: value };
      });
    };

    /*!
     * ## _getPathValue(parsed, obj)
     *
     * Helper companion function for `.parsePath` that returns
     * the value located at the parsed address.
     *
     *      var value = getPathValue(parsed, obj);
     *
     * @param {Object} parsed definition from `parsePath`.
     * @param {Object} object to search against
     * @returns {Object|Undefined} value
     * @api private
     */

    function _getPathValue (parsed, obj) {
      var tmp = obj
        , res;
      for (var i = 0, l = parsed.length; i < l; i++) {
        var part = parsed[i];
        if (tmp) {
          if ('undefined' !== typeof part.p)
            tmp = tmp[part.p];
          else if ('undefined' !== typeof part.i)
            tmp = tmp[part.i];
          if (i == (l - 1)) res = tmp;
        } else {
          res = undefined;
        }
      }
      return res;
    };

  }); // module: chai/utils/getPathValue.js

  require.register("chai/utils/getProperties.js", function(module, exports, require){
    /*!
     * Chai - getProperties utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * ### .getProperties(object)
     *
     * This allows the retrieval of property names of an object, enumerable or not,
     * inherited or not.
     *
     * @param {Object} object
     * @returns {Array}
     * @name getProperties
     * @api public
     */

    module.exports = function getProperties(object) {
      var result = Object.getOwnPropertyNames(subject);

      function addProperty(property) {
        if (result.indexOf(property) === -1) {
          result.push(property);
        }
      }

      var proto = Object.getPrototypeOf(subject);
      while (proto !== null) {
        Object.getOwnPropertyNames(proto).forEach(addProperty);
        proto = Object.getPrototypeOf(proto);
      }

      return result;
    };

  }); // module: chai/utils/getProperties.js

  require.register("chai/utils/index.js", function(module, exports, require){
    /*!
     * chai
     * Copyright(c) 2011 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /*!
     * Main exports
     */

    var exports = module.exports = {};

    /*!
     * test utility
     */

    exports.test = require('./test');

    /*!
     * type utility
     */

    exports.type = require('./type');

    /*!
     * message utility
     */

    exports.getMessage = require('./getMessage');

    /*!
     * actual utility
     */

    exports.getActual = require('./getActual');

    /*!
     * Inspect util
     */

    exports.inspect = require('./inspect');

    /*!
     * Object Display util
     */

    exports.objDisplay = require('./objDisplay');

    /*!
     * Flag utility
     */

    exports.flag = require('./flag');

    /*!
     * Flag transferring utility
     */

    exports.transferFlags = require('./transferFlags');

    /*!
     * Deep equal utility
     */

    exports.eql = require('./eql');

    /*!
     * Deep path value
     */

    exports.getPathValue = require('./getPathValue');

    /*!
     * Function name
     */

    exports.getName = require('./getName');

    /*!
     * add Property
     */

    exports.addProperty = require('./addProperty');

    /*!
     * add Method
     */

    exports.addMethod = require('./addMethod');

    /*!
     * overwrite Property
     */

    exports.overwriteProperty = require('./overwriteProperty');

    /*!
     * overwrite Method
     */

    exports.overwriteMethod = require('./overwriteMethod');

    /*!
     * Add a chainable method
     */

    exports.addChainableMethod = require('./addChainableMethod');


  }); // module: chai/utils/index.js

  require.register("chai/utils/inspect.js", function(module, exports, require){
    // This is (almost) directly from Node.js utils
    // https://github.com/joyent/node/blob/f8c335d0caf47f16d31413f89aa28eda3878e3aa/lib/util.js

    var getName = require('./getName');
    var getProperties = require('./getProperties');
    var getEnumerableProperties = require('./getEnumerableProperties');

    module.exports = inspect;

    /**
     * Echos the value of a value. Trys to print the value out
     * in the best way possible given the different types.
     *
     * @param {Object} obj The object to print out.
     * @param {Boolean} showHidden Flag that shows hidden (not enumerable)
     *    properties of objects.
     * @param {Number} depth Depth in which to descend in object. Default is 2.
     * @param {Boolean} colors Flag to turn on ANSI escape codes to color the
     *    output. Default is false (no coloring).
     */
    function inspect(obj, showHidden, depth, colors) {
      var ctx = {
        showHidden: showHidden,
        seen: [],
        stylize: function (str) { return str; }
      };
      return formatValue(ctx, obj, (typeof depth === 'undefined' ? 2 : depth));
    }

    // https://gist.github.com/1044128/
    var getOuterHTML = function(element) {
      if ('outerHTML' in element) return element.outerHTML;
      var ns = "http://www.w3.org/1999/xhtml";
      var container = document.createElementNS(ns, '_');
      var elemProto = (window.HTMLElement || window.Element).prototype;
      var xmlSerializer = new XMLSerializer();
      var html;
      if (document.xmlVersion) {
        return xmlSerializer.serializeToString(element);
      } else {
        container.appendChild(element.cloneNode(false));
        html = container.innerHTML.replace('><', '>' + element.innerHTML + '<');
        container.innerHTML = '';
        return html;
      }
    };

    // Returns true if object is a DOM element.
    var isDOMElement = function (object) {
      if (typeof HTMLElement === 'object') {
        return object instanceof HTMLElement;
      } else {
        return object &&
          typeof object === 'object' &&
          object.nodeType === 1 &&
          typeof object.nodeName === 'string';
      }
    };

    function formatValue(ctx, value, recurseTimes) {
      // Provide a hook for user-specified inspect functions.
      // Check that value is an object with an inspect function on it
      if (value && typeof value.inspect === 'function' &&
          // Filter out the util module, it's inspect function is special
          value.inspect !== exports.inspect &&
          // Also filter out any prototype objects using the circular check.
          !(value.constructor && value.constructor.prototype === value)) {
        return value.inspect(recurseTimes);
      }

      // Primitive types cannot have properties
      var primitive = formatPrimitive(ctx, value);
      if (primitive) {
        return primitive;
      }

      // If it's DOM elem, get outer HTML.
      if (isDOMElement(value)) {
        return getOuterHTML(value);
      }

      // Look up the keys of the object.
      var visibleKeys = getEnumerableProperties(value);
      var keys = ctx.showHidden ? getProperties(value) : visibleKeys;

      // Some type of object without properties can be shortcutted.
      // In IE, errors have a single `stack` property, or if they are vanilla `Error`,
      // a `stack` plus `description` property; ignore those for consistency.
      if (keys.length === 0 || (isError(value) && (
          (keys.length === 1 && keys[0] === 'stack') ||
          (keys.length === 2 && keys[0] === 'description' && keys[1] === 'stack')
         ))) {
        if (typeof value === 'function') {
          var name = getName(value);
          var nameSuffix = name ? ': ' + name : '';
          return ctx.stylize('[Function' + nameSuffix + ']', 'special');
        }
        if (isRegExp(value)) {
          return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
        }
        if (isDate(value)) {
          return ctx.stylize(Date.prototype.toUTCString.call(value), 'date');
        }
        if (isError(value)) {
          return formatError(value);
        }
      }

      var base = '', array = false, braces = ['{', '}'];

      // Make Array say that they are Array
      if (isArray(value)) {
        array = true;
        braces = ['[', ']'];
      }

      // Make functions say that they are functions
      if (typeof value === 'function') {
        var name = getName(value);
        var nameSuffix = name ? ': ' + name : '';
        base = ' [Function' + nameSuffix + ']';
      }

      // Make RegExps say that they are RegExps
      if (isRegExp(value)) {
        base = ' ' + RegExp.prototype.toString.call(value);
      }

      // Make dates with properties first say the date
      if (isDate(value)) {
        base = ' ' + Date.prototype.toUTCString.call(value);
      }

      // Make error with message first say the error
      if (isError(value)) {
        return formatError(value);
      }

      if (keys.length === 0 && (!array || value.length == 0)) {
        return braces[0] + base + braces[1];
      }

      if (recurseTimes < 0) {
        if (isRegExp(value)) {
          return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
        } else {
          return ctx.stylize('[Object]', 'special');
        }
      }

      ctx.seen.push(value);

      var output;
      if (array) {
        output = formatArray(ctx, value, recurseTimes, visibleKeys, keys);
      } else {
        output = keys.map(function(key) {
          return formatProperty(ctx, value, recurseTimes, visibleKeys, key, array);
        });
      }

      ctx.seen.pop();

      return reduceToSingleString(output, base, braces);
    }


    function formatPrimitive(ctx, value) {
      switch (typeof value) {
        case 'undefined':
          return ctx.stylize('undefined', 'undefined');

        case 'string':
          var simple = '\'' + JSON.stringify(value).replace(/^"|"$/g, '')
                                                   .replace(/'/g, "\\'")
                                                   .replace(/\\"/g, '"') + '\'';
          return ctx.stylize(simple, 'string');

        case 'number':
          return ctx.stylize('' + value, 'number');

        case 'boolean':
          return ctx.stylize('' + value, 'boolean');
      }
      // For some reason typeof null is "object", so special case here.
      if (value === null) {
        return ctx.stylize('null', 'null');
      }
    }


    function formatError(value) {
      return '[' + Error.prototype.toString.call(value) + ']';
    }


    function formatArray(ctx, value, recurseTimes, visibleKeys, keys) {
      var output = [];
      for (var i = 0, l = value.length; i < l; ++i) {
        if (Object.prototype.hasOwnProperty.call(value, String(i))) {
          output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
              String(i), true));
        } else {
          output.push('');
        }
      }
      keys.forEach(function(key) {
        if (!key.match(/^\d+$/)) {
          output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
              key, true));
        }
      });
      return output;
    }


    function formatProperty(ctx, value, recurseTimes, visibleKeys, key, array) {
      var name, str;
      if (value.__lookupGetter__) {
        if (value.__lookupGetter__(key)) {
          if (value.__lookupSetter__(key)) {
            str = ctx.stylize('[Getter/Setter]', 'special');
          } else {
            str = ctx.stylize('[Getter]', 'special');
          }
        } else {
          if (value.__lookupSetter__(key)) {
            str = ctx.stylize('[Setter]', 'special');
          }
        }
      }
      if (visibleKeys.indexOf(key) < 0) {
        name = '[' + key + ']';
      }
      if (!str) {
        if (ctx.seen.indexOf(value[key]) < 0) {
          if (recurseTimes === null) {
            str = formatValue(ctx, value[key], null);
          } else {
            str = formatValue(ctx, value[key], recurseTimes - 1);
          }
          if (str.indexOf('\n') > -1) {
            if (array) {
              str = str.split('\n').map(function(line) {
                return '  ' + line;
              }).join('\n').substr(2);
            } else {
              str = '\n' + str.split('\n').map(function(line) {
                return '   ' + line;
              }).join('\n');
            }
          }
        } else {
          str = ctx.stylize('[Circular]', 'special');
        }
      }
      if (typeof name === 'undefined') {
        if (array && key.match(/^\d+$/)) {
          return str;
        }
        name = JSON.stringify('' + key);
        if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
          name = name.substr(1, name.length - 2);
          name = ctx.stylize(name, 'name');
        } else {
          name = name.replace(/'/g, "\\'")
                     .replace(/\\"/g, '"')
                     .replace(/(^"|"$)/g, "'");
          name = ctx.stylize(name, 'string');
        }
      }

      return name + ': ' + str;
    }


    function reduceToSingleString(output, base, braces) {
      var numLinesEst = 0;
      var length = output.reduce(function(prev, cur) {
        numLinesEst++;
        if (cur.indexOf('\n') >= 0) numLinesEst++;
        return prev + cur.length + 1;
      }, 0);

      if (length > 60) {
        return braces[0] +
               (base === '' ? '' : base + '\n ') +
               ' ' +
               output.join(',\n  ') +
               ' ' +
               braces[1];
      }

      return braces[0] + base + ' ' + output.join(', ') + ' ' + braces[1];
    }

    function isArray(ar) {
      return Array.isArray(ar) ||
             (typeof ar === 'object' && objectToString(ar) === '[object Array]');
    }

    function isRegExp(re) {
      return typeof re === 'object' && objectToString(re) === '[object RegExp]';
    }

    function isDate(d) {
      return typeof d === 'object' && objectToString(d) === '[object Date]';
    }

    function isError(e) {
      return typeof e === 'object' && objectToString(e) === '[object Error]';
    }

    function objectToString(o) {
      return Object.prototype.toString.call(o);
    }

  }); // module: chai/utils/inspect.js

  require.register("chai/utils/objDisplay.js", function(module, exports, require){
    /*!
     * Chai - flag utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /*!
     * Module dependancies
     */

    var inspect = require('./inspect');

    /**
     * ### .objDisplay (object)
     *
     * Determines if an object or an array matches
     * criteria to be inspected in-line for error
     * messages or should be truncated.
     *
     * @param {Mixed} javascript object to inspect
     * @name objDisplay
     * @api public
     */

    module.exports = function (obj) {
      var str = inspect(obj)
        , type = Object.prototype.toString.call(obj);

      if (str.length >= 40) {
        if (type === '[object Function]') {
          return !obj.name || obj.name === ''
            ? '[Function]'
            : '[Function: ' + obj.name + ']';
        } else if (type === '[object Array]') {
          return '[ Array(' + obj.length + ') ]';
        } else if (type === '[object Object]') {
          var keys = Object.keys(obj)
            , kstr = keys.length > 2
              ? keys.splice(0, 2).join(', ') + ', ...'
              : keys.join(', ');
          return '{ Object (' + kstr + ') }';
        } else {
          return str;
        }
      } else {
        return str;
      }
    };

  }); // module: chai/utils/objDisplay.js

  require.register("chai/utils/overwriteMethod.js", function(module, exports, require){
    /*!
     * Chai - overwriteMethod utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * ### overwriteMethod (ctx, name, fn)
     *
     * Overwites an already existing method and provides
     * access to previous function. Must return function
     * to be used for name.
     *
     *     utils.overwriteMethod(chai.Assertion.prototype, 'equal', function (_super) {
     *       return function (str) {
     *         var obj = utils.flag(this, 'object');
     *         if (obj instanceof Foo) {
     *           new chai.Assertion(obj.value).to.equal(str);
     *         } else {
     *           _super.apply(this, arguments);
     *         }
     *       }
     *     });
     *
     * Can also be accessed directly from `chai.Assertion`.
     *
     *     chai.Assertion.overwriteMethod('foo', fn);
     *
     * Then can be used as any other assertion.
     *
     *     expect(myFoo).to.equal('bar');
     *
     * @param {Object} ctx object whose method is to be overwritten
     * @param {String} name of method to overwrite
     * @param {Function} method function that returns a function to be used for name
     * @name overwriteMethod
     * @api public
     */

    module.exports = function (ctx, name, method) {
      var _method = ctx[name]
        , _super = function () { return this; };

      if (_method && 'function' === typeof _method)
        _super = _method;

      ctx[name] = function () {
        var result = method(_super).apply(this, arguments);
        return result === undefined ? this : result;
      }
    };

  }); // module: chai/utils/overwriteMethod.js

  require.register("chai/utils/overwriteProperty.js", function(module, exports, require){
    /*!
     * Chai - overwriteProperty utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * ### overwriteProperty (ctx, name, fn)
     *
     * Overwites an already existing property getter and provides
     * access to previous value. Must return function to use as getter.
     *
     *     utils.overwriteProperty(chai.Assertion.prototype, 'ok', function (_super) {
     *       return function () {
     *         var obj = utils.flag(this, 'object');
     *         if (obj instanceof Foo) {
     *           new chai.Assertion(obj.name).to.equal('bar');
     *         } else {
     *           _super.call(this);
     *         }
     *       }
     *     });
     *
     *
     * Can also be accessed directly from `chai.Assertion`.
     *
     *     chai.Assertion.overwriteProperty('foo', fn);
     *
     * Then can be used as any other assertion.
     *
     *     expect(myFoo).to.be.ok;
     *
     * @param {Object} ctx object whose property is to be overwritten
     * @param {String} name of property to overwrite
     * @param {Function} getter function that returns a getter function to be used for name
     * @name overwriteProperty
     * @api public
     */

    module.exports = function (ctx, name, getter) {
      var _get = Object.getOwnPropertyDescriptor(ctx, name)
        , _super = function () {};

      if (_get && 'function' === typeof _get.get)
        _super = _get.get

      Object.defineProperty(ctx, name,
        { get: function () {
            var result = getter(_super).call(this);
            return result === undefined ? this : result;
          }
        , configurable: true
      });
    };

  }); // module: chai/utils/overwriteProperty.js

  require.register("chai/utils/test.js", function(module, exports, require){
    /*!
     * Chai - test utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /*!
     * Module dependancies
     */

    var flag = require('./flag');

    /**
     * # test(object, expression)
     *
     * Test and object for expression.
     *
     * @param {Object} object (constructed Assertion)
     * @param {Arguments} chai.Assertion.prototype.assert arguments
     */

    module.exports = function (obj, args) {
      var negate = flag(obj, 'negate')
        , expr = args[0];
      return negate ? !expr : expr;
    };

  }); // module: chai/utils/test.js

  require.register("chai/utils/transferFlags.js", function(module, exports, require){
    /*!
     * Chai - transferFlags utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /**
     * ### transferFlags(assertion, object, includeAll = true)
     *
     * Transfer all the flags for `assertion` to `object`. If
     * `includeAll` is set to `false`, then the base Chai
     * assertion flags (namely `object`, `ssfi`, and `message`)
     * will not be transferred.
     *
     *
     *     var newAssertion = new Assertion();
     *     utils.transferFlags(assertion, newAssertion);
     *
     *     var anotherAsseriton = new Assertion(myObj);
     *     utils.transferFlags(assertion, anotherAssertion, false);
     *
     * @param {Assertion} assertion the assertion to transfer the flags from
     * @param {Object} object the object to transfer the flags too; usually a new assertion
     * @param {Boolean} includeAll
     * @name getAllFlags
     * @api private
     */

    module.exports = function (assertion, object, includeAll) {
      var flags = assertion.__flags || (assertion.__flags = Object.create(null));

      if (!object.__flags) {
        object.__flags = Object.create(null);
      }

      includeAll = arguments.length === 3 ? includeAll : true;

      for (var flag in flags) {
        if (includeAll ||
            (flag !== 'object' && flag !== 'ssfi' && flag != 'message')) {
          object.__flags[flag] = flags[flag];
        }
      }
    };

  }); // module: chai/utils/transferFlags.js

  require.register("chai/utils/type.js", function(module, exports, require){
    /*!
     * Chai - type utility
     * Copyright(c) 2012-2013 Jake Luer <jake@alogicalparadox.com>
     * MIT Licensed
     */

    /*!
     * Detectable javascript natives
     */

    var natives = {
        '[object Arguments]': 'arguments'
      , '[object Array]': 'array'
      , '[object Date]': 'date'
      , '[object Function]': 'function'
      , '[object Number]': 'number'
      , '[object RegExp]': 'regexp'
      , '[object String]': 'string'
    };

    /**
     * ### type(object)
     *
     * Better implementation of `typeof` detection that can
     * be used cross-browser. Handles the inconsistencies of
     * Array, `null`, and `undefined` detection.
     *
     *     utils.type({}) // 'object'
     *     utils.type(null) // `null'
     *     utils.type(undefined) // `undefined`
     *     utils.type([]) // `array`
     *
     * @param {Mixed} object to detect type of
     * @name type
     * @api private
     */

    module.exports = function (obj) {
      var str = Object.prototype.toString.call(obj);
      if (natives[str]) return natives[str];
      if (obj === null) return 'null';
      if (obj === undefined) return 'undefined';
      if (obj === Object(obj)) return 'object';
      return typeof obj;
    };

  }); // module: chai/utils/type.js

  require.alias("./chai.js", "chai");

  return require('chai');
});

;(function(){


// CommonJS require()

function require(p){
    var path = require.resolve(p)
      , mod = require.modules[path];
    if (!mod) throw new Error('failed to require "' + p + '"');
    if (!mod.exports) {
      mod.exports = {};
      mod.call(mod.exports, mod, mod.exports, require.relative(path));
    }
    return mod.exports;
  }

require.modules = {};

require.resolve = function (path){
    var orig = path
      , reg = path + '.js'
      , index = path + '/index.js';
    return require.modules[reg] && reg
      || require.modules[index] && index
      || orig;
  };

require.register = function (path, fn){
    require.modules[path] = fn;
  };

require.relative = function (parent) {
    return function(p){
      if ('.' != p.charAt(0)) return require(p);

      var path = parent.split('/')
        , segs = p.split('/');
      path.pop();

      for (var i = 0; i < segs.length; i++) {
        var seg = segs[i];
        if ('..' == seg) path.pop();
        else if ('.' != seg) path.push(seg);
      }

      return require(path.join('/'));
    };
  };


require.register("browser/debug.js", function(module, exports, require){

module.exports = function(type){
  return function(){

  }
};
}); // module: browser/debug.js

require.register("browser/diff.js", function(module, exports, require){
/* See license.txt for terms of usage */

/*
 * Text diff implementation.
 *
 * This library supports the following APIS:
 * JsDiff.diffChars: Character by character diff
 * JsDiff.diffWords: Word (as defined by \b regex) diff which ignores whitespace
 * JsDiff.diffLines: Line based diff
 *
 * JsDiff.diffCss: Diff targeted at CSS content
 *
 * These methods are based on the implementation proposed in
 * "An O(ND) Difference Algorithm and its Variations" (Myers, 1986).
 * http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.4.6927
 */
var JsDiff = (function() {
  function clonePath(path) {
    return { newPos: path.newPos, components: path.components.slice(0) };
  }
  function removeEmpty(array) {
    var ret = [];
    for (var i = 0; i < array.length; i++) {
      if (array[i]) {
        ret.push(array[i]);
      }
    }
    return ret;
  }
  function escapeHTML(s) {
    var n = s;
    n = n.replace(/&/g, "&amp;");
    n = n.replace(/</g, "&lt;");
    n = n.replace(/>/g, "&gt;");
    n = n.replace(/"/g, "&quot;");

    return n;
  }


  var fbDiff = function(ignoreWhitespace) {
    this.ignoreWhitespace = ignoreWhitespace;
  };
  fbDiff.prototype = {
      diff: function(oldString, newString) {
        // Handle the identity case (this is due to unrolling editLength == 0
        if (newString == oldString) {
          return [{ value: newString }];
        }
        if (!newString) {
          return [{ value: oldString, removed: true }];
        }
        if (!oldString) {
          return [{ value: newString, added: true }];
        }

        newString = this.tokenize(newString);
        oldString = this.tokenize(oldString);

        var newLen = newString.length, oldLen = oldString.length;
        var maxEditLength = newLen + oldLen;
        var bestPath = [{ newPos: -1, components: [] }];

        // Seed editLength = 0
        var oldPos = this.extractCommon(bestPath[0], newString, oldString, 0);
        if (bestPath[0].newPos+1 >= newLen && oldPos+1 >= oldLen) {
          return bestPath[0].components;
        }

        for (var editLength = 1; editLength <= maxEditLength; editLength++) {
          for (var diagonalPath = -1*editLength; diagonalPath <= editLength; diagonalPath+=2) {
            var basePath;
            var addPath = bestPath[diagonalPath-1],
                removePath = bestPath[diagonalPath+1];
            oldPos = (removePath ? removePath.newPos : 0) - diagonalPath;
            if (addPath) {
              // No one else is going to attempt to use this value, clear it
              bestPath[diagonalPath-1] = undefined;
            }

            var canAdd = addPath && addPath.newPos+1 < newLen;
            var canRemove = removePath && 0 <= oldPos && oldPos < oldLen;
            if (!canAdd && !canRemove) {
              bestPath[diagonalPath] = undefined;
              continue;
            }

            // Select the diagonal that we want to branch from. We select the prior
            // path whose position in the new string is the farthest from the origin
            // and does not pass the bounds of the diff graph
            if (!canAdd || (canRemove && addPath.newPos < removePath.newPos)) {
              basePath = clonePath(removePath);
              this.pushComponent(basePath.components, oldString[oldPos], undefined, true);
            } else {
              basePath = clonePath(addPath);
              basePath.newPos++;
              this.pushComponent(basePath.components, newString[basePath.newPos], true, undefined);
            }

            var oldPos = this.extractCommon(basePath, newString, oldString, diagonalPath);

            if (basePath.newPos+1 >= newLen && oldPos+1 >= oldLen) {
              return basePath.components;
            } else {
              bestPath[diagonalPath] = basePath;
            }
          }
        }
      },

      pushComponent: function(components, value, added, removed) {
        var last = components[components.length-1];
        if (last && last.added === added && last.removed === removed) {
          // We need to clone here as the component clone operation is just
          // as shallow array clone
          components[components.length-1] =
            {value: this.join(last.value, value), added: added, removed: removed };
        } else {
          components.push({value: value, added: added, removed: removed });
        }
      },
      extractCommon: function(basePath, newString, oldString, diagonalPath) {
        var newLen = newString.length,
            oldLen = oldString.length,
            newPos = basePath.newPos,
            oldPos = newPos - diagonalPath;
        while (newPos+1 < newLen && oldPos+1 < oldLen && this.equals(newString[newPos+1], oldString[oldPos+1])) {
          newPos++;
          oldPos++;

          this.pushComponent(basePath.components, newString[newPos], undefined, undefined);
        }
        basePath.newPos = newPos;
        return oldPos;
      },

      equals: function(left, right) {
        var reWhitespace = /\S/;
        if (this.ignoreWhitespace && !reWhitespace.test(left) && !reWhitespace.test(right)) {
          return true;
        } else {
          return left == right;
        }
      },
      join: function(left, right) {
        return left + right;
      },
      tokenize: function(value) {
        return value;
      }
  };

  var CharDiff = new fbDiff();

  var WordDiff = new fbDiff(true);
  WordDiff.tokenize = function(value) {
    return removeEmpty(value.split(/(\s+|\b)/));
  };

  var CssDiff = new fbDiff(true);
  CssDiff.tokenize = function(value) {
    return removeEmpty(value.split(/([{}:;,]|\s+)/));
  };

  var LineDiff = new fbDiff();
  LineDiff.tokenize = function(value) {
    return value.split(/^/m);
  };

  return {
    diffChars: function(oldStr, newStr) { return CharDiff.diff(oldStr, newStr); },
    diffWords: function(oldStr, newStr) { return WordDiff.diff(oldStr, newStr); },
    diffLines: function(oldStr, newStr) { return LineDiff.diff(oldStr, newStr); },

    diffCss: function(oldStr, newStr) { return CssDiff.diff(oldStr, newStr); },

    createPatch: function(fileName, oldStr, newStr, oldHeader, newHeader) {
      var ret = [];

      ret.push("Index: " + fileName);
      ret.push("===================================================================");
      ret.push("--- " + fileName + (typeof oldHeader === "undefined" ? "" : "\t" + oldHeader));
      ret.push("+++ " + fileName + (typeof newHeader === "undefined" ? "" : "\t" + newHeader));

      var diff = LineDiff.diff(oldStr, newStr);
      if (!diff[diff.length-1].value) {
        diff.pop();   // Remove trailing newline add
      }
      diff.push({value: "", lines: []});   // Append an empty value to make cleanup easier

      function contextLines(lines) {
        return lines.map(function(entry) { return ' ' + entry; });
      }
      function eofNL(curRange, i, current) {
        var last = diff[diff.length-2],
            isLast = i === diff.length-2,
            isLastOfType = i === diff.length-3 && (current.added === !last.added || current.removed === !last.removed);

        // Figure out if this is the last line for the given file and missing NL
        if (!/\n$/.test(current.value) && (isLast || isLastOfType)) {
          curRange.push('\\ No newline at end of file');
        }
      }

      var oldRangeStart = 0, newRangeStart = 0, curRange = [],
          oldLine = 1, newLine = 1;
      for (var i = 0; i < diff.length; i++) {
        var current = diff[i],
            lines = current.lines || current.value.replace(/\n$/, "").split("\n");
        current.lines = lines;

        if (current.added || current.removed) {
          if (!oldRangeStart) {
            var prev = diff[i-1];
            oldRangeStart = oldLine;
            newRangeStart = newLine;

            if (prev) {
              curRange = contextLines(prev.lines.slice(-4));
              oldRangeStart -= curRange.length;
              newRangeStart -= curRange.length;
            }
          }
          curRange.push.apply(curRange, lines.map(function(entry) { return (current.added?"+":"-") + entry; }));
          eofNL(curRange, i, current);

          if (current.added) {
            newLine += lines.length;
          } else {
            oldLine += lines.length;
          }
        } else {
          if (oldRangeStart) {
            // Close out any changes that have been output (or join overlapping)
            if (lines.length <= 8 && i < diff.length-2) {
              // Overlapping
              curRange.push.apply(curRange, contextLines(lines));
            } else {
              // end the range and output
              var contextSize = Math.min(lines.length, 4);
              ret.push(
                  "@@ -" + oldRangeStart + "," + (oldLine-oldRangeStart+contextSize)
                  + " +" + newRangeStart + "," + (newLine-newRangeStart+contextSize)
                  + " @@");
              ret.push.apply(ret, curRange);
              ret.push.apply(ret, contextLines(lines.slice(0, contextSize)));
              if (lines.length <= 4) {
                eofNL(ret, i, current);
              }

              oldRangeStart = 0;  newRangeStart = 0; curRange = [];
            }
          }
          oldLine += lines.length;
          newLine += lines.length;
        }
      }

      return ret.join('\n') + '\n';
    },

    convertChangesToXML: function(changes){
      var ret = [];
      for ( var i = 0; i < changes.length; i++) {
        var change = changes[i];
        if (change.added) {
          ret.push("<ins>");
        } else if (change.removed) {
          ret.push("<del>");
        }

        ret.push(escapeHTML(change.value));

        if (change.added) {
          ret.push("</ins>");
        } else if (change.removed) {
          ret.push("</del>");
        }
      }
      return ret.join("");
    }
  };
})();

if (typeof module !== "undefined") {
    module.exports = JsDiff;
}

}); // module: browser/diff.js

require.register("browser/events.js", function(module, exports, require){

/**
 * Module exports.
 */

exports.EventEmitter = EventEmitter;

/**
 * Check if `obj` is an array.
 */

function isArray(obj) {
  return '[object Array]' == {}.toString.call(obj);
}

/**
 * Event emitter constructor.
 *
 * @api public
 */

function EventEmitter(){};

/**
 * Adds a listener.
 *
 * @api public
 */

EventEmitter.prototype.on = function (name, fn) {
  if (!this.$events) {
    this.$events = {};
  }

  if (!this.$events[name]) {
    this.$events[name] = fn;
  } else if (isArray(this.$events[name])) {
    this.$events[name].push(fn);
  } else {
    this.$events[name] = [this.$events[name], fn];
  }

  return this;
};

EventEmitter.prototype.addListener = EventEmitter.prototype.on;

/**
 * Adds a volatile listener.
 *
 * @api public
 */

EventEmitter.prototype.once = function (name, fn) {
  var self = this;

  function on () {
    self.removeListener(name, on);
    fn.apply(this, arguments);
  };

  on.listener = fn;
  this.on(name, on);

  return this;
};

/**
 * Removes a listener.
 *
 * @api public
 */

EventEmitter.prototype.removeListener = function (name, fn) {
  if (this.$events && this.$events[name]) {
    var list = this.$events[name];

    if (isArray(list)) {
      var pos = -1;

      for (var i = 0, l = list.length; i < l; i++) {
        if (list[i] === fn || (list[i].listener && list[i].listener === fn)) {
          pos = i;
          break;
        }
      }

      if (pos < 0) {
        return this;
      }

      list.splice(pos, 1);

      if (!list.length) {
        delete this.$events[name];
      }
    } else if (list === fn || (list.listener && list.listener === fn)) {
      delete this.$events[name];
    }
  }

  return this;
};

/**
 * Removes all listeners for an event.
 *
 * @api public
 */

EventEmitter.prototype.removeAllListeners = function (name) {
  if (name === undefined) {
    this.$events = {};
    return this;
  }

  if (this.$events && this.$events[name]) {
    this.$events[name] = null;
  }

  return this;
};

/**
 * Gets all listeners for a certain event.
 *
 * @api public
 */

EventEmitter.prototype.listeners = function (name) {
  if (!this.$events) {
    this.$events = {};
  }

  if (!this.$events[name]) {
    this.$events[name] = [];
  }

  if (!isArray(this.$events[name])) {
    this.$events[name] = [this.$events[name]];
  }

  return this.$events[name];
};

/**
 * Emits an event.
 *
 * @api public
 */

EventEmitter.prototype.emit = function (name) {
  if (!this.$events) {
    return false;
  }

  var handler = this.$events[name];

  if (!handler) {
    return false;
  }

  var args = [].slice.call(arguments, 1);

  if ('function' == typeof handler) {
    handler.apply(this, args);
  } else if (isArray(handler)) {
    var listeners = handler.slice();

    for (var i = 0, l = listeners.length; i < l; i++) {
      listeners[i].apply(this, args);
    }
  } else {
    return false;
  }

  return true;
};
}); // module: browser/events.js

require.register("browser/fs.js", function(module, exports, require){

}); // module: browser/fs.js

require.register("browser/path.js", function(module, exports, require){

}); // module: browser/path.js

require.register("browser/progress.js", function(module, exports, require){

/**
 * Expose `Progress`.
 */

module.exports = Progress;

/**
 * Initialize a new `Progress` indicator.
 */

function Progress() {
  this.percent = 0;
  this.size(0);
  this.fontSize(11);
  this.font('helvetica, arial, sans-serif');
}

/**
 * Set progress size to `n`.
 *
 * @param {Number} n
 * @return {Progress} for chaining
 * @api public
 */

Progress.prototype.size = function(n){
  this._size = n;
  return this;
};

/**
 * Set text to `str`.
 *
 * @param {String} str
 * @return {Progress} for chaining
 * @api public
 */

Progress.prototype.text = function(str){
  this._text = str;
  return this;
};

/**
 * Set font size to `n`.
 *
 * @param {Number} n
 * @return {Progress} for chaining
 * @api public
 */

Progress.prototype.fontSize = function(n){
  this._fontSize = n;
  return this;
};

/**
 * Set font `family`.
 *
 * @param {String} family
 * @return {Progress} for chaining
 */

Progress.prototype.font = function(family){
  this._font = family;
  return this;
};

/**
 * Update percentage to `n`.
 *
 * @param {Number} n
 * @return {Progress} for chaining
 */

Progress.prototype.update = function(n){
  this.percent = n;
  return this;
};

/**
 * Draw on `ctx`.
 *
 * @param {CanvasRenderingContext2d} ctx
 * @return {Progress} for chaining
 */

Progress.prototype.draw = function(ctx){
  var percent = Math.min(this.percent, 100)
    , size = this._size
    , half = size / 2
    , x = half
    , y = half
    , rad = half - 1
    , fontSize = this._fontSize;

  ctx.font = fontSize + 'px ' + this._font;

  var angle = Math.PI * 2 * (percent / 100);
  ctx.clearRect(0, 0, size, size);

  // outer circle
  ctx.strokeStyle = '#9f9f9f';
  ctx.beginPath();
  ctx.arc(x, y, rad, 0, angle, false);
  ctx.stroke();

  // inner circle
  ctx.strokeStyle = '#eee';
  ctx.beginPath();
  ctx.arc(x, y, rad - 1, 0, angle, true);
  ctx.stroke();

  // text
  var text = this._text || (percent | 0) + '%'
    , w = ctx.measureText(text).width;

  ctx.fillText(
      text
    , x - w / 2 + 1
    , y + fontSize / 2 - 1);

  return this;
};

}); // module: browser/progress.js

require.register("browser/tty.js", function(module, exports, require){

exports.isatty = function(){
  return true;
};

exports.getWindowSize = function(){
  return [window.innerHeight, window.innerWidth];
};
}); // module: browser/tty.js

require.register("context.js", function(module, exports, require){

/**
 * Expose `Context`.
 */

module.exports = Context;

/**
 * Initialize a new `Context`.
 *
 * @api private
 */

function Context(){}

/**
 * Set or get the context `Runnable` to `runnable`.
 *
 * @param {Runnable} runnable
 * @return {Context}
 * @api private
 */

Context.prototype.runnable = function(runnable){
  if (0 == arguments.length) return this._runnable;
  this.test = this._runnable = runnable;
  return this;
};

/**
 * Set test timeout `ms`.
 *
 * @param {Number} ms
 * @return {Context} self
 * @api private
 */

Context.prototype.timeout = function(ms){
  this.runnable().timeout(ms);
  return this;
};

/**
 * Set test slowness threshold `ms`.
 *
 * @param {Number} ms
 * @return {Context} self
 * @api private
 */

Context.prototype.slow = function(ms){
  this.runnable().slow(ms);
  return this;
};

/**
 * Inspect the context void of `._runnable`.
 *
 * @return {String}
 * @api private
 */

Context.prototype.inspect = function(){
  return JSON.stringify(this, function(key, val){
    if ('_runnable' == key) return;
    if ('test' == key) return;
    return val;
  }, 2);
};

}); // module: context.js

require.register("hook.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Runnable = require('./runnable');

/**
 * Expose `Hook`.
 */

module.exports = Hook;

/**
 * Initialize a new `Hook` with the given `title` and callback `fn`.
 *
 * @param {String} title
 * @param {Function} fn
 * @api private
 */

function Hook(title, fn) {
  Runnable.call(this, title, fn);
  this.type = 'hook';
}

/**
 * Inherit from `Runnable.prototype`.
 */

function F(){};
F.prototype = Runnable.prototype;
Hook.prototype = new F;
Hook.prototype.constructor = Hook;


/**
 * Get or set the test `err`.
 *
 * @param {Error} err
 * @return {Error}
 * @api public
 */

Hook.prototype.error = function(err){
  if (0 == arguments.length) {
    var err = this._error;
    this._error = null;
    return err;
  }

  this._error = err;
};


}); // module: hook.js

require.register("interfaces/bdd.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Suite = require('../suite')
  , Test = require('../test');

/**
 * BDD-style interface:
 *
 *      describe('Array', function(){
 *        describe('#indexOf()', function(){
 *          it('should return -1 when not present', function(){
 *
 *          });
 *
 *          it('should return the index when present', function(){
 *
 *          });
 *        });
 *      });
 *
 */

module.exports = function(suite){
  var suites = [suite];

  suite.on('pre-require', function(context, file, mocha){

    /**
     * Execute before running tests.
     */

    context.before = function(fn){
      suites[0].beforeAll(fn);
    };

    /**
     * Execute after running tests.
     */

    context.after = function(fn){
      suites[0].afterAll(fn);
    };

    /**
     * Execute before each test case.
     */

    context.beforeEach = function(fn){
      suites[0].beforeEach(fn);
    };

    /**
     * Execute after each test case.
     */

    context.afterEach = function(fn){
      suites[0].afterEach(fn);
    };

    /**
     * Describe a "suite" with the given `title`
     * and callback `fn` containing nested suites
     * and/or tests.
     */

    context.describe = context.context = function(title, fn){
      var suite = Suite.create(suites[0], title);
      suites.unshift(suite);
      fn.call(suite);
      suites.shift();
      return suite;
    };

    /**
     * Pending describe.
     */

    context.xdescribe =
    context.xcontext =
    context.describe.skip = function(title, fn){
      var suite = Suite.create(suites[0], title);
      suite.pending = true;
      suites.unshift(suite);
      fn.call(suite);
      suites.shift();
    };

    /**
     * Exclusive suite.
     */

    context.describe.only = function(title, fn){
      var suite = context.describe(title, fn);
      mocha.grep(suite.fullTitle());
    };

    /**
     * Describe a specification or test-case
     * with the given `title` and callback `fn`
     * acting as a thunk.
     */

    context.it = context.specify = function(title, fn){
      var suite = suites[0];
      if (suite.pending) var fn = null;
      var test = new Test(title, fn);
      suite.addTest(test);
      return test;
    };

    /**
     * Exclusive test-case.
     */

    context.it.only = function(title, fn){
      var test = context.it(title, fn);
      mocha.grep(test.fullTitle());
    };

    /**
     * Pending test case.
     */

    context.xit =
    context.xspecify =
    context.it.skip = function(title){
      context.it(title);
    };
  });
};

}); // module: interfaces/bdd.js

require.register("interfaces/exports.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Suite = require('../suite')
  , Test = require('../test');

/**
 * TDD-style interface:
 *
 *     exports.Array = {
 *       '#indexOf()': {
 *         'should return -1 when the value is not present': function(){
 *
 *         },
 *
 *         'should return the correct index when the value is present': function(){
 *
 *         }
 *       }
 *     };
 *
 */

module.exports = function(suite){
  var suites = [suite];

  suite.on('require', visit);

  function visit(obj) {
    var suite;
    for (var key in obj) {
      if ('function' == typeof obj[key]) {
        var fn = obj[key];
        switch (key) {
          case 'before':
            suites[0].beforeAll(fn);
            break;
          case 'after':
            suites[0].afterAll(fn);
            break;
          case 'beforeEach':
            suites[0].beforeEach(fn);
            break;
          case 'afterEach':
            suites[0].afterEach(fn);
            break;
          default:
            suites[0].addTest(new Test(key, fn));
        }
      } else {
        var suite = Suite.create(suites[0], key);
        suites.unshift(suite);
        visit(obj[key]);
        suites.shift();
      }
    }
  }
};
}); // module: interfaces/exports.js

require.register("interfaces/index.js", function(module, exports, require){

exports.bdd = require('./bdd');
exports.tdd = require('./tdd');
exports.qunit = require('./qunit');
exports.exports = require('./exports');

}); // module: interfaces/index.js

require.register("interfaces/qunit.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Suite = require('../suite')
  , Test = require('../test');

/**
 * QUnit-style interface:
 *
 *     suite('Array');
 *
 *     test('#length', function(){
 *       var arr = [1,2,3];
 *       ok(arr.length == 3);
 *     });
 *
 *     test('#indexOf()', function(){
 *       var arr = [1,2,3];
 *       ok(arr.indexOf(1) == 0);
 *       ok(arr.indexOf(2) == 1);
 *       ok(arr.indexOf(3) == 2);
 *     });
 *
 *     suite('String');
 *
 *     test('#length', function(){
 *       ok('foo'.length == 3);
 *     });
 *
 */

module.exports = function(suite){
  var suites = [suite];

  suite.on('pre-require', function(context){

    /**
     * Execute before running tests.
     */

    context.before = function(fn){
      suites[0].beforeAll(fn);
    };

    /**
     * Execute after running tests.
     */

    context.after = function(fn){
      suites[0].afterAll(fn);
    };

    /**
     * Execute before each test case.
     */

    context.beforeEach = function(fn){
      suites[0].beforeEach(fn);
    };

    /**
     * Execute after each test case.
     */

    context.afterEach = function(fn){
      suites[0].afterEach(fn);
    };

    /**
     * Describe a "suite" with the given `title`.
     */

    context.suite = function(title){
      if (suites.length > 1) suites.shift();
      var suite = Suite.create(suites[0], title);
      suites.unshift(suite);
    };

    /**
     * Describe a specification or test-case
     * with the given `title` and callback `fn`
     * acting as a thunk.
     */

    context.test = function(title, fn){
      suites[0].addTest(new Test(title, fn));
    };
  });
};

}); // module: interfaces/qunit.js

require.register("interfaces/tdd.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Suite = require('../suite')
  , Test = require('../test');

/**
 * TDD-style interface:
 *
 *      suite('Array', function(){
 *        suite('#indexOf()', function(){
 *          suiteSetup(function(){
 *
 *          });
 *
 *          test('should return -1 when not present', function(){
 *
 *          });
 *
 *          test('should return the index when present', function(){
 *
 *          });
 *
 *          suiteTeardown(function(){
 *
 *          });
 *        });
 *      });
 *
 */

module.exports = function(suite){
  var suites = [suite];

  suite.on('pre-require', function(context, file, mocha){

    /**
     * Execute before each test case.
     */

    context.setup = function(fn){
      suites[0].beforeEach(fn);
    };

    /**
     * Execute after each test case.
     */

    context.teardown = function(fn){
      suites[0].afterEach(fn);
    };

    /**
     * Execute before the suite.
     */

    context.suiteSetup = function(fn){
      suites[0].beforeAll(fn);
    };

    /**
     * Execute after the suite.
     */

    context.suiteTeardown = function(fn){
      suites[0].afterAll(fn);
    };

    /**
     * Describe a "suite" with the given `title`
     * and callback `fn` containing nested suites
     * and/or tests.
     */

    context.suite = function(title, fn){
      var suite = Suite.create(suites[0], title);
      suites.unshift(suite);
      fn.call(suite);
      suites.shift();
      return suite;
    };

    /**
     * Exclusive test-case.
     */

    context.suite.only = function(title, fn){
      var suite = context.suite(title, fn);
      mocha.grep(suite.fullTitle());
    };

    /**
     * Describe a specification or test-case
     * with the given `title` and callback `fn`
     * acting as a thunk.
     */

    context.test = function(title, fn){
      var test = new Test(title, fn);
      suites[0].addTest(test);
      return test;
    };

    /**
     * Exclusive test-case.
     */

    context.test.only = function(title, fn){
      var test = context.test(title, fn);
      mocha.grep(test.fullTitle());
    };

    /**
     * Pending test case.
     */

    context.test.skip = function(title){
      context.test(title);
    };
  });
};

}); // module: interfaces/tdd.js

require.register("mocha.js", function(module, exports, require){
/*!
 * mocha
 * Copyright(c) 2011 TJ Holowaychuk <tj@vision-media.ca>
 * MIT Licensed
 */

/**
 * Module dependencies.
 */

var path = require('browser/path')
  , utils = require('./utils');

/**
 * Expose `Mocha`.
 */

exports = module.exports = Mocha;

/**
 * Expose internals.
 */

exports.utils = utils;
exports.interfaces = require('./interfaces');
exports.reporters = require('./reporters');
exports.Runnable = require('./runnable');
exports.Context = require('./context');
exports.Runner = require('./runner');
exports.Suite = require('./suite');
exports.Hook = require('./hook');
exports.Test = require('./test');

/**
 * Return image `name` path.
 *
 * @param {String} name
 * @return {String}
 * @api private
 */

function image(name) {
  return __dirname + '/../images/' + name + '.png';
}

/**
 * Setup mocha with `options`.
 *
 * Options:
 *
 *   - `ui` name "bdd", "tdd", "exports" etc
 *   - `reporter` reporter instance, defaults to `mocha.reporters.Dot`
 *   - `globals` array of accepted globals
 *   - `timeout` timeout in milliseconds
 *   - `bail` bail on the first test failure
 *   - `slow` milliseconds to wait before considering a test slow
 *   - `ignoreLeaks` ignore global leaks
 *   - `grep` string or regexp to filter tests with
 *
 * @param {Object} options
 * @api public
 */

function Mocha(options) {
  options = options || {};
  this.files = [];
  this.options = options;
  this.grep(options.grep);
  this.suite = new exports.Suite('', new exports.Context);
  this.ui(options.ui);
  this.bail(options.bail);
  this.reporter(options.reporter);
  if (options.timeout) this.timeout(options.timeout);
  if (options.slow) this.slow(options.slow);
}

/**
 * Enable or disable bailing on the first failure.
 *
 * @param {Boolean} [bail]
 * @api public
 */

Mocha.prototype.bail = function(bail){
  if (null == bail) bail = true;
  this.suite.bail(bail);
  return this;
};

/**
 * Add test `file`.
 *
 * @param {String} file
 * @api public
 */

Mocha.prototype.addFile = function(file){
  this.files.push(file);
  return this;
};

/**
 * Set reporter to `reporter`, defaults to "dot".
 *
 * @param {String|Function} reporter name or constructor
 * @api public
 */

Mocha.prototype.reporter = function(reporter){
  if ('function' == typeof reporter) {
    this._reporter = reporter;
  } else {
    reporter = reporter || 'dot';
    try {
      this._reporter = require('./reporters/' + reporter);
    } catch (err) {
      this._reporter = require(reporter);
    }
    if (!this._reporter) throw new Error('invalid reporter "' + reporter + '"');
  }
  return this;
};

/**
 * Set test UI `name`, defaults to "bdd".
 *
 * @param {String} bdd
 * @api public
 */

Mocha.prototype.ui = function(name){
  name = name || 'bdd';
  this._ui = exports.interfaces[name];
  if (!this._ui) throw new Error('invalid interface "' + name + '"');
  this._ui = this._ui(this.suite);
  return this;
};

/**
 * Load registered files.
 *
 * @api private
 */

Mocha.prototype.loadFiles = function(fn){
  var self = this;
  var suite = this.suite;
  var pending = this.files.length;
  this.files.forEach(function(file){
    file = path.resolve(file);
    suite.emit('pre-require', global, file, self);
    suite.emit('require', require(file), file, self);
    suite.emit('post-require', global, file, self);
    --pending || (fn && fn());
  });
};

/**
 * Enable growl support.
 *
 * @api private
 */

Mocha.prototype._growl = function(runner, reporter) {
  var notify = require('growl');

  runner.on('end', function(){
    var stats = reporter.stats;
    if (stats.failures) {
      var msg = stats.failures + ' of ' + runner.total + ' tests failed';
      notify(msg, { name: 'mocha', title: 'Failed', image: image('error') });
    } else {
      notify(stats.passes + ' tests passed in ' + stats.duration + 'ms', {
          name: 'mocha'
        , title: 'Passed'
        , image: image('ok')
      });
    }
  });
};

/**
 * Add regexp to grep, if `re` is a string it is escaped.
 *
 * @param {RegExp|String} re
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.grep = function(re){
  this.options.grep = 'string' == typeof re
    ? new RegExp(utils.escapeRegexp(re))
    : re;
  return this;
};

/**
 * Invert `.grep()` matches.
 *
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.invert = function(){
  this.options.invert = true;
  return this;
};

/**
 * Ignore global leaks.
 *
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.ignoreLeaks = function(){
  this.options.ignoreLeaks = true;
  return this;
};

/**
 * Enable global leak checking.
 *
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.checkLeaks = function(){
  this.options.ignoreLeaks = false;
  return this;
};

/**
 * Enable growl support.
 *
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.growl = function(){
  this.options.growl = true;
  return this;
};

/**
 * Ignore `globals` array or string.
 *
 * @param {Array|String} globals
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.globals = function(globals){
  this.options.globals = (this.options.globals || []).concat(globals);
  return this;
};

/**
 * Set the timeout in milliseconds.
 *
 * @param {Number} timeout
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.timeout = function(timeout){
  this.suite.timeout(timeout);
  return this;
};

/**
 * Set slowness threshold in milliseconds.
 *
 * @param {Number} slow
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.slow = function(slow){
  this.suite.slow(slow);
  return this;
};

/**
 * Makes all tests async (accepting a callback)
 *
 * @return {Mocha}
 * @api public
 */

Mocha.prototype.asyncOnly = function(){
  this.options.asyncOnly = true;
  return this;
};

/**
 * Run tests and invoke `fn()` when complete.
 *
 * @param {Function} fn
 * @return {Runner}
 * @api public
 */

Mocha.prototype.run = function(fn){
  if (this.files.length) this.loadFiles();
  var suite = this.suite;
  var options = this.options;
  var runner = new exports.Runner(suite);
  var reporter = new this._reporter(runner);
  runner.ignoreLeaks = options.ignoreLeaks;
  runner.asyncOnly = options.asyncOnly;
  if (options.grep) runner.grep(options.grep, options.invert);
  if (options.globals) runner.globals(options.globals);
  if (options.growl) this._growl(runner, reporter);
  return runner.run(fn);
};

}); // module: mocha.js

require.register("ms.js", function(module, exports, require){

/**
 * Helpers.
 */

var s = 1000;
var m = s * 60;
var h = m * 60;
var d = h * 24;

/**
 * Parse or format the given `val`.
 *
 * @param {String|Number} val
 * @return {String|Number}
 * @api public
 */

module.exports = function(val){
  if ('string' == typeof val) return parse(val);
  return format(val);
}

/**
 * Parse the given `str` and return milliseconds.
 *
 * @param {String} str
 * @return {Number}
 * @api private
 */

function parse(str) {
  var m = /^((?:\d+)?\.?\d+) *(ms|seconds?|s|minutes?|m|hours?|h|days?|d|years?|y)?$/i.exec(str);
  if (!m) return;
  var n = parseFloat(m[1]);
  var type = (m[2] || 'ms').toLowerCase();
  switch (type) {
    case 'years':
    case 'year':
    case 'y':
      return n * 31557600000;
    case 'days':
    case 'day':
    case 'd':
      return n * 86400000;
    case 'hours':
    case 'hour':
    case 'h':
      return n * 3600000;
    case 'minutes':
    case 'minute':
    case 'm':
      return n * 60000;
    case 'seconds':
    case 'second':
    case 's':
      return n * 1000;
    case 'ms':
      return n;
  }
}

/**
 * Format the given `ms`.
 *
 * @param {Number} ms
 * @return {String}
 * @api public
 */

function format(ms) {
  if (ms == d) return Math.round(ms / d) + ' day';
  if (ms > d) return Math.round(ms / d) + ' days';
  if (ms == h) return Math.round(ms / h) + ' hour';
  if (ms > h) return Math.round(ms / h) + ' hours';
  if (ms == m) return Math.round(ms / m) + ' minute';
  if (ms > m) return Math.round(ms / m) + ' minutes';
  if (ms == s) return Math.round(ms / s) + ' second';
  if (ms > s) return Math.round(ms / s) + ' seconds';
  return ms + ' ms';
}
}); // module: ms.js

require.register("reporters/base.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var tty = require('browser/tty')
  , diff = require('browser/diff')
  , ms = require('../ms');

/**
 * Save timer references to avoid Sinon interfering (see GH-237).
 */

var Date = global.Date
  , setTimeout = global.setTimeout
  , setInterval = global.setInterval
  , clearTimeout = global.clearTimeout
  , clearInterval = global.clearInterval;

/**
 * Check if both stdio streams are associated with a tty.
 */

var isatty = tty.isatty(1) && tty.isatty(2);

/**
 * Expose `Base`.
 */

exports = module.exports = Base;

/**
 * Enable coloring by default.
 */

exports.useColors = isatty;

/**
 * Default color map.
 */

exports.colors = {
    'pass': 90
  , 'fail': 31
  , 'bright pass': 92
  , 'bright fail': 91
  , 'bright yellow': 93
  , 'pending': 36
  , 'suite': 0
  , 'error title': 0
  , 'error message': 31
  , 'error stack': 90
  , 'checkmark': 32
  , 'fast': 90
  , 'medium': 33
  , 'slow': 31
  , 'green': 32
  , 'light': 90
  , 'diff gutter': 90
  , 'diff added': 42
  , 'diff removed': 41
};

/**
 * Default symbol map.
 */

exports.symbols = {
  ok: 'вњ“',
  err: 'вњ–',
  dot: 'вЂ¤'
};

// With node.js on Windows: use symbols available in terminal default fonts
if ('win32' == process.platform) {
  exports.symbols.ok = '\u221A';
  exports.symbols.err = '\u00D7';
  exports.symbols.dot = '.';
}

/**
 * Color `str` with the given `type`,
 * allowing colors to be disabled,
 * as well as user-defined color
 * schemes.
 *
 * @param {String} type
 * @param {String} str
 * @return {String}
 * @api private
 */

var color = exports.color = function(type, str) {
  if (!exports.useColors) return str;
  return '\u001b[' + exports.colors[type] + 'm' + str + '\u001b[0m';
};

/**
 * Expose term window size, with some
 * defaults for when stderr is not a tty.
 */

exports.window = {
  width: isatty
    ? process.stdout.getWindowSize
      ? process.stdout.getWindowSize(1)[0]
      : tty.getWindowSize()[1]
    : 75
};

/**
 * Expose some basic cursor interactions
 * that are common among reporters.
 */

exports.cursor = {
  hide: function(){
    process.stdout.write('\u001b[?25l');
  },

  show: function(){
    process.stdout.write('\u001b[?25h');
  },

  deleteLine: function(){
    process.stdout.write('\u001b[2K');
  },

  beginningOfLine: function(){
    process.stdout.write('\u001b[0G');
  },

  CR: function(){
    exports.cursor.deleteLine();
    exports.cursor.beginningOfLine();
  }
};

/**
 * Outut the given `failures` as a list.
 *
 * @param {Array} failures
 * @api public
 */

exports.list = function(failures){
  console.error();
  failures.forEach(function(test, i){
    // format
    var fmt = color('error title', '  %s) %s:\n')
      + color('error message', '     %s')
      + color('error stack', '\n%s\n');

    // msg
    var err = test.err
      , message = err.message || ''
      , stack = err.stack || message
      , index = stack.indexOf(message) + message.length
      , msg = stack.slice(0, index)
      , actual = err.actual
      , expected = err.expected
      , escape = true;

    // explicitly show diff
    if (err.showDiff) {
      escape = false;
      err.actual = actual = JSON.stringify(actual, null, 2);
      err.expected = expected = JSON.stringify(expected, null, 2);
    }

    // actual / expected diff
    if ('string' == typeof actual && 'string' == typeof expected) {
      var len = Math.max(actual.length, expected.length);

      if (len < 20) msg = errorDiff(err, 'Chars', escape);
      else msg = errorDiff(err, 'Words', escape);

      // linenos
      var lines = msg.split('\n');
      if (lines.length > 4) {
        var width = String(lines.length).length;
        msg = lines.map(function(str, i){
          return pad(++i, width) + ' |' + ' ' + str;
        }).join('\n');
      }

      // legend
      msg = '\n'
        + color('diff removed', 'actual')
        + ' '
        + color('diff added', 'expected')
        + '\n\n'
        + msg
        + '\n';

      // indent
      msg = msg.replace(/^/gm, '      ');

      fmt = color('error title', '  %s) %s:\n%s')
        + color('error stack', '\n%s\n');
    }

    // indent stack trace without msg
    stack = stack.slice(index ? index + 1 : index)
      .replace(/^/gm, '  ');

    console.error(fmt, (i + 1), test.fullTitle(), msg, stack);
  });
};

/**
 * Initialize a new `Base` reporter.
 *
 * All other reporters generally
 * inherit from this reporter, providing
 * stats such as test duration, number
 * of tests passed / failed etc.
 *
 * @param {Runner} runner
 * @api public
 */

function Base(runner) {
  var self = this
    , stats = this.stats = { suites: 0, tests: 0, passes: 0, pending: 0, failures: 0 }
    , failures = this.failures = [];

  if (!runner) return;
  this.runner = runner;

  runner.stats = stats;

  runner.on('start', function(){
    stats.start = new Date;
  });

  runner.on('suite', function(suite){
    stats.suites = stats.suites || 0;
    suite.root || stats.suites++;
  });

  runner.on('test end', function(test){
    stats.tests = stats.tests || 0;
    stats.tests++;
  });

  runner.on('pass', function(test){
    stats.passes = stats.passes || 0;

    var medium = test.slow() / 2;
    test.speed = test.duration > test.slow()
      ? 'slow'
      : test.duration > medium
        ? 'medium'
        : 'fast';

    stats.passes++;
  });

  runner.on('fail', function(test, err){
    stats.failures = stats.failures || 0;
    stats.failures++;
    test.err = err;
    failures.push(test);
  });

  runner.on('end', function(){
    stats.end = new Date;
    stats.duration = new Date - stats.start;
  });

  runner.on('pending', function(){
    stats.pending++;
  });
}

/**
 * Output common epilogue used by many of
 * the bundled reporters.
 *
 * @api public
 */

Base.prototype.epilogue = function(){
  var stats = this.stats
    , fmt
    , tests;

  console.log();

  function pluralize(n) {
    return 1 == n ? 'test' : 'tests';
  }

  // failure
  if (stats.failures) {
    fmt = color('bright fail', '  ' + exports.symbols.err)
      + color('fail', ' %d of %d %s failed')
      + color('light', ':')

    console.error(fmt,
      stats.failures,
      this.runner.total,
      pluralize(this.runner.total));

    Base.list(this.failures);
    console.error();
    return;
  }

  // pass
  fmt = color('bright pass', ' ')
    + color('green', ' %d %s complete')
    + color('light', ' (%s)');

  console.log(fmt,
    stats.tests || 0,
    pluralize(stats.tests),
    ms(stats.duration));

  // pending
  if (stats.pending) {
    fmt = color('pending', ' ')
      + color('pending', ' %d %s pending');

    console.log(fmt, stats.pending, pluralize(stats.pending));
  }

  console.log();
};

/**
 * Pad the given `str` to `len`.
 *
 * @param {String} str
 * @param {String} len
 * @return {String}
 * @api private
 */

function pad(str, len) {
  str = String(str);
  return Array(len - str.length + 1).join(' ') + str;
}

/**
 * Return a character diff for `err`.
 *
 * @param {Error} err
 * @return {String}
 * @api private
 */

function errorDiff(err, type, escape) {
  return diff['diff' + type](err.actual, err.expected).map(function(str){
    if (escape) {
      str.value = str.value
        .replace(/\t/g, '<tab>')
        .replace(/\r/g, '<CR>')
        .replace(/\n/g, '<LF>\n');
    }
    if (str.added) return colorLines('diff added', str.value);
    if (str.removed) return colorLines('diff removed', str.value);
    return str.value;
  }).join('');
}

/**
 * Color lines for `str`, using the color `name`.
 *
 * @param {String} name
 * @param {String} str
 * @return {String}
 * @api private
 */

function colorLines(name, str) {
  return str.split('\n').map(function(str){
    return color(name, str);
  }).join('\n');
}

}); // module: reporters/base.js

require.register("reporters/doc.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , utils = require('../utils');

/**
 * Expose `Doc`.
 */

exports = module.exports = Doc;

/**
 * Initialize a new `Doc` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function Doc(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , total = runner.total
    , indents = 2;

  function indent() {
    return Array(indents).join('  ');
  }

  runner.on('suite', function(suite){
    if (suite.root) return;
    ++indents;
    console.log('%s<section class="suite">', indent());
    ++indents;
    console.log('%s<h1>%s</h1>', indent(), utils.escape(suite.title));
    console.log('%s<dl>', indent());
  });

  runner.on('suite end', function(suite){
    if (suite.root) return;
    console.log('%s</dl>', indent());
    --indents;
    console.log('%s</section>', indent());
    --indents;
  });

  runner.on('pass', function(test){
    console.log('%s  <dt>%s</dt>', indent(), utils.escape(test.title));
    var code = utils.escape(utils.clean(test.fn.toString()));
    console.log('%s  <dd><pre><code>%s</code></pre></dd>', indent(), code);
  });
}

}); // module: reporters/doc.js

require.register("reporters/dot.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , color = Base.color;

/**
 * Expose `Dot`.
 */

exports = module.exports = Dot;

/**
 * Initialize a new `Dot` matrix test reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function Dot(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , width = Base.window.width * .75 | 0
    , n = 0;

  runner.on('start', function(){
    process.stdout.write('\n  ');
  });

  runner.on('pending', function(test){
    process.stdout.write(color('pending', Base.symbols.dot));
  });

  runner.on('pass', function(test){
    if (++n % width == 0) process.stdout.write('\n  ');
    if ('slow' == test.speed) {
      process.stdout.write(color('bright yellow', Base.symbols.dot));
    } else {
      process.stdout.write(color(test.speed, Base.symbols.dot));
    }
  });

  runner.on('fail', function(test, err){
    if (++n % width == 0) process.stdout.write('\n  ');
    process.stdout.write(color('fail', Base.symbols.dot));
  });

  runner.on('end', function(){
    console.log();
    self.epilogue();
  });
}

/**
 * Inherit from `Base.prototype`.
 */

function F(){};
F.prototype = Base.prototype;
Dot.prototype = new F;
Dot.prototype.constructor = Dot;

}); // module: reporters/dot.js

require.register("reporters/html-cov.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var JSONCov = require('./json-cov')
  , fs = require('browser/fs');

/**
 * Expose `HTMLCov`.
 */

exports = module.exports = HTMLCov;

/**
 * Initialize a new `JsCoverage` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function HTMLCov(runner) {
  var jade = require('jade')
    , file = __dirname + '/templates/coverage.jade'
    , str = fs.readFileSync(file, 'utf8')
    , fn = jade.compile(str, { filename: file })
    , self = this;

  JSONCov.call(this, runner, false);

  runner.on('end', function(){
    process.stdout.write(fn({
        cov: self.cov
      , coverageClass: coverageClass
    }));
  });
}

/**
 * Return coverage class for `n`.
 *
 * @return {String}
 * @api private
 */

function coverageClass(n) {
  if (n >= 75) return 'high';
  if (n >= 50) return 'medium';
  if (n >= 25) return 'low';
  return 'terrible';
}
}); // module: reporters/html-cov.js

require.register("reporters/html.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , utils = require('../utils')
  , Progress = require('../browser/progress')
  , escape = utils.escape;

/**
 * Save timer references to avoid Sinon interfering (see GH-237).
 */

var Date = global.Date
  , setTimeout = global.setTimeout
  , setInterval = global.setInterval
  , clearTimeout = global.clearTimeout
  , clearInterval = global.clearInterval;

/**
 * Expose `Doc`.
 */

exports = module.exports = HTML;

/**
 * Stats template.
 */

var statsTemplate = '<ul id="mocha-stats">'
  + '<li class="progress"><canvas width="40" height="40"></canvas></li>'
  + '<li class="passes"><a href="#">passes:</a> <em>0</em></li>'
  + '<li class="failures"><a href="#">failures:</a> <em>0</em></li>'
  + '<li class="duration">duration: <em>0</em>s</li>'
  + '</ul>';

/**
 * Initialize a new `Doc` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function HTML(runner, root) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , total = runner.total
    , stat = fragment(statsTemplate)
    , items = stat.getElementsByTagName('li')
    , passes = items[1].getElementsByTagName('em')[0]
    , passesLink = items[1].getElementsByTagName('a')[0]
    , failures = items[2].getElementsByTagName('em')[0]
    , failuresLink = items[2].getElementsByTagName('a')[0]
    , duration = items[3].getElementsByTagName('em')[0]
    , canvas = stat.getElementsByTagName('canvas')[0]
    , report = fragment('<ul id="mocha-report"></ul>')
    , stack = [report]
    , progress
    , ctx

  root = root || document.getElementById('mocha');

  if (canvas.getContext) {
    var ratio = window.devicePixelRatio || 1;
    canvas.style.width = canvas.width;
    canvas.style.height = canvas.height;
    canvas.width *= ratio;
    canvas.height *= ratio;
    ctx = canvas.getContext('2d');
    ctx.scale(ratio, ratio);
    progress = new Progress;
  }

  if (!root) return error('#mocha div missing, add it to your document');

  // pass toggle
  on(passesLink, 'click', function(){
    unhide();
    var name = /pass/.test(report.className) ? '' : ' pass';
    report.className = report.className.replace(/fail|pass/g, '') + name;
    if (report.className.trim()) hideSuitesWithout('test pass');
  });

  // failure toggle
  on(failuresLink, 'click', function(){
    unhide();
    var name = /fail/.test(report.className) ? '' : ' fail';
    report.className = report.className.replace(/fail|pass/g, '') + name;
    if (report.className.trim()) hideSuitesWithout('test fail');
  });

  root.appendChild(stat);
  root.appendChild(report);

  if (progress) progress.size(40);

  runner.on('suite', function(suite){
    if (suite.root) return;

    // suite
    var url = '?grep=' + encodeURIComponent(suite.fullTitle());
    var el = fragment('<li class="suite"><h1><a href="%s">%s</a></h1></li>', url, escape(suite.title));

    // container
    stack[0].appendChild(el);
    stack.unshift(document.createElement('ul'));
    el.appendChild(stack[0]);
  });

  runner.on('suite end', function(suite){
    if (suite.root) return;
    stack.shift();
  });

  runner.on('fail', function(test, err){
    if ('hook' == test.type) runner.emit('test end', test);
  });

  runner.on('test end', function(test){
    window.scrollTo(0, document.body.scrollHeight);

    // TODO: add to stats
    var percent = stats.tests / this.total * 100 | 0;
    if (progress) progress.update(percent).draw(ctx);

    // update stats
    var ms = new Date - stats.start;
    text(passes, stats.passes);
    text(failures, stats.failures);
    text(duration, (ms / 1000).toFixed(2));

    // test
    if ('passed' == test.state) {
      var el = fragment('<li class="test pass %e"><h2>%e<span class="duration">%ems</span> <a href="?grep=%e" class="replay">вЂЈ</a></h2></li>', test.speed, test.title, test.duration, encodeURIComponent(test.fullTitle()));
    } else if (test.pending) {
      var el = fragment('<li class="test pass pending"><h2>%e</h2></li>', test.title);
    } else {
      var el = fragment('<li class="test fail"><h2>%e <a href="?grep=%e" class="replay">вЂЈ</a></h2></li>', test.title, encodeURIComponent(test.fullTitle()));
      var str = test.err.stack || test.err.toString();

      // FF / Opera do not add the message
      if (!~str.indexOf(test.err.message)) {
        str = test.err.message + '\n' + str;
      }

      // <=IE7 stringifies to [Object Error]. Since it can be overloaded, we
      // check for the result of the stringifying.
      if ('[object Error]' == str) str = test.err.message;

      // Safari doesn't give you a stack. Let's at least provide a source line.
      if (!test.err.stack && test.err.sourceURL && test.err.line !== undefined) {
        str += "\n(" + test.err.sourceURL + ":" + test.err.line + ")";
      }

      el.appendChild(fragment('<pre class="error">%e</pre>', str));
    }

    // toggle code
    // TODO: defer
    if (!test.pending) {
      var h2 = el.getElementsByTagName('h2')[0];

      on(h2, 'click', function(){
        pre.style.display = 'none' == pre.style.display
          ? 'block'
          : 'none';
      });

      var pre = fragment('<pre><code>%e</code></pre>', utils.clean(test.fn.toString()));
      el.appendChild(pre);
      pre.style.display = 'none';
    }

    // Don't call .appendChild if #mocha-report was already .shift()'ed off the stack.
    if (stack[0]) stack[0].appendChild(el);
  });
}

/**
 * Display error `msg`.
 */

function error(msg) {
  document.body.appendChild(fragment('<div id="mocha-error">%s</div>', msg));
}

/**
 * Return a DOM fragment from `html`.
 */

function fragment(html) {
  var args = arguments
    , div = document.createElement('div')
    , i = 1;

  div.innerHTML = html.replace(/%([se])/g, function(_, type){
    switch (type) {
      case 's': return String(args[i++]);
      case 'e': return escape(args[i++]);
    }
  });

  return div.firstChild;
}

/**
 * Check for suites that do not have elements
 * with `classname`, and hide them.
 */

function hideSuitesWithout(classname) {
  var suites = document.getElementsByClassName('suite');
  for (var i = 0; i < suites.length; i++) {
    var els = suites[i].getElementsByClassName(classname);
    if (0 == els.length) suites[i].className += ' hidden';
  }
}

/**
 * Unhide .hidden suites.
 */

function unhide() {
  var els = document.getElementsByClassName('suite hidden');
  for (var i = 0; i < els.length; ++i) {
    els[i].className = els[i].className.replace('suite hidden', 'suite');
  }
}

/**
 * Set `el` text to `str`.
 */

function text(el, str) {
  if (el.textContent) {
    el.textContent = str;
  } else {
    el.innerText = str;
  }
}

/**
 * Listen on `event` with callback `fn`.
 */

function on(el, event, fn) {
  if (el.addEventListener) {
    el.addEventListener(event, fn, false);
  } else {
    el.attachEvent('on' + event, fn);
  }
}

}); // module: reporters/html.js

require.register("reporters/index.js", function(module, exports, require){

exports.Base = require('./base');
exports.Dot = require('./dot');
exports.Doc = require('./doc');
exports.TAP = require('./tap');
exports.JSON = require('./json');
exports.HTML = require('./html');
exports.List = require('./list');
exports.Min = require('./min');
exports.Spec = require('./spec');
exports.Nyan = require('./nyan');
exports.XUnit = require('./xunit');
exports.Markdown = require('./markdown');
exports.Progress = require('./progress');
exports.Landing = require('./landing');
exports.JSONCov = require('./json-cov');
exports.HTMLCov = require('./html-cov');
exports.JSONStream = require('./json-stream');
exports.Teamcity = require('./teamcity');

}); // module: reporters/index.js

require.register("reporters/json-cov.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base');

/**
 * Expose `JSONCov`.
 */

exports = module.exports = JSONCov;

/**
 * Initialize a new `JsCoverage` reporter.
 *
 * @param {Runner} runner
 * @param {Boolean} output
 * @api public
 */

function JSONCov(runner, output) {
  var self = this
    , output = 1 == arguments.length ? true : output;

  Base.call(this, runner);

  var tests = []
    , failures = []
    , passes = [];

  runner.on('test end', function(test){
    tests.push(test);
  });

  runner.on('pass', function(test){
    passes.push(test);
  });

  runner.on('fail', function(test){
    failures.push(test);
  });

  runner.on('end', function(){
    var cov = global._$jscoverage || {};
    var result = self.cov = map(cov);
    result.stats = self.stats;
    result.tests = tests.map(clean);
    result.failures = failures.map(clean);
    result.passes = passes.map(clean);
    if (!output) return;
    process.stdout.write(JSON.stringify(result, null, 2 ));
  });
}

/**
 * Map jscoverage data to a JSON structure
 * suitable for reporting.
 *
 * @param {Object} cov
 * @return {Object}
 * @api private
 */

function map(cov) {
  var ret = {
      instrumentation: 'node-jscoverage'
    , sloc: 0
    , hits: 0
    , misses: 0
    , coverage: 0
    , files: []
  };

  for (var filename in cov) {
    var data = coverage(filename, cov[filename]);
    ret.files.push(data);
    ret.hits += data.hits;
    ret.misses += data.misses;
    ret.sloc += data.sloc;
  }

  ret.files.sort(function(a, b) {
    return a.filename.localeCompare(b.filename);
  });

  if (ret.sloc > 0) {
    ret.coverage = (ret.hits / ret.sloc) * 100;
  }

  return ret;
};

/**
 * Map jscoverage data for a single source file
 * to a JSON structure suitable for reporting.
 *
 * @param {String} filename name of the source file
 * @param {Object} data jscoverage coverage data
 * @return {Object}
 * @api private
 */

function coverage(filename, data) {
  var ret = {
    filename: filename,
    coverage: 0,
    hits: 0,
    misses: 0,
    sloc: 0,
    source: {}
  };

  data.source.forEach(function(line, num){
    num++;

    if (data[num] === 0) {
      ret.misses++;
      ret.sloc++;
    } else if (data[num] !== undefined) {
      ret.hits++;
      ret.sloc++;
    }

    ret.source[num] = {
        source: line
      , coverage: data[num] === undefined
        ? ''
        : data[num]
    };
  });

  ret.coverage = ret.hits / ret.sloc * 100;

  return ret;
}

/**
 * Return a plain-object representation of `test`
 * free of cyclic properties etc.
 *
 * @param {Object} test
 * @return {Object}
 * @api private
 */

function clean(test) {
  return {
      title: test.title
    , fullTitle: test.fullTitle()
    , duration: test.duration
  }
}

}); // module: reporters/json-cov.js

require.register("reporters/json-stream.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , color = Base.color;

/**
 * Expose `List`.
 */

exports = module.exports = List;

/**
 * Initialize a new `List` test reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function List(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , total = runner.total;

  runner.on('start', function(){
    console.log(JSON.stringify(['start', { total: total }]));
  });

  runner.on('pass', function(test){
    console.log(JSON.stringify(['pass', clean(test)]));
  });

  runner.on('fail', function(test, err){
    console.log(JSON.stringify(['fail', clean(test)]));
  });

  runner.on('end', function(){
    process.stdout.write(JSON.stringify(['end', self.stats]));
  });
}

/**
 * Return a plain-object representation of `test`
 * free of cyclic properties etc.
 *
 * @param {Object} test
 * @return {Object}
 * @api private
 */

function clean(test) {
  return {
      title: test.title
    , fullTitle: test.fullTitle()
    , duration: test.duration
  }
}
}); // module: reporters/json-stream.js

require.register("reporters/json.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , cursor = Base.cursor
  , color = Base.color;

/**
 * Expose `JSON`.
 */

exports = module.exports = JSONReporter;

/**
 * Initialize a new `JSON` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function JSONReporter(runner) {
  var self = this;
  Base.call(this, runner);

  var tests = []
    , failures = []
    , passes = [];

  runner.on('test end', function(test){
    tests.push(test);
  });

  runner.on('pass', function(test){
    passes.push(test);
  });

  runner.on('fail', function(test){
    failures.push(test);
  });

  runner.on('end', function(){
    var obj = {
        stats: self.stats
      , tests: tests.map(clean)
      , failures: failures.map(clean)
      , passes: passes.map(clean)
    };

    process.stdout.write(JSON.stringify(obj, null, 2));
  });
}

/**
 * Return a plain-object representation of `test`
 * free of cyclic properties etc.
 *
 * @param {Object} test
 * @return {Object}
 * @api private
 */

function clean(test) {
  return {
      title: test.title
    , fullTitle: test.fullTitle()
    , duration: test.duration
  }
}
}); // module: reporters/json.js

require.register("reporters/landing.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , cursor = Base.cursor
  , color = Base.color;

/**
 * Expose `Landing`.
 */

exports = module.exports = Landing;

/**
 * Airplane color.
 */

Base.colors.plane = 0;

/**
 * Airplane crash color.
 */

Base.colors['plane crash'] = 31;

/**
 * Runway color.
 */

Base.colors.runway = 90;

/**
 * Initialize a new `Landing` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function Landing(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , width = Base.window.width * .75 | 0
    , total = runner.total
    , stream = process.stdout
    , plane = color('plane', 'вњ€')
    , crashed = -1
    , n = 0;

  function runway() {
    var buf = Array(width).join('-');
    return '  ' + color('runway', buf);
  }

  runner.on('start', function(){
    stream.write('\n  ');
    cursor.hide();
  });

  runner.on('test end', function(test){
    // check if the plane crashed
    var col = -1 == crashed
      ? width * ++n / total | 0
      : crashed;

    // show the crash
    if ('failed' == test.state) {
      plane = color('plane crash', 'вњ€');
      crashed = col;
    }

    // render landing strip
    stream.write('\u001b[4F\n\n');
    stream.write(runway());
    stream.write('\n  ');
    stream.write(color('runway', Array(col).join('в‹…')));
    stream.write(plane)
    stream.write(color('runway', Array(width - col).join('в‹…') + '\n'));
    stream.write(runway());
    stream.write('\u001b[0m');
  });

  runner.on('end', function(){
    cursor.show();
    console.log();
    self.epilogue();
  });
}

/**
 * Inherit from `Base.prototype`.
 */

function F(){};
F.prototype = Base.prototype;
Landing.prototype = new F;
Landing.prototype.constructor = Landing;

}); // module: reporters/landing.js

require.register("reporters/list.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , cursor = Base.cursor
  , color = Base.color;

/**
 * Expose `List`.
 */

exports = module.exports = List;

/**
 * Initialize a new `List` test reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function List(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , n = 0;

  runner.on('start', function(){
    console.log();
  });

  runner.on('test', function(test){
    process.stdout.write(color('pass', '    ' + test.fullTitle() + ': '));
  });

  runner.on('pending', function(test){
    var fmt = color('checkmark', '  -')
      + color('pending', ' %s');
    console.log(fmt, test.fullTitle());
  });

  runner.on('pass', function(test){
    var fmt = color('checkmark', '  '+Base.symbols.dot)
      + color('pass', ' %s: ')
      + color(test.speed, '%dms');
    cursor.CR();
    console.log(fmt, test.fullTitle(), test.duration);
  });

  runner.on('fail', function(test, err){
    cursor.CR();
    console.log(color('fail', '  %d) %s'), ++n, test.fullTitle());
  });

  runner.on('end', self.epilogue.bind(self));
}

/**
 * Inherit from `Base.prototype`.
 */

function F(){};
F.prototype = Base.prototype;
List.prototype = new F;
List.prototype.constructor = List;


}); // module: reporters/list.js

require.register("reporters/markdown.js", function(module, exports, require){
/**
 * Module dependencies.
 */

var Base = require('./base')
  , utils = require('../utils');

/**
 * Expose `Markdown`.
 */

exports = module.exports = Markdown;

/**
 * Initialize a new `Markdown` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function Markdown(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , level = 0
    , buf = '';

  function title(str) {
    return Array(level).join('#') + ' ' + str;
  }

  function indent() {
    return Array(level).join('  ');
  }

  function mapTOC(suite, obj) {
    var ret = obj;
    obj = obj[suite.title] = obj[suite.title] || { suite: suite };
    suite.suites.forEach(function(suite){
      mapTOC(suite, obj);
    });
    return ret;
  }

  function stringifyTOC(obj, level) {
    ++level;
    var buf = '';
    var link;
    for (var key in obj) {
      if ('suite' == key) continue;
      if (key) link = ' - [' + key + '](#' + utils.slug(obj[key].suite.fullTitle()) + ')\n';
      if (key) buf += Array(level).join('  ') + link;
      buf += stringifyTOC(obj[key], level);
    }
    --level;
    return buf;
  }

  function generateTOC(suite) {
    var obj = mapTOC(suite, {});
    return stringifyTOC(obj, 0);
  }

  generateTOC(runner.suite);

  runner.on('suite', function(suite){
    ++level;
    var slug = utils.slug(suite.fullTitle());
    buf += '<a name="' + slug + '"></a>' + '\n';
    buf += title(suite.title) + '\n';
  });

  runner.on('suite end', function(suite){
    --level;
  });

  runner.on('pass', function(test){
    var code = utils.clean(test.fn.toString());
    buf += test.title + '.\n';
    buf += '\n```js\n';
    buf += code + '\n';
    buf += '```\n\n';
  });

  runner.on('end', function(){
    process.stdout.write('# TOC\n');
    process.stdout.write(generateTOC(runner.suite));
    process.stdout.write(buf);
  });
}
}); // module: reporters/markdown.js

require.register("reporters/min.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base');

/**
 * Expose `Min`.
 */

exports = module.exports = Min;

/**
 * Initialize a new `Min` minimal test reporter (best used with --watch).
 *
 * @param {Runner} runner
 * @api public
 */

function Min(runner) {
  Base.call(this, runner);

  runner.on('start', function(){
    // clear screen
    process.stdout.write('\u001b[2J');
    // set cursor position
    process.stdout.write('\u001b[1;3H');
  });

  runner.on('end', this.epilogue.bind(this));
}

/**
 * Inherit from `Base.prototype`.
 */

function F(){};
F.prototype = Base.prototype;
Min.prototype = new F;
Min.prototype.constructor = Min;

}); // module: reporters/min.js

require.register("reporters/nyan.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , color = Base.color;

/**
 * Expose `Dot`.
 */

exports = module.exports = NyanCat;

/**
 * Initialize a new `Dot` matrix test reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function NyanCat(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , width = Base.window.width * .75 | 0
    , rainbowColors = this.rainbowColors = self.generateColors()
    , colorIndex = this.colorIndex = 0
    , numerOfLines = this.numberOfLines = 4
    , trajectories = this.trajectories = [[], [], [], []]
    , nyanCatWidth = this.nyanCatWidth = 11
    , trajectoryWidthMax = this.trajectoryWidthMax = (width - nyanCatWidth)
    , scoreboardWidth = this.scoreboardWidth = 5
    , tick = this.tick = 0
    , n = 0;

  runner.on('start', function(){
    Base.cursor.hide();
    self.draw('start');
  });

  runner.on('pending', function(test){
    self.draw('pending');
  });

  runner.on('pass', function(test){
    self.draw('pass');
  });

  runner.on('fail', function(test, err){
    self.draw('fail');
  });

  runner.on('end', function(){
    Base.cursor.show();
    for (var i = 0; i < self.numberOfLines; i++) write('\n');
    self.epilogue();
  });
}

/**
 * Draw the nyan cat with runner `status`.
 *
 * @param {String} status
 * @api private
 */

NyanCat.prototype.draw = function(status){
  this.appendRainbow();
  this.drawScoreboard();
  this.drawRainbow();
  this.drawNyanCat(status);
  this.tick = !this.tick;
};

/**
 * Draw the "scoreboard" showing the number
 * of passes, failures and pending tests.
 *
 * @api private
 */

NyanCat.prototype.drawScoreboard = function(){
  var stats = this.stats;
  var colors = Base.colors;

  function draw(color, n) {
    write(' ');
    write('\u001b[' + color + 'm' + n + '\u001b[0m');
    write('\n');
  }

  draw(colors.green, stats.passes);
  draw(colors.fail, stats.failures);
  draw(colors.pending, stats.pending);
  write('\n');

  this.cursorUp(this.numberOfLines);
};

/**
 * Append the rainbow.
 *
 * @api private
 */

NyanCat.prototype.appendRainbow = function(){
  var segment = this.tick ? '_' : '-';
  var rainbowified = this.rainbowify(segment);

  for (var index = 0; index < this.numberOfLines; index++) {
    var trajectory = this.trajectories[index];
    if (trajectory.length >= this.trajectoryWidthMax) trajectory.shift();
    trajectory.push(rainbowified);
  }
};

/**
 * Draw the rainbow.
 *
 * @api private
 */

NyanCat.prototype.drawRainbow = function(){
  var self = this;

  this.trajectories.forEach(function(line, index) {
    write('\u001b[' + self.scoreboardWidth + 'C');
    write(line.join(''));
    write('\n');
  });

  this.cursorUp(this.numberOfLines);
};

/**
 * Draw the nyan cat with `status`.
 *
 * @param {String} status
 * @api private
 */

NyanCat.prototype.drawNyanCat = function(status) {
  var self = this;
  var startWidth = this.scoreboardWidth + this.trajectories[0].length;

  [0, 1, 2, 3].forEach(function(index) {
    write('\u001b[' + startWidth + 'C');

    switch (index) {
      case 0:
        write('_,------,');
        write('\n');
        break;
      case 1:
        var padding = self.tick ? '  ' : '   ';
        write('_|' + padding + '/\\_/\\ ');
        write('\n');
        break;
      case 2:
        var padding = self.tick ? '_' : '__';
        var tail = self.tick ? '~' : '^';
        var face;
        switch (status) {
          case 'pass':
            face = '( ^ .^)';
            break;
          case 'fail':
            face = '( o .o)';
            break;
          default:
            face = '( - .-)';
        }
        write(tail + '|' + padding + face + ' ');
        write('\n');
        break;
      case 3:
        var padding = self.tick ? ' ' : '  ';
        write(padding + '""  "" ');
        write('\n');
        break;
    }
  });

  this.cursorUp(this.numberOfLines);
};

/**
 * Move cursor up `n`.
 *
 * @param {Number} n
 * @api private
 */

NyanCat.prototype.cursorUp = function(n) {
  write('\u001b[' + n + 'A');
};

/**
 * Move cursor down `n`.
 *
 * @param {Number} n
 * @api private
 */

NyanCat.prototype.cursorDown = function(n) {
  write('\u001b[' + n + 'B');
};

/**
 * Generate rainbow colors.
 *
 * @return {Array}
 * @api private
 */

NyanCat.prototype.generateColors = function(){
  var colors = [];

  for (var i = 0; i < (6 * 7); i++) {
    var pi3 = Math.floor(Math.PI / 3);
    var n = (i * (1.0 / 6));
    var r = Math.floor(3 * Math.sin(n) + 3);
    var g = Math.floor(3 * Math.sin(n + 2 * pi3) + 3);
    var b = Math.floor(3 * Math.sin(n + 4 * pi3) + 3);
    colors.push(36 * r + 6 * g + b + 16);
  }

  return colors;
};

/**
 * Apply rainbow to the given `str`.
 *
 * @param {String} str
 * @return {String}
 * @api private
 */

NyanCat.prototype.rainbowify = function(str){
  var color = this.rainbowColors[this.colorIndex % this.rainbowColors.length];
  this.colorIndex += 1;
  return '\u001b[38;5;' + color + 'm' + str + '\u001b[0m';
};

/**
 * Stdout helper.
 */

function write(string) {
  process.stdout.write(string);
}

/**
 * Inherit from `Base.prototype`.
 */

function F(){};
F.prototype = Base.prototype;
NyanCat.prototype = new F;
NyanCat.prototype.constructor = NyanCat;


}); // module: reporters/nyan.js

require.register("reporters/progress.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , cursor = Base.cursor
  , color = Base.color;

/**
 * Expose `Progress`.
 */

exports = module.exports = Progress;

/**
 * General progress bar color.
 */

Base.colors.progress = 90;

/**
 * Initialize a new `Progress` bar test reporter.
 *
 * @param {Runner} runner
 * @param {Object} options
 * @api public
 */

function Progress(runner, options) {
  Base.call(this, runner);

  var self = this
    , options = options || {}
    , stats = this.stats
    , width = Base.window.width * .50 | 0
    , total = runner.total
    , complete = 0
    , max = Math.max;

  // default chars
  options.open = options.open || '[';
  options.complete = options.complete || 'в–¬';
  options.incomplete = options.incomplete || Base.symbols.dot;
  options.close = options.close || ']';
  options.verbose = false;

  // tests started
  runner.on('start', function(){
    console.log();
    cursor.hide();
  });

  // tests complete
  runner.on('test end', function(){
    complete++;
    var incomplete = total - complete
      , percent = complete / total
      , n = width * percent | 0
      , i = width - n;

    cursor.CR();
    process.stdout.write('\u001b[J');
    process.stdout.write(color('progress', '  ' + options.open));
    process.stdout.write(Array(n).join(options.complete));
    process.stdout.write(Array(i).join(options.incomplete));
    process.stdout.write(color('progress', options.close));
    if (options.verbose) {
      process.stdout.write(color('progress', ' ' + complete + ' of ' + total));
    }
  });

  // tests are complete, output some stats
  // and the failures if any
  runner.on('end', function(){
    cursor.show();
    console.log();
    self.epilogue();
  });
}

/**
 * Inherit from `Base.prototype`.
 */

function F(){};
F.prototype = Base.prototype;
Progress.prototype = new F;
Progress.prototype.constructor = Progress;


}); // module: reporters/progress.js

require.register("reporters/spec.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , cursor = Base.cursor
  , color = Base.color;

/**
 * Expose `Spec`.
 */

exports = module.exports = Spec;

/**
 * Initialize a new `Spec` test reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function Spec(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , indents = 0
    , n = 0;

  function indent() {
    return Array(indents).join('  ')
  }

  runner.on('start', function(){
    console.log();
  });

  runner.on('suite', function(suite){
    ++indents;
    console.log(color('suite', '%s%s'), indent(), suite.title);
  });

  runner.on('suite end', function(suite){
    --indents;
    if (1 == indents) console.log();
  });

  runner.on('test', function(test){
    process.stdout.write(indent() + color('pass', '  в—¦ ' + test.title + ': '));
  });

  runner.on('pending', function(test){
    var fmt = indent() + color('pending', '  - %s');
    console.log(fmt, test.title);
  });

  runner.on('pass', function(test){
    if ('fast' == test.speed) {
      var fmt = indent()
        + color('checkmark', '  ' + Base.symbols.ok)
        + color('pass', ' %s ');
      cursor.CR();
      console.log(fmt, test.title);
    } else {
      var fmt = indent()
        + color('checkmark', '  ' + Base.symbols.ok)
        + color('pass', ' %s ')
        + color(test.speed, '(%dms)');
      cursor.CR();
      console.log(fmt, test.title, test.duration);
    }
  });

  runner.on('fail', function(test, err){
    cursor.CR();
    console.log(indent() + color('fail', '  %d) %s'), ++n, test.title);
  });

  runner.on('end', self.epilogue.bind(self));
}

/**
 * Inherit from `Base.prototype`.
 */

function F(){};
F.prototype = Base.prototype;
Spec.prototype = new F;
Spec.prototype.constructor = Spec;


}); // module: reporters/spec.js

require.register("reporters/tap.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , cursor = Base.cursor
  , color = Base.color;

/**
 * Expose `TAP`.
 */

exports = module.exports = TAP;

/**
 * Initialize a new `TAP` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function TAP(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , n = 1
    , passes = 0
    , failures = 0;

  runner.on('start', function(){
    var total = runner.grepTotal(runner.suite);
    console.log('%d..%d', 1, total);
  });

  runner.on('test end', function(){
    ++n;
  });

  runner.on('pending', function(test){
    console.log('ok %d %s # SKIP -', n, title(test));
  });

  runner.on('pass', function(test){
    passes++;
    console.log('ok %d %s', n, title(test));
  });

  runner.on('fail', function(test, err){
    failures++;
    console.log('not ok %d %s', n, title(test));
    if (err.stack) console.log(err.stack.replace(/^/gm, '  '));
  });

  runner.on('end', function(){
    console.log('# tests ' + (passes + failures));
    console.log('# pass ' + passes);
    console.log('# fail ' + failures);
  });
}

/**
 * Return a TAP-safe title of `test`
 *
 * @param {Object} test
 * @return {String}
 * @api private
 */

function title(test) {
  return test.fullTitle().replace(/#/g, '');
}

}); // module: reporters/tap.js

require.register("reporters/teamcity.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base');

/**
 * Expose `Teamcity`.
 */

exports = module.exports = Teamcity;

/**
 * Initialize a new `Teamcity` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function Teamcity(runner) {
  Base.call(this, runner);
  var stats = this.stats;

  runner.on('start', function() {
    console.log("##teamcity[testSuiteStarted name='mocha.suite']");
  });

  runner.on('test', function(test) {
    console.log("##teamcity[testStarted name='" + escape(test.fullTitle()) + "']");
  });

  runner.on('fail', function(test, err) {
    console.log("##teamcity[testFailed name='" + escape(test.fullTitle()) + "' message='" + escape(err.message) + "']");
  });

  runner.on('pending', function(test) {
    console.log("##teamcity[testIgnored name='" + escape(test.fullTitle()) + "' message='pending']");
  });

  runner.on('test end', function(test) {
    console.log("##teamcity[testFinished name='" + escape(test.fullTitle()) + "' duration='" + test.duration + "']");
  });

  runner.on('end', function() {
    console.log("##teamcity[testSuiteFinished name='mocha.suite' duration='" + stats.duration + "']");
  });
}

/**
 * Escape the given `str`.
 */

function escape(str) {
  return str
    .replace(/\|/g, "||")
    .replace(/\n/g, "|n")
    .replace(/\r/g, "|r")
    .replace(/\[/g, "|[")
    .replace(/\]/g, "|]")
    .replace(/\u0085/g, "|x")
    .replace(/\u2028/g, "|l")
    .replace(/\u2029/g, "|p")
    .replace(/'/g, "|'");
}

}); // module: reporters/teamcity.js

require.register("reporters/xunit.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Base = require('./base')
  , utils = require('../utils')
  , escape = utils.escape;

/**
 * Save timer references to avoid Sinon interfering (see GH-237).
 */

var Date = global.Date
  , setTimeout = global.setTimeout
  , setInterval = global.setInterval
  , clearTimeout = global.clearTimeout
  , clearInterval = global.clearInterval;

/**
 * Expose `XUnit`.
 */

exports = module.exports = XUnit;

/**
 * Initialize a new `XUnit` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function XUnit(runner) {
  Base.call(this, runner);
  var stats = this.stats
    , tests = []
    , self = this;

  runner.on('pass', function(test){
    tests.push(test);
  });

  runner.on('fail', function(test){
    tests.push(test);
  });

  runner.on('end', function(){
    console.log(tag('testsuite', {
        name: 'Mocha Tests'
      , tests: stats.tests
      , failures: stats.failures
      , errors: stats.failures
      , skip: stats.tests - stats.failures - stats.passes
      , timestamp: (new Date).toUTCString()
      , time: stats.duration / 1000
    }, false));

    tests.forEach(test);
    console.log('</testsuite>');
  });
}

/**
 * Inherit from `Base.prototype`.
 */

function F(){};
F.prototype = Base.prototype;
XUnit.prototype = new F;
XUnit.prototype.constructor = XUnit;


/**
 * Output tag for the given `test.`
 */

function test(test) {
  var attrs = {
      classname: test.parent.fullTitle()
    , name: test.title
    , time: test.duration / 1000
  };

  if ('failed' == test.state) {
    var err = test.err;
    attrs.message = escape(err.message);
    console.log(tag('testcase', attrs, false, tag('failure', attrs, false, cdata(err.stack))));
  } else if (test.pending) {
    console.log(tag('testcase', attrs, false, tag('skipped', {}, true)));
  } else {
    console.log(tag('testcase', attrs, true) );
  }
}

/**
 * HTML tag helper.
 */

function tag(name, attrs, close, content) {
  var end = close ? '/>' : '>'
    , pairs = []
    , tag;

  for (var key in attrs) {
    pairs.push(key + '="' + escape(attrs[key]) + '"');
  }

  tag = '<' + name + (pairs.length ? ' ' + pairs.join(' ') : '') + end;
  if (content) tag += content + '</' + name + end;
  return tag;
}

/**
 * Return cdata escaped CDATA `str`.
 */

function cdata(str) {
  return '<![CDATA[' + escape(str) + ']]>';
}

}); // module: reporters/xunit.js

require.register("runnable.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var EventEmitter = require('browser/events').EventEmitter
  , debug = require('browser/debug')('mocha:runnable')
  , milliseconds = require('./ms');

/**
 * Save timer references to avoid Sinon interfering (see GH-237).
 */

var Date = global.Date
  , setTimeout = global.setTimeout
  , setInterval = global.setInterval
  , clearTimeout = global.clearTimeout
  , clearInterval = global.clearInterval;

/**
 * Object#toString().
 */

var toString = Object.prototype.toString;

/**
 * Expose `Runnable`.
 */

module.exports = Runnable;

/**
 * Initialize a new `Runnable` with the given `title` and callback `fn`.
 *
 * @param {String} title
 * @param {Function} fn
 * @api private
 */

function Runnable(title, fn) {
  this.title = title;
  this.fn = fn;
  this.async = fn && fn.length;
  this.sync = ! this.async;
  this._timeout = 2000;
  this._slow = 75;
  this.timedOut = false;
}

/**
 * Inherit from `EventEmitter.prototype`.
 */

function F(){};
F.prototype = EventEmitter.prototype;
Runnable.prototype = new F;
Runnable.prototype.constructor = Runnable;


/**
 * Set & get timeout `ms`.
 *
 * @param {Number|String} ms
 * @return {Runnable|Number} ms or self
 * @api private
 */

Runnable.prototype.timeout = function(ms){
  if (0 == arguments.length) return this._timeout;
  if ('string' == typeof ms) ms = milliseconds(ms);
  debug('timeout %d', ms);
  this._timeout = ms;
  if (this.timer) this.resetTimeout();
  return this;
};

/**
 * Set & get slow `ms`.
 *
 * @param {Number|String} ms
 * @return {Runnable|Number} ms or self
 * @api private
 */

Runnable.prototype.slow = function(ms){
  if (0 === arguments.length) return this._slow;
  if ('string' == typeof ms) ms = milliseconds(ms);
  debug('timeout %d', ms);
  this._slow = ms;
  return this;
};

/**
 * Return the full title generated by recursively
 * concatenating the parent's full title.
 *
 * @return {String}
 * @api public
 */

Runnable.prototype.fullTitle = function(){
  return this.parent.fullTitle() + ' ' + this.title;
};

/**
 * Clear the timeout.
 *
 * @api private
 */

Runnable.prototype.clearTimeout = function(){
  clearTimeout(this.timer);
};

/**
 * Inspect the runnable void of private properties.
 *
 * @return {String}
 * @api private
 */

Runnable.prototype.inspect = function(){
  return JSON.stringify(this, function(key, val){
    if ('_' == key[0]) return;
    if ('parent' == key) return '#<Suite>';
    if ('ctx' == key) return '#<Context>';
    return val;
  }, 2);
};

/**
 * Reset the timeout.
 *
 * @api private
 */

Runnable.prototype.resetTimeout = function(){
  var self = this
    , ms = this.timeout();

  this.clearTimeout();
  if (ms) {
    this.timer = setTimeout(function(){
      self.callback(new Error('timeout of ' + ms + 'ms exceeded'));
      self.timedOut = true;
    }, ms);
  }
};

/**
 * Run the test and invoke `fn(err)`.
 *
 * @param {Function} fn
 * @api private
 */

Runnable.prototype.run = function(fn){
  var self = this
    , ms = this.timeout()
    , start = new Date
    , ctx = this.ctx
    , finished
    , emitted;

  if (ctx) ctx.runnable(this);

  // timeout
  if (this.async) {
    if (ms) {
      this.timer = setTimeout(function(){
        done(new Error('timeout of ' + ms + 'ms exceeded'));
        self.timedOut = true;
      }, ms);
    }
  }

  // called multiple times
  function multiple(err) {
    if (emitted) return;
    emitted = true;
    self.emit('error', err || new Error('done() called multiple times'));
  }

  // finished
  function done(err) {
    if (self.timedOut) return;
    if (finished) return multiple(err);
    self.clearTimeout();
    self.duration = new Date - start;
    finished = true;
    fn(err);
  }

  // for .resetTimeout()
  this.callback = done;

  // async
  if (this.async) {
    try {
      this.fn.call(ctx, function(err){
        if (err instanceof Error || toString.call(err) === "[object Error]") return done(err);
        if (null != err) return done(new Error('done() invoked with non-Error: ' + err));
        done();
      });
    } catch (err) {
      done(err);
    }
    return;
  }

  if (this.asyncOnly) {
    return done(new Error('--async-only option in use without declaring `done()`'));
  }

  // sync
  try {
    if (!this.pending) this.fn.call(ctx);
    this.duration = new Date - start;
    fn();
  } catch (err) {
    fn(err);
  }
};

}); // module: runnable.js

require.register("runner.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var EventEmitter = require('browser/events').EventEmitter
  , debug = require('browser/debug')('mocha:runner')
  , Test = require('./test')
  , utils = require('./utils')
  , filter = utils.filter
  , keys = utils.keys
  , noop = function(){};

/**
 * Non-enumerable globals.
 */

var globals = [
  'setTimeout',
  'clearTimeout',
  'setInterval',
  'clearInterval',
  'XMLHttpRequest',
  'Date'
];

/**
 * Expose `Runner`.
 */

module.exports = Runner;

/**
 * Initialize a `Runner` for the given `suite`.
 *
 * Events:
 *
 *   - `start`  execution started
 *   - `end`  execution complete
 *   - `suite`  (suite) test suite execution started
 *   - `suite end`  (suite) all tests (and sub-suites) have finished
 *   - `test`  (test) test execution started
 *   - `test end`  (test) test completed
 *   - `hook`  (hook) hook execution started
 *   - `hook end`  (hook) hook complete
 *   - `pass`  (test) test passed
 *   - `fail`  (test, err) test failed
 *
 * @api public
 */

function Runner(suite) {
  var self = this;
  this._globals = [];
  this.suite = suite;
  this.total = suite.total();
  this.failures = 0;
  this.on('test end', function(test){ self.checkGlobals(test); });
  this.on('hook end', function(hook){ self.checkGlobals(hook); });
  this.grep(/.*/);
  this.globals(this.globalProps().concat(['errno']));
}

/**
 * Inherit from `EventEmitter.prototype`.
 */

function F(){};
F.prototype = EventEmitter.prototype;
Runner.prototype = new F;
Runner.prototype.constructor = Runner;


/**
 * Run tests with full titles matching `re`. Updates runner.total
 * with number of tests matched.
 *
 * @param {RegExp} re
 * @param {Boolean} invert
 * @return {Runner} for chaining
 * @api public
 */

Runner.prototype.grep = function(re, invert){
  debug('grep %s', re);
  this._grep = re;
  this._invert = invert;
  this.total = this.grepTotal(this.suite);
  return this;
};

/**
 * Returns the number of tests matching the grep search for the
 * given suite.
 *
 * @param {Suite} suite
 * @return {Number}
 * @api public
 */

Runner.prototype.grepTotal = function(suite) {
  var self = this;
  var total = 0;

  suite.eachTest(function(test){
    var match = self._grep.test(test.fullTitle());
    if (self._invert) match = !match;
    if (match) total++;
  });

  return total;
};

/**
 * Return a list of global properties.
 *
 * @return {Array}
 * @api private
 */

Runner.prototype.globalProps = function() {
  var props = utils.keys(global);

  // non-enumerables
  for (var i = 0; i < globals.length; ++i) {
    if (~utils.indexOf(props, globals[i])) continue;
    props.push(globals[i]);
  }

  return props;
};

/**
 * Allow the given `arr` of globals.
 *
 * @param {Array} arr
 * @return {Runner} for chaining
 * @api public
 */

Runner.prototype.globals = function(arr){
  if (0 == arguments.length) return this._globals;
  debug('globals %j', arr);
  utils.forEach(arr, function(arr){
    this._globals.push(arr);
  }, this);
  return this;
};

/**
 * Check for global variable leaks.
 *
 * @api private
 */

Runner.prototype.checkGlobals = function(test){
  if (this.ignoreLeaks) return;
  var ok = this._globals;
  var globals = this.globalProps();
  var isNode = process.kill;
  var leaks;

  // check length - 2 ('errno' and 'location' globals)
  if (isNode && 1 == ok.length - globals.length) return
  else if (2 == ok.length - globals.length) return;

  leaks = filterLeaks(ok, globals);
  this._globals = this._globals.concat(leaks);

  if (leaks.length > 1) {
    this.fail(test, new Error('global leaks detected: ' + leaks.join(', ') + ''));
  } else if (leaks.length) {
    this.fail(test, new Error('global leak detected: ' + leaks[0]));
  }
};

/**
 * Fail the given `test`.
 *
 * @param {Test} test
 * @param {Error} err
 * @api private
 */

Runner.prototype.fail = function(test, err){
  ++this.failures;
  test.state = 'failed';

  if ('string' == typeof err) {
    err = new Error('the string "' + err + '" was thrown, throw an Error :)');
  }

  this.emit('fail', test, err);
};

/**
 * Fail the given `hook` with `err`.
 *
 * Hook failures (currently) hard-end due
 * to that fact that a failing hook will
 * surely cause subsequent tests to fail,
 * causing jumbled reporting.
 *
 * @param {Hook} hook
 * @param {Error} err
 * @api private
 */

Runner.prototype.failHook = function(hook, err){
  this.fail(hook, err);
  this.emit('end');
};

/**
 * Run hook `name` callbacks and then invoke `fn()`.
 *
 * @param {String} name
 * @param {Function} function
 * @api private
 */

Runner.prototype.hook = function(name, fn){
  var suite = this.suite
    , hooks = suite['_' + name]
    , self = this
    , timer;

  function next(i) {
    var hook = hooks[i];
    if (!hook) return fn();
    self.currentRunnable = hook;

    self.emit('hook', hook);

    hook.on('error', function(err){
      self.failHook(hook, err);
    });

    hook.run(function(err){
      hook.removeAllListeners('error');
      var testError = hook.error();
      if (testError) self.fail(self.test, testError);
      if (err) return self.failHook(hook, err);
      self.emit('hook end', hook);
      next(++i);
    });
  }

  process.nextTick(function(){
    next(0);
  });
};

/**
 * Run hook `name` for the given array of `suites`
 * in order, and callback `fn(err)`.
 *
 * @param {String} name
 * @param {Array} suites
 * @param {Function} fn
 * @api private
 */

Runner.prototype.hooks = function(name, suites, fn){
  var self = this
    , orig = this.suite;

  function next(suite) {
    self.suite = suite;

    if (!suite) {
      self.suite = orig;
      return fn();
    }

    self.hook(name, function(err){
      if (err) {
        self.suite = orig;
        return fn(err);
      }

      next(suites.pop());
    });
  }

  next(suites.pop());
};

/**
 * Run hooks from the top level down.
 *
 * @param {String} name
 * @param {Function} fn
 * @api private
 */

Runner.prototype.hookUp = function(name, fn){
  var suites = [this.suite].concat(this.parents()).reverse();
  this.hooks(name, suites, fn);
};

/**
 * Run hooks from the bottom up.
 *
 * @param {String} name
 * @param {Function} fn
 * @api private
 */

Runner.prototype.hookDown = function(name, fn){
  var suites = [this.suite].concat(this.parents());
  this.hooks(name, suites, fn);
};

/**
 * Return an array of parent Suites from
 * closest to furthest.
 *
 * @return {Array}
 * @api private
 */

Runner.prototype.parents = function(){
  var suite = this.suite
    , suites = [];
  while (suite = suite.parent) suites.push(suite);
  return suites;
};

/**
 * Run the current test and callback `fn(err)`.
 *
 * @param {Function} fn
 * @api private
 */

Runner.prototype.runTest = function(fn){
  var test = this.test
    , self = this;

  if (this.asyncOnly) test.asyncOnly = true;

  try {
    test.on('error', function(err){
      self.fail(test, err);
    });
    test.run(fn);
  } catch (err) {
    fn(err);
  }
};

/**
 * Run tests in the given `suite` and invoke
 * the callback `fn()` when complete.
 *
 * @param {Suite} suite
 * @param {Function} fn
 * @api private
 */

Runner.prototype.runTests = function(suite, fn){
  var self = this
    , tests = suite.tests.slice()
    , test;

  function next(err) {
    // if we bail after first err
    if (self.failures && suite._bail) return fn();

    // next test
    test = tests.shift();

    // all done
    if (!test) return fn();

    // grep
    var match = self._grep.test(test.fullTitle());
    if (self._invert) match = !match;
    if (!match) return next();

    // pending
    if (test.pending) {
      self.emit('pending', test);
      self.emit('test end', test);
      return next();
    }

    // execute test and hook(s)
    self.emit('test', self.test = test);
    self.hookDown('beforeEach', function(){
      self.currentRunnable = self.test;
      self.runTest(function(err){
        test = self.test;

        if (err) {
          self.fail(test, err);
          self.emit('test end', test);
          return self.hookUp('afterEach', next);
        }

        test.state = 'passed';
        self.emit('pass', test);
        self.emit('test end', test);
        self.hookUp('afterEach', next);
      });
    });
  }

  this.next = next;
  next();
};

/**
 * Run the given `suite` and invoke the
 * callback `fn()` when complete.
 *
 * @param {Suite} suite
 * @param {Function} fn
 * @api private
 */

Runner.prototype.runSuite = function(suite, fn){
  var total = this.grepTotal(suite)
    , self = this
    , i = 0;

  debug('run suite %s', suite.fullTitle());

  if (!total) return fn();

  this.emit('suite', this.suite = suite);

  function next() {
    var curr = suite.suites[i++];
    if (!curr) return done();
    self.runSuite(curr, next);
  }

  function done() {
    self.suite = suite;
    self.hook('afterAll', function(){
      self.emit('suite end', suite);
      fn();
    });
  }

  this.hook('beforeAll', function(){
    self.runTests(suite, next);
  });
};

/**
 * Handle uncaught exceptions.
 *
 * @param {Error} err
 * @api private
 */

Runner.prototype.uncaught = function(err){
  debug('uncaught exception %s', err.message);
  var runnable = this.currentRunnable;
  if (!runnable || 'failed' == runnable.state) return;
  runnable.clearTimeout();
  err.uncaught = true;
  this.fail(runnable, err);

  // recover from test
  if ('test' == runnable.type) {
    this.emit('test end', runnable);
    this.hookUp('afterEach', this.next);
    return;
  }

  // bail on hooks
  this.emit('end');
};

/**
 * Run the root suite and invoke `fn(failures)`
 * on completion.
 *
 * @param {Function} fn
 * @return {Runner} for chaining
 * @api public
 */

Runner.prototype.run = function(fn){
  var self = this
    , fn = fn || function(){};

  debug('start');

  // callback
  this.on('end', function(){
    debug('end');
    process.removeListener('uncaughtException', function(err){
      self.uncaught(err);
    });
    fn(self.failures);
  });

  // run suites
  this.emit('start');
  this.runSuite(this.suite, function(){
    debug('finished running');
    self.emit('end');
  });

  // uncaught exception
  process.on('uncaughtException', function(err){
    self.uncaught(err);
  });

  return this;
};

/**
 * Filter leaks with the given globals flagged as `ok`.
 *
 * @param {Array} ok
 * @param {Array} globals
 * @return {Array}
 * @api private
 */

function filterLeaks(ok, globals) {
  return filter(globals, function(key){
    var matched = filter(ok, function(ok){
      if (~ok.indexOf('*')) return 0 == key.indexOf(ok.split('*')[0]);
      // Opera and IE expose global variables for HTML element IDs (issue #243)
      if (/^mocha-/.test(key)) return true;
      return key == ok;
    });
    return matched.length == 0 && (!global.navigator || 'onerror' !== key);
  });
}

}); // module: runner.js

require.register("suite.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var EventEmitter = require('browser/events').EventEmitter
  , debug = require('browser/debug')('mocha:suite')
  , milliseconds = require('./ms')
  , utils = require('./utils')
  , Hook = require('./hook');

/**
 * Expose `Suite`.
 */

exports = module.exports = Suite;

/**
 * Create a new `Suite` with the given `title`
 * and parent `Suite`. When a suite with the
 * same title is already present, that suite
 * is returned to provide nicer reporter
 * and more flexible meta-testing.
 *
 * @param {Suite} parent
 * @param {String} title
 * @return {Suite}
 * @api public
 */

exports.create = function(parent, title){
  var suite = new Suite(title, parent.ctx);
  suite.parent = parent;
  if (parent.pending) suite.pending = true;
  title = suite.fullTitle();
  parent.addSuite(suite);
  return suite;
};

/**
 * Initialize a new `Suite` with the given
 * `title` and `ctx`.
 *
 * @param {String} title
 * @param {Context} ctx
 * @api private
 */

function Suite(title, ctx) {
  this.title = title;
  this.ctx = ctx;
  this.suites = [];
  this.tests = [];
  this.pending = false;
  this._beforeEach = [];
  this._beforeAll = [];
  this._afterEach = [];
  this._afterAll = [];
  this.root = !title;
  this._timeout = 2000;
  this._slow = 75;
  this._bail = false;
}

/**
 * Inherit from `EventEmitter.prototype`.
 */

function F(){};
F.prototype = EventEmitter.prototype;
Suite.prototype = new F;
Suite.prototype.constructor = Suite;


/**
 * Return a clone of this `Suite`.
 *
 * @return {Suite}
 * @api private
 */

Suite.prototype.clone = function(){
  var suite = new Suite(this.title);
  debug('clone');
  suite.ctx = this.ctx;
  suite.timeout(this.timeout());
  suite.slow(this.slow());
  suite.bail(this.bail());
  return suite;
};

/**
 * Set timeout `ms` or short-hand such as "2s".
 *
 * @param {Number|String} ms
 * @return {Suite|Number} for chaining
 * @api private
 */

Suite.prototype.timeout = function(ms){
  if (0 == arguments.length) return this._timeout;
  if ('string' == typeof ms) ms = milliseconds(ms);
  debug('timeout %d', ms);
  this._timeout = parseInt(ms, 10);
  return this;
};

/**
 * Set slow `ms` or short-hand such as "2s".
 *
 * @param {Number|String} ms
 * @return {Suite|Number} for chaining
 * @api private
 */

Suite.prototype.slow = function(ms){
  if (0 === arguments.length) return this._slow;
  if ('string' == typeof ms) ms = milliseconds(ms);
  debug('slow %d', ms);
  this._slow = ms;
  return this;
};

/**
 * Sets whether to bail after first error.
 *
 * @parma {Boolean} bail
 * @return {Suite|Number} for chaining
 * @api private
 */

Suite.prototype.bail = function(bail){
  if (0 == arguments.length) return this._bail;
  debug('bail %s', bail);
  this._bail = bail;
  return this;
};

/**
 * Run `fn(test[, done])` before running tests.
 *
 * @param {Function} fn
 * @return {Suite} for chaining
 * @api private
 */

Suite.prototype.beforeAll = function(fn){
  if (this.pending) return this;
  var hook = new Hook('"before all" hook', fn);
  hook.parent = this;
  hook.timeout(this.timeout());
  hook.slow(this.slow());
  hook.ctx = this.ctx;
  this._beforeAll.push(hook);
  this.emit('beforeAll', hook);
  return this;
};

/**
 * Run `fn(test[, done])` after running tests.
 *
 * @param {Function} fn
 * @return {Suite} for chaining
 * @api private
 */

Suite.prototype.afterAll = function(fn){
  if (this.pending) return this;
  var hook = new Hook('"after all" hook', fn);
  hook.parent = this;
  hook.timeout(this.timeout());
  hook.slow(this.slow());
  hook.ctx = this.ctx;
  this._afterAll.push(hook);
  this.emit('afterAll', hook);
  return this;
};

/**
 * Run `fn(test[, done])` before each test case.
 *
 * @param {Function} fn
 * @return {Suite} for chaining
 * @api private
 */

Suite.prototype.beforeEach = function(fn){
  if (this.pending) return this;
  var hook = new Hook('"before each" hook', fn);
  hook.parent = this;
  hook.timeout(this.timeout());
  hook.slow(this.slow());
  hook.ctx = this.ctx;
  this._beforeEach.push(hook);
  this.emit('beforeEach', hook);
  return this;
};

/**
 * Run `fn(test[, done])` after each test case.
 *
 * @param {Function} fn
 * @return {Suite} for chaining
 * @api private
 */

Suite.prototype.afterEach = function(fn){
  if (this.pending) return this;
  var hook = new Hook('"after each" hook', fn);
  hook.parent = this;
  hook.timeout(this.timeout());
  hook.slow(this.slow());
  hook.ctx = this.ctx;
  this._afterEach.push(hook);
  this.emit('afterEach', hook);
  return this;
};

/**
 * Add a test `suite`.
 *
 * @param {Suite} suite
 * @return {Suite} for chaining
 * @api private
 */

Suite.prototype.addSuite = function(suite){
  suite.parent = this;
  suite.timeout(this.timeout());
  suite.slow(this.slow());
  suite.bail(this.bail());
  this.suites.push(suite);
  this.emit('suite', suite);
  return this;
};

/**
 * Add a `test` to this suite.
 *
 * @param {Test} test
 * @return {Suite} for chaining
 * @api private
 */

Suite.prototype.addTest = function(test){
  test.parent = this;
  test.timeout(this.timeout());
  test.slow(this.slow());
  test.ctx = this.ctx;
  this.tests.push(test);
  this.emit('test', test);
  return this;
};

/**
 * Return the full title generated by recursively
 * concatenating the parent's full title.
 *
 * @return {String}
 * @api public
 */

Suite.prototype.fullTitle = function(){
  if (this.parent) {
    var full = this.parent.fullTitle();
    if (full) return full + ' ' + this.title;
  }
  return this.title;
};

/**
 * Return the total number of tests.
 *
 * @return {Number}
 * @api public
 */

Suite.prototype.total = function(){
  return utils.reduce(this.suites, function(sum, suite){
    return sum + suite.total();
  }, 0) + this.tests.length;
};

/**
 * Iterates through each suite recursively to find
 * all tests. Applies a function in the format
 * `fn(test)`.
 *
 * @param {Function} fn
 * @return {Suite}
 * @api private
 */

Suite.prototype.eachTest = function(fn){
  utils.forEach(this.tests, fn);
  utils.forEach(this.suites, function(suite){
    suite.eachTest(fn);
  });
  return this;
};

}); // module: suite.js

require.register("test.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var Runnable = require('./runnable');

/**
 * Expose `Test`.
 */

module.exports = Test;

/**
 * Initialize a new `Test` with the given `title` and callback `fn`.
 *
 * @param {String} title
 * @param {Function} fn
 * @api private
 */

function Test(title, fn) {
  Runnable.call(this, title, fn);
  this.pending = !fn;
  this.type = 'test';
}

/**
 * Inherit from `Runnable.prototype`.
 */

function F(){};
F.prototype = Runnable.prototype;
Test.prototype = new F;
Test.prototype.constructor = Test;


}); // module: test.js

require.register("utils.js", function(module, exports, require){

/**
 * Module dependencies.
 */

var fs = require('browser/fs')
  , path = require('browser/path')
  , join = path.join
  , debug = require('browser/debug')('mocha:watch');

/**
 * Ignored directories.
 */

var ignore = ['node_modules', '.git'];

/**
 * Escape special characters in the given string of html.
 *
 * @param  {String} html
 * @return {String}
 * @api private
 */

exports.escape = function(html){
  return String(html)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
};

/**
 * Array#forEach (<=IE8)
 *
 * @param {Array} array
 * @param {Function} fn
 * @param {Object} scope
 * @api private
 */

exports.forEach = function(arr, fn, scope){
  for (var i = 0, l = arr.length; i < l; i++)
    fn.call(scope, arr[i], i);
};

/**
 * Array#indexOf (<=IE8)
 *
 * @parma {Array} arr
 * @param {Object} obj to find index of
 * @param {Number} start
 * @api private
 */

exports.indexOf = function(arr, obj, start){
  for (var i = start || 0, l = arr.length; i < l; i++) {
    if (arr[i] === obj)
      return i;
  }
  return -1;
};

/**
 * Array#reduce (<=IE8)
 *
 * @param {Array} array
 * @param {Function} fn
 * @param {Object} initial value
 * @api private
 */

exports.reduce = function(arr, fn, val){
  var rval = val;

  for (var i = 0, l = arr.length; i < l; i++) {
    rval = fn(rval, arr[i], i, arr);
  }

  return rval;
};

/**
 * Array#filter (<=IE8)
 *
 * @param {Array} array
 * @param {Function} fn
 * @api private
 */

exports.filter = function(arr, fn){
  var ret = [];

  for (var i = 0, l = arr.length; i < l; i++) {
    var val = arr[i];
    if (fn(val, i, arr)) ret.push(val);
  }

  return ret;
};

/**
 * Object.keys (<=IE8)
 *
 * @param {Object} obj
 * @return {Array} keys
 * @api private
 */

exports.keys = Object.keys || function(obj) {
  var keys = []
    , has = Object.prototype.hasOwnProperty // for `window` on <=IE8

  for (var key in obj) {
    if (has.call(obj, key)) {
      keys.push(key);
    }
  }

  return keys;
};

/**
 * Watch the given `files` for changes
 * and invoke `fn(file)` on modification.
 *
 * @param {Array} files
 * @param {Function} fn
 * @api private
 */

exports.watch = function(files, fn){
  var options = { interval: 100 };
  files.forEach(function(file){
    debug('file %s', file);
    fs.watchFile(file, options, function(curr, prev){
      if (prev.mtime < curr.mtime) fn(file);
    });
  });
};

/**
 * Ignored files.
 */

function ignored(path){
  return !~ignore.indexOf(path);
}

/**
 * Lookup files in the given `dir`.
 *
 * @return {Array}
 * @api private
 */

exports.files = function(dir, ret){
  ret = ret || [];

  fs.readdirSync(dir)
  .filter(ignored)
  .forEach(function(path){
    path = join(dir, path);
    if (fs.statSync(path).isDirectory()) {
      exports.files(path, ret);
    } else if (path.match(/\.(js|coffee)$/)) {
      ret.push(path);
    }
  });

  return ret;
};

/**
 * Compute a slug from the given `str`.
 *
 * @param {String} str
 * @return {String}
 * @api private
 */

exports.slug = function(str){
  return str
    .toLowerCase()
    .replace(/ +/g, '-')
    .replace(/[^-\w]/g, '');
};

/**
 * Strip the function definition from `str`,
 * and re-indent for pre whitespace.
 */

exports.clean = function(str) {
  str = str
    .replace(/^function *\(.*\) *{/, '')
    .replace(/\s+\}$/, '');

  var spaces = str.match(/^\n?( *)/)[1].length
    , re = new RegExp('^ {' + spaces + '}', 'gm');

  str = str.replace(re, '');

  return exports.trim(str);
};

/**
 * Escape regular expression characters in `str`.
 *
 * @param {String} str
 * @return {String}
 * @api private
 */

exports.escapeRegexp = function(str){
  return str.replace(/[-\\^$*+?.()|[\]{}]/g, "\\$&");
};

/**
 * Trim the given `str`.
 *
 * @param {String} str
 * @return {String}
 * @api private
 */

exports.trim = function(str){
  return str.replace(/^\s+|\s+$/g, '');
};

/**
 * Parse the given `qs`.
 *
 * @param {String} qs
 * @return {Object}
 * @api private
 */

exports.parseQuery = function(qs){
  return exports.reduce(qs.replace('?', '').split('&'), function(obj, pair){
    var i = pair.indexOf('=')
      , key = pair.slice(0, i)
      , val = pair.slice(++i);

    obj[key] = decodeURIComponent(val);
    return obj;
  }, {});
};

/**
 * Highlight the given string of `js`.
 *
 * @param {String} js
 * @return {String}
 * @api private
 */

function highlight(js) {
  return js
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\/\/(.*)/gm, '<span class="comment">//$1</span>')
    .replace(/('.*?')/gm, '<span class="string">$1</span>')
    .replace(/(\d+\.\d+)/gm, '<span class="number">$1</span>')
    .replace(/(\d+)/gm, '<span class="number">$1</span>')
    .replace(/\bnew *(\w+)/gm, '<span class="keyword">new</span> <span class="init">$1</span>')
    .replace(/\b(function|new|throw|return|var|if|else)\b/gm, '<span class="keyword">$1</span>')
}

/**
 * Highlight the contents of tag `name`.
 *
 * @param {String} name
 * @api private
 */

exports.highlightTags = function(name) {
  var code = document.getElementsByTagName(name);
  for (var i = 0, len = code.length; i < len; ++i) {
    code[i].innerHTML = highlight(code[i].innerHTML);
  }
};

}); // module: utils.js
/**
 * Node shims.
 *
 * These are meant only to allow
 * mocha.js to run untouched, not
 * to allow running node code in
 * the browser.
 */

process = {};
process.exit = function(status){};
process.stdout = {};
global = window;

/**
 * next tick implementation.
 */

process.nextTick = (function(){
  // postMessage behaves badly on IE8
  if (window.ActiveXObject || !window.postMessage) {
    return function(fn){ fn() };
  }

  // based on setZeroTimeout by David Baron
  // - http://dbaron.org/log/20100309-faster-timeouts
  var timeouts = []
    , name = 'mocha-zero-timeout'

  window.addEventListener('message', function(e){
    if (e.source == window && e.data == name) {
      if (e.stopPropagation) e.stopPropagation();
      if (timeouts.length) timeouts.shift()();
    }
  }, true);

  return function(fn){
    timeouts.push(fn);
    window.postMessage(name, '*');
  }
})();

/**
 * Remove uncaughtException listener.
 */

process.removeListener = function(e){
  if ('uncaughtException' == e) {
    window.onerror = null;
  }
};

/**
 * Implements uncaughtException listener.
 */

process.on = function(e, fn){
  if ('uncaughtException' == e) {
    window.onerror = function(err, url, line){
      fn(new Error(err + ' (' + url + ':' + line + ')'));
    };
  }
};

// boot
;(function(){

  /**
   * Expose mocha.
   */

  var Mocha = window.Mocha = require('mocha'),
      mocha = window.mocha = new Mocha({ reporter: 'html' });

  /**
   * Override ui to ensure that the ui functions are initialized.
   * Normally this would happen in Mocha.prototype.loadFiles.
   */

  mocha.ui = function(ui){
    Mocha.prototype.ui.call(this, ui);
    this.suite.emit('pre-require', window, null, this);
    return this;
  };

  /**
   * Setup mocha with the given setting options.
   */

  mocha.setup = function(opts){
    if ('string' == typeof opts) opts = { ui: opts };
    for (var opt in opts) this[opt](opts[opt]);
    return this;
  };

  /**
   * Run mocha, returning the Runner.
   */

  mocha.run = function(fn){
    var options = mocha.options;
    mocha.globals('location');

    var query = Mocha.utils.parseQuery(window.location.search || '');
    if (query.grep) mocha.grep(query.grep);
    if (query.invert) mocha.invert();

    return Mocha.prototype.run.call(mocha, function(){
      Mocha.utils.highlightTags('code');
      if (fn) fn();
    });
  };
})();
})();

