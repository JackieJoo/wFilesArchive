( function _FileRecordFactory_s_() {

'use strict'/*fff*/; 

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

//

/**
 * @class wFileRecordFactory
 * @memberof module:Tools/mid/Files
*/

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileRecordFactory( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self && arguments.length === 1 )
  {
    _.assert( arguments.length === 1, 'Expects single argument' );
    return o;
  }
  else
  {
    return new( _.constructorJoin( Self, arguments ) );
  }
  return Self.prototype.init.apply( this,arguments );
}

Self.shortName = 'FileRecordFactory';

_.assert( !_.FileRecordFactory );

// --
// routine
// --

function init( o )
{
  let factory = this;

  factory[ usingSoftLinkSymbol ] = null;
  factory[ resolvingSoftLinkSymbol ] = null;
  factory[ usingTextLinkSymbol ] = null;
  factory[ resolvingTextLinkSymbol ] = null;
  factory[ statingSymbol ] = null;
  factory[ safeSymbol ] = null;

  _.assert( arguments.length === 0 || arguments.length === 1, 'Expects single argument' );

  _.instanceInit( factory );
  Object.preventExtensions( factory );

  /* */

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let src = arguments[ a ];
    if( _.mapIs( src ) )
    Object.assign( factory, src );
    else
    Object.assign( factory, _.mapOnly( src, Self.prototype.fieldsOfCopyableGroups ) );
  }

  // factory._formAssociations();

  return factory;
}

//

/**
 * @summary Creates factory instance ignoring unknown options.
 * @param {Object} o Options map.
 * @function TollerantFrom
 * @memberof module:Tools/mid/Files.wFileRecordFactory
*/

function TollerantFrom( o )
{
  _.assert( arguments.length >= 1, 'Expects at least one argument' );
  _.assert( _.objectIs( Self.prototype.Composes ) );
  o = _.mapsExtend( null, arguments );
  return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
}

//

function _formAssociations()
{
  let factory = this;

  _.assert( factory.formed === 0 );

  /* */

  if( factory.filter )
  {
    factory.hubFileProvider = factory.hubFileProvider || factory.filter.hubFileProvider;
    factory.effectiveFileProvider = factory.effectiveFileProvider || factory.filter.effectiveFileProvider;
    factory.defaultFileProvider = factory.defaultFileProvider || factory.filter.defaultFileProvider;
  }

  /* */

  if( factory.hubFileProvider )
  {
    if( factory.hubFileProvider.hub && factory.hubFileProvider.hub !== factory.hubFileProvider )
    {
      _.assert( factory.effectiveFileProvider === null || factory.effectiveFileProvider === factory.hubFileProvider );
      factory.effectiveFileProvider = factory.hubFileProvider;
      factory.hubFileProvider = factory.hubFileProvider.hub;
    }
  }

  // if( factory.defaultFileProvider )
  // {
  //   if( factory.defaultFileProvider instanceof _.FileProvider.Hub )
  //   {
  //     _.assert( factory.hubFileProvider === null || factory.hubFileProvider === factory.defaultFileProvider );
  //     factory.hubFileProvider = factory.defaultFileProvider;
  //     factory.defaultFileProvider = null;
  //   }
  // }
  //
  // if( factory.defaultFileProvider && factory.defaultFileProvider.hub )
  // {
  //   _.assert( factory.hubFileProvider === null || factory.hubFileProvider === factory.defaultFileProvider.hub );
  //   factory.hubFileProvider = factory.defaultFileProvider.hub;
  // }

  if( factory.effectiveFileProvider )
  {
    if( factory.effectiveFileProvider instanceof _.FileProvider.Hub )
    {
      _.assert( factory.hubFileProvider === null || factory.hubFileProvider === factory.effectiveFileProvider );
      factory.hubFileProvider = factory.effectiveFileProvider;
      factory.effectiveFileProvider = null;
    }
  }

  if( factory.effectiveFileProvider && factory.effectiveFileProvider.hub )
  {
    _.assert( factory.hubFileProvider === null || factory.hubFileProvider === factory.effectiveFileProvider.hub );
    factory.hubFileProvider = factory.effectiveFileProvider.hub;
  }

  if( !factory.defaultFileProvider )
  {
    factory.defaultFileProvider = factory.defaultFileProvider || factory.effectiveFileProvider || factory.hubFileProvider;
  }

  /* */

  _.assert( !factory.hubFileProvider || factory.hubFileProvider instanceof _.FileProvider.Abstract, 'Expects {- factory.hubFileProvider -}' );
  _.assert( factory.defaultFileProvider instanceof _.FileProvider.Abstract );
  _.assert( !factory.effectiveFileProvider || !( factory.effectiveFileProvider instanceof _.FileProvider.Hub ) );

}

//

function form()
{
  let factory = this;

  _.assert( arguments.length === 0 );
  _.assert( !factory.formed );

  factory._formAssociations();

  /* */

  factory._formAssociations();

  let hubFileProvider = factory.hubFileProvider || factory.effectiveFileProvider || factory.defaultFileProvider;
  let path = hubFileProvider.path;

  /* */

  if( factory.basePath )
  {

    _.assert( !!path );

    factory.basePath = path.from( factory.basePath );
    factory.basePath = path.normalize( factory.basePath );

    if( !factory.effectiveFileProvider )
    factory.effectiveFileProvider = hubFileProvider.providerForPath( factory.basePath );

    if( Config.debug )
    if( _.path.isGlobal( factory.basePath ) )
    {
      let url = _.uri.parse( factory.basePath );
    }

  }

  /* */

  if( factory.dirPath )
  {
    factory.dirPath = path.from( factory.dirPath );
    factory.dirPath = path.normalize( factory.dirPath );

    if( factory.basePath )
    factory.dirPath = path.join( factory.basePath, factory.dirPath );

    if( Config.debug )
    if( _.path.isGlobal( factory.dirPath ) )
    {
      let url = _.uri.parse( factory.dirPath );
    }
  }

  if( !factory.stemPath )
  {
    factory.stemPath = path.normalize( path.join( factory.basePath, factory.dirPath || '' ) );
  }
  else if( factory.stemPath )
  {
    factory.stemPath = path.normalize( path.join( factory.basePath, factory.dirPath || '', factory.stemPath ) );
  }

  if( !factory.basePath )
  if( factory.dirPath )
  {
    factory.basePath = factory.dirPath;
  }

  if( !factory.basePath && factory.filter && factory.stemPath )
  {
    _.assert( factory.filter.formed === 5 );
    factory.basePath = factory.filter.formedBasePath[ factory.stemPath ];
  }

  /* */

  if( !factory.hubFileProvider )
  factory.hubFileProvider = factory.defaultFileProvider;

  if( !factory.effectiveFileProvider )
  factory.effectiveFileProvider = factory.defaultFileProvider;

  _.assert( !!factory.hubFileProvider );

  factory.hubFileProvider._recordFactoryFormEnd( factory );

  /* */

  if( Config.debug )
  {

    _.assert( factory.hubFileProvider instanceof _.FileProvider.Abstract );
    _.assert( path.isAbsolute( factory.basePath ) );
    _.assert( factory.dirPath === null || path.is( factory.dirPath ) );
    _.assert( path.isAbsolute( factory.stemPath ) );

    if( factory.dirPath )
    _.assert( _.path.isGlobal( factory.dirPath ) || path.isAbsolute( factory.dirPath ), () => '{-o.dirPath-} should be absolute path' + _.strQuote( factory.dirPath ) );

    _.assert( _.strDefined( factory.basePath ) );
    _.assert( _.path.isGlobal( factory.basePath ) || path.isAbsolute( factory.basePath ), () => '{-o.basePath-} should be absolute path' + _.strQuote( factory.basePath ) );

    _.assert( factory.filter === null || factory.filter instanceof _.FileRecordFilter );

    if( factory.filter )
    {
      _.assert( factory.filter.formed === 5 );
      _.assert( factory.filter.formedBasePath[ factory.stemPath ] === factory.basePath );
      _.assert( factory.filter.effectiveFileProvider === factory.effectiveFileProvider );
      _.assert( factory.filter.hubFileProvider === factory.hubFileProvider || factory.filter.hubFileProvider === null );
      _.assert( factory.filter.defaultFileProvider === factory.defaultFileProvider );
    }

  }

  factory.formed = 1;
  Object.freeze( factory );
  return factory;
}

//

/**
 * @summary Creates instance of FileRecord.
 * @param {Object} o Options map.
 * @function record
 * @memberof module:Tools/mid/Files.wFileRecordFactory#
*/

function record( o )
{
  let factory = this;

  if( o instanceof _.FileRecord )
  {
    _.assert( o.factory === factory || !!o.factory );
    return o;
  }

  let op = Object.create( null );

  if( _.strIs( o ) )
  {
    o = { input : o }
  }

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.input ), () => 'Expects string {-o.input-}, but got ' + _.strType( o.input ) );
  _.assert( o.factory === undefined || o.factory === factory );

  o.factory = factory;

  return _.FileRecord( o );
}

//

/**
 * @summary Creates instances of FileRecord for provided file paths.
 * @param {Array} filePaths Paths to files.
 * @function records
 * @memberof module:Tools/mid/Files.wFileRecordFactory#
*/

/**
 * @summary Creates instances of FileRecord for provided file paths ignoring files that don't exist in file system.
 * @param {Array} filePaths Paths to files.
 * @function recordsFiltered
 * @memberof module:Tools/mid/Files.wFileRecordFactory#
*/

function recordsFiltered( filePaths,fileContext )
{
  var factory = this;

  _.assert( arguments.length === 1 );

  var result = factory.records( filePaths );

  for( var r = result.length-1 ; r >= 0 ; r-- )
  if( !result[ r ].stat )
  result.splice( r,1 );

  return result;
}

//

function _usingSoftLinkGet()
{
  let factory = this;

  if( factory[ usingSoftLinkSymbol ] !== null )
  return factory[ usingSoftLinkSymbol ];

  if( factory.effectiveFileProvider )
  return factory.effectiveFileProvider.usingSoftLink;
  else if( factory.hubFileProvider )
  return factory.hubFileProvider.usingSoftLink;

  return factory[ usingSoftLinkSymbol ];
}

//

function _resolvingSoftLinkSet( src )
{
  let factory = this;
  factory[ resolvingSoftLinkSymbol ] = src;
}

//

function _resolvingSoftLinkGet()
{
  let factory = this;

  if( !factory.resolving )
  return false;

  if( factory[ resolvingSoftLinkSymbol ] !== null )
  return factory[ resolvingSoftLinkSymbol ];

  if( factory.effectiveFileProvider )
  return factory.effectiveFileProvider.resolvingSoftLink;
  else if( factory.hubFileProvider )
  return factory.hubFileProvider.resolvingSoftLink;

  return factory[ resolvingSoftLinkSymbol ];
}

//

function _usingTextLinkGet()
{
  let factory = this;

  if( !factory.resolving )
  return false;

  if( factory[ usingTextLinkSymbol ] !== null )
  return factory[ usingTextLinkSymbol ];

  if( factory.effectiveFileProvider )
  return factory.effectiveFileProvider.usingTextLink;
  else if( factory.hubFileProvider )
  return factory.hubFileProvider.usingTextLink;

  return factory[ usingTextLinkSymbol ];
}

//

function _resolvingTextLinkGet()
{
  let factory = this;

  if( factory[ resolvingTextLinkSymbol ] !== null )
  return factory[ resolvingTextLinkSymbol ];

  if( factory.effectiveFileProvider )
  return factory.effectiveFileProvider.resolvingTextLink;
  else if( factory.hubFileProvider )
  return factory.hubFileProvider.resolvingTextLink;

  return factory[ resolvingTextLinkSymbol ];
}

//

function _statingGet()
{
  let factory = this;

  if( factory[ statingSymbol ] !== null )
  return factory[ statingSymbol ];

  if( factory.effectiveFileProvider )
  return factory.effectiveFileProvider.stating;
  else if( factory.hubFileProvider )
  return factory.hubFileProvider.stating;

  return factory[ statingSymbol ];
}

//

function _safeGet()
{
  let factory = this;

  if( factory[ safeSymbol ] !== null )
  return factory[ safeSymbol ];

  if( factory.effectiveFileProvider )
  return factory.effectiveFileProvider.safe;
  else if( factory.hubFileProvider )
  return factory.hubFileProvider.safe;

  return factory[ safeSymbol ];
}

// --
// relation
// --

let usingSoftLinkSymbol = Symbol.for( 'usingSoftLink' );
let resolvingSoftLinkSymbol = Symbol.for( 'resolvingSoftLink' );
let usingTextLinkSymbol = Symbol.for( 'usingTextLink' );
let resolvingTextLinkSymbol = Symbol.for( 'resolvingTextLink' );
let statingSymbol = Symbol.for( 'stating' );
let safeSymbol = Symbol.for( 'safe' );

/**
 * @typedef {Object} Fields
 * @property {String} dirPath
 * @property {String} basePath
 * @property {String} stemPath
 * @property {Boolean} strict=1
 * @property {Boolean} allowingMissed
 * @property {Boolean} allowingCycled
 * @property {Boolean} resolvingSoftLink
 * @property {Boolean} resolvingTextLink
 * @property {Boolean} usingTextLink
 * @property {Boolean} stating
 * @property {Boolean} resolving
 * @property {Boolean} safe
 * @memberof module:Tools/mid/Files.wFileRecordFactory
*/

let Composes =
{

  dirPath : null,
  basePath : null,
  stemPath : null,

  // onRecord : null,
  strict : 1,

  allowingMissed : 0,
  allowingCycled : 0,
  resolvingSoftLink : null,
  resolvingTextLink : null,
  usingTextLink : null,
  stating : null,
  resolving : 1,
  safe : null,

}

let Aggregates =
{
}

let Associates =
{
  hubFileProvider : null,
  effectiveFileProvider : null,
  defaultFileProvider : null,
  filter : null,
}

let Medials =
{
}

let Restricts =
{
  formed : 0,
}

let Statics =
{
  TollerantFrom : TollerantFrom,
}

let Forbids =
{

  dir : 'dir',
  sync : 'sync',
  relative : 'relative',
  relativeIn : 'relativeIn',
  relativeOut : 'relativeOut',
  verbosity : 'verbosity',
  maskAll : 'maskAll',
  maskTerminal : 'maskTerminal',
  maskDirectory : 'maskDirectory',
  notOlder : 'notOlder',
  notNewer : 'notNewer',
  notOlderAge : 'notOlderAge',
  notNewerAge : 'notNewerAge',
  originPath : 'originPath',
  onRecord : 'onRecord',
  fileProviderEffective : 'fileProviderEffective',
  fileProvider : 'fileProvider',

}

let Accessors =
{

  resolvingSoftLink : 'resolvingSoftLink',
  usingSoftLink : 'usingSoftLink',

  resolvingTextLink : 'resolvingTextLink',
  usingTextLink : 'usingTextLink',

  stating : 'stating',
  safe : 'safe',

}

// --
// declare
// --

let Proto =
{

  init,
  TollerantFrom,

  _formAssociations,
  form,

  record,
  records : _.routineVectorize_functor( record ),
  recordsFiltered,

  _usingSoftLinkGet,
  _resolvingSoftLinkSet,
  _resolvingSoftLinkGet,

  _usingTextLinkGet,
  _resolvingTextLinkGet,

  _statingGet,
  _safeGet,

  /* */

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,
  Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' )
{

  require( './FileRecord.s' );

}

//

_[ Self.shortName ] = Self;

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
