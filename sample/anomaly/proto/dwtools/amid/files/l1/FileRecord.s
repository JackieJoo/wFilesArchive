( function _FileRecord_s_() {

'use strict'/*fff*/;

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

// --
//
// --

/**
 * @classdesc Class to create record for a file.
 * @class wFileRecord
 * @memberof module:Tools/mid/Files
*/

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileRecord( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'FileRecord';

_.assert( !_.FileRecord );

// --
//
// --

function init( o )
{
  let record = this;

  if( _.strIs( o ) )
  o = { input : o }

  _.assert( arguments.length === 1 );
  _.assert( !( arguments[ 0 ] instanceof _.FileRecordFactory ) );
  _.assert( _.strIs( o.input ), () => 'Expects string {-o.input-}, but got ' + _.strType( o.input ) );
  _.assert( _.objectIs( o.factory ) );

  _.instanceInit( record );

  record._filterReset();
  record._statReset();

  // record[ isTransientSymbol ] = null;
  // record[ isActualSymbol ] = null;
  // record[ statSymbol ] = 0;
  // record[ realSymbol ] = 0;

  record.copy( o );

  let f = record.factory;
  if( f.strict )
  Object.preventExtensions( record );

  if( !f.formed )
  {
    if( !f.basePath && !f.dirPath && !f.stemPath )
    {
      f.basePath = _.uri.dir( o.input );
      f.stemPath = f.basePath;
    }
    f.form();
  }

  record.form();

  return record;
}

//

function form()
{
  let record = this;

  _.assert( Object.isFrozen( record.factory ) );
  _.assert( !!record.factory.formed, 'Record factory is not formed' );
  _.assert( record.factory.hubFileProvider instanceof _.FileProvider.Abstract );
  _.assert( record.factory.effectiveFileProvider instanceof _.FileProvider.Abstract );
  _.assert( _.strIs( record.input ), '{ record.input } must be a string' );
  _.assert( record.factory instanceof _.FileRecordFactory, 'Expects instance of { FileRecordFactory }' );

  record._pathsForm();
  // record._filterApply();
  // record._statRead();
  // record._statAnalyze();

  _.assert( record.fullName.indexOf( '/' ) === -1, 'something wrong with filename' );

  return record;
}

//

/**
 * @summary Returns a clone of current file record.
 * @function clone
 * @memberof module:Tools/mid/Files.wFileRecord#
*/

function clone( src )
{
  let record = this;
  let f = record.factory;

  src = src || record.input;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strIs( src ) );

  let result = _.FileRecord({ input : src, factory : f });

  return result;
}

//

/**
 * @summary Creates instance of FileRecord from provided entity `src`.
 * @param {Object|String} src Options map or path to a file.
 * @function From
 * @memberof module:Tools/mid/Files.wFileRecord
*/

function From( src )
{
  return Self( src );
}

//

/**
 * @summary Creates several instances of FileRecord from provided arguments.
 * @param {Array} src Array with options or paths.
 * @function FromMany
 * @memberof module:Tools/mid/Files.wFileRecord
*/

function FromMany( src )
{
  let result = [];

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.arrayIs( src ) );

  for( let s = 0 ; s < src.length ; s++ )
  result[ s ] = Self.From( src[ s ] );

  return result;
}

//

/**
 * @summary Returns absolute path to a file associated with provided `record`.
 * @description Uses current instance if no argument provided.
 * @param {Object} record Instance of FileRecord.
 * @function toAbsolute
 * @memberof module:Tools/mid/Files.wFileRecord#
*/

function toAbsolute( record )
{

  if( record === undefined )
  record = this;

  if( _.strIs( record ) )
  return record;

  _.assert( _.objectIs( record ) );

  let result = record.absolute;

  _.assert( _.strIs( result ) );

  return result;
}

//

function _safeCheck()
{
  let record = this;
  let path = record.path;
  let f = record.factory;

  _.assert( arguments.length === 0 );

  if( f.safe && f.stating )
  {
    if( record.stat )
    if( !path.isSafe( record.absolute, f.safe ) )
    {
      debugger;
      throw path.ErrorNotSafe( 'Making record', record.absolute, f.safe );
    }
    if( record.stat && !record.stat.isTerminal() && !record.stat.isDir() && !record.stat.isSymbolicLink() )
    {
      debugger;
      throw path.ErrorNotSafe( 'Making record. Unknown kind of file', record.absolute, f.safe );
    }
  }

  return true;
}

//

function _pathsForm()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.effectiveFileProvider;
  let path = record.path
  let inputPath = record.input;

  _.assert( arguments.length === 0 );
  _.assert( _.strIs( f.basePath ) );
  _.assert( _.strIs( f.stemPath ) );
  _.assert( path.isAbsolute( f.stemPath ) );

  inputPath = path.normalize( inputPath );
  let isAbsolute = path.isAbsolute( inputPath );

  /* input path */

  if( !isAbsolute )
  if( f.dirPath )
  inputPath = path.join( f.basePath, f.dirPath, f.stemPath, inputPath );
  else if( f.basePath )
  inputPath = path.join( f.basePath, f.stemPath, inputPath );
  else if( !path.isAbsolute( inputPath ) )
  _.assert( 0, 'FileRecordFactory expects defined fields {-dirPath-} or {-basePath-} or absolute path' );

  /* relative path */

  record[ relativeSymbol ] = fileProvider.path.relative( f.basePath, inputPath );
  _.assert( record.relative[ 0 ] !== '/' );
  record[ relativeSymbol ] = path.dot( record.relative );

  /* absolute path */

  if( f.basePath )
  record[ absoluteSymbol ] = fileProvider.path.resolve( f.basePath, record.relative );
  else
  record[ absoluteSymbol ] = inputPath;

  record[ absoluteSymbol ] = path.normalize( record[ absoluteSymbol ] );

  /* */

  // f.hubFileProvider._recordFormBegin( record );
  f.hubFileProvider._recordFormBegin( record );
  // f.hubFileProvider._recordPathForm( record );

  return record;
}

//

function _filterReset()
{
  let record = this;
  let f = record.factory;

  _.assert( arguments.length === 0 );

  record[ isTransientSymbol ] = null;
  record[ isActualSymbol ] = null;

}

//

function _filterApply()
{
  let record = this;
  let f = record.factory;

  _.assert( arguments.length === 0 );

  if( record[ isTransientSymbol ] === null )
  record[ isTransientSymbol ] = true;
  if( record[ isActualSymbol ] === null )
  record[ isActualSymbol ] = true;

  if( f.filter )
  {
    _.assert( f.filter.formed === 5, 'Expects formed filter' );
    f.filter.applyTo( record );
  }

}

//

function _statReset()
{
  let record = this;
  let f = record.factory;

  _.assert( arguments.length === 0 );

  record[ realSymbol ] = null;
  record[ statSymbol ] = 0;

}

//

function _statRead()
{
  let record = this;
  let f = record.factory;
  let stat;

  _.assert( arguments.length === 0 );

  record[ realSymbol ] = record.absolute;

  if( f.resolvingSoftLink || f.resolvingTextLink )
  {

    let o2 =
    {
      hub : f.hubFileProvider,
      filePath : record.absolute,
      resolvingSoftLink : f.resolvingSoftLink,
      resolvingTextLink : f.resolvingTextLink,
      resolvingHeadDirect : 1,
      resolvingHeadReverse : 1,
      allowingMissed : f.allowingMissed,
      allowingCycled : f.allowingCycled,
      throwing : 1,
    }

    record[ realSymbol ] = f.effectiveFileProvider.pathResolveLinkFull( o2 );

    stat = o2.stat;

  }

  /* read and set stat */

  if( f.stating )
  {

    if( stat === undefined )
    stat = f.effectiveFileProvider.statReadAct
    ({
      filePath : record.real,
      throwing : 0,
      resolvingSoftLink : 0,
      sync : 1,
    });

    record[ statSymbol ] = stat;

  }

  /* analyze stat */

  return record;
}

//

function _statAnalyze()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.effectiveFileProvider;
  let path = record.path;
  let logger = fileProvider.logger || _global.logger;

  _.assert( f instanceof _.FileRecordFactory, '_record expects instance of ( FileRecordFactory )' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract, 'Expects file provider instance of FileProvider' );
  _.assert( arguments.length === 0 );

  if( f.stating )
  {
    _.assert( record.stat === null || _.fileStatIs( record.stat ) );
    record._safeCheck();
  }

  f.hubFileProvider._recordFormEnd( record );

}

//

/**
 * @summary Resets stats and filter values of current instance.
 * @function reset
 * @memberof module:Tools/mid/Files.wFileRecord#
*/

function reset()
{
  let record = this;

  _.assert( arguments.length === 0 );

  record._filterReset();
  record._statReset();

  // record._statRead();
  // record._statAnalyze();

}

//

/**
 * @summary Changes file extension of current record.
 * @param {String} ext New file extension.
 * @function changeExt
 * @memberof module:Tools/mid/Files.wFileRecord#
*/

function changeExt( ext )
{
  let record = this;
  let path = record.path;
  _.assert( arguments.length === 1, 'Expects single argument' ); debugger;
  record.input = path.changeExt( record.input, ext );
  // record.form();
}

//

/**
 * @summary Returns file hash of current record.
 * @function hashRead
 * @memberof module:Tools/mid/Files.wFileRecord#
*/

function hashRead()
{
  let record = this;
  let f = record.factory;

  _.assert( arguments.length === 0 );

  if( record.hash !== null )
  return record.hash;

  record.hash = f.effectiveFileProvider.hashRead
  ({
    filePath : record.absolute,
    verbosity : 0,
  });

  return record.hash;
}

//

function _isTransientGet()
{
  let record = this;
  let result = record[ isTransientSymbol ];
  if( result === null )
  {
    record._filterApply();
    result = record[ isTransientSymbol ];
  }
  return result;
}

//

function _isTransientSet( src )
{
  let record = this;
  src = !!src;
  record[ isTransientSymbol ] = src;
  return src;
}

//

function _isActualGet()
{
  let record = this;
  let result = record[ isActualSymbol ];
  if( result === null )
  {
    record._filterApply();
    result = record[ isActualSymbol ];
  }
  return result;
}

//

function _isActualSet( src )
{
  let record = this;
  src = !!src;
  record[ isActualSymbol ] = src;
  return src;
}

//

function _isStemGet()
{
  let record = this;
  let f = record.factory;
  return f.stemPath === record.absolute;
}

//

function _isDirGet()
{
  let record = this;

  // debugger;

  if( !record.stat )
  return false;

  _.assert( _.routineIs( record.stat.isDir ) );

  return record.stat.isDir();
}

//

function _isTerminalGet()
{
  let record = this;

  if( !record.stat )
  return false;

  _.assert( _.routineIs( record.stat.isTerminal ) );

  return record.stat.isTerminal();
}

//

function _isHardLinkGet()
{
  let record = this;
  let f = record.factory;

  if( !record.stat )
  return false;

  return record.stat.isHardLink();
}

//

function _isSoftLinkGet()
{
  let record = this;
  let f = record.factory;

  if( !f.usingSoftLink )
  return false;

  if( !record.stat )
  return false;

  return record.stat.isSoftLink();
}

//

function _isTextLinkGet()
{
  let record = this;
  let f = record.factory;

  if( !f.usingTextLink )
  return false;

  if( f.resolvingTextLink )
  return false;

  debugger;

  if( !record.stat )
  return false;

  return record.stat.isTextLink();
}

//

function _isLinkGet()
{
  let record = this;
  let f = record.factory;
  return record._isSoftLinkGet() || record._isTextLinkGet();
}

//

function absoluteSet( src )
{
  let record = this;
  let f = record.factory;
  let formed = !!record[ absoluteSymbol ];

  record.reset();

  if( src )
  {
    record[ absoluteSymbol ] = null;
    record[ relativeSymbol ] = null;
    record[ inputSymbol ] = src;
    if( formed )
    record._pathsForm();
  }

}

//

function relativeSet( src )
{
  let record = this;
  let f = record.factory;
  let formed = !!record[ absoluteSymbol ];

  record.reset();

  if( src )
  {
    record[ absoluteSymbol ] = null;
    record[ relativeSymbol ] = null;
    record[ inputSymbol ] = src;
    if( formed )
    record._pathsForm();
  }

}

//

function inputSet( src )
{
  let record = this;
  let f = record.factory;
  let formed = !!record[ absoluteSymbol ];

  record.reset();

  if( src )
  {
    record[ absoluteSymbol ] = null;
    record[ relativeSymbol ] = null;
    record[ inputSymbol ] = src;
    if( formed )
    record._pathsForm();
  }

}

//

function _pathGet()
{
  let record = this;
  let f = record.factory;
  _.assert( !!f );
  let fileProvider = f.hubFileProvider;
  return fileProvider.path;
}

//

function _statGet()
{
  let record = this;
  if( record[ statSymbol ] === 0 )
  {
    record._statRead();
    record._statAnalyze();
  }
  return record[ statSymbol ];
}

//

function _realGet()
{
  let record = this;
  if( record[ realSymbol ] === null )
  {
    record._statRead();
    record._statAnalyze();
  }
  return record[ realSymbol ];
}

//

function _absoluteGlobalGet()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.effectiveFileProvider;
  return fileProvider.path.globalFromLocal( record.absolute );
}

//

function _realGlobalGet()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.effectiveFileProvider;
  return fileProvider.path.globalFromLocal( record.real );
}

//

function _absoluteGlobalMaybeGet()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.hubFileProvider;
  return fileProvider._recordAbsoluteGlobalMaybeGet( record );
}

//

function _realGlobalMaybeGet()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.hubFileProvider;
  return fileProvider._recordRealGlobalMaybeGet( record );
}

//

function _dirGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.dir( record.absolute );
}

//

function _extsGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.exts( record.absolute );
}

//

function _extGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.ext( record.absolute );
}

//

function _extWithDotGet()
{
  let record = this;
  let f = record.factory;
  let ext = record.ext;
  return ext ? '.' + ext : '';
}

//

function _nickNameGet()
{
  let record = this;
  let f = record.factory;
  if( f && f.path )
  return '{ ' + record.constructor.shortName + ' : ' + f.path.name( record.absolute ) + ' }';
  else
  return '{ ' + record.constructor.shortName + ' }';
}

//

function _nameGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.name( record.absolute );
}

//

function _fullNameGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.fullName( record.absolute );
}

// --
// statics
// --

function statCopier( it )
{
  let record = this;
  if( it.technique === 'data' )
  return _.mapFields( it.src );
  else
  return it.src;
}

// --
// relations
// --

let statSymbol = Symbol.for( 'stat' );
let realSymbol = Symbol.for( 'real' );
let isTransientSymbol = Symbol.for( 'isTransient' );
let isActualSymbol = Symbol.for( 'isActual' );

let inputSymbol = Symbol.for( 'input' );
let relativeSymbol = Symbol.for( 'relative' );
let absoluteSymbol = Symbol.for( 'absolute' );

/**
 * @typedef {Object} Fields
 * @property {String} absolute Absolute path to a file.
 * @property {String} relative Relative path to a file.
 * @property {String} input Source path to a file.
 * @property {String} hash Hash of a file.
 * @property {Object} factory Instance of FileRecordFactory.
 * @memberof module:Tools/mid/Files.wFileRecord
*/

let Composes =
{

  absolute : null,
  relative : null,
  input : null,
  hash : null,

}

let Aggregates =
{
}

let Associates =
{
  factory : null,
  associated : null,
}

let Restricts =
{
}

let Statics =
{
  From : From,
  FromMany : FromMany,
  toAbsolute : toAbsolute,
}

let Copiers =
{
  stat : statCopier,
}

let Forbids =
{

  file : 'file',
  relativeIn : 'relativeIn',
  relativeOut : 'relativeOut',
  verbosity : 'verbosity',
  safe : 'safe',
  basePath : 'basePath',
  base : 'base',
  resolvingSoftLink : 'resolvingSoftLink',
  resolvingTextLink : 'resolvingTextLink',
  usingTextLink : 'usingTextLink',
  stating : 'stating',
  effective : 'effective',
  fileProvider : 'fileProvider',
  effectiveFileProvider : 'effectiveFileProvider',
  originPath : 'originPath',
  base : 'base',
  full : 'full',
  superRelative : 'superRelative',
  inclusion : 'inclusion',
  isBase : 'isBase',
  absoluteEffective : 'absoluteEffective',
  realEffective : 'realEffective',
  isBranch : 'isBranch',
  realAbsolute : 'realAbsolute',
  realUri : 'realUri',
  absoluteUri : 'absoluteUri',
  hubAbsolute : 'hubAbsolute',
  context : 'context',

}

let Accessors =
{

  path : { readOnly : 1 },
  stat : { readOnly : 1 },

  real : { readOnly : 1 },
  absoluteGlobal : { readOnly : 1 },
  realGlobal : { readOnly : 1 },
  absoluteGlobalMaybe : { readOnly : 1 },
  realGlobalMaybe : { readOnly : 1 },

  dir : { readOnly : 1 },
  exts : { readOnly : 1 },
  ext : { readOnly : 1 },
  extWithDot : { readOnly : 1 },
  nickName : { readOnly : 1 },
  name : { readOnly : 1 },
  fullName : { readOnly : 1 },

  isTransient : { readOnly : 0 },
  isActual : { readOnly : 0 },
  isStem : { readOnly : 1 },
  isDir : { readOnly : 1 },
  isTerminal : { readOnly : 1 },
  isHardLink : { readOnly : 1 },
  isSoftLink : { readOnly : 1 },
  isTextLink : { readOnly : 1 },
  isLink : { readOnly : 1 },

  absolute : { setter : absoluteSet },
  relative : { setter : relativeSet },
  input : { setter : inputSet },

}

// --
// declare
// --

let Proto =
{

  init,
  form,
  clone,
  From,
  FromMany,
  toAbsolute,

  _safeCheck,
  _pathsForm,
  _filterReset,
  _filterApply,
  _statReset,
  _statRead,
  _statAnalyze,

  reset,
  changeExt,
  hashRead,

  _isTransientGet,
  _isTransientSet,
  _isActualGet,
  _isActualSet,
  _isStemGet,
  _isDirGet,
  _isTerminalGet,
  _isHardLinkGet,
  _isSoftLinkGet,
  _isTextLinkGet,
  _isLinkGet,

  absoluteSet,
  relativeSet,
  inputSet,

  _pathGet,
  _statGet,

  _realGet,
  _absoluteGlobalGet,
  _realGlobalGet,
  _absoluteGlobalMaybeGet,
  _realGlobalMaybeGet,

  _dirGet,
  _extsGet,
  _extGet,
  _extWithDotGet,
  _nickNameGet,
  _nameGet,
  _fullNameGet,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Copiers,
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

_.assert( !_global_.wFileRecord && !_.FileRecord, 'wFileRecord already defined' );

//

if( typeof module !== 'undefined' )
require( './FileRecordFactory.s' );

// --
// export
// --

_[ Self.shortName ] = Self;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
