swat-julia-tracker
%%%%%%%%%%%%%%%%%%

:Version:           1.1.0
:Home page:         https://github.com/sergeii/swat-julia-tracker
:Author:            Sergei Khoroshilov <kh.sergei@gmail.com>
:License:           The MIT License (http://opensource.org/licenses/MIT)

Description
===========
This is an extension to the `Julia <https://github.com/sergeii/swat-julia>`_ SWAT 4 server framework that allows SWAT 4 server owners to capture and transmit round data to web applications.


Dependencies
============
* `Utils <https://github.com/sergeii/swat-utils>`_ *>=1.0.0*
* `HTTP <https://github.com/sergeii/swat-http>`_ *>=1.1.0*
* `Julia <https://github.com/sergeii/swat-julia>`_ *>=2.0.0*

Installation
============

1. Install the required packages listed above in the **Dependencies** section.

2. Download compiled binaries or compile the ``JuliaTracker`` package yourself.

   Every release is accompanied by two tar files, each containing a compiled package for a specific game version::

      swat-julia-tracker.X.Y.Z.swat4.tar.gz
      swat-julia-tracker.X.Y.Z.swat4exp.tar.gz

   with `X.Y.Z` being a package version, followed by a game version identifier::

      swat4 - SWAT 4 1.0-1.1
      swat4exp - SWAT 4: The Stetchkov Syndicate

   Please check the `releases page <https://github.com/sergeii/swat-julia-tracker/releases>`_ to get the latest stable package version appropriate to your server game version.

3. Copy contents of a tar archive into the server's ``System`` directory.

4. Open ``Swat4DedicatedServer.ini``

5. Navigate to the ``[Engine.GameEngine]`` section.

6. Append the following lines to the bottom of the section::

    ServerActors=Utils.Package
    ServerActors=HTTP.Package
    ServerActors=Julia.Core
    ServerActors=JuliaTracker.Extension

7. Enable the mod by placing the following sections at the bottom of ``Swat4DedicatedServer.ini``::

    [Julia.Core]
    Enabled=True

    [JuliaTracker.Extension]
    Enabled=True
    URL=
    Key=

If you have done everything right, contents of your ``Swat4DedicatedServer.ini`` should look similar to::

    [Engine.GameEngine]
    EnableDevTools=False
    InitialMenuClass=SwatGui.SwatMainMenu
    ...
    ServerActors=Utils.Package
    ServerActors=HTTP.Package
    ServerActors=Julia.Core
    ServerActors=JuliaTracker.Extension
    ...

    [Julia.Core]
    Enabled=True

    [JuliaTracker.Extension]
    Enabled=True
    URL=
    Key=

The server's ``System`` directory must also contain the following files::

    Utils.u
    HTTP.u
    Julia.u
    JuliaTracker.u

Compatibility
=============
If you have already installed either of the ``Utils``, ``HTTP`` or ``Julia`` packages before, the ``JuliaTracker`` dependency package order must be still maintained: ``Utils`` > ``HTTP`` > ``Julia`` > ``JuliaTracker``

Suppose you had the following packages installed::

    ServerActors=Utils.Package
    ServerActors=GS1.Listener
    ServerActors=Julia.Core
    ServerActors=JuliaAdmin.Extension

To install the ``JuliaTracker`` package you would want to maintain the dependency package order::

    ServerActors=Utils.Package
    ServerActors=GS1.Listener
    ServerActors=GS2.Listener
    ServerActors=HTTP.Package
    ServerActors=Julia.Core
    ServerActors=JuliaAdmin.Extension
    ServerActors=JuliaTracker.Extension

Properties
==========
The ``[JuliaTracker.Extension]`` section of ``Swat4DedicatedServer.ini`` accepts the following properties:

.. list-table::
   :widths: 15 40 10 10
   :header-rows: 1

   * - Property
     - Descripion
     - Options
     - Default
   * - Enabled
     - Enables the mod
     - True/False
     - False
   * - Key
     - The server unique key required for authentication
     - Variable length combination of the latin, numeric or punctuation characters.
     - 
   * - URL
     - URL address of a web application.
       The property supports multiple URL declarations::

        URL=http://example.org/
        URL=http://example.com/
        URL=http://example.net/

       Each web application defined with a URL line will recieve a copy of the same round data.
     - URL address
     -
   * - Feedback
     - Makes the server to display messages sent by a tracker in admin chat
     - True/False
     - False
   * - Compatible
     - Encodes stream data sent by a server to be compatible with php's $_POST.
       
       php's $_POST automatically expands a querystring like ``foo[bar]=ham&foo[spam]=eggs`` into the following multidimensional structure ``array('foo' => array('ham', 'eggs'))``.
       You should use this option if your application is powered by php.

       With this option set to ``False`` the querystring above would be sent as ``foo.bar=ham&foo.spam=eggs`` using a dot character to delimit keys.
     - True/False
     - False


See Also
========
* `swat4stats.com Data Streaming HOWTO <https://github.com/sergeii/swat-julia-tracker/wiki/swat4stats.com-Data-Streaming-HOWTO>`_