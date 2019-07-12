( function _FileRecordFilter_s_() {

'use strict'/*fff*/;


if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

//

/**
 * @class wFileRecordFilter
 * @memberof module:Tools/mid/Files
*/

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileRecordFilter( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'FileRecordFilter';

_.assert( !_.FileRecordFilter );
_.assert( !!_.regexpsEscape );

// --
//
// --

/**
 * @summary Creates filter instance ignoring unknown options.
 * @param {Object} o Options map.
 * @function TollerantFrom
 * @memberof module:Tools/mid/Files.wFileRecordFilter
*/

function TollerantFrom( o )
{
  _.assert( arguments.length >= 1, 'Expects at least one argument' );
  _.assert( _.objectIs( Self.prototype.Composes ) );
  o = _.mapsExtend( null, arguments );
  return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
}

//

function init( o )
{
  let filter = this;

  _.instanceInit( filter );
  Object.preventExtensions( filter );

  if( o )
  filter.copy( o );

  filter._formAssociations();

  return filter;
}

//

function copy( src )
{
  let filter = this;

  _.assert( arguments.length === 1 );

  if( _.strIs( src ) || _.arrayIs( src ) )
  src = { prefixPath : src, filePath : '.' }

  // if( _.strIs( src ) || _.arrayIs( src ) )
  // src = { prefixPath : src, filePath : src }

  let result = _.Copyable.prototype.copy.call( filter, src );

  return result;
}

//

function pairedClone()
{
  let filter = this;

  let result = filter.clone();

  if( filter./*srcFilter*/src )
  {
    result./*srcFilter*/src = filter./*srcFilter*/src.clone();
    result./*srcFilter*/src.pairWithDst( result );
    result./*srcFilter*/src.pairRefineLight();
    return result;
  }

  if( filter./*dstFilter*/dst )
  {
    result./*dstFilter*/dst = filter./*dstFilter*/dst.clone();
    result.pairWithDst( result./*dstFilter*/dst );
    result.pairRefineLight();
    return result;
  }

  return result;
}

// --
// former
// --

function form()
{
  let filter = this;

  if( filter.formed === 5 )
  return filter;

  filter._formAssociations();
  filter._formFinal();

  _.assert( filter.formed === 5 );
  Object.freeze( filter );
  return filter;
}

//

function _formAssociations()
{
  let filter = this;

  /* */

  if( filter.hubFileProvider )
  {
    if( filter.hubFileProvider.hub && filter.hubFileProvider.hub !== filter.hubFileProvider )
    {
      _.assert( filter.effectiveFileProvider === null || filter.effectiveFileProvider === filter.hubFileProvider );
      filter.effectiveFileProvider = filter.hubFileProvider;
      filter.hubFileProvider = filter.hubFileProvider.hub;
    }
  }

  if( filter.effectiveFileProvider )
  {
    if( filter.effectiveFileProvider instanceof _.FileProvider.Hub )
    {
      _.assert( filter.hubFileProvider === null || filter.hubFileProvider === filter.effectiveFileProvider );
      filter.hubFileProvider = filter.effectiveFileProvider;
      filter.effectiveFileProvider = null;
    }
  }

  if( filter.effectiveFileProvider && filter.effectiveFileProvider.hub )
  {
    _.assert( filter.hubFileProvider === null || filter.hubFileProvider === filter.effectiveFileProvider.hub );
    filter.hubFileProvider = filter.effectiveFileProvider.hub;
  }

  if( !filter.defaultFileProvider )
  {
    filter.defaultFileProvider = filter.defaultFileProvider || filter.effectiveFileProvider || filter.hubFileProvider;
  }

  /* */

  _.assert( !filter.hubFileProvider || filter.hubFileProvider instanceof _.FileProvider.Abstract, 'Expects {- filter.hubFileProvider -}' );
  _.assert( filter.defaultFileProvider instanceof _.FileProvider.Abstract );
  _.assert( !filter.effectiveFileProvider || !( filter.effectiveFileProvider instanceof _.FileProvider.Hub ) );

  /* */

  filter.maskAll = _.RegexpObject( filter.maskAll );
  filter.maskTerminal = _.RegexpObject( filter.maskTerminal );
  filter.maskDirectory = _.RegexpObject( filter.maskDirectory );

  filter.maskTransientAll = _.RegexpObject( filter.maskTransientAll );
  filter.maskTransientTerminal = _.RegexpObject( filter.maskTransientTerminal );
  filter.maskTransientDirectory = _.RegexpObject( filter.maskTransientDirectory );

  /* */

  filter.formed = 1;
}

//

function _formPre()
{
  let filter = this;

  if( filter.formed < 1 )
  filter._formAssociations();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 1 );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.arrayIs( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) || _.arrayIs( filter.postfixPath ) );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );

  filter.formed = 2;
}

//

function _formPaths()
{
  let filter = this;

  // if( filter.prefixPath === '/src/*' )
  // debugger;

  if( filter.formed === 3 )
  return;
  if( filter.formed < 2 )
  filter._formPre();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 2 );

  let applicableToTrue = false;
  if( filter.filePath )
  applicableToTrue = !path.mapDstFromSrc( filter.filePath ).filter( ( e ) => !_.boolLike( e ) ).length;
  filter.prefixesApply({ applicableToTrue : applicableToTrue });

  filter.pathsNormalize();

  if( _.mapIs( filter.filePath ) )
  filter.filePath = filter.filePathGlobSimplify( filter.basePath, filter.filePath );

  filter.formed = 3;
}

//

function _formMasks()
{
  let filter = this;

  if( filter.formed < 3 )
  filter._formPaths();

  let fileProvider = filter.effectiveFileProvider || filter.defaultFileProvider || filter.hubFileProvider;
  let path = fileProvider.path;

  /* */

  if( Config.debug )
  {

    _.assert( arguments.length === 0 );
    _.assert( filter.formed === 3 );

    if( filter.basePath )
    filter.assertBasePath();

    _.assert
    (
         ( _.arrayIs( filter.filePath ) && filter.filePath.length === 0 )
      || ( _.mapIs( filter.filePath ) && _.mapKeys( filter.filePath ).length === 0 )
      || ( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length > 0 )
      || _.strIs( filter.basePath )
      , 'Cant deduce base path'
    );

    // _.assert( _.mapIs( filter.filePath ) || !filter./*srcFilter*/src, 'Destination filter should have file map' );
    _.assert( _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );
    // _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );

  }

  /* */

  filter.maskExtensionApply();
  filter.maskBeginsApply();
  filter.maskEndsApply();
  filter.filePathGenerate();

  filter.formed = 4;
}

//

function _formFinal()
{
  let filter = this;

  if( filter.formed < 4 )
  filter._formMasks();

  /*
    should use effectiveFileProvider because of option globbing of file provider
  */

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  /* - */

  if( Config.debug )
  {

    _.assert( arguments.length === 0 );
    _.assert( filter.formed === 4 );
    _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ) );
    _.assert( _.mapIs( filter.formedBasePath ) || _.mapKeys( filter.formedFilePath ).length === 0 );
    _.assert( _.mapIs( filter.formedFilePath ) );
    // _.assert( _.mapIs( filter.basePath ) || _.mapKeys( filter.formedFilePath ).length === 0 );
    _.assert( _.objectIs( filter.effectiveFileProvider ) );
    _.assert( filter.hubFileProvider === filter.effectiveFileProvider.hub || filter.hubFileProvider === filter.effectiveFileProvider );
    _.assert( filter.hubFileProvider instanceof _.FileProvider.Abstract );
    _.assert( filter.defaultFileProvider instanceof _.FileProvider.Abstract );

    let filePath = filter.filePathArrayGet( filter.formedFilePath ).filter( ( e ) => _.strIs( e ) );
    _.assert( path.s.noneAreGlob( filePath ) );
    _.assert( path.s.allAreAbsolute( filePath ) || path.s.allAreGlobal( filePath ) );

    if( _.mapIs( filter.formedBasePath ) )
    for( let p in filter.formedBasePath )
    {
      let filePath = p;
      let basePath = filter.formedBasePath[ p ];
      _.assert
      (
        path.isAbsolute( filePath ) && path.isNormalized( filePath ) && !path.isGlob( filePath ) && !path.isTrailed( filePath ),
        () => 'Stem path should be absolute and normalized, but not glob, neither trailed' + '\nstemPath : ' + _.toStr( filePath )
      );
      _.assert
      (
        path.isAbsolute( basePath ) && path.isNormalized( basePath ) && !path.isGlob( basePath ) && !path.isTrailed( basePath ),
        () => 'Base path should be absolute and normalized, but not glob, neither trailed' + '\nbasePath : ' + _.toStr( basePath )
      );
    }

    /* time */

    if( filter.notOlder )
    _.assert( _.numberIs( filter.notOlder ) || _.dateIs( filter.notOlder ) );

    if( filter.notNewer )
    _.assert( _.numberIs( filter.notNewer ) || _.dateIs( filter.notNewer ) );

    if( filter.notOlderAge )
    _.assert( _.numberIs( filter.notOlderAge ) || _.dateIs( filter.notOlderAge )  );

    if( filter.notNewerAge )
    _.assert( _.numberIs( filter.notNewerAge ) || _.dateIs( filter.notNewerAge ) );

  }

  /* - */

  filter.applyTo = filter._applyToRecordNothing;

  if( filter.notOlder || filter.notNewer || filter.notOlderAge || filter.notNewerAge )
  filter.applyTo = filter._applyToRecordFull;
  else if( filter.hasMask() )
  filter.applyTo = filter._applyToRecordMasks;

  filter.formed = 5;
}

// --
// mutator
// --

/**
 * @summary Applies file extension mask to the filter.
 * @function maskExtensionApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function maskExtensionApply()
{
  let filter = this;

  if( filter.hasExtension )
  {
    _.assert( _.strIs( filter.hasExtension ) || _.strsAreAll( filter.hasExtension ) );

    filter.hasExtension = _.arrayAs( filter.hasExtension );
    filter.hasExtension = new RegExp( '^.*\\.(' + _.regexpsEscape( filter.hasExtension ).join( '|' ) + ')(\\.|$)(?!.*\/.+)', 'i' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll, { includeAll : filter.hasExtension } );
    filter.hasExtension = null;
  }

}

//

/**
 * @summary Applies file begins mask to the filter.
 * @function maskBeginsApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function maskBeginsApply()
{
  let filter = this;

  if( filter.begins )
  {
    _.assert( _.strIs( filter.begins ) || _.strsAreAll( filter.begins ) );

    filter.begins = _.arrayAs( filter.begins );
    filter.begins = new RegExp( '^(\\.\\/)?(' + _.regexpsEscape( filter.begins ).join( '|' ) + ')' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.begins } );
    filter.begins = null;
  }

}

/**
 * @summary Applies file ends mask to the filter.
 * @function maskEndsApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

//

function maskEndsApply()
{
  let filter = this;

  if( filter.ends )
  {
    _.assert( _.strIs( filter.ends ) || _.strsAreAll( filter.ends ) );

    filter.ends = _.arrayAs( filter.ends );
    filter.ends = new RegExp( '(' + '^\.|' + _.regexpsEscape( filter.ends ).join( '|' ) + ')$' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.ends } );
    filter.ends = null;
  }

}

//

/**
 * @descriptionNeeded
 * @function filePathGenerate
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function filePathGenerate()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  let globFound = !filter./*srcFilter*/src;
  if( globFound )
  globFound = filter.filePathHasGlob();

  if( globFound )
  {

    _.assert( !filter./*srcFilter*/src );
    _.assert( filter.formedFilterMap === null );
    filter.formedFilterMap = Object.create( null );

    // debugger;
    let _processed = path.pathMapToRegexps( filter.filePath, filter.basePath  );
    // debugger;

    filter.formedBasePath = _processed.unglobedBasePath;
    filter.formedFilePath = _processed.unglobedFilePath;

    filter.assertBasePath();

    for( let p in _processed.regexpMap )
    {
      let basePath = filter.formedBasePath[ p ];
      _.assert( _.strDefined( basePath ), 'No base path for', p );
      let relative = p;
      let regexps = _processed.regexpMap[ p ];
      _.assert( !filter.formedFilterMap[ relative ] );
      let subfilter = filter.formedFilterMap[ relative ] = Object.create( null );
      subfilter.maskAll = _.RegexpObject.Or( filter.maskAll.clone(), { includeAll : regexps.actualAll, includeAny : regexps.actualAny, excludeAny : regexps.notActual } );
      subfilter.maskTerminal = filter.maskTerminal.clone();
      subfilter.maskDirectory = filter.maskDirectory.clone();
      subfilter.maskTransientAll = filter.maskTransientAll.clone();
      subfilter.maskTransientTerminal = _.RegexpObject.Or( filter.maskTransientTerminal.clone(), { includeAny : /$_^/ } );
      // subfilter.maskTransientTerminal = filter.maskTransientTerminal.clone(); // zzz
      subfilter.maskTransientDirectory = _.RegexpObject.Or( filter.maskTransientDirectory.clone(), { includeAny : regexps.transient } );
      _.assert( subfilter.maskAll !== filter.maskAll );
    }

  }
  else
  {
    /* if base path is redundant then return empty map */
    if( _.mapIs( filter.basePath ) )
    filter.formedBasePath = _.entityShallowClone( filter.basePath );
    else
    filter.formedBasePath = Object.create( null );
    filter.formedFilePath = _.entityShallowClone( filter.filePath );
  }

}

//

/**
 * @descriptionNeeded
 * @param {String} srcPath
 * @param {String} dstPath
 * @function filePathSelect
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function filePathSelect( srcPath, dstPath )
{
  let /*srcFilter*/src = this;
  let /*dstFilter*/dst = /*srcFilter*/src./*dstFilter*/dst;
  let fileProvider = /*srcFilter*/src.hubFileProvider || /*srcFilter*/src.effectiveFileProvider || /*srcFilter*/src.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( srcPath ) );
  _.assert( _.strIs( dstPath ) );

  let filePath = path.mapExtend( null, srcPath, dstPath );

  if( /*dstFilter*/dst )
  try
  {

    if( _.mapIs( /*dstFilter*/dst.basePath ) )
    for( let dstPath2 in /*dstFilter*/dst.basePath )
    {
      if( dstPath !== dstPath2 )
      {
        _.assert( _.strIs( /*dstFilter*/dst.basePath[ dstPath2 ] ), () => 'No base path for ' + dstPath2 );
        delete /*dstFilter*/dst.basePath[ dstPath2 ];
      }
    }

    /*dstFilter*/dst.filePath = filePath;
    /*dstFilter*/dst.form();
    dstPath = /*dstFilter*/dst.filePathSimplest();
    _.assert( _.strIs( dstPath ) );
    filePath = /*dstFilter*/dst.filePath;
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Failed to form destination filter\n', err );
  }

  try
  {

    if( _.mapIs( /*srcFilter*/src.basePath ) )
    for( let srcPath2 in /*srcFilter*/src.basePath )
    {
      if( filePath[ srcPath2 ] === undefined )
      {
        _.assert( _.strIs( /*srcFilter*/src.basePath[ srcPath2 ] ), () => 'No base path for ' + srcPath2 );
        delete /*srcFilter*/src.basePath[ srcPath2 ];
      }
    }

    /*srcFilter*/src.filePath = filePath;
    _.assert( /*dstFilter*/dst === null || /*srcFilter*/src.filePath === /*dstFilter*/dst.filePath );
    /*srcFilter*/src.form();
    _.assert( /*dstFilter*/dst === null || /*srcFilter*/src.filePath === /*dstFilter*/dst.filePath );
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Failed to form source filter\n', err );
  }

}

//

/**
 * @descriptionNeeded
 * @param {Object} o Options map.
 * @param {Boolean} o.applicableToTrue=false
 * @function prefixesApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function prefixesApply( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let adjustingFilePath = true;
  let paired = false;

  if( filter.prefixPath === null && filter.postfixPath === null )
  return filter;

  if( filter./*srcFilter*/src && filter./*srcFilter*/src.filePath === filter.filePath )
  paired = true;

  if( filter./*dstFilter*/dst && filter./*dstFilter*/dst.filePath === filter.filePath )
  paired = true;

  o = _.routineOptions( prefixesApply, arguments );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.strsAreAll( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) || _.strsAreAll( filter.postfixPath ) );
  _.assert( filter.postfixPath === null, 'not implemented' );

  if( !filter.filePath )
  {
    adjustingFilePath = false;
  }

  /* */

  _.assert( filter.postfixPath === null || !path.s.AllAreGlob( filter.postfixPath ) );

  if( adjustingFilePath )
  {
    let o2 = { basePath : 0, fixes : 0, filePath : 1, inplace : 1, onEach : filePathEach }
    filter.allPaths( o2 );
  }
  else
  {
    if( filter./*srcFilter*/src )
    filter.filePath = path.mapsPair( filter.prefixPath, null );
    else if( filter./*dstFilter*/dst )
    filter.filePath = path.mapsPair( null, filter.prefixPath );
    else
    filter.filePath = filter.prefixPath;
  }

  if( filter.basePath )
  {
    filter.basePathEach( basePathEach );
    filter.basePathSimplify();
  }

  /* */

  filter.prefixPath = null;
  filter.postfixPath = null;

  if( !Config.debug )
  return filter;

  _.assert( !_.arrayIs( filter.basePath ) );
  _.assert( _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) || filter.basePath === null );

  if( filter.basePath && filter.filePath )
  filter.assertBasePath();

  if( paired && filter./*srcFilter*/src && filter./*srcFilter*/src.filePath !== filter.filePath )
  filter./*srcFilter*/src.filePath = filter.filePath;

  if( paired && filter./*dstFilter*/dst && filter./*dstFilter*/dst.filePath !== filter.filePath )
  filter./*dstFilter*/dst.filePath = filter.filePath;

  return filter;

  /* */

  function filePathEach( element, it )
  {
    _.assert( it.value === null || _.strIs( it.value ) || _.boolLike( it.value ) || _.arrayIs( it.value ) );

    if( filter./*srcFilter*/src )
    {
      if( it.side === 'src' ) // yyy
      return it.value;
    }
    else if( filter./*dstFilter*/dst )
    {
      if( it.side === 'dst' ) // yyy
      return it.value;
    }

    if( !o.applicableToTrue )
    if( it.side === 'src' && _.boolLike( it.dst ) ) // yyy
    {
      return it.value;
    }

    if( filter.prefixPath || filter.postfixPath )
    {
      if( it.value === null || ( o.applicableToTrue && _.boolLike( it.value ) && it.value ) )
      {
        it.value = path.s.join( filter.prefixPath || '.', filter.postfixPath || '.' );
      }
      else if( !_.boolLike( it.value ) )
      {
        it.value = path.s.join( filter.prefixPath || '.', it.value, filter.postfixPath || '.' );
      }
    }

    if( it.side === 'dst' && _.strIs( it.value ) ) // yyy
    it.value = path.fromGlob( it.value );

    return it.value;
  }

  /* */

  function basePathEach( filePath, basePath )
  {
    if( !filter.prefixPath && !filter.postfixPath )
    return;

    let r = Object.create( null );

    basePath = path.s.join( filter.prefixPath || '.', basePath, filter.postfixPath || '.' );

    if( !_.boolLike( filePath ) )
    filePath = path.s.join( filter.prefixPath || '.', filePath, filter.postfixPath || '.' );

    if( _.arrayIs( filePath ) )
    {
      for( let f = 0 ; f < filePath.length ; f++ )
      r[ filePath[ f ] ] = basePath[ f ];
      return r;
    }
    else
    {
      r[ filePath ] = basePath;
      return r;
    }

  }

}

prefixesApply.defaults =
{
  applicableToTrue : 0,
}

//

/**
 * @descriptionNeeded
 * @param {String} prefixPath
 * @function prefixesRelative
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function prefixesRelative( prefixPath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  prefixPath = prefixPath || filter.prefixPath;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !prefixPath || filter.prefixPath === null || filter.prefixPath === prefixPath );

  if( filter.filePath && !prefixPath )
  {

    prefixPath = filter.prefixPathFromFilePath({ usingBools : 1 });

    // // debugger; // xxx
    //
    // let filePath = filter.filePathArrayNonBoolGet( filter.filePath, 1 );
    //
    // // let filePath;
    // // if( filter./*srcFilter*/src )
    // // filePath = path.mapDstFromDst( filter.filePath );
    // // else
    // // filePath = path.mapSrcFromSrc( filter.filePath );
    //
    // if( filePath )
    // {
    //   filePath = filePath.filter( ( filePath ) => _.strIs( filePath ) );
    //   if( path.s.anyAreAbsolute( filePath ) )
    //   filePath = filePath.filter( ( filePath ) => path.isAbsolute( filePath ) );
    // }
    //
    // if( filePath && filePath.length )
    // {
    //   prefixPath = path.fromGlob( path.detrail( path.common( filePath ) ) );
    // }

  }

  if( prefixPath )
  {

    if( filter.basePath )
    filter.basePath = path.filter( filter.basePath, relative_functor() );

    if( filter.filePath )
    {
      if( filter./*srcFilter*/src )
      filter.filePath = path.filterInplace( filter.filePath, relative_functor( 'dst' ) );
      else if( filter./*dstFilter*/dst )
      filter.filePath = path.filterInplace( filter.filePath, relative_functor( 'src' ) );
      else
      filter.filePath = path.filterInplace( filter.filePath, relative_functor() );
    }

    filter.prefixPath = prefixPath;
  }

  return prefixPath;

  /* */

  function relative_functor( side )
  {
    return function relative( filePath, it )
    {

      if( !side || it.side === side || it.side === undefined )
      {
        if( !_.strIs( filePath ) )
        return filePath;

        _.assert( path.isGlobal( prefixPath ) ^ path.isGlobal( filePath ) ^ true );

        if( path.isAbsolute( prefixPath ) ^ path.isAbsolute( filePath ) )
        return filePath;

        return path.relative( prefixPath, filePath );
      }

      return filePath;
    }
  }

}

//

function prefixPathFromFilePath( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.routineOptions( prefixPathFromFilePath, arguments );

  let result = o.filePath || filter.filePath;

  if( result === null )
  return null;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !!result );

  if( o.usingBools )
  result = filter.filePathArrayGet( result );
  else
  result = filter.filePathArrayNonBoolGet( result, 1 );

  if( result )
  {
    result = result.filter( ( filePath ) => _.strIs( filePath ) );
    if( path.s.anyAreAbsolute( result ) )
    result = result.filter( ( filePath ) => path.isAbsolute( filePath ) );
  }

  if( result && result.length )
  {
    result = path.fromGlob( path.detrail( path.common( result ) ) );
  }
  else
  {
    result = null;
  }

  return result;
}

prefixPathFromFilePath.defaults =
{
  filePath : null,
  usingBools : 1,
}

//

/**
 * @summary Converts global path into local.
 * @param {String} filePath Input file path.
 * @function prefixesRelative
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function pathLocalize( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( _.strIs( filePath ) );

  filePath = path.normalizeCanonical( filePath );

  if( filter.effectiveFileProvider && !path.isGlobal( filePath ) )
  return filePath;

  let effectiveProvider2 = fileProvider.providerForPath( filePath );
  _.assert( filter.effectiveFileProvider === null || effectiveProvider2 === null || filter.effectiveFileProvider === effectiveProvider2, 'Record filter should have paths of single file provider' );
  filter.effectiveFileProvider = filter.effectiveFileProvider || effectiveProvider2;

  if( filter.effectiveFileProvider )
  {

    if( !filter.hubFileProvider )
    filter.hubFileProvider = filter.effectiveFileProvider.hub;
    _.assert( filter.effectiveFileProvider.hub === null || filter.hubFileProvider === filter.effectiveFileProvider.hub );
    _.assert( filter.effectiveFileProvider.hub === null || filter.hubFileProvider instanceof _.FileProvider.Hub );

  }

  if( !path.isGlobal( filePath ) )
  return filePath;

  _.assert( !path.isTrailed( filePath ) );

  let provider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider;
  let result = provider.path.localFromGlobal( filePath );
  return result;
}

//

/**
 * @summary Normalizes path properties of the filter.
 * @function pathsNormalize
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function pathsNormalize()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let originalFilePath = filter.filePath;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 2 );
  _.assert( filter.prefixPath === null, 'Prefixes should be applied so far' );
  _.assert( filter.postfixPath === null, 'Posftixes should be applied so far' );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  // _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );
  // _.assert( _.mapIs( filter.filePath ) || !filter./*srcFilter*/src, 'Destination filter should have file map' );

  /* */

  filter.filePath = filter.filePathNormalize( filter.filePath );
  _.assert( _.mapIs( filter.filePath ) );

  filter.basePath = filter.basePathNormalize( filter.basePath, filter.filePath );
  _.assert( _.mapIs( filter.basePath ) || filter.basePath === null || filter.filePathArrayNonBoolGet( filter.filePath, 1 ).filter( ( e ) => e !== null ).length === 0 );

  filter.filePathAbsolutize();
  filter.providersNormalize();

  // /* */
  //
  // if( !Config.debug )
  // return;
  //
  // if( filter.basePath )
  // filter.assertBasePath();
  //
  // _.assert
  // (
  //      ( _.arrayIs( filter.filePath ) && filter.filePath.length === 0 )
  //   || ( _.mapIs( filter.filePath ) && _.mapKeys( filter.filePath ).length === 0 )
  //   || ( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length > 0 )
  //   || _.strIs( filter.basePath )
  //   , 'Cant deduce base path'
  // );

}

//

/**
 * @summary Converts local paths of filter into global.
 * @function globalsFromLocals
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function globalsFromLocals()
{
  let filter = this;

  if( !filter.effectiveFileProvider )
  return;

  if( filter.basePath )
  filter.basePath = filter.effectiveFileProvider.globalsFromLocals( filter.basePath );

  if( filter.filePath )
  filter.filePath = filter.effectiveFileProvider.globalsFromLocals( filter.filePath );

}

// --
// combiner
// --

/**
 * @descriptionNeeded
 * @function And
 * @memberof module:Tools/mid/Files.wFileRecordFilter
*/

function And()
{
  _.assert( !_.instanceIs( this ) );

  let /*dstFilter*/dst = null;

  if( arguments.length === 1 )
  return this.Self( arguments[ 0 ] );

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let /*srcFilter*/src = arguments[ a ];

    if( /*dstFilter*/dst )
    /*dstFilter*/dst = this.Self( /*dstFilter*/dst );
    if( /*dstFilter*/dst )
    /*dstFilter*/dst.and( /*srcFilter*/src );
    else
    /*dstFilter*/dst = this.Self( /*srcFilter*/src );

  }

  return /*dstFilter*/dst;
}

//

/**
 * @descriptionNeeded
 * @function and
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function and( src )
{
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.and( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.effectiveFileProvider || !src.effectiveFileProvider || filter.effectiveFileProvider === src.effectiveFileProvider );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );

  if( src === filter )
  return filter;

  /* */

  if( src.effectiveFileProvider )
  filter.effectiveFileProvider = src.effectiveFileProvider

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider

  /* */

  let appending =
  {

    hasExtension : null,
    begins : null,
    ends : null,

  }

  for( let a in appending )
  {
    if( src[ a ] === null || src[ a ] === undefined )
    continue;
    _.assert( _.strIs( src[ a ] ) || _.strsAreAll( src[ a ] ) );
    _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAreAll( filter[ a ] ) );
    if( filter[ a ] === null )
    {
      filter[ a ] = src[ a ];
    }
    else
    {
      if( _.strIs( filter[ a ] ) )
      filter[ a ] = [ filter[ a ] ];
      _.arrayAppendOnce( filter[ a ], src[ a ] );
    }
  }

  /* */

  let once =
  {
    notOlder : null,
    notNewer : null,
    notOlderAge : null,
    notNewerAge : null,
  }

  for( let n in once )
  {
    _.assert( !filter[ n ] || !src[ n ], 'Cant "and" filter with another filter, them both have field', n );
    if( src[ n ] )
    filter[ n ] = src[ n ];
  }

  /* */

  filter.maskAll = _.RegexpObject.And( filter.maskAll, src.maskAll || null );
  filter.maskTerminal = _.RegexpObject.And( filter.maskTerminal, src.maskTerminal || null );
  filter.maskDirectory = _.RegexpObject.And( filter.maskDirectory, src.maskDirectory || null );
  filter.maskTransientAll = _.RegexpObject.And( filter.maskTransientAll, src.maskTransientAll || null );
  filter.maskTransientTerminal = _.RegexpObject.And( filter.maskTransientTerminal, src.maskTransientTerminal || null );
  filter.maskTransientDirectory = _.RegexpObject.And( filter.maskTransientDirectory, src.maskTransientDirectory || null );

  return filter;
}

//

function _pathsJoin_pre( routine, args )
{
  let filter = this;
  let o;

  if( _.mapIs( args[ 0 ] ) )
  o = args[ 0 ];
  else
  o = { src : args }

  _.assert( arguments.length === 2 );
  _.routineOptions( routine, o );

  return o;
}

//

function _pathsJoin_body( o )
{
  let filter = this;

  if( _.arrayLike( o.src ) )
  {
    for( let a = 0 ; a < o.src.length ; a++ )
    {
      let o2 = _.mapExtend( null, o );
      o2.src = o2.src[ a ];
      filter._pathsJoin.body.call( filter, o2 );
    }
    return filter;
  }

  if( Config.debug )
  if( o.src && !( o.src instanceof filter.Self ) )
  _.assertMapHasOnly( o.src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !o.src.formed || o.src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !o.src.hubFileProvider || filter.hubFileProvider === o.src.hubFileProvider );
  _.assert( o.src !== filter );
  _.assert( _.objectIs( o.src ) );
  // _.assert( o.src.filePath === null || o.src.filePath === undefined || o.src.filePath === '.' || _.strIs( o.src.filePath ) );

  let fileProvider = filter.hubFileProvider || filter.defaultFileProvider || filter.effectiveFileProvider || o.src.hubFileProvider || o.src.defaultFileProvider || o.src.effectiveFileProvider;
  let path = fileProvider.path;

  if( o.src.hubFileProvider )
  filter.hubFileProvider = o.src.hubFileProvider;

  /* */

  for( let n in o.joiningAsPathMap )
  if( o.src[ n ] !== undefined && o.src[ n ] !== null )
  {
    if( filter[ n ] === null )
    {
      filter[ n ] = o.src[ n ];
      continue;
    }
    // _.assert( !!filter./*dstFilter*/dst || !!filter./*srcFilter*/src, 'Filters should be paired first!' );
    if( filter./*srcFilter*/src )
    {
      debugger;
      if( !_.mapIs( filter[ n ] ) )
      filter[ n ] = path.mapExtend( null, null, filter[ n ] );
      path.mapExtend( filter[ n ], o.src[ n ], null );
    }
    else
    {
      debugger;
      path.mapExtend( filter[ n ], o.src[ n ], null );
    }
    // _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
    // _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
    // filter[ n ] = path.join( filter[ n ], o.src[ n ] );
  }

  /* */

  for( let n in o.joiningWithoutNullMap )
  if( o.src[ n ] !== undefined && o.src[ n ] !== null )
  {
    _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
    _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
    filter[ n ] = path.join( filter[ n ], o.src[ n ] );
  }

  /* */

  for( let n in o.joiningMap )
  if( o.src[ n ] !== undefined )
  {
    _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
    _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
    filter[ n ] = path.join( filter[ n ], o.src.basePath );
  }

  /* */

  for( let a in o.appendingMap )
  {
    if( o.src[ a ] === null || o.src[ a ] === undefined )
    continue;

    _.assert( _.strIs( o.src[ a ] ) || _.strsAreAll( o.src[ a ] ) );
    _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAreAll( filter[ a ] ) );

    if( filter[ a ] === null )
    {
      filter[ a ] = o.src[ a ];
    }
    else
    {
      if( _.strIs( filter[ a ] ) )
      filter[ a ] = [ filter[ a ] ];
      _.arrayAppendOnce( filter[ a ], o.src[ a ] );
    }

  }

  return filter;
}

_pathsJoin_body.defaults =
{

  src : null,

  joiningAsPathMap :
  {
    filePath : null,
  },

  joiningWithoutNullMap :
  {
    // filePath : null, // yyy
  },

  joiningMap :
  {
    basePath : null,
  },

  appendingMap :
  {
    prefixPath : null,
    postfixPath : null,
  },

}

let _pathsJoin = _.routineFromPreAndBody( _pathsJoin_pre, _pathsJoin_body );

//

function pathsJoin()
{
  let filter = this;
  return filter._pathsJoin
  ({
    src : arguments,
    joiningAsPathMap :
    {
      filePath : null,
    },
    joiningWithoutNullMap :
    {
      // filePath : null,
    },
    joiningMap :
    {
      basePath : null,
    },
    appendingMap :
    {
      prefixPath : null,
      postfixPath : null,
    },
  });
}

//

function pathsJoinWithoutNull()
{
  let filter = this;
  return filter._pathsJoin
  ({
    src : arguments,
    joiningAsPathMap :
    {
      filePath : null,
    },
    joiningWithoutNullMap :
    {
      // filePath : null,
      basePath : null,
    },
    joiningMap :
    {
    },
    appendingMap :
    {
      prefixPath : null,
      postfixPath : null,
    },
  });
}

//

function pathsExtend2( src )
{
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.pathsJoin( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  /* */

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider;

  /* */

  if( !( src instanceof Self ) )
  src = fileProvider.recordFilter( src );

  // if( src.prefixPath )
  // src.prefixesApply();
  //
  // if( filter.prefixPath )
  // filter.prefixesApply();

  if( src.prefixPath && filter.prefixPath )
  {
    let prefixPath = src.prefixPath;
    src.prefixesApply();
    filter.prefixesApply();
    _.assert( !_.mapIs( filter.filePath ) || !!_.mapKeys( filter.filePath ).length );
    if( filter.filePath === null )
    filter.prefixPath = prefixPath;
  }

  if( src.prefixPath && src.filePath )
  {
    src.prefixesApply();
  }

  if( filter.prefixPath && filter.filePath )
  {
    filter.prefixesApply();
  }

  _.assert( src.prefixPath === null || filter.prefixPath === null );
  _.assert( src.postfixPath === null || filter.postfixPath === null );
  _.assert( src.postfixPath === null && filter.postfixPath === null, 'not implemented' );

  filter.prefixPath = src.prefixPath || filter.prefixPath;
  filter.postfixPath = src.postfixPath || filter.postfixPath;

  /* */

  if( src.basePath && filter.basePath )
  {

    if( _.strIs( src.basePath ) )
    src.basePath = src.basePathFrom( src.basePath, src.filePath || {} );
    _.assert( src.basePath === null || _.mapIs( src.basePath ) || _.strIs( src.basePath ) ); // yyy
    // _.assert( src.basePath === null || _.mapIs( src.basePath ) );

    if( _.strIs( filter.basePath ) )
    filter.basePath = filter.basePathFrom( filter.basePath, filter.filePath || {} );
    _.assert( filter.basePath === null || _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) ); // yyy
    // _.assert( filter.basePath === null || _.mapIs( filter.basePath ) );

    if( _.mapIs( src.basePath ) )
    filter.basePath = _.mapExtend( filter.basePath, src.basePath );

  }
  else
  {
    filter.basePath = filter.basePath || src.basePath;
  }

  /* */

  if( filter.filePath && src.filePath )
  {

    let isDst = !!filter./*srcFilter*/src || !!src./*srcFilter*/src;
    if( ( _.mapIs( filter.filePath ) && _.mapIs( src.filePath ) ) || !isDst )
    {
      filter.filePath = path.mapExtend( filter.filePath, src.filePath, null );
    }
    else if( !_.mapIs( src.filePath ) )
    {
      debugger;
      _.assert( 0, 'not tested' );
      filter.filePath = path.mapExtend( filter.filePath, filter.filePath, src.filePath );
    }
    else if( !_.mapIs( filter.filePath ) )
    {
      filter.filePath = path.mapExtend( null, src.filePath, filter.filePath );
    }

  }
  else
  {
    filter.filePath = filter.filePath || src.filePath;
  }

  /* */

  return filter;
}

//

function pathsInherit( src )
{
  let filter = this;
  let paired = false;

  if( filter./*srcFilter*/src && filter./*srcFilter*/src.filePath === filter.filePath )
  paired = true;

  if( filter./*dstFilter*/dst && filter./*dstFilter*/dst.filePath === filter.filePath )
  paired = true;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.pathsJoin( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  /* */

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider;

  /* */

  if( !( src instanceof Self ) )
  src = fileProvider.recordFilter( src );

  if( src.prefixPath && filter.prefixPath )
  {
    let prefixPath = filter.prefixPath;
    src.prefixesApply();
    filter.prefixesApply();
    _.assert( !_.mapIs( filter.filePath ) || !!_.mapKeys( filter.filePath ).length );
    if( filter.filePath === null )
    filter.prefixPath = prefixPath;
  }

  _.assert( src.prefixPath === null || filter.prefixPath === null );
  _.assert( src.postfixPath === null || filter.postfixPath === null );
  _.assert( src.postfixPath === null && filter.postfixPath === null, 'not implemented' );

  filter.prefixPath = filter.prefixPath || src.prefixPath;
  filter.postfixPath = filter.postfixPath || src.postfixPath;

  /* */

  let dstSrcNonBoolPaths = filter.filePathSrcArrayNonBoolGet( filter.filePath, 0 );
  let srcOnlyBoolPathMap = src.filePathMapOnlyBools( src.filePath );
  let srcSrcNonBoolPaths = src.filePathSrcArrayNonBoolGet( src.filePath, 0 );

  let dstFilePath = filter.filePath;
  let srcFilePath = src.filePath;
  if( dstSrcNonBoolPaths.length === 0 && srcSrcNonBoolPaths.length === 0 )
  {
    if( dstFilePath )
    dstFilePath = path.filter( dstFilePath, ( e ) => _.boolLike( e ) && e ? null : e );
    if( srcFilePath )
    srcFilePath = path.filter( srcFilePath, ( e ) => _.boolLike( e ) && e ? null : e );
  }

  let dstSrcIsDot = false;
  if( dstSrcNonBoolPaths.length === 1 && dstSrcNonBoolPaths[ 0 ] === '.' )
  {
    dstSrcIsDot = true;
    dstSrcNonBoolPaths = [];
  }

  /* */

  if( filter.basePath === null && _.mapIs( src.basePath ) )
  {

    for( let p = 0 ; p < dstSrcNonBoolPaths.length ; p++ )
    {
      let filePath = dstSrcNonBoolPaths[ p ];
      if( src.basePath[ p ] === undefined )
      {
        filter.basePath = filter.basePath || Object.create( null );
        filter.basePath[ filePath ] = filePath;
      }
    }

  }

  if( src.basePath && filter.basePath )
  {

    if( _.strIs( src.basePath ) )
    src.basePath = src.basePathFrom( src.basePath, src.filePath || {} );
    _.assert( _.mapIs( src.basePath ) || _.strIs( src.basePath ) );

    if( _.strIs( filter.basePath ) )
    filter.basePath = filter.basePathFrom( filter.basePath, filter.filePath || {} );
    _.assert( _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) );

  }

  /* */

  if( filter.filePath && src.filePath )
  {

    if( dstSrcNonBoolPaths.length === 0 && !dstSrcIsDot )
    {
      if( filter./*srcFilter*/src && !_.mapIs( filter./*srcFilter*/src ) )
      filter.filePath = path.mapExtend( null, filter.filePath, null );

      if( src./*srcFilter*/src && !_.mapIs( src./*srcFilter*/src ) )
      src.filePath = path.mapExtend( null, src.filePath, null );

      filter.filePath = path.mapExtend( filter.filePath, src.filePath, null );
    }
    else if( Object.keys( srcOnlyBoolPathMap ).length )
    {
      if( filter./*srcFilter*/src && !_.mapIs( filter./*srcFilter*/src ) )
      filter.filePath = path.mapExtend( null, filter.filePath, null );
      filter.filePath = path.mapExtend( filter.filePath, srcOnlyBoolPathMap, null );
    }
    else
    {
      let dstSrcPath = filter.filePathSrcArrayGet();
      if( dstSrcPath.length === 1 && dstSrcPath[ 0 ] === '.' )
      {
        let dstDstPath = filter.filePathDstArrayGet();
        if( !dstDstPath.length )
        dstDstPath = null;
        filter.filePath = path.mapExtend( null, src.filePathSrcArrayGet(), dstDstPath );
      }
      else
      {
        // let dstDstPath = filter.filePathDstArrayGet();
        // if( !dstDstPath.length )
        // dstDstPath = null;
        // _.assert( !_.arrayIs( dstDstPath ) || !_.arrayHas( dstDstPath, null ) );
        // if( dstDstPath === null ) // yyy
        // filter.filePath = filter.filePath;
        // // else
        // // filter.filePath = path.mapExtend( filter.filePath, src.filePathSrcArrayGet(), dstDstPath );
      }
    }

  }
  else
  {
    filter.filePath = filter.filePath || src.filePath;
  }

  /* */

  if( src.basePath && filter.basePath )
  {

    if( _.mapIs( filter.basePath ) )
    for( let filePath in filter.basePath )
    {
      if( _.boolLike( srcFilePath[ filePath ] ) && !srcFilePath[ filePath ] )
      delete filter.basePath[ filePath ];
    }

    _.assert( _.mapIs( filter.filePath ) || filter.filePath === null );
    if( _.mapIs( src.basePath ) )
    for( let filePath in src.basePath )
    {
      let basePath = src.basePath[ filePath ];
      if( filter.filePath[ filePath ] !== undefined )
      if( !filter.basePath[ filePath ] )
      filter.basePath[ filePath ] = basePath;
    }

  }
  else
  {
    filter.basePath = filter.basePath || src.basePath;
  }

  /* */

  if( paired && filter./*srcFilter*/src && filter./*srcFilter*/src.filePath !== filter.filePath )
  filter./*srcFilter*/src.filePath = filter.filePath;

  if( paired && filter./*dstFilter*/dst && filter./*dstFilter*/dst.filePath !== filter.filePath )
  filter./*dstFilter*/dst.filePath = filter.filePath;

  return filter;
}

// //
//
// function pathsExtend( src )
// {
//   let filter = this;
//
//   if( arguments.length > 1 )
//   {
//     for( let a = 0 ; a < arguments.length ; a++ )
//     filter.pathsExtend( arguments[ a ] );
//     return filter;
//   }
//
//   if( Config.debug )
//   if( src && !( src instanceof filter.Self ) )
//   _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );
//
//   _.assert( _.instanceIs( filter ) );
//   _.assert( !filter.formed || filter.formed <= 1 );
//   _.assert( !src.formed || src.formed <= 1 );
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( filter.formedFilterMap === null );
//   _.assert( filter.applyTo === null );
//   _.assert( filter.filePath === null );
//   _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
//   _.assert( src !== filter );
//   _.assert( src.filePath === null || src.filePath === undefined || filter.filePath === null );
//
//   let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
//   let path = fileProvider.path;
//
//   let replacing =
//   {
//
//     hubFileProvider : null,
//     basePath : null,
//     filePath : null,
//     prefixPath : null,
//     postfixPath : null,
//
//   }
//
//   /* */
//
//   for( let s in replacing )
//   {
//     if( src[ s ] === null || src[ s ] === undefined )
//     continue;
//     filter[ s ] = src[ s ];
//   }
//
//   return filter;
// }

// --
// base path
// --

/**
 * @summary Returns relative path for provided path `filePath`.
 * @function relativeFor
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function relativeFor( filePath )
{
  let filter = this;
  let basePath = filter.basePathForFilePath( filePath );
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  relativePath = path.relative( basePath, filePath );

  return relativePath;
}

//

/**
 * @summary Returns base path for provided path `filePath`.
 * @param {String|Boolean} filePath Source file path.
 * @function basePathForFilePath
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function basePathForFilePath( filePath )
{
  let filter = this;
  let result = null;

  if( !filter.basePath )
  return;

  if( _.boolLike( filePath ) )
  {
    if( _.strIs( filter.basePath ) )
    return filter.basePath;
    _.assert( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length === 1 );
    return _.mapVals( filter.basePath )[ 0 ];
  }

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

  if( _.strIs( filter.basePath ) )
  return filter.basePath;

  _.assert( _.mapIs( filter.basePath ) );

  result = filter.basePath[ filePath ];

  _.assert( result !== undefined, 'No base path for ' + filePath );

  return result;
}

//

/**
 * @summary Returns base path for provided path `filePath`.
 * @param {String|Boolean} filePath Source file path.
 * @function basePathFor
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function basePathFor( filePath )
{
  let filter = this;
  let result = null;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( !filter.basePath )
  return;

  if( _.boolLike( filePath ) )
  {
    if( _.strIs( filter.basePath ) )
    return filter.basePath;
    _.assert( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length === 1 );
    return _.mapVals( filter.basePath )[ 0 ];
  }

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

  if( _.strIs( filter.basePath ) )
  return filter.basePath;

  _.assert( _.mapIs( filter.basePath ) );

  result = filter.basePath[ filePath ];
  if( !result && !_.strBegins( filePath, '..' ) && !_.strBegins( filePath, '/..' ) )
  {

    let filePath2 = path.join( filePath, '..' );
    while( filePath2 !== '..' && filePath2 !== '/..' )
    {
      result = filter.basePath[ filePath2 ];
      if( result )
      break;
      filePath2 = path.join( filePath2, '..' );
    }

  }

  return result;
}

//

function basePathsGet()
{
  let filter = this;

  _.assert( arguments.length === 0 );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );

  if( _.objectIs( filter.basePath ) )
  return _.longUnduplicate( null, _.mapVals( filter.basePath ) )
  else if( _.strIs( filter.basePath ) )
  return [ filter.basePath ];
  else
  return [];
}

//

function basePathFrom( basePath, filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( basePath === undefined )
  basePath = filter.basePath
  if( filePath === undefined )
  filePath = filter.prefixPath || filter.filePath;

  _.assert( basePath === null || _.strIs( basePath ) );
  _.assert( arguments.length === 0 || arguments.length === 2 );

  if( basePath )
  basePath = filter.pathLocalize( basePath );
  filePath = filter.filePathArrayNonBoolGet( filePath, 1 ).filter( ( e ) => e !== null );

  let basePath2 = Object.create( null );

  if( basePath )
  {
    for( let s = 0 ; s < filePath.length ; s++ )
    {
      let thisFilePath = filePath[ s ];
      if( path.isRelative( basePath ) )
      basePath2[ thisFilePath ] = path.detrail( path.join( path.fromGlob( thisFilePath ), basePath ) );
      else
      basePath2[ thisFilePath ] = basePath;
    }
  }
  else
  {
    for( let s = 0 ; s < filePath.length ; s++ )
    {
      let thisFilePath = filePath[ s ];
      basePath2[ thisFilePath ] = path.fromGlob( thisFilePath );
    }
  }

  if( !basePath || _.mapKeys( basePath2 ).length )
  return basePath2;
  else
  return basePath;
}

//

function basePathMapNormalize( basePathMap )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let basePathMap2 = Object.create( null );
  basePathMap = basePathMap || filter.basePath;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  for( let filePath in basePathMap )
  {
    let basePath = basePathMap[ filePath ];

    _.assert( _.strIs( basePath ) );
    _.assert( _.strIs( filePath ) );
    _.assert( !path.isGlob( basePath ) );

    filePath = filter.pathLocalize( filePath );
    basePath = filter.pathLocalize( basePath );
    basePathMap2[ filePath ] = basePath;
  }

  return basePathMap2;
}

//

function basePathNormalize( basePath, filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  basePath = basePath || filter.basePath;
  filePath = filePath || filter.filePath;

  _.assert( !_.arrayIs( basePath ) );
  _.assert( arguments.length === 0 || arguments.length === 2 );

  if( basePath === null || _.strIs( basePath ) )
  {
    basePath = filter.basePathFrom( basePath, filePath );
  }
  else if( _.mapIs( basePath ) )
  {
    basePath = filter.basePathMapNormalize( basePath );
  }
  else _.assert( 0 );

  _.assert( _.mapIs( basePath ) || basePath === null || filter.filePathArrayNonBoolGet( filePath, 1 ).filter( ( e ) => e !== null ).length === 0 );
  // _.assert( _.mapIs( basePath ) || basePath === null || _.mapKeys( filePath ).length === 0 );

  return basePath;
}

//

function basePathSimplify()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( !filter.basePath || _.strIs( filter.basePath ) )
  return;

  let basePath = _.arrayAppendArrayOnce( [], _.mapVals( filter.basePath ) );

  if( basePath.length !== 1 )
  return;

  filter.basePath = basePath[ 0 ];

}

//

function basePathDotUnwrap()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  if( !filter.basePath )
  return;

  if( _.strIs( filter.basePath ) && filter.basePath !== '.' )
  return;

  if( _.mapIs( filter.basePath ) && !_.mapsAreIdentical( filter.basePath, { '.' : '.' } ) )
  return;

  debugger;
  let filePath = filter.filePathArrayNonBoolGet(); // xxx : boolFallingBack?

  let basePath = _.mapIs( filter.basePath ) ? filter.basePath : Object.create( null );
  delete basePath[ '.' ];
  filter.basePath = basePath;

  filePath.forEach( ( fp ) => basePath[ fp ] = fp );

}

//

function basePathEach( onEach )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( arguments.length === 1 );

  let basePath = filter.basePath;
  if( !_.mapIs( basePath ) )
  {
    // basePath = filter.basePathFrom( basePath, filter.filePath ); // yyy
    basePath = filter.basePathFrom( basePath, filter.prefixPath || filter.filePath );
  }

  if( _.strIs( basePath ) )
  {
    let r = onEach( null, basePath );
    _.assert( r === undefined || _.strIs( r ) );
    if( r )
    basePath = r;
  }
  else if( _.mapIs( basePath ) )
  for( let b in basePath )
  {
    let r = onEach( b, basePath[ b ] );
    _.assert( r === undefined || _.mapIs( r ) );
    if( r )
    {
      delete basePath[ b ];
      _.mapExtend( basePath, r );
    }
  }
  else _.assert( 0 );

  filter.basePath = basePath;

}

// --
// file path
// --

function filePathCopy( o )
{

  _.assertRoutineOptions( filePathCopy, arguments );

  /* get */

  if( o.value === null )
  if( _.instanceIs( o.srcInstance ) )
  {
    o.value = o.srcInstance[ filePathSymbol ];
  }
  else if( o.srcInstance )
  {
    debugger;
    o.value = o.srcInstance.filePath;
  }

  if( o.srcInstance && o.dstInstance )
  {
    o.value = _.entityShallowClone( o.value );
  }

  /* set */

  if( _.instanceIs( o.dstInstance ) )
  {
    _.assert( o.value === null || _.strIs( o.value ) || _.arrayIs( o.value ) || _.mapIs( o.value ) );

    if( o.dstInstance./*srcFilter*/src )
    {
      let fileProvider = o.dstInstance.hubFileProvider || o.dstInstance.effectiveFileProvider || o.dstInstance.defaultFileProvider;
      let path = fileProvider.path;
      if( _.strIs( o.value ) || _.arrayIs( o.value ) || _.boolLike( o.value ) )
      o.value = path.mapsPair( o.value, null );
      _.assert( o.value === null || _.mapIs( o.value ), () => 'Paired filter could have only path map as file path, not ' + _.strType( o.value ) );
      if( o.value !== o.dstInstance./*srcFilter*/src.filePath )
      o.dstInstance./*srcFilter*/src[ filePathSymbol ] = o.value;
    }
    else if( o.dstInstance./*dstFilter*/dst )
    {
      let fileProvider = o.dstInstance.hubFileProvider || o.dstInstance.effectiveFileProvider || o.dstInstance.defaultFileProvider;
      let path = fileProvider.path;
      if( _.strIs( o.value ) || _.arrayIs( o.value ) || _.boolLike( o.value ) )
      o.value = path.mapsPair( null, o.value );
      _.assert( o.value === null || _.mapIs( o.value ), () => 'Paired filter could have only path map as file path, not ' + _.strType( o.value ) );
      if( o.value !== o.dstInstance./*dstFilter*/dst.filePath )
      o.dstInstance./*dstFilter*/dst[ filePathSymbol ] = o.value;
    }

    o.dstInstance[ filePathSymbol ] = o.value;
  }
  else if( o.dstInstance )
  {
    debugger;
    o.dstInstance.filePath = o.value;
  }

  /* */

  return o;
}

filePathCopy.defaults =
{
  dstInstance : null,
  srcInstance : null,
  instanceKey : null,
  srcContainer : null,
  dstContainer : null,
  containerKey : null,
  value : null,
}

//

function filePathGet()
{
  let filter = this;
  return filter[ filePathSymbol ];
}

//

function filePathSet( src )
{
  let filter = this;

  _.assert( src === null || _.strIs( src ) || _.arrayIs( src ) || _.mapIs( src ) );

  if( filter./*srcFilter*/src )
  {
    let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
    let path = fileProvider.path;
    if( _.strIs( src ) || _.arrayIs( src ) || _.boolLike( src ) )
    src = path.mapsPair( src, null );
    _.assert( src === null || _.mapIs( src ), () => 'Paired filter could have only path map as file path, not ' + _.strType( src ) );
    if( src !== filter./*srcFilter*/src.filePath )
    filter./*srcFilter*/src[ filePathSymbol ] = src;
  }
  else if( filter./*dstFilter*/dst )
  {
    let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
    let path = fileProvider.path;
    if( _.strIs( src ) || _.arrayIs( src ) || _.boolLike( src ) )
    src = path.mapsPair( null, src );
    _.assert( src === null || _.mapIs( src ), () => 'Paired filter could have only path map as file path, not ' + _.strType( src ) );
    if( src !== filter./*dstFilter*/dst.filePath )
    filter./*dstFilter*/dst[ filePathSymbol ] = src;
  }

  filter[ filePathSymbol ] = src;

  return src;
}

//

function filePathNormalize( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );

  if( !_.mapIs( filePath ) )
  filePath = path.mapExtend( null, filePath );

  if( filter./*srcFilter*/src )
  {

    for( let srcPath in filePath )
    {
      let dstPath = filePath[ srcPath ];

      if( !_.strIs( dstPath ) )
      continue;

      let dstPath2 = path.normalize( dstPath );
      dstPath2 = filter.pathLocalize( dstPath2 );
      if( dstPath === dstPath2 )
      continue;
      _.assert( _.strIs( dstPath2 ) );
      filePath[ srcPath ] = dstPath2;
    }

  }
  else
  {

    for( let srcPath in filePath )
    {
      let srcPath2 = path.normalize( srcPath );
      srcPath2 = filter.pathLocalize( srcPath2 );
      if( srcPath === srcPath2 )
      continue;
      _.assert( _.strIs( srcPath2 ) );
      filePath[ srcPath2 ] = filePath[ srcPath ];
      delete filePath[ srcPath ];
    }

  }

  _.assert( _.mapIs( filePath ) );

  return filePath;
}

//

function filePathPrependBasePath( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( _.mapIs( basePath ) );

  if( filter./*srcFilter*/src )
  {
    debugger;

    for( let srcPath in filePath )
    {

      let dstPath = filePath[ srcPath ];
      let b = basePath[ dstPath ];

      if( path.isAbsolute( dstPath ) )
      continue;
      if( !b )
      continue;
      if( !path.isAbsolute( b ) )
      continue;

      _.assert( path.isAbsolute( b ) );

      let joinedPath = path.join( b, dstPath );
      if( joinedPath !== dstPath )
      {
        delete basePath[ dstPath ];
        basePath[ joinedPath ] = b;
        delete filePath[ srcPath ];
        path.mapExtend( filePath, srcPath, joinedPath );
      }

    }

    debugger;
  }
  // {
  //
  //   debugger;
  //   for( let srcPath in filePath )
  //   {
  //
  //     let dstPath = filePath[ srcPath ];
  //     let b = basePath[ dstPath ];
  //     if( !_.strIs( dstPath ) || path.isAbsolute( dstPath ) )
  //     continue;
  //
  //     _.assert( path.isAbsolute( b ) );
  //
  //     let joinedPath = path.join( b, dstPath );
  //     if( joinedPath !== dstPath )
  //     {
  //       delete basePath[ dstPath ];
  //       basePath[ joinedPath ] = b;
  //       filePath[ srcPath ] = joinedPath;
  //     }
  //
  //   }
  //   debugger;
  //
  // }
  else
  {

    for( let srcPath in filePath )
    {

      let dstPath = filePath[ srcPath ];
      let b = basePath[ srcPath ];

      if( path.isAbsolute( srcPath ) )
      continue;
      if( !b )
      continue;
      if( !path.isAbsolute( b ) )
      continue;

      _.assert( path.isAbsolute( b ) );

      let joinedPath = path.join( b, srcPath );
      if( joinedPath !== srcPath )
      {
        delete basePath[ srcPath ];
        basePath[ joinedPath ] = b;
        delete filePath[ srcPath ];
        path.mapExtend( filePath, joinedPath, dstPath );
      }

    }

  }

}

//

function filePathMultiplyRelatives( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( _.mapIs( basePath ) );
  // _.assert( !filter./*srcFilter*/src );

  // if( !filter./*srcFilter*/src )
  // debugger;

  let relativePath = _.mapExtend( null, filePath );

  for( let r in relativePath )
  if( path.isRelative( r ) )
  {
    delete basePath[ r ];
    delete filePath[ r ];
  }
  else
  {
    delete relativePath[ r ];
  }

  let basePath2 = _.mapExtend( null, basePath );

  for( let b in basePath2 )
  {
    let currentBasePath = basePath[ b ];
    let normalizedFilePath = path.fromGlob( b );
    for( let r in relativePath )
    {
      let dstPath = relativePath[ r ];
      let srcPath = path.join( normalizedFilePath, r );
      _.assert( filePath[ srcPath ] === undefined || filePath[ srcPath ] === dstPath );
      filePath[ srcPath ] = dstPath;
      _.assert( basePath[ srcPath ] === undefined || basePath[ srcPath ] === currentBasePath );
      if( !_.boolLike( dstPath ) )
      basePath[ srcPath ] = currentBasePath;
    }
  }

}

//

function filePathAbsolutize()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( _.mapKeys( filter.filePath ).length === 0 )
  return;

  // _.assert( _.mapIs( filter.basePath ) );
  _.assert( _.mapIs( filter.filePath ) );

  let filePath = filter.filePathArrayGet().filter( ( e ) => _.strIs( e ) );

  if( path.s.anyAreRelative( filePath ) )
  {
    if( path.s.anyAreAbsolute( filePath ) )
    filter.filePathMultiplyRelatives( filter.filePath, filter.basePath );
    else
    filter.filePathPrependBasePath( filter.filePath, filter.basePath );
  }

}

//

/*
Easy optimization. No need to enable slower glob searching if glob is "**".
Result of such glob is equivalent to result of recursive searching.
*/

function filePathGlobSimplify( basePath, filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  basePath = basePath || filter.basePath;
  filePath = filePath || filter.filePath;

  _.assert( arguments.length === 0 || arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );

  let dst = filter.filePathDstArrayGet();

  if( _.any( dst, ( e ) => _.boolIs( e ) ) )
  return filePath

  for( let src in filePath )
  {
    if( _.strEnds( src, '/**' ) || src === '**' )
    simplify( src, '**' )
  }

  return filePath;

  /* */

  function simplify( src, what )
  {
    let src2 = path.normalizeCanonical( _.strRemoveEnd( src, what ) );
    if( !path.isGlob( src2 ) )
    {
      _.assert( filePath[ src2 ] === undefined )
      filePath[ src2 ] = filePath[ src ];
      delete filePath[ src ];

      if( _.mapIs( basePath ) )
      {
        _.assert( basePath[ src2 ] === undefined )
        basePath[ src2 ] = basePath[ src ];
        delete basePath[ src ];
      }

    }
  }

}

//

function filePathFromFixes()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  if( !filter.filePath )
  {
    filter.filePath = path.s.join( filter.prefixPath || '.', filter.postfixPath || '.' );
    _.assert( path.s.allAreAbsolute( filter.filePath ), 'Can deduce file path' );
  }

  return filter.filePath;
}

//

function filePathSimplest( filePath )
{
  let filter = this;

  filePath = filePath || filter.filePathArrayNonBoolGet();
  // filePath = filePath || filter.filePathNormalizedGet();

  _.assert( !_.mapIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( _.arrayIs( filePath ) && filePath.length === 1 )
  return filePath[ 0 ];

  if( _.arrayIs( filePath ) && filePath.length === 0 )
  return null;

  return filePath;
}

//
// //
//
// function filePathSimplest()
// {
//   let filter = this;
//
//   let filePath = filter.filePathNormalizedGet();
//
//   _.assert( !_.mapIs( filePath ) );
//
//   if( _.arrayIs( filePath ) && filePath.length === 1 )
//   return filePath[ 0 ];
//
//   if( _.arrayIs( filePath ) && filePath.length === 0 )
//   return null;
//
//   return filePath;
// }

//

function filePathNullizeMaybe( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  let filePath2 = filter.filePathDstArrayGet( filePath );
  if( _.any( filePath2, ( e ) => !_.boolLike( e ) ) )
  return filePath;

  return path.filterInplace( filePath, ( e ) => _.boolLike( e ) && e ? null : e );
}

//

function filePathHasGlob( filePath )
{
  let filter = this;
  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  /*
    should use effectiveFileProvider because of option globbing of file provider
  */

  filePath = filePath || filter.filePath;

  let globFound = true;
  if( _.none( path.s.areGlob( filter.filePath ) ) )
  if( !filter.filePathDstArrayGet().filter( ( e ) => _.boolLike( e ) ).length )
  globFound = false;

  return globFound;
}

//

function filePathDstHasAllBools( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filter.filePathDstArrayGet( filePath );

  if( !filePath.length )
  return true;

  return !filePath.filter( ( e ) => !_.boolLike( e ) ).length;
}

//

function filePathDstHasAnyBools( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filter.filePathDstArrayGet( filePath );

  return !!filePath.filter( ( e ) => _.boolLike( e ) ).length;
}

//

function filePathMapOnlyBools( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( filePath === null || _.strIs( filePath ) || _.arrayIs( filePath ) )
  return {};

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.mapIs( filePath ) );

  let result = Object.create( null );
  for( let src in filePath )
  {
    if( _.boolIs( filePath[ src ] ) )
    result[ src ] = filePath[ src ];
  }

  return result;
}

//

function filePathDstArrayGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter./*srcFilter*/src )
  {
    return path.mapDstFromDst( filePath );
  }
  else
  {
    return path.mapDstFromSrc( filePath );
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathSrcArrayGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter./*srcFilter*/src )
  {
    return path.mapSrcFromDst( filePath );
  }
  else
  {
    return path.mapSrcFromSrc( filePath );
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathArrayGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter./*srcFilter*/src )
  {
    filePath = path.mapDstFromDst( filePath );
  }
  else
  {
    filePath = path.mapSrcFromSrc( filePath );
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathDstArrayNonBoolGet( filePath, boolFallingBack )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  // if( boolFallingBack === undefined )
  // boolFallingBack = true;

  if( boolFallingBack === undefined )
  boolFallingBack = false;

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

  if( filter./*srcFilter*/src )
  {
    filePath = path.mapDstFromDst( filePath );
  }
  else
  {
    filePath = path.mapDstFromSrc( filePath );
  }

  let filePath2 = filePath.filter( ( e ) => !_.boolLike( e ) );
  if( filePath2.length || !boolFallingBack )
  {
    filePath = filePath2;
  }
  else
  {
    filePath = _.filter( filePath, ( e ) =>
    {
      if( !_.boolLike( e ) )
      return e;
      if( e )
      return null;
      return undefined;
    });
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathSrcArrayNonBoolGet( filePath, boolFallingBack )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  // if( boolFallingBack === undefined )
  // boolFallingBack = true;

  if( boolFallingBack === undefined )
  boolFallingBack = false;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

  if( _.mapIs( filePath ) )
  {
    let r = [];
    for( let src in filePath )
    {
      if( _.boolLike( filePath[ src ] ) )
      continue;
      r.push( src );
    }
    if( !r.length && boolFallingBack )
    {
      for( let src in filePath )
      {
        if( !filePath[ src ] )
        continue;
        r.push( src );
      }
    }
    filePath = r;
  }
  else
  {
    if( filter./*srcFilter*/src )
    {
      filePath = path.mapSrcFromDst( filePath );
    }
    else
    {
      filePath = path.mapSrcFromSrc( filePath );
    }
  }

  _.assert( _.arrayIs( filePath ) );
  _.longUnduplicate( filePath );

  return filePath;
}

//

function filePathArrayNonBoolGet( filePath, boolFallingBack )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

  if( filter./*srcFilter*/src )
  {
    return filter.filePathDstArrayNonBoolGet( filePath, boolFallingBack );
  }
  else
  {
    return filter.filePathSrcArrayNonBoolGet( filePath, boolFallingBack );
  }

}

//

function filePathDstArrayBoolGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter./*srcFilter*/src )
  {
    filePath = path.mapDstFromDst( filePath );
  }
  else
  {
    filePath = path.mapDstFromSrc( filePath );
  }

  let filePath2 = _.filter( filePath, ( e ) => _.boolLike( e ) ? !!e : undefined );
  filePath = _.longUnduplicate( null, filePath2 );

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathSrcArrayBoolGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( _.mapIs( filePath ) )
  {
    let r = [];

    for( let src in filePath )
    {
      if( !_.boolLike( filePath[ src ] ) )
      continue;
      r.push( src );
    }

    filePath = r;

  }
  else
  {
    filePath = [];
    // if( filter./*srcFilter*/src )
    // {
    //   filePath = path.mapSrcFromDst( filePath );
    // }
    // else
    // {
    //   filePath = path.mapSrcFromSrc( filePath );
    // }
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathArrayBoolGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter./*srcFilter*/src )
  {
    return filter.filePathDstArrayBoolGet( filePath );
  }
  else
  {
    return filter.filePathSrcArrayBoolGet( filePath );
  }

}

//

function filePathDstNormalizedGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  filePath = filter.filePathDstArrayGet();

  _.assert( _.arrayIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.arrayIs( p ) )
    {
      return _.unrollFrom( p );
    }
    return p;
  });

  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.strIs( p ) )
    return p;

    if( p === null )
    {
      if( !!p )
      return filter.prefixPath || filter.basePathForFilePath( p ) || undefined;
      return;
    }

    if( _.boolLike( p ) )
    return;

    return p;
  });

  filePath = _.arrayAppendArrayOnce( [], filePath );

  if( filter.prefixPath || filter.postfixPath )
  filePath = path.s.join( filter.prefixPath || '.', filePath, filter.postfixPath || '.' );

  return filePath;
}

//

function filePathSrcNormalizedGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  filePath = filter.filePathSrcArrayGet();

  _.assert( _.arrayIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.arrayIs( p ) )
    {
      debugger;
      _.assert( 0, 'not tested' );
      return _.unrollFrom( p );
    }
    return p;
  });

  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.strIs( p ) )
    return p;

    if( p === null )
    {
      if( !!p )
      return filter.prefixPath || undefined;
      return;
    }

    if( _.boolLike( p ) )
    return;

    return p;
  });

  filePath = _.arrayAppendArrayOnce( [], filePath );

  if( filter.prefixPath || filter.postfixPath )
  filePath = path.s.join( filter.prefixPath || '.', filePath, filter.postfixPath || '.' );

  return filePath
}

//

function filePathNormalizedGet( filePath )
{
  let filter = this;
  if( filter./*srcFilter*/src )
  return filter.filePathDstNormalizedGet( filePath );
  else
  return filter.filePathSrcNormalizedGet( filePath );
}

//

function filePathCommon( filePath )
{
  let filter = this;
  if( filter./*srcFilter*/src )
  return filter.filePathDstCommon( filePath );
  else
  return filter.filePathSrcCommon( filePath );
}

//

function filePathDstCommon()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let filePath = filter.filePathDstNormalizedGet();

  return path.common.apply( path, filePath );
}

//

function filePathSrcCommon()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let filePath = filter.filePathSrcNormalizedGet();

  return path.common.apply( path, filePath );
}

// --
// pair
// --

// function pairFor( srcPath, dstPath ) // xxx : remove maybe
// {
//   let /*srcFilter*/src = this;
//   let /*dstFilter*/dst = /*srcFilter*/src./*dstFilter*/dst;
//   let fileProvider = /*srcFilter*/src.hubFileProvider || /*srcFilter*/src.effectiveFileProvider || /*srcFilter*/src.defaultFileProvider;
//   let path = fileProvider.path;
//
//   _.assert( /*dstFilter*/dst instanceof Self );
//   _.assert( /*dstFilter*/dst./*srcFilter*/src === /*srcFilter*/src );
//
//   /*dstFilter*/dst = /*dstFilter*/dst.clone();
//   /*srcFilter*/src = /*srcFilter*/src.clone();
//   /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
//   /*srcFilter*/src.filePathSelect( srcPath, dstPath );
//
//   return /*srcFilter*/src;
// }

//

function pairedFilterGet()
{
  let filter = this;
  _.assert( arguments.length === 0 );
  if( filter.src )
  return filter.src
  else
  return filter.dst;
}

//

function pairWithDst( /*dstFilter*/dst )
{
  let filter = this;

  _.assert( /*dstFilter*/dst instanceof Self );
  _.assert( filter instanceof Self );
  _.assert( filter./*dstFilter*/dst === null || filter./*dstFilter*/dst === /*dstFilter*/dst );
  _.assert( /*dstFilter*/dst./*srcFilter*/src === null || /*dstFilter*/dst./*srcFilter*/src === filter );

  filter./*dstFilter*/dst = /*dstFilter*/dst;
  /*dstFilter*/dst./*srcFilter*/src = filter;

  return filter;
}

//

function pairRefineLight()
{
  let /*srcFilter*/src = this;
  let /*dstFilter*/dst = /*srcFilter*/src./*dstFilter*/dst;
  let fileProvider = /*srcFilter*/src.hubFileProvider || /*srcFilter*/src.effectiveFileProvider || /*srcFilter*/src.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( /*dstFilter*/dst instanceof Self );
  _.assert( /*srcFilter*/src instanceof Self );
  _.assert( /*dstFilter*/dst./*srcFilter*/src === /*srcFilter*/src );
  _.assert( /*srcFilter*/src./*dstFilter*/dst === /*dstFilter*/dst );
  _.assert( arguments.length === 0 );

  /*srcFilter*/src.filePath = /*dstFilter*/dst.filePath = path.mapsPair( /*dstFilter*/dst.filePath, /*srcFilter*/src.filePath );

  _.assert( /*srcFilter*/src.filePath !== undefined );
  _.assert( _.mapIs( /*srcFilter*/src.filePath ) || /*srcFilter*/src.filePath === null );
  _.assert( /*srcFilter*/src.filePath === /*dstFilter*/dst.filePath );

}

//

function isPaired( aFilter )
{
  let /*srcFilter*/src = this;
  let /*dstFilter*/dst = /*srcFilter*/src./*dstFilter*/dst;

  aFilter = aFilter || /*srcFilter*/src./*dstFilter*/dst || /*srcFilter*/src./*srcFilter*/src;

  if( /*srcFilter*/src./*srcFilter*/src )
  {
    /*dstFilter*/dst = /*srcFilter*/src;
    /*srcFilter*/src = /*srcFilter*/src./*srcFilter*/src;
    if( aFilter !== /*srcFilter*/src )
    return false;
  }
  else
  {
    if( aFilter !== /*dstFilter*/dst )
    return false;
  }

  _.assert( !!/*dstFilter*/dst );
  _.assert( /*srcFilter*/src./*dstFilter*/dst === /*dstFilter*/dst );
  _.assert( /*dstFilter*/dst./*srcFilter*/src === /*srcFilter*/src );
  _.assert( /*srcFilter*/src./*srcFilter*/src === null );
  _.assert( /*dstFilter*/dst./*dstFilter*/dst === null );

  return true;
}

// //
//
// function pairRefine()
// {
//   let /*srcFilter*/src = this;
//   let /*dstFilter*/dst = /*srcFilter*/src./*dstFilter*/dst;
//   let fileProvider = /*srcFilter*/src.hubFileProvider || /*srcFilter*/src.effectiveFileProvider || /*srcFilter*/src.defaultFileProvider;
//   let path = fileProvider.path;
//   let lackOfDst = false;
//
//   _.assert( arguments.length === 0 );
//
//   if( _.mapIs( /*srcFilter*/src.filePath ) && _.entityIdentical( /*srcFilter*/src.filePath, /*dstFilter*/dst.filePath ) )
//   {
//     /*dstFilter*/dst.filePath = /*srcFilter*/src.filePath;
//   }
//
//   /* deduce src path if required */
//
//   if( !/*srcFilter*/src.filePath )
//   {
//     if( _.mapIs( /*dstFilter*/dst.filePath ) )
//     /*srcFilter*/src.filePath = /*dstFilter*/dst.filePath;
//     else if( !/*srcFilter*/src.filePath && ( /*srcFilter*/src.prefixPath || /*srcFilter*/src.postfixPath ) )
//     /*srcFilter*/src.filePath = path.join( /*srcFilter*/src.prefixPath || '.', /*srcFilter*/src.postfixPath || '.' );
//     else
//     {}
//   }
//
//   /* deduce dst path if required */
//
//   let dstRequired = _.mapIs( /*srcFilter*/src.filePath ) && _.any( /*srcFilter*/src.filePath, ( e, k ) => e === null );
//   if( dstRequired || _.arrayIs( /*srcFilter*/src.filePath ) || _.strIs( /*srcFilter*/src.filePath ) )
//   {
//
//     if( _.entityIdentical( /*dstFilter*/dst.basePath, { '.' : '.' } ) )
//     /*dstFilter*/dst.basePath = '.';
//
//     if( _.arrayIs( /*dstFilter*/dst.filePath ) && /*dstFilter*/dst.filePath.length === 1 )
//     /*dstFilter*/dst.filePath = /*dstFilter*/dst.filePath[ 0 ];
//     if( /*dstFilter*/dst.filePath === '.' )
//     {
//       _.assert( /*dstFilter*/dst.basePath === null || /*dstFilter*/dst.basePath === '.' || _.entityIdentical( /*dstFilter*/dst.basePath, { '.' : '.' } ) );
//       /*dstFilter*/dst.filePath = null;
//     }
//
//     if( !/*dstFilter*/dst.filePath )
//     {
//       if( /*dstFilter*/dst.prefixPath || /*dstFilter*/dst.postfixPath )
//       /*dstFilter*/dst.filePath = path.join( /*dstFilter*/dst.prefixPath || '.', /*dstFilter*/dst.postfixPath || '.' );
//     }
//     else
//     {
//       let dstPath1 = path.mapDstFromSrc( /*srcFilter*/src.filePath ).filter( ( e, k ) => _.strIs( e ) );
//       let dstPath2 = path.mapDstFromDst( /*dstFilter*/dst.filePath ).filter( ( e, k ) => _.strIs( e ) );
//       _.assert( dstPath1.length === 0 || dstPath2.length === 0 || _.arraySetIdentical( dstPath1, dstPath2 ) );
//     }
//
//     /*srcFilter*/src._formAssociations();
//     if( /*srcFilter*/src.filePath )
//     /*srcFilter*/src.prefixesApply();
//
//     /*dstFilter*/dst._formAssociations();
//     if( /*dstFilter*/dst.filePath )
//     /*dstFilter*/dst.prefixesApply()
//
//     if( /*dstFilter*/dst.filePath )
//     {
//       srcVerify();
//       let dstPath = /*dstFilter*/dst.filePathDstNormalizedGet();
//       if( _.arrayIs( dstPath ) && dstPath.length === 1 )
//       dstPath = dstPath[ 0 ];
//       if( _.arrayIs( dstPath ) && dstPath.length === 0 )
//       {
//         dstPath = null;
//         lackOfDst = true;
//       }
//       _.assert( _.strIs( dstPath ) || _.arrayIs( dstPath ) || _.boolLike( dstPath ) || dstPath === null );
//       /*srcFilter*/src.filePath = /*dstFilter*/dst.filePath = path.mapExtend( null, /*srcFilter*/src.filePath, dstPath );
//     }
//     else
//     {
//       lackOfDst = true;
//       if( _.strIs( /*srcFilter*/src.filePath ) )
//       /*srcFilter*/src.filePath = { [ /*srcFilter*/src.filePath ] : null }
//     }
//
//   }
//
//   /* assign destination path */
//
//   _.assert( /*srcFilter*/src.filePath === null || _.mapIs( /*srcFilter*/src.filePath ) );
//
//   if( /*dstFilter*/dst.filePath && /*dstFilter*/dst.filePath !== /*srcFilter*/src.filePath )
//   {
//
//     srcVerify();
//     dstVerify();
//
//     if( _.mapIs( /*dstFilter*/dst.filePath ) )
//     {
//     }
//     else if( /*srcFilter*/src.filePath && !_.mapIs( /*dstFilter*/dst.filePath ) )
//     {
//       /*dstFilter*/dst.filePath = _.arrayAs( /*dstFilter*/dst.filePath );
//       _.assert( _.strsAreAll( /*dstFilter*/dst.filePath ) );
//       dstVerify();
//     }
//
//   }
//
//   if( /*dstFilter*/dst.filePath !== /*srcFilter*/src.filePath && /*srcFilter*/src.filePath )
//   /*dstFilter*/dst.filePath = /*srcFilter*/src.filePath;
//
//   /* validate */
//
//   let dstFilePath = /*srcFilter*/src.filePathSrcArrayGet();
//
//   _.assert( /*srcFilter*/src.filePath === null || /*dstFilter*/dst.filePath === null || /*srcFilter*/src.filePath === /*dstFilter*/dst.filePath )
//   _.assert( /*srcFilter*/src.filePath === null || _.all( /*srcFilter*/src.filePath, ( e, k ) => path.is( k ) ) );
//   _.assert( /*srcFilter*/src.filePath === null || _.all( dstFilePath, ( e, k ) => _.boolLike( e ) || path.s.allAre( e ) ) );
//
//   /* */
//
//   function srcVerify()
//   {
//     if( /*dstFilter*/dst.filePath && /*srcFilter*/src.filePath && Config.debug )
//     {
//       let srcPath1 = path.mapSrcFromSrc( /*srcFilter*/src.filePath );
//       let srcPath2 = path.mapSrcFromDst( /*dstFilter*/dst.filePath );
//       _.assert( srcPath1.length === 0 || srcPath2.length === 0 || _.arraySetIdentical( srcPath1, srcPath2 ), () => 'Source paths are inconsistent ' + _.toStr( srcPath1 ) + ' ' + _.toStr( srcPath2 ) );
//     }
//   }
//
//   /* */
//
//   function dstVerify()
//   {
//     if( /*dstFilter*/dst.filePath && /*srcFilter*/src.filePath && Config.debug )
//     {
//       let dstPath1 = path.mapDstFromSrc( /*srcFilter*/src.filePath );
//       let dstPath2 = path.mapDstFromDst( /*dstFilter*/dst.filePath );
//       _.arrayRemove( dstPath2, '.' );
//       _.assert( dstPath1.length === 0 || dstPath2.length === 0 || _.arraySetIdentical( dstPath1, dstPath2 ), () => 'Destination paths are inconsistent ' + _.toStr( dstPath1 ) + ' ' + _.toStr( dstPath2 ) );
//     }
//   }
//
// }

// --
// etc
// --

function providersNormalize()
{
  let filter = this;

  if( !filter.effectiveFileProvider )
  filter.effectiveFileProvider = filter.defaultFileProvider;
  if( !filter.hubFileProvider )
  filter.hubFileProvider = filter.effectiveFileProvider;
  if( filter.hubFileProvider.hub )
  filter.hubFileProvider = filter.hubFileProvider.hub;

}

//

function providerForPath( filePath )
{
  let filter = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.effectiveFileProvider )
  return filter.effectiveFileProvider;

  if( !filePath )
  filePath = filter.filePath;

  if( !filePath )
  filePath = filter.filePath;

  if( !filePath )
  filePath = filter.basePath

  _.assert( _.strIs( filePath ), 'Expects string' );

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;

  filter.effectiveFileProvider = fileProvider.providerForPath( filePath );

  return filter.effectiveFileProvider;
}

// --
// iterative
// --

function allPaths( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let thePath;

  if( _.routineIs( o ) )
  o = { onEach : o }
  o = _.routineOptions( allPaths, o );
  _.assert( arguments.length === 1 );

  if( o.fixes )
  if( !each( filter.prefixPath, 'prefixPath' ) )
  return false;

  if( o.fixes )
  if( !each( filter.postfix, 'postfix' ) )
  return false;

  if( o.basePath )
  if( !each( filter.basePath, 'basePath' ) )
  return false;

  if( o.filePath )
  if( !each( filter.filePath, 'filePath' ) )
  return false;

  return true;

  /* - */

  function each( thePath, fieldName )
  {
    // let it = Object.create( null );
    // it.fieldName = fieldName;
    // it.side = null;
    // it.value = thePath;
    // let result = path.pathMapIterate({ iteration : it, filePath : thePath, onEach : o.onEach });

    // debugger;
    let result = o.inplace ? path.filterInplace( thePath, o.onEach ) : path.filter( thePath, o.onEach );
    // debugger;

    // filter[ fieldName ] = it.value;
    if( o.inplace )
    filter[ fieldName ] = result;

    // return it.result;
    return result;
  }

}

allPaths.defaults =
{
  onEach : null,
  fixes : 1,
  basePath : 1,
  filePath : 1,
  inplace : 1,
}

//

function isRelative( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let thePath;

  o = _.routineOptions( isRelative, arguments );

  _.assert( 0, 'not tested' );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;
  o2.inplace = 0;

  return filter.allPaths( o2 );

  /* - */

  function onEach( element, it )
  {
    debugger;
    _.assert( 0, 'not tested' );
    if( it.value === null )
    return;
    if( path.isRelative( it.value ) )
    return;
    // it.value = false; // yyy
    return it.value;
  }

}

isRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // filePath : 1,
  filePath : 1,
}

//

function sureRelative( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  o = _.routineOptions( sureRelative, arguments );

  _.assert( 0, 'not tested' );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;
  o2.inplace = 0;

  return filter.allPaths( o2 );

  /* - */

  function onEach( element, it )
  {
    _.sure
    (
      it.value === null || path.isRelative( it.value ),
      () => 'Filter should have relative ' + it.fieldName + ', but has  ' + _.toStr( it.value )
    );
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // filePath : 1,
  filePath : 1,
}

//

function sureRelativeOrGlobal( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  o = _.routineOptions( sureRelative, arguments );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;
  o2.inplace = 0;

  let result = filter.allPaths( o2 );

  return result;

  /* - */

  function onEach( element, it )
  {
    _.sure
    (
      it.value === null || _.boolLike( it.value ) || path.s.allAreRelative( it.value ) || path.s.allAreGlobal( it.value ),
      () => 'Filter should have relative ' + it.fieldName + ', but has ' + _.toStr( it.value )
    );
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  filePath : 1,
}

//

function sureBasePath( basePath, filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  basePath = basePath || filter.basePath;
  filePath = filter.filePathArrayNonBoolGet( filePath || filter.filePath, 1 );
  filePath = filePath.filter( ( e ) => _.strIs( e ) );

  _.assert( arguments.length === 0 || arguments.length === 2 );
  _.assert( !_.arrayIs( basePath ) );

  if( !basePath || _.strIs( basePath ) )
  return;

  let diff = _.arraySetDiff( path.s.fromGlob( _.mapKeys( basePath ) ), path.s.fromGlob( filePath ) );
  _.sure( diff.length === 0, () => 'Some file paths do not have base paths or opposite : ' + _.strQuote( diff ) );

  for( let g in basePath )
  {
    _.sure( !path.isGlob( basePath[ g ] ) );
  }

}

//

function assertBasePath( basePath, filePath )
{
  let filter = this;

  if( !Config.debug )
  return;

  _.assert( arguments.length === 0 || arguments.length === 2 );

  return filter.sureBasePath( basePath, filePath );
}

function filteringClear()
{
  let filter = this;

  filter.maskAll = null;
  filter.maskTerminal = null;
  filter.maskDirectory = null;
  filter.maskTransientAll = null;
  filter.maskTransientTerminal = null;
  filter.maskTransientDirectory = null;

  filter.hasExtension = null;
  filter.begins = null;
  filter.ends = null;

  filter.notOlder = null;
  filter.notNewer = null;
  filter.notOlderAge = null;
  filter.notNewerAge = null;

  return filter;
}

//

function hasMask()
{
  let filter = this;

  if( filter.formedFilterMap )
  return true;

  let hasMask = false;

  hasMask = hasMask || ( filter.maskAll && !filter.maskAll.isEmpty() );
  hasMask = hasMask || ( filter.maskTerminal && !filter.maskTerminal.isEmpty() );
  hasMask = hasMask || ( filter.maskDirectory && !filter.maskDirectory.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientAll && !filter.maskTransientAll.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientTerminal && !filter.maskTransientTerminal.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientDirectory && !filter.maskTransientDirectory.isEmpty() );

  hasMask = hasMask || !!filter.hasExtension;
  hasMask = hasMask || !!filter.begins;
  hasMask = hasMask || !!filter.ends;

  return hasMask;
}

//

function hasFiltering()
{
  let filter = this;

  if( filter.hasMask() )
  return true;

  if( filter.notOlder !== null )
  return true;
  if( filter.notNewer !== null )
  return true;
  if( filter.notOlderAge !== null )
  return true;
  if( filter.notNewerAge !== null )
  return true;

  return false;
}

//

function hasAnyPath()
{
  let filter = this;

  _.assert( arguments.length === 0 );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.strsAreAll( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) );
  _.assert( filter.filePath === null || _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ) );

  if( _.strIs( filter.basePath ) || _.mapIsPopulated( filter.basePath ) )
  return true;

  if( _.any( filter.prefixPath, ( e ) => _.strIs( e ) ) )
  return true;

  if( _.any( filter.postfixPath, ( e ) => _.strIs( e ) ) )
  return true;

  // let filePath = filter.filePathArrayGet();
  let filePath = filter.filePathArrayNonBoolGet();

  if( filePath.length === 1 )
  if( filePath[ 0 ] === '.' || filePath[ 0 ] === '' || filePath[ 0 ] === null )
  {
    /*
    exception for dst filter
    actually, exception for src filter
    */
    if( filePath[ 0 ] === '.' && filter./*srcFilter*/src )
    return true;
    return false;
  }

  if( filePath.length )
  return true;

  // if( _.any( filePath, ( e ) => _.strIs( e ) ) )
  // return true;

  return false;
}

//

function hasData()
{
  let filter = this;

  if( filter.hasAnyPath() )
  return true;

  if( filter.hasFiltering() )
  return true;

  return false;
}

// --
// exporter
// --

function moveTextualReport()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( filter.isPaired() );

  filter = filter.pairedClone();
  filter._formPaths();
  filter.pairedFilter._formPaths();

  let srcFilter = filter.src ? filter.src : filter;
  let dstFilter = srcFilter.dst;

  let srcPath = srcFilter.filePathSrcCommon();
  let dstPath = dstFilter.filePathDstCommon();
  let result = path.moveTextualReport( dstPath, srcPath );

  return result;
}

//

function compactField( it )
{
  let filter = this;

  if( it.dst === null )
  return;

  if( it.dst && it.dst instanceof _.RegexpObject )
  if( !it.dst.hasData() )
  return;

  if( _.objectIs( it.dst ) && _.mapKeys( it.dst ).length === 0 )
  return;

  return it.dst;
}

//

function toStr()
{
  let filter = this;
  let result = '';

  result += 'Filter';

  for( let m in filter.MaskNames )
  {
    let maskName = filter.MaskNames[ m ];
    if( filter[ maskName ] !== null )
    {
      if( !filter[ maskName ].isEmpty )
      result += '\n' + '  ' + maskName + ' : ' + true;
    }
  }

  let FieldNames =
  [
    'prefixPath', 'postfixPath',
    'filePath',
    'basePath',
    'hasExtension', 'begins', 'ends',
    'notOlder', 'notNewer', 'notOlderAge', 'notNewerAge',
  ];

  for( let f in FieldNames )
  {
    let fieldName = FieldNames[ f ];
    if( filter[ fieldName ] !== null )
    result += '\n' + '  ' + fieldName + ' : ' + _.toStr( filter[ fieldName ] );
  }

  return result;
}

// --
// applier
// --

function _applyToRecordNothing( record )
{
  let filter = this;
  return record.isActual;
}

//

function _applyToRecordMasks( record )
{
  let filter = this;
  let relative = record.relative;
  let f = record.factory;
  let path = record.path;
  filter = filter.formedFilterMap ? filter.formedFilterMap[ f.stemPath ] : filter;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!filter, 'Cant resolve filter map for stem path', () => _.strQuote( f.stemPath ) );
  _.assert( !!f.formed, 'Record factor was not formed!' );

  /* */

  if( record.isDir )
  {

    if( record.isTransient && filter.maskTransientAll )
    record[ isTransientSymbol ] = filter.maskTransientAll.test( relative );
    if( record.isTransient && filter.maskTransientDirectory )
    record[ isTransientSymbol ] = filter.maskTransientDirectory.test( relative );

    if( record.isActual && filter.maskAll )
    record[ isActualSymbol ] = filter.maskAll.test( relative );
    if( record.isActual && filter.maskDirectory )
    record[ isActualSymbol ] = filter.maskDirectory.test( relative );

  }
  else
  {

    if( record.isActual && filter.maskAll )
    record[ isActualSymbol ] = filter.maskAll.test( relative );
    if( record.isActual && filter.maskTerminal )
    record[ isActualSymbol ] = filter.maskTerminal.test( relative );

    if( record.isTransient && filter.maskTransientAll )
    record[ isTransientSymbol ] = filter.maskTransientAll.test( relative );
    if( record.isTransient && filter.maskTransientTerminal )
    record[ isTransientSymbol ] = filter.maskTransientTerminal.test( relative );

  }

  /* */

  return record.isActual;
}

//

function _applyToRecordTime( record )
{
  let filter = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( record.isActual === false )
  return record.isActual;

  if( !record.isDir )
  {
    let time;
    if( record.isActual === true )
    {
      time = record.stat.mtime;
      if( record.stat.birthtime > record.stat.mtime )
      time = record.stat.birthtime;
    }

    if( record.isActual === true )
    if( filter.notOlder !== null )
    {
      record[ isActualSymbol ] = time >= filter.notOlder;
    }

    if( record.isActual === true )
    if( filter.notNewer !== null )
    {
      record[ isActualSymbol ] = time <= filter.notNewer;
    }

    if( record.isActual === true )
    if( filter.notOlderAge !== null )
    {
      record[ isActualSymbol ] = _.timeNow() - filter.notOlderAge - time <= 0;
    }

    if( record.isActual === true )
    if( filter.notNewerAge !== null )
    {
      record[ isActualSymbol ] = _.timeNow() - filter.notNewerAge - time >= 0;
    }
  }

  return record.isActual;
}

//

function _applyToRecordFull( record )
{
  let filter = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( record.isActual === false )
  return record.isActual;

  filter._applyToRecordMasks( record );
  filter._applyToRecordTime( record );

  return record.isActual;
}

// --
// relations
// --

/**
 * @typedef {Object} Fields
 * @property {String} filePath
 * @property {String} basePath
 * @property {String} prefixPath
 * @property {String} postfixPath
 *
 * @property {String} hasExtension
 * @property {String} begins
 * @property {String} ends
 *
 * @property {String|Array|RegExp} maskTransientAll
 * @property {String|Array|RegExp} maskTransientTerminal,
 * @property {String|Array|RegExp} maskTransientDirectory
 * @property {String|Array|RegExp} maskAll
 * @property {String|Array|RegExp} maskTerminal
 * @property {String|Array|RegExp} maskDirectory
 *
 * @property {Date} notOlder
 * @property {Date} notNewer
 * @property {Date} notOlderAge
 * @property {Date} notNewerAge
 * @memberof module:Tools/mid/Files.wFileRecordFilter
*/

let isTransientSymbol = Symbol.for( 'isTransient' );
let isActualSymbol = Symbol.for( 'isActual' );
let filePathSymbol = Symbol.for( 'filePath' );

let MaskNames =
[
  'maskAll',
  'maskTerminal',
  'maskDirectory',
  'maskTransientAll',
  'maskTransientTerminal',
  'maskTransientDirectory',
]

let Composes =
{

  filePath : null,
  basePath : null,
  prefixPath : null,
  postfixPath : null,

  hasExtension : null,
  begins : null,
  ends : null,

  maskTransientAll : null,
  maskTransientTerminal : null,
  maskTransientDirectory : null,
  maskAll : null,
  maskTerminal : null,
  maskDirectory : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

}

let Aggregates =
{

}

let Associates =
{
  effectiveFileProvider : null,
  defaultFileProvider : null,
  hubFileProvider : null,
}

let Restricts =
{

  formedFilePath : null,
  formedBasePath : null,
  formedFilterMap : null,

  applyTo : null,
  formed : 0,

  /*srcFilter*/src : null,
  /*dstFilter*/dst : null,

}

let Medials =
{

  // /*srcFilter*/src : null,
  // /*dstFilter*/dst : null,

}

let Statics =
{
  TollerantFrom : TollerantFrom,
  And : And,
  MaskNames : MaskNames,
}

let Globals =
{
}

let Forbids =
{

  options : 'options',
  glob : 'glob',
  recipe : 'recipe',
  globOut : 'globOut',
  inPrefixPath : 'inPrefixPath',
  inPostfixPath : 'inPostfixPath',
  fixedFilePath : 'fixedFilePath',
  fileProvider : 'fileProvider',
  fileProviderEffective : 'fileProviderEffective',
  isEmpty : 'isEmpty',
  globMap : 'globMap',
  _processed : '_processed',
  test : 'test',
  inFilePath : 'inFilePath',
  stemPath : 'stemPath',
  // src : 'src',
  // dst : 'dst',
  globFound : 'globFound',

}

let Accessors =
{

  filePath : {},
  basePaths : { getter : basePathsGet, readOnly : 1 },
  pairedFilter : { getter : pairedFilterGet, readOnly : 1 },

}

// --
// declare
// --

let Extend =
{

  TollerantFrom,
  init,
  copy,
  pairedClone,

  // former

  form,
  _formAssociations,
  _formPre,
  _formPaths,
  _formMasks,
  _formFinal,

  // mutator

  maskExtensionApply,
  maskBeginsApply,
  maskEndsApply,
  filePathGenerate,
  filePathSelect,

  prefixesApply,
  prefixesRelative,
  prefixPathFromFilePath,
  pathLocalize,
  pathsNormalize,
  globalsFromLocals,

  // combiner

  And,
  and,
  _pathsJoin,
  pathsJoin,
  pathsJoinWithoutNull,
  pathsExtend2,
  pathsInherit,
  // pathsExtend,

  // base path

  relativeFor,
  basePathForFilePath,
  basePathFor,
  basePathsGet,
  basePathFrom,
  basePathMapNormalize,
  basePathNormalize,
  basePathSimplify,
  basePathDotUnwrap,
  basePathEach,

  // file path

  filePathCopy,
  // filePathGet,
  // filePathSet,

  filePathNormalize,
  filePathPrependBasePath,
  filePathMultiplyRelatives,
  filePathAbsolutize,
  filePathGlobSimplify,
  filePathFromFixes,
  filePathSimplest,
  filePathNullizeMaybe,
  filePathHasGlob,

  filePathDstHasAllBools,
  filePathDstHasAnyBools,
  filePathMapOnlyBools,

  filePathDstArrayGet,
  filePathSrcArrayGet,
  filePathArrayGet,

  filePathDstArrayNonBoolGet,
  filePathSrcArrayNonBoolGet,
  filePathArrayNonBoolGet,

  filePathDstArrayBoolGet,
  filePathSrcArrayBoolGet,
  filePathArrayBoolGet,

  filePathDstNormalizedGet, /* xxx : remove maybe? */
  filePathSrcNormalizedGet, /* xxx : remove maybe? */
  filePathNormalizedGet, /* xxx : remove maybe? */

  filePathCommon,
  filePathDstCommon,
  filePathSrcCommon,

  // pair

  pairedFilterGet,
  // pairFor,
  pairWithDst,
  pairRefineLight,
  isPaired,

  // etc

  filteringClear,
  providersNormalize,
  providerForPath,

  // iterative

  allPaths,
  isRelative,
  sureRelative,
  sureRelativeOrGlobal,
  sureBasePath,
  assertBasePath,

  hasMask,
  hasFiltering,
  hasAnyPath,
  hasData,

  // exporter

  moveTextualReport,
  compactField,
  toStr,

  // applier

  _applyToRecordNothing,
  _applyToRecordMasks,
  _applyToRecordTime,
  _applyToRecordFull,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Medials,
  Statics,
  Forbids,
  Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

_.mapExtend( _,Globals );

_.Copyable.mixin( Self );

// --
// export
// --

_[ Self.shortName ] = Self;

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
